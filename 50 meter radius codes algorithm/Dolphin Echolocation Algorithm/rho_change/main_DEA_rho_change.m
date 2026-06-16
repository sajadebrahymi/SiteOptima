% -------------------------------------------------------------------------
% MAIN SCRIPT - SCENARIO: Rho Decay Rate Change
% Base condition: 8 Cranes, Min Distance 50m
% Change: rho_decay_rate is set to 0.90.
% -------------------------------------------------------------------------
clear;
close all;
clc;

fprintf('Starting Crane Layout Optimization - SCENARIO: Rho Decay Rate = 0.90\n');

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

% --- 2. DEA Algorithm Parameters ---
dea_params.Npop = 50; 
dea_params.Tmax = 200; 
dea_params.num_pulses_per_dolphin = 10;
dea_params.R_init = 0.1 * site_dims.width; 
% ******** خط کلیدی که تغییر کرده است ********
dea_params.rho_decay_rate = 0.90; % <-- نرخ کاهش شعاع به 0.90 تغییر یافت
% *******************************************
dea_params.delta_decay_rate = 0.995;

% --- 3. Pack all problem information ---
problem.site_dims = site_dims;
problem.supply_points = supply_points;
problem.num_supply_points = num_supply_points;
problem.demand_points = demand_points;
problem.num_demand_points = num_demand_points;
problem.crane_specs = crane_specs;
problem.num_variables = crane_specs.num_cranes * 2; 

% --- 4. Run Algorithm & Measure Time ---
tic; % Start timer
[best_crane_positions, best_fitness_value, fitness_history] = ...
    dolphin_echolocation_algorithm_final(problem, dea_params); 
execution_time = toc; % Stop timer and get elapsed time

% --- 5. Display Results ---
fprintf('=============================================\n');
fprintf('OPTIMIZATION FINISHED\n');
fprintf('=============================================\n');
fprintf('Algorithm: Dolphin Echolocation Algorithm\n');
fprintf('Scenario: Rho Decay Rate = 0.90\n');
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