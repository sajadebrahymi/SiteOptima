% -------------------------------------------------------------------------
% PLOT RESULTS for Crane Layout Optimization
% -------------------------------------------------------------------------
function plot_results(best_positions, problem, fitness_history)

    figure;

    % --- Plot 1: Crane Layout ---
    subplot(1,2,1);
    hold on;

    % Site boundaries
    plot([0, problem.site_dims.width, problem.site_dims.width, 0, 0], ...
         [0, 0, problem.site_dims.length, problem.site_dims.length, 0], 'k-', 'LineWidth', 1.5);
    
    % Supply Points
    plot(problem.supply_points(:,1), problem.supply_points(:,2), 'bs', ...
        'MarkerFaceColor', 'b', 'MarkerSize', 10, 'DisplayName', 'Supply Points (S)');
    for i = 1:problem.num_supply_points
        text(problem.supply_points(i,1)+2, problem.supply_points(i,2), ['S' num2str(i)], 'Color', 'b');
    end

    % Demand Points
    plot(problem.demand_points(:,1), problem.demand_points(:,2), 'ro', ...
        'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Demand Points (D)');
     for i = 1:problem.num_demand_points
        text(problem.demand_points(i,1)+2, problem.demand_points(i,2), ['D' num2str(i)], 'Color', 'r', 'FontSize', 7);
    end

    % Crane Positions and Reach
    crane_colors = lines(problem.crane_specs.num_cranes); % Different color for each crane
    for k = 1:problem.crane_specs.num_cranes
        plot(best_positions(k,1), best_positions(k,2), 'x', ...
            'Color', crane_colors(k,:), 'MarkerSize', 12, 'LineWidth', 2, ...
            'DisplayName', ['Crane ' num2str(k)]);
        text(best_positions(k,1)+2, best_positions(k,2)-2, ['C' num2str(k)], 'Color', crane_colors(k,:), 'FontWeight', 'bold');
        
        % Draw crane reach circle
        viscircles([best_positions(k,1), best_positions(k,2)], problem.crane_specs.max_radius, ...
            'Color', crane_colors(k,:), 'LineStyle', '--', 'LineWidth', 0.5);
    end

    axis equal;
    xlabel('Site Width (X-axis, meters)');
    ylabel('Site Length (Y-axis, meters)');
    title('Optimal Crane Layout');
    legend('show', 'Location', 'northeastoutside');
    grid on;
    hold off;

    % --- Plot 2: Convergence Curve ---
    subplot(1,2,2);
    plot(1:length(fitness_history), fitness_history, 'b-', 'LineWidth', 1.5);
    xlabel('Iteration');
    ylabel('Best Objective Function Value (Total Time)');
    title('DEA Convergence Curve');
    grid on;
    
    sgtitle('Crane Layout Optimization Results'); % Super title for the figure
end