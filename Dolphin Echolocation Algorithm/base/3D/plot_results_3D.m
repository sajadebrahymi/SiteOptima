% -------------------------------------------------------------------------
% PLOT RESULTS (3D Version) for Crane Layout Optimization
% Updated to draw each crane jib at a unique angle to avoid visual clash.
% -------------------------------------------------------------------------
function plot_results_3D(best_positions, problem, fitness_history)

    figure('Name', 'Crane Layout Optimization Results (3D)', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);

    % --- Plot 1: 3D Crane Layout ---
    ax1 = subplot(1, 2, 1);
    hold(ax1, 'on');
    
    % Extract dimensions for clarity
    site_width = problem.site_dims.width;
    site_length = problem.site_dims.length;
    
    % Plot Site Floor
    floor_x = [0, site_width, site_width, 0];
    floor_y = [0, 0, site_length, site_length];
    floor_z = [0, 0, 0, 0];
    patch(ax1, floor_x, floor_y, floor_z, 'g', 'FaceAlpha', 0.05, 'DisplayName', 'Site Floor');

    % Plot Supply Points
    if ~isempty(problem.supply_points)
        S = problem.supply_points;
        plot3(ax1, S(:,1), S(:,2), S(:,3), 'bs', ...
            'MarkerFaceColor', 'b', 'MarkerSize', 10, 'DisplayName', 'Supply Points (S)');
    end

    % Plot Demand Points
    if ~isempty(problem.demand_points)
        D = problem.demand_points;
        plot3(ax1, D(:,1), D(:,2), D(:,3), 'ro', ...
            'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Demand Points (D)');
    end

    % Plot Cranes with unique orientations
    if ~isempty(best_positions)
        num_cranes_to_plot = problem.crane_specs.num_cranes;
        crane_colors = lines(num_cranes_to_plot);
        tower_height = problem.crane_specs.tower_height;
        max_radius = problem.crane_specs.max_radius;
        counter_jib_len = max_radius / 3.5;
        tower_width = 1.5;
        jib_height = 2.0;
        
        % Define a set of distinct angles for the jibs to avoid visual overlap
        angles_deg = linspace(0, 360, num_cranes_to_plot + 1);
        angles_deg = angles_deg(1:end-1); % Use N distinct angles
        
        for k = 1:num_cranes_to_plot
            base_x = best_positions(k,1);
            base_y = best_positions(k,2);
            crane_color = crane_colors(k,:);
            
            % --- Draw Tower Mast ---
            half_w = tower_width / 2;
            corners_x = [base_x-half_w, base_x+half_w, base_x+half_w, base_x-half_w];
            corners_y = [base_y-half_w, base_y-half_w, base_y+half_w, base_y+half_w];
            for c_idx = 1:4
                plot3(ax1, [corners_x(c_idx), corners_x(c_idx)], [corners_y(c_idx), corners_y(c_idx)], [0, tower_height], ...
                    '-', 'Color', crane_color, 'LineWidth', 1, 'HandleVisibility', 'off');
            end
             plot3(ax1, [corners_x, corners_x(1)], [corners_y, corners_y(1)], [tower_height, tower_height, tower_height, tower_height, tower_height], ...
                 '-', 'Color', crane_color, 'LineWidth', 1, 'HandleVisibility', 'off');

            % --- Calculate Rotated Jib and Counter-Jib Positions ---
            angle_rad = deg2rad(angles_deg(k)); % Get unique angle for this crane
            
            % Define jib/counter-jib vectors in a local coordinate system (e.g., along X-axis)
            jib_vec = [max_radius; 0];
            counter_jib_vec = [-counter_jib_len; 0];
            
            % 2D Rotation Matrix
            R = [cos(angle_rad), -sin(angle_rad); sin(angle_rad), cos(angle_rad)];
            
            % Apply rotation
            rotated_jib_vec = R * jib_vec;
            rotated_counter_jib_vec = R * counter_jib_vec;
            
            % --- Draw Jib Assembly at the calculated angle ---
            jib_height_top = tower_height + jib_height;
            
            % Main Jib
            plot3(ax1, [base_x, base_x + rotated_jib_vec(1)], [base_y, base_y + rotated_jib_vec(2)], [tower_height, tower_height], ...
                '-', 'Color', crane_color, 'LineWidth', 2, 'HandleVisibility', 'off');
            % Counter-Jib
            plot3(ax1, [base_x, base_x + rotated_counter_jib_vec(1)], [base_y, base_y + rotated_counter_jib_vec(2)], [tower_height, tower_height], ...
                '-', 'Color', crane_color, 'LineWidth', 2, 'HandleVisibility', 'off');
            
            % Cabin/Top Marker for Legend
            plot3(ax1, base_x, base_y, tower_height, 's', 'MarkerEdgeColor', 'k', ...
                  'MarkerFaceColor', crane_color, 'MarkerSize', 8, 'DisplayName', ['Crane ' num2str(k)]);
        end
    end
    
    % Set plot properties
    view(ax1, -50, 25);
    axis(ax1, 'equal');
    axis(ax1, 'tight');
    xlim(ax1, [-10 site_width+10]);
    ylim(ax1, [-10 site_length+10]);
    zlim(ax1, [0 tower_height * 1.2]);
    
    xlabel(ax1, 'Site X-axis (m)');
    ylabel(ax1, 'Site Y-axis (m)');
    zlabel(ax1, 'Height (m)');
    title(ax1, ['3D Layout: ' num2str(problem.crane_specs.num_cranes) ' Cranes']);
    legend(ax1, 'show', 'Location', 'northeastoutside');
    grid(ax1, 'on');
    box(ax1, 'on');
    hold(ax1, 'off');

    % --- Plot 2: Convergence Curve (remains 2D) ---
    ax2 = subplot(1, 2, 2);
    % ... (بخش مربوط به نمودار همگرایی بدون تغییر باقی می‌ماند) ...
    if ~isempty(fitness_history) && any(~isinf(fitness_history))
        plot(ax2, 1:length(fitness_history), fitness_history, 'b-', 'LineWidth', 1.5);
        xlabel(ax2, 'Iteration');
        ylabel(ax2, 'Best Objective Function Value');
        title(ax2, 'Algorithm Convergence Curve');
        grid(ax2, 'on');
        valid_history = fitness_history(~isinf(fitness_history));
        if ~isempty(valid_history)
            ylim_min = min(valid_history);
            ylim_max = max(valid_history);
            if ylim_min < ylim_max
                 ylim(ax2, [ylim_min - 0.01*abs(ylim_min), ylim_max + 0.01*abs(ylim_max)]);
            elseif ~isempty(ylim_min)
                 ylim(ax2, [ylim_min - 0.1*abs(ylim_min), ylim_min + 1]); 
            end
        end
    else
        text(0.5, 0.5, 'No valid fitness history to plot.', 'HorizontalAlignment', 'center', 'Parent', ax2);
        title(ax2, 'Algorithm Convergence Curve (No Data)');
    end
    
    sgtitle('Crane Layout Optimization Results');
end