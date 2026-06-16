% -------------------------------------------------------------------------
% MAIN SCRIPT - FINAL VERSION for Particle Swarm Optimization (PSO)
% Scenario: Base with Min Distance 50m
% -------------------------------------------------------------------------
clear;
close all;
clc;

fprintf('Starting Crane Layout Optimization - FINAL SCENARIO (PSO)\n');

% --- 1. Problem Definition ---
site_dims.width = 250; 
site_dims.length = 75;
supply_points = [40, 20.5, 0; 235, 20.5, 0; 137.5, 29.25, 0];
num_supply_points = size(supply_points, 1);
demand_points = [ 
    230,  55,    50, 36.89; 195,  57.5,  50, 33.58; 175,  57.5,  50, 31.68;
    155,  57.5,  50, 30.59; 135,  57.5,  50, 29.67; 115,  57.5,  50, 31.23;
    95,   57.5,  50, 34.56; 75,   57.5,  50, 35.98; 55,   57.5,  50, 28.41;
    35,   57.5,  50, 26.45; 15,   13,    50, 25.55; 15,   17,    50, 29.31;
    15,   57.5,  50, 37.21; 60,   29.25, 50, 34.65; 60,   11.75, 50, 32.56;
    80,   29.25, 50, 26.41; 80,   11.75, 50, 28.67; 100,  29.25, 50, 27.29;
    100,  11.75, 50, 31.45; 120,  11.75, 50, 35.98; 137.5,11.75, 50, 33.59;
    155,  11.75, 50, 31.12; 175,  29.25, 50, 30.89; 175,  11.75, 50, 26.45;
    195,  29.25, 50, 29.28; 195,  11.75, 50, 27.98; 215,  29.25, 50, 25.99;
    215,  11.75, 50, 26.78
];
num_demand_points = size(demand_points, 1);
crane_specs.num_cranes = 8;
crane_specs.max_radius = 50; 
crane_specs.max_lift_capacity_per_cycle = 5; 
crane_specs.hoist_speed = 0.75; 
crane_specs.trolley_speed = 0.8;
crane_specs.slew_speed_rpm = 0.8; 
crane_specs.slew_speed_rad_per_sec = crane_specs.slew_speed_rpm * (2*pi) / 60;
crane_specs.gamma_k = 1.0; 
crane_specs.beta = 0.5;    
crane_specs.min_dist_between_cranes = 50;
crane_specs.tower_height = 65; 

% --- 2. PSO Algorithm Parameters ---
pso_params.num_particles = 50;    % Population size
pso_params.MaxIter = 200;       % Maximum number of iterations
pso_params.w_initial = 0.9;     % Initial inertia weight
pso_params.w_final = 0.4;       % Final inertia weight
pso_params.c1 = 2.0;            % Cognitive coefficient
pso_params.c2 = 2.0;            % Social coefficient
pso_params.Vmax_ratio = 0.2;    % Max velocity as a ratio of search space

% --- 3. Pack all problem information ---
problem.site_dims = site_dims;
problem.supply_points = supply_points;
problem.num_supply_points = num_supply_points;
problem.demand_points = demand_points;
problem.num_demand_points = num_demand_points;
problem.crane_specs = crane_specs;

% --- 4. Run Algorithm & Measure Time ---
tic; % Start timer
[best_crane_positions, best_fitness_value, fitness_history] = ...
    pso_optimizer_final(problem, pso_params); 
execution_time = toc; % Stop timer and get elapsed time

% --- 5. Display Results ---
fprintf('=============================================\n');
fprintf('OPTIMIZATION FINISHED\n');
fprintf('=============================================\n');
fprintf('Algorithm: Particle Swarm Optimization (PSO)\n');
fprintf('Total Execution Time: %.2f seconds\n', execution_time);
fprintf('Best Objective Function Value (Total Time): %.2f seconds\n', best_fitness_value);
fprintf('Optimal Crane Positions (x, y) for %d cranes:\n', crane_specs.num_cranes);
for k = 1:crane_specs.num_cranes
    fprintf('  Crane %d: (%.2f, %.2f)\n', k, best_crane_positions(k,1), best_crane_positions(k,2));
end
fprintf('=============================================\n');

% --- 6. Plotting Results ---
plot_results_separate_figs(best_crane_positions, problem, fitness_history);

fprintf('Program Ended.\n');