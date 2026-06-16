% -------------------------------------------------------------------------
% FITNESS FUNCTION for Crane Layout Optimization
% Calculates the total operational time (objective function value)
% (This file is unchanged from the previous provided version)
% -------------------------------------------------------------------------
function total_weighted_time = calculate_fitness(crane_positions, problem)

    % Extract problem data
    site_dims = problem.site_dims;
    S = problem.supply_points; % [x, y, z_s]
    D = problem.demand_points; % [x, y, z_d, Q_j_tonnes]
    num_S = problem.num_supply_points;
    num_D = problem.num_demand_points;
    
    cs = problem.crane_specs;
    num_cranes = cs.num_cranes; % This will be 10 in the new scenario
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
    for k_constr = 1:num_cranes 
        if crane_positions(k_constr,1) < 0 || crane_positions(k_constr,1) > site_dims.width || ...
           crane_positions(k_constr,2) < 0 || crane_positions(k_constr,2) > site_dims.length
            total_weighted_time = large_penalty * num_D; 
            return;
        end
    end

    % --- Constraint Check 2: Minimum distance between cranes ---
    if num_cranes > 1
        for k1 = 1:num_cranes
            for k2 = (k1+1):num_cranes
                dist_sq = (crane_positions(k1,1) - crane_positions(k2,1))^2 + ...
                          (crane_positions(k1,2) - crane_positions(k2,2))^2;
                if dist_sq < min_dist_cranes_sq && dist_sq > 1e-9 
                    total_weighted_time = total_weighted_time + large_penalty; 
                end
            end
        end
    end
    % if total_weighted_time >= large_penalty 
    %     return; 
    % end

    % --- Calculate Objective Function ---
    all_demands_covered_this_solution = true; 
    for j = 1:num_D 
        Dj_coord = D(j, 1:2);
        Dj_height = D(j, 3);
        Qj_tonnes = D(j, 4);

        min_time_for_Dj_this_solution = inf; 

        num_cycles_for_Dj = ceil(Qj_tonnes / cap_per_cycle);

        for k_calc = 1:num_cranes 
            Ck_coord = crane_positions(k_calc,:);
            
            dist_Ck_Dj = norm(Ck_coord - Dj_coord);
            if dist_Ck_Dj > R_max
                continue; 
            end

            for i_calc = 1:num_S 
                Si_coord = S(i_calc, 1:2);
                Si_height = S(i_calc, 3);

                dist_Ck_Si = norm(Ck_coord - Si_coord);
                if dist_Ck_Si > R_max
                    continue; 
                end
                
                T_v_ijk = abs(Dj_height - Si_height) / v_h;

                r_ki = dist_Ck_Si; 
                r_kj = dist_Ck_Dj; 
                
                T_trolley_ijk = abs(r_kj - r_ki) / v_t;
                
                vec_Ck_Si = Si_coord - Ck_coord;
                vec_Ck_Dj = Dj_coord - Ck_coord;
                
                angle_Si_from_Ck_xaxis = atan2(vec_Ck_Si(2), vec_Ck_Si(1));
                angle_Dj_from_Ck_xaxis = atan2(vec_Ck_Dj(2), vec_Ck_Dj(1));
                
                delta_angle = abs(angle_Dj_from_Ck_xaxis - angle_Si_from_Ck_xaxis);
                if delta_angle > pi 
                    delta_angle = 2*pi - delta_angle;
                end
                T_slew_ijk = delta_angle / omega_s_rad;
                
                T_h_ijk = max(T_trolley_ijk, T_slew_ijk);

                T_ijk = gamma_k * (max(T_h_ijk, T_v_ijk) + beta * min(T_h_ijk, T_v_ijk));
                
                current_total_time_for_op = num_cycles_for_Dj * T_ijk;

                if current_total_time_for_op < min_time_for_Dj_this_solution
                    min_time_for_Dj_this_solution = current_total_time_for_op;
                end
            end 
        end 

        if isinf(min_time_for_Dj_this_solution)
            all_demands_covered_this_solution = false;
            total_weighted_time = total_weighted_time + large_penalty; 
        else
            total_weighted_time = total_weighted_time + min_time_for_Dj_this_solution;
        end
    end 
end