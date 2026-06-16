% -------------------------------------------------------------------------
% PARTICLE SWARM OPTIMIZATION (PSO) for Crane Layout Optimization
% -------------------------------------------------------------------------
function [gbest_positions, gbest_fitness, fitness_history] = ...
    pso_optimizer(problem, pso_params)

    % Extract PSO parameters
    N = pso_params.num_particles;
    MaxIter = pso_params.MaxIter;
    w_initial = pso_params.w_initial;
    w_final = pso_params.w_final;
    c1 = pso_params.c1;
    c2 = pso_params.c2;
    
    % Extract problem parameters
    num_cranes = problem.crane_specs.num_cranes;
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length; % This is the Y-dimension
    min_dist_cranes = problem.crane_specs.min_dist_between_cranes;

    % Define Velocity Limits
    Vmax_x = pso_params.Vmax_ratio_x * site_width;
    Vmin_x = -Vmax_x;
    Vmax_y = pso_params.Vmax_ratio_y * site_length;
    Vmin_y = -Vmax_y;

    % --- INITIALIZATION ---
    % Particles: Each particle has position, velocity, pbest_position, pbest_fitness
    Particles = repmat(struct(...
        'positions', zeros(num_cranes, 2), ... % Current positions [x, y] for each crane
        'velocity', zeros(num_cranes, 2), ...  % Current velocity [vx, vy] for each crane
        'fitness', inf, ...
        'pbest_positions', zeros(num_cranes, 2), ...
        'pbest_fitness', inf ...
    ), N, 1);

    gbest_positions = zeros(num_cranes, 2);
    gbest_fitness = inf;

    for i = 1:N
        % Initialize positions randomly
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
        Particles(i).positions = temp_positions;
        
        % Initialize velocity (e.g., small random values or zero)
        Particles(i).velocity = (rand(num_cranes, 2) - 0.5) * 0.1; % Small initial velocities

        % Evaluate initial fitness
        Particles(i).fitness = calculate_fitness(Particles(i).positions, problem);
        
        % Initialize pbest
        Particles(i).pbest_positions = Particles(i).positions;
        Particles(i).pbest_fitness = Particles(i).fitness;
        
        % Update gbest
        if Particles(i).pbest_fitness < gbest_fitness
            gbest_fitness = Particles(i).pbest_fitness;
            gbest_positions = Particles(i).pbest_positions;
        end
    end
    
    fitness_history = zeros(MaxIter, 1);
    if ~isinf(gbest_fitness)
        fitness_history(1) = gbest_fitness;
    else
        fitness_history(1) = inf; % Should not happen if calculate_fitness handles impossible solutions well
        warning('PSO:Initialisation', 'Initial global best fitness is Inf. Check problem constraints or initialization.');
    end


    % --- MAIN PSO LOOP (Iterations) ---
    for iter = 1:MaxIter
        if mod(iter,10) == 0 || iter == 1
            fprintf('Iteration %d/%d, Global Best Fitness: %.2f\n', iter, MaxIter, gbest_fitness);
        end
        
        % Update inertia weight (linear damping)
        w = w_final + (w_initial - w_final) * (MaxIter - iter) / MaxIter;
        
        for i = 1:N % For each particle
            % Update velocity
            r1 = rand(num_cranes, 2); % Random numbers for cognitive component
            r2 = rand(num_cranes, 2); % Random numbers for social component
            
            cognitive_component = c1 * r1 .* (Particles(i).pbest_positions - Particles(i).positions);
            social_component = c2 * r2 .* (gbest_positions - Particles(i).positions);
            
            Particles(i).velocity = w * Particles(i).velocity + cognitive_component + social_component;
            
            % Apply velocity limits
            Particles(i).velocity(:,1) = max(Vmin_x, min(Particles(i).velocity(:,1), Vmax_x));
            Particles(i).velocity(:,2) = max(Vmin_y, min(Particles(i).velocity(:,2), Vmax_y));
            
            % Update position
            Particles(i).positions = Particles(i).positions + Particles(i).velocity;
            
            % Apply boundary constraints (clamp positions to site dimensions)
            Particles(i).positions(:,1) = max(0, min(Particles(i).positions(:,1), site_width));
            Particles(i).positions(:,2) = max(0, min(Particles(i).positions(:,2), site_length));
            
            % Evaluate new fitness
            Particles(i).fitness = calculate_fitness(Particles(i).positions, problem);
            
            % Update pbest
            if Particles(i).fitness < Particles(i).pbest_fitness
                Particles(i).pbest_positions = Particles(i).positions;
                Particles(i).pbest_fitness = Particles(i).fitness;
                
                % Update gbest if this particle's pbest is the new global best
                if Particles(i).pbest_fitness < gbest_fitness
                    gbest_fitness = Particles(i).pbest_fitness;
                    gbest_positions = Particles(i).pbest_positions;
                end
            end
        end % End loop for particles
        
        fitness_history(iter) = gbest_fitness;
    end % End of iterations loop
end