% -------------------------------------------------------------------------
% Particle Swarm Optimization (PSO) - FINAL VERSION
% Change: Prints output for every iteration.
% -------------------------------------------------------------------------
function [gbest_positions, gbest_fitness, fitness_history] = ...
    pso_optimizer_final(problem, pso_params)

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
    site_length = problem.site_dims.length;

    % Define Velocity Limits
    Vmax_x = pso_params.Vmax_ratio * site_width;
    Vmin_x = -Vmax_x;
    Vmax_y = pso_params.Vmax_ratio * site_length;
    Vmin_y = -Vmax_y;

    % --- INITIALIZATION ---
    Particles = repmat(struct(...
        'positions', zeros(num_cranes, 2), ...
        'velocity', zeros(num_cranes, 2), ...
        'fitness', inf, ...
        'pbest_positions', zeros(num_cranes, 2), ...
        'pbest_fitness', inf ...
    ), N, 1);

    gbest_positions = zeros(num_cranes, 2);
    gbest_fitness = inf;

    for i = 1:N
        Particles(i).positions = rand(num_cranes, 2) .* [site_width, site_length];
        Particles(i).velocity = (rand(num_cranes, 2) - 0.5) * 0.1; 
        Particles(i).fitness = calculate_fitness(Particles(i).positions, problem);
        Particles(i).pbest_positions = Particles(i).positions;
        Particles(i).pbest_fitness = Particles(i).fitness;
        
        if Particles(i).pbest_fitness < gbest_fitness
            gbest_fitness = Particles(i).pbest_fitness;
            gbest_positions = Particles(i).pbest_positions;
        end
    end
    
    fitness_history = zeros(MaxIter, 1);
    fitness_history(1) = gbest_fitness;
    
    fprintf('Running Particle Swarm Optimization...\n');

    % --- MAIN PSO LOOP (Iterations) ---
    for iter = 1:MaxIter
        fprintf('Iteration %d/%d, Global Best Fitness: %.2f\n', iter, MaxIter, gbest_fitness);
        
        % Update inertia weight (linear damping)
        w = w_final + (w_initial - w_final) * (MaxIter - iter) / MaxIter;
        
        for i = 1:N
            % Update velocity
            r1 = rand(num_cranes, 2); 
            r2 = rand(num_cranes, 2);
            
            cognitive_component = c1 * r1 .* (Particles(i).pbest_positions - Particles(i).positions);
            social_component = c2 * r2 .* (gbest_positions - Particles(i).positions);
            
            Particles(i).velocity = w * Particles(i).velocity + cognitive_component + social_component;
            
            % Apply velocity limits
            Particles(i).velocity(:,1) = max(Vmin_x, min(Particles(i).velocity(:,1), Vmax_x));
            Particles(i).velocity(:,2) = max(Vmin_y, min(Particles(i).velocity(:,2), Vmax_y));
            
            % Update position
            Particles(i).positions = Particles(i).positions + Particles(i).velocity;
            
            % Apply boundary constraints
            Particles(i).positions(:,1) = max(0, min(Particles(i).positions(:,1), site_width));
            Particles(i).positions(:,2) = max(0, min(Particles(i).positions(:,2), site_length));
            
            % Evaluate new fitness
            Particles(i).fitness = calculate_fitness(Particles(i).positions, problem);
            
            % Update pbest and gbest
            if Particles(i).fitness < Particles(i).pbest_fitness
                Particles(i).pbest_positions = Particles(i).positions;
                Particles(i).pbest_fitness = Particles(i).fitness;
                
                if Particles(i).pbest_fitness < gbest_fitness
                    gbest_fitness = Particles(i).pbest_fitness;
                    gbest_positions = Particles(i).pbest_positions;
                end
            end
        end
        fitness_history(iter) = gbest_fitness;
    end
end