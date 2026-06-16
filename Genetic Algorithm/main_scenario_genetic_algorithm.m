% -------------------------------------------------------------------------
% MAIN SCRIPT for Crane Layout Optimization using GENETIC ALGORITHM
% Based on "Base Scenario" problem definition.
% -------------------------------------------------------------------------
clear;
close all;
clc;

fprintf('Starting Crane Layout Optimization using GENETIC ALGORITHM...\n');

% --- Problem Definition (Same as Base Scenario) ---
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

% Demand Points (D_j) [x, y, z_d, Q_j_tonnes] - ORIGINAL Weights
demand_points_original = [ 
    230,  55,    50, 36.89; 195,  57.5,  50, 33.58; 175,  57.5,  50, 31.68; % D1-D3
    155,  57.5,  50, 30.59; 135,  57.5,  50, 29.67; 115,  57.5,  50, 31.23; % D4-D6
    95,   57.5,  50, 34.56; 75,   57.5,  50, 35.98; 55,   57.5,  50, 28.41; % D7-D9
    35,   57.5,  50, 26.45;                                               % D10
    15,   13,    50, 25.55; 15,   17,    50, 29.31; 15,   57.5,  50, 37.21; % D11-D13
    60,   29.25, 50, 34.65; 60,   11.75, 50, 32.56; 80,   29.25, 50, 26.41; % D14-D16
    80,   11.75, 50, 28.67; 100,  29.25, 50, 27.29; 100,  11.75, 50, 31.45; % D17-D19
    120,  11.75, 50, 35.98; 137.5,11.75, 50, 33.59; 155,  11.75, 50, 31.12; % D20-D22
    175,  29.25, 50, 30.89; 175,  11.75, 50, 26.45; 195,  29.25, 50, 29.28; % D23-D25
    195,  11.75, 50, 27.98; 215,  29.25, 50, 25.99; 215,  11.75, 50, 26.78  % D26-D28
];
num_demand_points = size(demand_points_original, 1);

% Crane Specifications (Liebherr 110 EC-B 5)
crane_specs.num_cranes = 8; % Number of cranes for base scenario
crane_specs.max_radius = 50; % meters
crane_specs.max_lift_capacity_per_cycle = 5; % tonnes
crane_specs.hoist_speed = 0.75; % m/s
crane_specs.trolley_speed = 0.8; % m/s
crane_specs.slew_speed_rpm = 0.8; % rpm
crane_specs.slew_speed_rad_per_sec = crane_specs.slew_speed_rpm * (2*pi) / 60;
crane_specs.gamma_k = 1.0; % Performance factor
crane_specs.beta = 0.5;    % Movement overlap factor
crane_specs.min_dist_between_cranes = 15; % meters, for anti-collision constraint

% --- Genetic Algorithm Parameters ---
ga_params.Npop = 50;    % Population size
ga_params.MaxGen = 200; % Maximum number of generations
ga_params.Pc = 0.8;     % Crossover probability
ga_params.Pm_gene = 0.05; % Mutation probability per gene (coordinate)
ga_params.elite_count = 2; % Number of elite individuals to carry to next generation
% Initial mutation strength (e.g., as a fraction of site width)
ga_params.initial_mutation_strength = 0.1 * site_dims.width; % Adjust as needed, e.g., 10-25m
ga_params.mutation_decay_rate = 0.99; % Mutation strength decays like rho in DEA_v2

% --- Pack all problem information into a structure ---
problem.site_dims = site_dims;
problem.supply_points = supply_points;
problem.num_supply_points = num_supply_points;
problem.demand_points = demand_points_original; 
problem.num_demand_points = num_demand_points; 
problem.crane_specs = crane_specs;
problem.num_variables = crane_specs.num_cranes * 2; 

% --- Run Genetic Algorithm ---
fprintf('Running Genetic Algorithm...\n');
fprintf('  Npop = %d, MaxGen = %d, Pc = %.2f, Pm_gene = %.3f, EliteCount = %d\n', ...
    ga_params.Npop, ga_params.MaxGen, ga_params.Pc, ga_params.Pm_gene, ga_params.elite_count);

[best_crane_positions, best_fitness_value, fitness_history] = ...
    genetic_algorithm_optimizer(problem, ga_params); 

% --- Results ---
fprintf('Optimization Finished with Genetic Algorithm.\n');
fprintf('Best Objective Function Value (Total Time): %.2f seconds\n', best_fitness_value);
fprintf('Optimal Crane Positions (x, y) for %d cranes:\n', crane_specs.num_cranes);
for k = 1:crane_specs.num_cranes
    fprintf('  Crane %d: (%.2f, %.2f)\n', k, best_crane_positions(k,1), best_crane_positions(k,2));
end

% --- Plotting Results ---
% Using the same plotting function
plot_results(best_crane_positions, problem, fitness_history);

fprintf('Program Ended.\n');