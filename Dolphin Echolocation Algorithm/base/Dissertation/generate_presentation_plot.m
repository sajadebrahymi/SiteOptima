% -------------------------------------------------------------------------
% SCRIPT to generate a high-quality, static 3D plot of a final crane layout
% This script uses FIXED crane positions for presentation purposes.
% -------------------------------------------------------------------------
clear; 
close all; 
clc;

fprintf('Generating final presentation plot...\n');

%% --- Define Problem Data (from the base scenario) ---
site_dims.width = 250; 
site_dims.length = 75;

supply_points = [
    40,   20.5, 0;
    235,  20.5, 0;
    137.5, 29.25,0
];
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
crane_specs.tower_height = 65; % ارتفاع برج جرثقیل (متر)

% Pack into problem struct
problem.site_dims = site_dims;
problem.supply_points = supply_points;
problem.num_supply_points = num_supply_points;
problem.demand_points = demand_points;
problem.num_demand_points = num_demand_points;
problem.crane_specs = crane_specs;


%% --- Define the FINAL Crane Positions and Fitness History to be Plotted ---

% این مختصات دقیقاً همان‌هایی هستند که شما از خروجی اجرای خود ارسال کردید
final_crane_positions = [
    189.60, 25.78;
     89.64, 21.57;
    180.73, 53.85;
     23.23, 61.75;
     76.63, 53.78;
     59.42, 66.50;
    214.20, 57.76;
    108.80, 60.23
];

% بازسازی تاریخچه همگرایی بر اساس لاگ ارسالی شما برای رسم نمودار
iterations = [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200];
fitness_values = [14256.09, 13573.29, 13550.25, 13517.49, 13509.36, 13499.22, 13497.83, 13495.60, 13495.60, 13492.90, 13492.90, 13492.90, 13492.90, 13492.90, 13492.90, 13491.59, 13491.59, 13491.23, 13487.03, 13485.79, 13485.32];

% Interpolate to create a full 200-point history for a smooth plot
fitness_history = interp1(iterations, fitness_values, 1:200, 'pchip');


%% --- Call the 3D plotting function ---
plot_results_3D(final_crane_positions, problem, fitness_history);

fprintf('Presentation plot generated successfully.\n');