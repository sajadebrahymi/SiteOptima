% -------------------------------------------------------------------------
% PLOT RESULTS for Crane Layout Optimization
% (This file is unchanged from the previous provided version)
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
    if ~isempty(problem.supply_points)
        plot(problem.supply_points(:,1), problem.supply_points(:,2), 'bs', ...
            'MarkerFaceColor', 'b', 'MarkerSize', 10, 'DisplayName', 'Supply Points (S)');
        for i = 1:problem.num_supply_points
            text(problem.supply_points(i,1)+2, problem.supply_points(i,2), ['S' num2str(i)], 'Color', 'b');
        end
    end

    % Demand Points
    if ~isempty(problem.demand_points)
        plot(problem.demand_points(:,1), problem.demand_points(:,2), 'ro', ...
            'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Demand Points (D)');
         for i = 1:problem.num_demand_points
            text(problem.demand_points(i,1)+2, problem.demand_points(i,2), ['D' num2str(i)], 'Color', 'r', 'FontSize', 7);
        end
    end

    % Crane Positions and Reach
    if ~isempty(best_positions)
        num_cranes_to_plot = problem.crane_specs.num_cranes; % Will be 10 for the new scenario
        crane_colors = lines(num_cranes_to_plot); 
        for k_plot = 1:num_cranes_to_plot 
            plot(best_positions(k_plot,1), best_positions(k_plot,2), 'x', ...
                'Color', crane_colors(k_plot,:), 'MarkerSize', 12, 'LineWidth', 2, ...
                'DisplayName', ['Crane ' num2str(k_plot)]);
            text(best_positions(k_plot,1)+2, best_positions(k_plot,2)-2, ['C' num2str(k_plot)], ...
                'Color', crane_colors(k_plot,:), 'FontWeight', 'bold');
            
            viscircles([best_positions(k_plot,1), best_positions(k_plot,2)], problem.crane_specs.max_radius, ...
                'Color', crane_colors(k_plot,:), 'LineStyle', '--', 'LineWidth', 0.5);
        end
    end

    axis equal;
    axis([0 problem.site_dims.width 0 problem.site_dims.length]); 
    xlabel('Site Width (X-axis, meters)');
    ylabel('Site Length (Y-axis, meters)');
    title(['Optimal Layout: ' num2str(problem.crane_specs.num_cranes) ' Cranes']);
    if problem.crane_specs.num_cranes > 0 
        legend('show', 'Location', 'northeastoutside');
    end
    grid on;
    hold off;

    % --- Plot 2: Convergence Curve ---
    subplot(1,2,2);
    if ~isempty(fitness_history) && any(~isinf(fitness_history)) 
        plot(1:length(fitness_history), fitness_history, 'b-', 'LineWidth', 1.5);
        xlabel('Iteration');
        ylabel('Best Objective Function Value (Total Time)');
        title('DEA Convergence Curve');
        grid on;
        ylim_min = min(fitness_history(fitness_history > -inf & fitness_history < inf));
        ylim_max = max(fitness_history(fitness_history > -inf & fitness_history < inf));
        if ~isempty(ylim_min) && ~isempty(ylim_max) && ylim_min < ylim_max
             ylim([ylim_min - 0.1*abs(ylim_min), ylim_max + 0.1*abs(ylim_max)]);
        elseif ~isempty(ylim_min)
             ylim([ylim_min - 0.1*abs(ylim_min), ylim_min + 1]); 
        end
    else
        text(0.5, 0.5, 'No valid fitness history to plot.', 'HorizontalAlignment', 'center');
        title('DEA Convergence Curve (No Data)');
    end
    
    sgtitle(['Crane Layout Optimization Results (' num2str(problem.crane_specs.num_cranes) ' Cranes)']); 
end