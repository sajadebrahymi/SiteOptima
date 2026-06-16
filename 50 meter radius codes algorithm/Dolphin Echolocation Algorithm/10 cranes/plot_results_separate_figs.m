% -------------------------------------------------------------------------
% PLOT RESULTS (Separate Figures, FINAL Version)
% This version creates two separate figures and cleans the convergence data
% by removing large penalty values for better visualization.
% -------------------------------------------------------------------------
function plot_results_separate_figs(best_positions, problem, fitness_history)

    %% --- Figure 1: 3D Crane Layout ---
    figure('Name', '3D Crane Layout', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
    ax1 = gca; 
    hold(ax1, 'on');
    
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length;
    tower_height = problem.crane_specs.tower_height;
    
    floor_x = [0, site_width, site_width, 0];
    floor_y = [0, 0, site_length, site_length];
    floor_z = [0, 0, 0, 0];
    patch(ax1, floor_x, floor_y, floor_z, 'g', 'FaceAlpha', 0.05, 'DisplayName', 'Site Floor');

    S = problem.supply_points;
    plot3(ax1, S(:,1), S(:,2), S(:,3), 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 10, 'DisplayName', 'Supply Points (S)');
    D = problem.demand_points;
    plot3(ax1, D(:,1), D(:,2), D(:,3), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Demand Points (D)');

    if ~isempty(best_positions)
        num_cranes_to_plot = problem.crane_specs.num_cranes;
        crane_colors = lines(num_cranes_to_plot);
        max_radius = problem.crane_specs.max_radius;
        counter_jib_len = max_radius / 3.5;
        
        angles_deg = linspace(0, 360, num_cranes_to_plot + 1);
        angles_deg = angles_deg(1:end-1) + 20;
        
        for k = 1:num_cranes_to_plot
            base_x = best_positions(k,1);
            base_y = best_positions(k,2);
            crane_color = crane_colors(k,:);

            % Draw Simplified & Clean T-shape Crane Icon
            plot3(ax1, [base_x, base_x], [base_y, base_y], [0, tower_height], '-', 'Color', crane_color, 'LineWidth', 3, 'HandleVisibility', 'off');
            angle_rad = deg2rad(angles_deg(k));
            R_mat = [cos(angle_rad), -sin(angle_rad); sin(angle_rad), cos(angle_rad)];
            jib_vec_local = [max_radius; 0];
            rotated_jib_vec = R_mat * jib_vec_local;
            counter_jib_vec_local = [-counter_jib_len; 0];
            rotated_counter_jib_vec = R_mat * counter_jib_vec_local;
            jib_line_x = [base_x + rotated_counter_jib_vec(1), base_x + rotated_jib_vec(1)];
            jib_line_y = [base_y + rotated_counter_jib_vec(2), base_y + rotated_jib_vec(2)];
            jib_line_z = [tower_height, tower_height];
            plot3(ax1, jib_line_x, jib_line_y, jib_line_z, '-', 'Color', crane_color, 'LineWidth', 4, 'HandleVisibility', 'off');
            
            plot3(ax1, base_x, base_y, tower_height, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', crane_color, 'MarkerSize', 8, 'DisplayName', ['Crane ' num2str(k)]);
        end
    end
    
    view(ax1, -50, 25);
    axis(ax1, 'equal');
    axis(ax1, 'tight');
    xlim(ax1, [-10 site_width+10]);
    ylim(ax1, [-10 site_length+10]);
    zlim(ax1, [0 tower_height * 1.2]);
    xlabel(ax1, 'Site X-axis (m)');
    ylabel(ax1, 'Site Y-axis (m)');
    zlabel(ax1, 'Height (m)');
    title(ax1, ['Final Optimal Layout: ' num2str(problem.crane_specs.num_cranes) ' Cranes']);
    legend(ax1, 'show', 'Location', 'northeastoutside');
    grid(ax1, 'on');
    box(ax1, 'on');
    hold(ax1, 'off');

    %% --- Figure 2: Convergence Curve (with data cleaning) ---
    figure('Name', 'Convergence Curve', 'NumberTitle', 'off', 'Position', [950, 100, 550, 450]);
    ax2 = gca;
    
    if ~isempty(fitness_history) && any(isfinite(fitness_history))
        
        plot_history = fitness_history;
        
        % Filter out large penalty values for better visualization
        finite_vals = plot_history(isfinite(plot_history));
        if ~isempty(finite_vals)
            % Use median of finite values as a baseline for filtering
            median_val = median(finite_vals);
            plot_history(plot_history > median_val * 10) = NaN; % Filter values 10x larger than median
        end
        
        plot(ax2, 1:length(plot_history), plot_history, 'b-', 'LineWidth', 1.5);
        
        xlabel(ax2, 'Iteration');
        ylabel(ax2, 'Best Objective Function Value');
        title(ax2, 'Algorithm Convergence Curve');
        grid(ax2, 'on');
        
        valid_history = plot_history(~isnan(plot_history));
        if ~isempty(valid_history)
            ylim_min = min(valid_history);
            ylim_max = max(valid_history);
            if ylim_min < ylim_max
                 ylim(ax2, [ylim_min - 0.05*abs(ylim_min), ylim_max + 0.05*abs(ylim_max)]);
            elseif ~isempty(ylim_min)
                 ylim(ax2, [ylim_min - 0.1*abs(ylim_min), ylim_min + 1]); 
            end
        end
    else
        text(0.5, 0.5, 'No valid fitness history to plot.', 'HorizontalAlignment', 'center', 'Parent', ax2);
        title(ax2, 'Algorithm Convergence Curve (No Data)');
    end
end