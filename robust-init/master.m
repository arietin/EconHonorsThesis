clearvars -except part Theta outdir y seed
addpath('mfunctions')
%part = 1
%Theta = [0.322773392263051 -0.281851152140988 -2.39059597031676 -2.044644989741 -0.897883745312797 0 0 0 -0.922580122977585 0 0 -1.43235200557379 0 -1.35905026847786]
%outdir = "2023_20260304"
%y = "2023"
%seed = 1

seed = seed+1; % to avoid changing the startup.py code
SDs = [0.087307	0.072176	0.064961	0.093102	0.257039	0.320767	0.170229	0.172406	0.266011	0.197764	0.290414	0.051216	0.254831	0.080893]; % from bootstrapped data
%SDs = ones(size(Theta)) % for testing ONLY
change = (-1+2*mod(seed,2))*floor(seed/2)*SDs % the pattern is 0, -1, 1, -2, 2...
Theta = Theta + change;


%% Define the Objective function

syms w_1 h_1 w_2 h_2 Y;
M(w_1,h_1,w_2,h_2,Y) = w_1*h_1 + w_2*h_2+Y;

syms tau_1 tau_2 delta_1 delta_2;
k(tau_1,tau_2,delta_1,delta_2) = (tau_1^delta_1) *(tau_2^delta_2)*M(w_1,h_1,w_2,h_2,Y)^(1-delta_1-delta_2);

syms lambda_1 T;
u_1(lambda_1) = lambda_1*log(T-tau_1-h_1)+(1-lambda_1)*log(k(tau_1,tau_2,delta_1,delta_2));

syms lambda_2;
u_2(lambda_2) = lambda_2*log(T-tau_2-h_2)+(1-lambda_2)*log(k(tau_1,tau_2,delta_1,delta_2));

syms alpha;
W(h_1, h_2, tau_1, tau_2)= alpha * u_1(lambda_1) + (1-alpha)*u_2(lambda_2)

%options = optimoptions('fmincon', 'Display', 'notify-detailed', 'Algorithm','active-set','OptimalityTolerance',0.0001);
opt_master = optimoptions('fminunc','Algorithm','quasi-newton','FunValCheck','on','OptimalityTolerance',1e-8,'StepTolerance', 1e-8);
%%%%OK. Actually Finding the Value
%%The stuff that we only need to do once:
% start by substituting in a T = 120 and a guess:
% specify inequality constraints on h_1,h_2,tau_1, tau_2
A = cat(1, diag(-1*ones([1,4])), [1,0,1,0;0,1,0,1]);
b = cat(1, zeros([4,1]), [120;120]);
W_T = subs(W, [T, alpha],[120, 0.5]);




%% Can hold constant-- this is the initial guess from DBF

x0 = [45.7, 38.6, 7.9, 14.9];

%head = parquetread(strcat(y,"_data_partitions/part",string(part),".parquet"));
head_o = readtable(strcat(outdir,"/used_data.csv"));
head_o = head_o(head_o.kfamincly0>=0,:);
head_o.Properties.RowNames = string(head_o{:,"fakeid0"});

%% bootstrap!
%rng(seed,"twister")
%head = datasample(head_o,height(head_o));
head = head_o;

%head = head(2:11,:)
%head = head(find(head.Properties.RowNames == "1687"):end,:)
true_hours = head(:, ["hrs_workly0","hrs_workly1","hrs_house0","hrs_house1"]);

cpus = feature('numCores')
if height(gcp("nocreate")) == 0
    parpool(cpus); %Comment out if testing this a lot so only starts once
end
hhidvals = head.Properties.RowNames.';


%Cost function
e = 10
l = 0
u = 120
cost = @(var) exp(e*(l-var)) + exp(e*(var-u));
costs = cost(h_1)+ cost(h_2)+ cost(tau_1)+ cost(tau_1)+ cost(h_1+tau_1)+ cost(h_2+tau_2);
W_C = -W_T + costs;
grad_f = gradient(W_C,[h_1, h_2, tau_1, tau_2]);

options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true);
%% call the child process

%c = child(Theta_g, head, hhidvals, options, W_C, grad_f, outdir, x0)
obs_tmat = [head.hrs_workly0, head.hrs_workly1, head.hrs_house0, head.hrs_house1, head.knlabincly0, head.wage_inc0, head.wage_inc1];
vn = [{'h_1'},{ 'h_2'},{ 'tau_1'},{ 'tau_2'},{ 'Y'},{ 'w_1'},{ 'w_2'}];
truetime = array2table(double(obs_tmat),"VariableNames",vn);
obs_mom = table2array(moms(truetime));

%%
Wmat = bootstrap(truetime);

obj_c = @(sim) (obs_mom - sim)*Wmat*(obs_mom - sim)';

fun = @(x) obj_c(table2array(moms(simulate(x, head, hhidvals, options, W_C, grad_f, x0))));

%% Actual Optimization
[Theta_opt, Theta_fval] = fminunc(fun,Theta,opt_master)

%[Theta_opt, Theta_fval] = ga(fun,14);
%%
writetable(array2table([seed,Theta_opt,Theta_fval]),strcat(outdir,"/optimalTheta.csv"),'WriteMode','Append')