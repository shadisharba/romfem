error('this function is not maintained');
% function [R_out,n_m0,n_m1,X0,X1,t0] = interpolate_cycles(R,classical_cycle,period,n_jump,scale_factor)
% n_m0 = [];
% n_m1 = [];
% X0 = [];
% X1 = [];
% t0 = [];
%     % no need to suibtract the elastic initialisation here, it's ignored and recomputed for the new load in the input_check function
%     % R_out.results{1}.delta_eps_e = copy_cyclic(period,R.results{1}.delta_eps_e,scale_factor); % todo: not needed?

%     %% damage increment within the current cycle
%     X0 = R.results{4}.primal-R.results{4}.primal(:,1);
%
%     %% Interpolation
%     t_m0 = numerical_model.temporal.mesh;
%     t0 = t_m0(1);
%     t_m1 = period * (n_jump+1) + t_m0;
%     t1 = t_m1(1);
%     n_m0 = @(t) (t1-t)/(t1-t0);
%     n_m1 = @(t) (t-t0)/(t1-t0);
%
%     D0 = R_out.results{4}.primal;
%     f_d= R_out.results{4}.dual -Y0; % damage yield function
%     f_d(f_d(:)<0)=0; % <= tol
%     d_D = kd * (f_d.^nd);
%     X1=integration(d_D,t_m1); % integration with zero initial conditions / estimate the damage evolution in the next cycle
%
%     %% linear interpolation for the damage increment within one cycle
%     for j=1:n_jump
%         T = t0 + period * j;
%         delta_D=n_m0(T) * (X0) + n_m1(T) * (X1);
%         D0 = D0 + delta_D(:,end);
%     end
%     R_out.results{4}.initial_damage = D0; % TODO: compare with   max(R_out.results{4}.primal(:,end)) + n_jump * max(R_out.results{4}.primal(:,end))
%     R_out.results{1}.p_mu_in_init = 0;
%
%     % this is used for the initial value of the accumulated plastic strain
%     J2_d_eps_p = sqrt(2/3 * _dot_product(numerical_model.mesh,(R.results{1}.d_primal),(R.results{1}.d_primal)));
%     J2_eps_p = R.results{1}.init_acc_eps_p + integration(J2_d_eps_p,numerical_model.temporal.mesh); % todo: is it okay to keep the time mesh always starting from zero?
%     R_out.results{1}.init_acc_eps_p = J2_eps_p;
%     %% init_acc_eps_p is not correct with the 2-time-scale approach
%     R_out.numerical_model=numerical_model;
%
%     R_out.results{4}.initial = 0;
% end
