% -------------------------------------------------------------------------
% Dolphin Echolocation Algorithm (DEA) - Version 2
% Incorporating R_init, rho_decay_rate, delta_decay_rate
% -------------------------------------------------------------------------
function [best_overall_positions, best_overall_fitness, fitness_history] = ...
    dolphin_echolocation_algorithm_v2(problem, dea_params)

    % Extract parameters
    N = dea_params.Npop;
    MaxIter = dea_params.Tmax;
    M = dea_params.num_pulses_per_dolphin;
    
    R_init = dea_params.R_init;
    rho_decay_rate = dea_params.rho_decay_rate;
    delta_decay_rate = dea_params.delta_decay_rate;
    initial_global_best_influence = 1.0;

    num_cranes = problem.crane_specs.num_cranes;
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length;
    min_dist_cranes = problem.crane_specs.min_dist_between_cranes;

    % Initialization
    Dolphins = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), N, 1);

    for i = 1:N
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
                    if min_dist_to_others >= min_dist_cranes * 0.5 
                        valid_pos = true;
                    end
                else
                    valid_pos = true;
                end
                attempts = attempts + 1;
                if attempts >= 100, valid_pos = true; end
            end
        end
        Dolphins(i).positions = temp_positions;
        Dolphins(i).fitness = calculate_fitness(Dolphins(i).positions, problem);
    end

    [best_overall_fitness, best_idx] = min([Dolphins.fitness]);
    best_overall_positions = Dolphins(best_idx).positions;

    fitness_history = zeros(MaxIter, 1);
    if ~isempty(best_overall_fitness) && ~isinf(best_overall_fitness)
        fitness_history(1) = best_overall_fitness;
    else
        fitness_history(1) = inf; 
        warning('PSO:Initialisation', 'Initial global best fitness is Inf. Check problem constraints or initialization.');
    end


    % --- Main DEA Loop ---
    for iter = 1:MaxIter
        if mod(iter,10) == 0 || iter == 1
            fprintf('Iteration %d/%d, Best Fitness: %.2f\n', iter, MaxIter, best_overall_fitness);
        end

        current_R = R_init * (rho_decay_rate ^ iter);
        current_global_best_influence_factor = initial_global_best_influence * (delta_decay_rate ^ iter);

        for i = 1:N 
            current_dolphin_positions = Dolphins(i).positions;
            current_dolphin_fitness = Dolphins(i).fitness;

            candidate_pulses = repmat(struct('positions', zeros(num_cranes, 2), 'fitness', inf), M, 1);

            for p = 1:M
                new_pulse_positions = current_dolphin_positions; 
                
                strategy_rand = rand();

                if strategy_rand < 0.6 && ~isinf(best_overall_fitness) 
                    direction_to_global_best = best_overall_positions - current_dolphin_positions;
                    step_global = current_global_best_influence_factor * rand() * direction_to_global_best;
                    new_pulse_positions = current_dolphin_positions + step_global;
                
                elseif strategy_rand < 0.9 
                    temp_positions_local = current_dolphin_positions;
                    num_cranes_to_perturb = randi([1, max(1,floor(num_cranes/3))]); 
                    indices_to_perturb = randperm(num_cranes, num_cranes_to_perturb); 
                    for c_idx = 1:num_cranes_to_perturb
                        crane_to_perturb = indices_to_perturb(c_idx);
                        perturb_x = (rand() - 0.5) * 2 * current_R; 
                        perturb_y = (rand() - 0.5) * 2 * current_R;
                        temp_positions_local(crane_to_perturb, 1) = temp_positions_local(crane_to_perturb, 1) + perturb_x;
                        temp_positions_local(crane_to_perturb, 2) = temp_positions_local(crane_to_perturb, 2) + perturb_y;
                    end
                    new_pulse_positions = temp_positions_local;

                else 
                     temp_positions_jump = current_dolphin_positions;
                     crane_to_jump = randi(num_cranes);
                     temp_positions_jump(crane_to_jump, 1) = rand() * site_width;
                     temp_positions_jump(crane_to_jump, 2) = rand() * site_length;
                     new_pulse_positions = temp_positions_jump;
                end

                new_pulse_positions(:,1) = max(0, min(new_pulse_positions(:,1), site_width));
                new_pulse_positions(:,2) = max(0, min(new_pulse_positions(:,2), site_length));
                
                candidate_pulses(p).positions = new_pulse_positions;
                candidate_pulses(p).fitness = calculate_fitness(candidate_pulses(p).positions, problem);
            end

            [best_pulse_fitness, best_pulse_idx] = min([candidate_pulses.fitness]);
             if ~isempty(best_pulse_idx) && ~isinf(best_pulse_fitness)
                best_pulse_positions = candidate_pulses(best_pulse_idx).positions;

                if best_pulse_fitness < current_dolphin_fitness
                    Dolphins(i).positions = best_pulse_positions;
                    Dolphins(i).fitness = best_pulse_fitness;

                    if best_pulse_fitness < best_overall_fitness
                        best_overall_fitness = best_pulse_fitness;
                        best_overall_positions = best_pulse_positions;
                    end
                end
            end
        end 

        fitness_history(iter) = best_overall_fitness;
    end 
end