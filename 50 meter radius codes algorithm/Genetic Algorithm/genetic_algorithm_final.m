% -------------------------------------------------------------------------
% Genetic Algorithm (GA) - FINAL VERSION (Basic Implementation)
% -------------------------------------------------------------------------
function [best_overall_positions, best_overall_fitness, fitness_history] = ...
    genetic_algorithm_final(problem, ga_params)

    % Extract GA parameters
    Npop = ga_params.Npop;
    MaxGen = ga_params.MaxGen;
    Pc = ga_params.Pc;
    Pm_individual = ga_params.Pm_individual;
    mutation_strength = ga_params.mutation_strength;
    elite_count = ga_params.elite_count;
    k_tournament = 2; % Tournament size for selection

    % Extract problem parameters
    num_cranes = problem.crane_specs.num_cranes;
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length;

    % --- INITIALIZATION ---
    Population = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), Npop, 1);
    for i = 1:Npop
        Population(i).positions = rand(num_cranes, 2) .* [site_width, site_length];
        Population(i).fitness = calculate_fitness(Population(i).positions, problem);
    end

    % Find initial best
    [fitness_values, sort_indices] = sort([Population.fitness]);
    best_overall_fitness = fitness_values(1);
    best_overall_positions = Population(sort_indices(1)).positions;
    
    fitness_history = zeros(MaxGen, 1);
    fitness_history(1) = best_overall_fitness;
    
    fprintf('Running Genetic Algorithm...\n');

    % --- MAIN GA LOOP (Generations) ---
    for gen = 1:MaxGen
        fprintf('Generation %d/%d, Best Fitness: %.2f\n', gen, MaxGen, best_overall_fitness);

        % Sort population by fitness
        [fitness_values, sort_indices] = sort([Population.fitness]);
        Population = Population(sort_indices);

        if Population(1).fitness < best_overall_fitness
            best_overall_fitness = Population(1).fitness;
            best_overall_positions = Population(1).positions;
        end
        fitness_history(gen) = best_overall_fitness;

        % Create new population
        NewPopulation = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), Npop, 1);

        % Elitism
        for e = 1:elite_count
            NewPopulation(e) = Population(e);
        end

        % Fill the rest of the new population
        for i = (elite_count + 1):Npop
            % SELECTION (Tournament)
            p1_idx = tournament_selection(Population, k_tournament);
            p2_idx = tournament_selection(Population, k_tournament);
            Parent1 = Population(p1_idx);
            Parent2 = Population(p2_idx);

            % CROSSOVER (Uniform at Crane Level)
            offspring_pos = Parent1.positions;
            if rand() < Pc
                for k_crane = 1:num_cranes
                    if rand() < 0.5
                        offspring_pos(k_crane, :) = Parent2.positions(k_crane, :);
                    end
                end
            end

            % MUTATION (Gaussian Perturbation on one crane)
            if rand() < Pm_individual
                crane_to_mutate = randi(num_cranes);
                perturbation = randn(1, 2) * mutation_strength;
                offspring_pos(crane_to_mutate, :) = offspring_pos(crane_to_mutate, :) + perturbation;
            end
            
            % Apply boundary constraints
            offspring_pos(:,1) = max(0, min(offspring_pos(:,1), site_width));
            offspring_pos(:,2) = max(0, min(offspring_pos(:,2), site_length));

            NewPopulation(i).positions = offspring_pos;
            NewPopulation(i).fitness = calculate_fitness(NewPopulation(i).positions, problem);
        end
        Population = NewPopulation;
    end
end

% --- Helper function for Tournament Selection ---
function winner_idx = tournament_selection(Population, k)
    N = numel(Population);
    contender_indices = randi(N, 1, k);
    contender_fitness = [Population(contender_indices).fitness];
    [~, best_local_idx] = min(contender_fitness);
    winner_idx = contender_indices(best_local_idx);
end