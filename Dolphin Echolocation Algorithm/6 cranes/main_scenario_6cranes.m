% -------------------------------------------------------------------------
% MAIN SCRIPT for Crane Layout Optimization - SCENARIO: 6 CRANES
% Based on "Base Scenario" (v2 with explicit decay params)
% Change: Number of cranes reduced from 8 to 6.
% -------------------------------------------------------------------------
clear;
close all;
clc;

fprintf('Starting Crane Layout Optimization - SCENARIO: 6 CRANES\n');

% --- Problem Definition ---
% Site Dimensions
site_dims.width = 250; % meters (X-axis)
site_dims.length = 75;  % meters (Y-axis)

% Supply Points (S_i) [x, y, z_s]
supply_points = [
    40,   20.5, 0;
    235,  20.5, 0;
    137.5, 29.25,0
];
num_supply_points = size(supply_points, 1);

% Demand Points (D_j) [x, y, z_d, Q_j_tonnes]
demand_points = [ % Same data as base scenario
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

% Crane Specifications (Liebherr 110 EC-B 5)
% ******** ключевое изменение здесь ********
crane_specs.num_cranes = 6; % <--- تغییر از 8 به 6
% ***********************************
crane_specs.max_radius = 50; % meters
crane_specs.max_lift_capacity_per_cycle = 5; % tonnes
crane_specs.hoist_speed = 0.75; % m/s
crane_specs.trolley_speed = 0.8; % m/s
crane_specs.slew_speed_rpm = 0.8; % rpm
crane_specs.slew_speed_rad_per_sec = crane_specs.slew_speed_rpm * (2*pi) / 60;
crane_specs.gamma_k = 1.0; % Performance factor
crane_specs.beta = 0.5;    % Movement overlap factor
crane_specs.min_dist_between_cranes = 15; % meters, for anti-collision constraint

% --- DEA Algorithm Parameters (Same as Base Scenario) ---
dea_params.Npop = 50; 
dea_params.Tmax = 200; 
dea_params.num_pulses_per_dolphin = 10;
dea_params.R_init = 0.1 * site_dims.width; 
dea_params.rho_decay_rate = 0.99; 
dea_params.delta_decay_rate = 0.995;

% --- Pack all problem information into a structure ---
problem.site_dims = site_dims;
problem.supply_points = supply_points;
problem.num_supply_points = num_supply_points;
problem.demand_points = demand_points;
problem.num_demand_points = num_demand_points;
problem.crane_specs = crane_specs;
problem.num_variables = crane_specs.num_cranes * 2; % Automatically updated

% --- Run Dolphin Echolocation Algorithm ---
fprintf('Running Dolphin Echolocation Algorithm (Base Scenario v2 logic).\n');
fprintf('  Number of Cranes = %d\n', crane_specs.num_cranes);
fprintf('  Npop = %d, Tmax = %d\n', dea_params.Npop, dea_params.Tmax);
fprintf('  R_init = %.2f m, rho_decay_rate = %.3f, delta_decay_rate = %.3f\n', ...
    dea_params.R_init, dea_params.rho_decay_rate, dea_params.delta_decay_rate);

% Call the same DEA function as the base scenario
[best_crane_positions, best_fitness_value, fitness_history] = ...
    dolphin_echolocation_algorithm_v2(problem, dea_params); 

% --- Results ---
fprintf('Optimization Finished for 6-Crane Scenario.\n');
fprintf('Best Objective Function Value (Total Time): %.2f seconds\n', best_fitness_value);
fprintf('Optimal Crane Positions (x, y) for %d cranes:\n', crane_specs.num_cranes);
for k = 1:crane_specs.num_cranes
    fprintf('  Crane %d: (%.2f, %.2f)\n', k, best_crane_positions(k,1), best_crane_positions(k,2));
end

% --- Plotting Results ---
% Using the same plotting function
plot_results(best_crane_positions, problem, fitness_history);

fprintf('Program Ended.\n');