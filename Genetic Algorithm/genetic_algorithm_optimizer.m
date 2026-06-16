% -------------------------------------------------------------------------
% GENETIC ALGORITHM (GA) for Crane Layout Optimization
% -------------------------------------------------------------------------
function [best_overall_positions, best_overall_fitness, fitness_history] = ...
    genetic_algorithm_optimizer(problem, ga_params)

    % Extract GA parameters
    Npop = ga_params.Npop;
    MaxGen = ga_params.MaxGen;
    Pc = ga_params.Pc;
    Pm_gene = ga_params.Pm_gene; % Per-gene mutation probability
    elite_count = ga_params.elite_count;
    initial_mutation_strength = ga_params.initial_mutation_strength;
    mutation_decay_rate = ga_params.mutation_decay_rate;

    % Extract problem parameters
    num_cranes = problem.crane_specs.num_cranes;
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length;
    min_dist_cranes = problem.crane_specs.min_dist_between_cranes;

    % --- INITIALIZATION ---
    % Population: Npop individuals, each is a num_cranes x 2 matrix of positions
    Population = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), Npop, 1);

    for i = 1:Npop
        temp_positions = zeros(num_cranes, 2);
        for k_init = 1:num_cranes
            valid_pos = false;
            attempts = 0;
            while ~valid_pos && attempts < 100 
                temp_positions(k_init,1) = rand() * site_width;
                temp_positions(k_init,2) = rand() * site_length;
                if k_init > 1
                    min_dist_to_others = inf;
                    for prev_k = 1:k_init-1
                       dist_sq = (temp_positions(k_init,1) - temp_positions(prev_k,1))^2 + ...
                                 (temp_positions(k_init,2) - temp_positions(prev_k,2))^2;
                       min_dist_to_others = min(min_dist_to_others, sqrt(dist_sq));
                    end
                    if min_dist_to_others >= min_dist_cranes * 0.5 % Relaxed for init
                        valid_pos = true;
                    end
                else
                    valid_pos = true;
                end
                attempts = attempts + 1;
                if attempts >= 100, valid_pos = true; end % Accept if stuck
            end
        end
        Population(i).positions = temp_positions;
        Population(i).fitness = calculate_fitness(Population(i).positions, problem);
    end

    % Find initial best
    [overall_fitness_values, sort_indices] = sort([Population.fitness]);
    best_overall_fitness = overall_fitness_values(1);
    best_overall_positions = Population(sort_indices(1)).positions;
    
    fitness_history = zeros(MaxGen, 1);
    fitness_history(1) = best_overall_fitness;

    % --- MAIN GA LOOP (Generations) ---
    for gen = 1:MaxGen
        if mod(gen,10) == 0 || gen == 1
            fprintf('Generation %d/%d, Best Fitness: %.2f\n', gen, MaxGen, best_overall_fitness);
        end

        current_mutation_strength = initial_mutation_strength * (mutation_decay_rate ^ gen);
        
        % Calculate fitness for all individuals (already done for gen 1)
        if gen > 1
            for i = 1:Npop
                Population(i).fitness = calculate_fitness(Population(i).positions, problem);
            end
        end
        
        % Sort population by fitness
        [fitness_values, sort_indices] = sort([Population.fitness]);
        Population = Population(sort_indices); % Sorted: Population(1) is best

        % Update overall best
        if Population(1).fitness < best_overall_fitness
            best_overall_fitness = Population(1).fitness;
            best_overall_positions = Population(1).positions;
        end
        fitness_history(gen) = best_overall_fitness;

        % Create new population
        NewPopulation = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), Npop, 1);

        % Elitism: Copy best individuals to new population
        for e = 1:elite_count
            NewPopulation(e) = Population(e);
        end

        % Fill the rest of the new population using Selection, Crossover, Mutation
        for count = (elite_count + 1) : 2 : Npop % Create two offspring per loop
            % --- SELECTION (Tournament Selection) ---
            k_tournament = 2; % Tournament size
            
            idx1 = randi(Npop); % Select first candidate for parent 1
            for t = 2:k_tournament
                idx_temp = randi(Npop);
                if Population(idx_temp).fitness < Population(idx1).fitness
                    idx1 = idx_temp;
                end
            end
            Parent1 = Population(idx1);

            idx2 = randi(Npop); % Select first candidate for parent 2
            for t = 2:k_tournament
                idx_temp = randi(Npop);
                if Population(idx_temp).fitness < Population(idx2).fitness
                    idx2 = idx_temp;
                end
            end
            Parent2 = Population(idx2);

            % --- CROSSOVER (Arithmetic Crossover for each crane's position) ---
            Offspring1_pos = Parent1.positions; % Initialize with Parent1
            Offspring2_pos = Parent2.positions; % Initialize with Parent2

            if rand() < Pc
                for k_crane = 1:num_cranes
                    alpha = rand(); % Blend factor
                    Offspring1_pos(k_crane, :) = alpha * Parent1.positions(k_crane, :) + (1-alpha) * Parent2.positions(k_crane, :);
                    Offspring2_pos(k_crane, :) = (1-alpha) * Parent1.positions(k_crane, :) + alpha * Parent2.positions(k_crane, :);
                end
            end
            
            % --- MUTATION (Per gene with decaying strength) ---
            % Mutate Offspring1
            for k_crane = 1:num_cranes
                for coord = 1:2 % x and y
                    if rand() < Pm_gene
                        Offspring1_pos(k_crane, coord) = Offspring1_pos(k_crane, coord) + ...
                            randn() * current_mutation_strength;
                    end
                end
            end
             % Apply boundary constraints
            Offspring1_pos(:,1) = max(0, min(Offspring1_pos(:,1), site_width));
            Offspring1_pos(:,2) = max(0, min(Offspring1_pos(:,2), site_length));
            NewPopulation(count).positions = Offspring1_pos;
            % Fitness will be calculated at start of next generation or upon use

            if (count + 1) <= Npop % If there's space for the second offspring
                % Mutate Offspring2
                for k_crane = 1:num_cranes
                    for coord = 1:2 % x and y
                        if rand() < Pm_gene
                            Offspring2_pos(k_crane, coord) = Offspring2_pos(k_crane, coord) + ...
                                randn() * current_mutation_strength;
                        end
                    end
                end
                % Apply boundary constraints
                Offspring2_pos(:,1) = max(0, min(Offspring2_pos(:,1), site_width));
                Offspring2_pos(:,2) = max(0, min(Offspring2_pos(:,2), site_length));
                NewPopulation(count+1).positions = Offspring2_pos;
            end
        end % End filling new population
        Population = NewPopulation;
    end % End of generations loop
end