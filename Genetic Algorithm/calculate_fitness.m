% -------------------------------------------------------------------------
% FITNESS FUNCTION for Crane Layout Optimization
% Calculates the total operational time (objective function value)
% -------------------------------------------------------------------------
function total_weighted_time = calculate_fitness(crane_positions, problem)

    % Extract problem data
    site_dims = problem.site_dims;
    S = problem.supply_points; % [x, y, z_s]
    D = problem.demand_points; % [x, y, z_d, Q_j_tonnes]
    num_S = problem.num_supply_points;
    num_D = problem.num_demand_points;
    
    cs = problem.crane_specs;
    num_cranes = cs.num_cranes;
    R_max = cs.max_radius;
    cap_per_cycle = cs.max_lift_capacity_per_cycle;
    v_h = cs.hoist_speed;
    v_t = cs.trolley_speed;
    omega_s_rad = cs.slew_speed_rad_per_sec;
    gamma_k = cs.gamma_k;
    beta = cs.beta;
    min_dist_cranes_sq = cs.min_dist_between_cranes^2;

    total_weighted_time = 0;
    large_penalty = 1e9; % Penalty for constraint violations

    % --- Constraint Check 1: Cranes within site boundaries ---
    % (This should be handled by DEA generation, but good to double check or enforce)
    for k = 1:num_cranes
        if crane_positions(k,1) < 0 || crane_positions(k,1) > site_dims.width || ...
           crane_positions(k,2) < 0 || crane_positions(k,2) > site_dims.length
            total_weighted_time = large_penalty * num_D; % Severe penalty
            return;
        end
    end

    % --- Constraint Check 2: Minimum distance between cranes ---
    if num_cranes > 1
        for k1 = 1:num_cranes
            for k2 = (k1+1):num_cranes
                dist_sq = (crane_positions(k1,1) - crane_positions(k2,1))^2 + ...
                          (crane_positions(k1,2) - crane_positions(k2,2))^2;
                if dist_sq < min_dist_cranes_sq
                    total_weighted_time = total_weighted_time + large_penalty; % Add penalty
                    % If penalty is too high, can return here as well
                    % For now, accumulate penalty and continue to check coverage
                end
            end
        end
    end
    if total_weighted_time >= large_penalty % if already penalized heavily, maybe stop early
        % return; % Can uncomment if strict separation is primary
    end


    % --- Calculate Objective Function ---
    all_demands_covered = true;
    for j = 1:num_D % For each demand point
        Dj_coord = D(j, 1:2);
        Dj_height = D(j, 3);
        Qj_tonnes = D(j, 4);

        min_time_for_Dj = inf;
        best_S_idx = -1;
        best_C_idx = -1;

        num_cycles_for_Dj = ceil(Qj_tonnes / cap_per_cycle);

        for k = 1:num_cranes % For each crane
            Ck_coord = crane_positions(k,:);
            
            % Check if crane k can reach demand point j
            dist_Ck_Dj = norm(Ck_coord - Dj_coord);
            if dist_Ck_Dj > R_max
                continue; % Crane k cannot reach demand j
            end

            for i = 1:num_S % For each supply point
                Si_coord = S(i, 1:2);
                Si_height = S(i, 3);

                % Check if crane k can reach supply point i
                dist_Ck_Si = norm(Ck_coord - Si_coord);
                if dist_Ck_Si > R_max
                    continue; % Crane k cannot reach supply i
                end
                
                % If reachable, calculate time T_ijk for one cycle
                % Vertical time (one way, lifting)
                T_v_ijk = abs(Dj_height - Si_height) / v_h;

                % Horizontal time
                r_ki = dist_Ck_Si; % Radius to supply point from crane base
                r_kj = dist_Ck_Dj; % Radius to demand point from crane base
                
                T_trolley_ijk = abs(r_kj - r_ki) / v_t;
                
                % Angle calculation for slewing (vector math)
                vec_Ck_Si = Si_coord - Ck_coord;
                vec_Ck_Dj = Dj_coord - Ck_coord;
                
                % Angle between (Ck_Si) and (Ck_Dj)
                % Using atan2 for robustness, or dot product for angle
                angle_Si_from_Ck_xaxis = atan2(vec_Ck_Si(2), vec_Ck_Si(1));
                angle_Dj_from_Ck_xaxis = atan2(vec_Ck_Dj(2), vec_Ck_Dj(1));
                
                delta_angle = abs(angle_Dj_from_Ck_xaxis - angle_Si_from_Ck_xaxis);
                if delta_angle > pi % Ensure shortest angle
                    delta_angle = 2*pi - delta_angle;
                end
                T_slew_ijk = delta_angle / omega_s_rad;
                
                T_h_ijk = max(T_trolley_ijk, T_slew_ijk);

                % Total time for one cycle T_ijk
                T_ijk = gamma_k * (max(T_h_ijk, T_v_ijk) + beta * min(T_h_ijk, T_v_ijk));
                
                current_total_time_for_op = num_cycles_for_Dj * T_ijk;

                if current_total_time_for_op < min_time_for_Dj
                    min_time_for_Dj = current_total_time_for_op;
                    % best_S_idx = i; % Not strictly needed for fitness, but for z_ijk
                    % best_C_idx = k;
                end
            end % End loop supply points
        end % End loop cranes

        if isinf(min_time_for_Dj)
            all_demands_covered = false;
            total_weighted_time = total_weighted_time + large_penalty; % Penalty for not covering demand
        else
            total_weighted_time = total_weighted_time + min_time_for_Dj;
        end
    end % End loop demand points

    % Optional: If not all demands covered, could make fitness INF or very large
    if ~all_demands_covered
         % Already added penalty per uncovered demand, could add more here if needed
    end
end