function HouseholdDraws = simulate(Theta, head, hhidvals, options, W_C, grad_f, x0)
tic
%% CREATING Sigma and mu from Theta

mu = Theta(1:4)
Sig = Theta(5:end)
lt = tril(reshape(1:16,[4,4]));
mask = lt(lt ~=0);
C = changem(lt, Sig,mask.').';
C = C + diag(exp(diag(C))-diag(C)); % replace the diagonal with exponents, as in DBF
Sigma = C'*C

%% Random Draws
rng("default")
x_draws_arr = mvnrnd(double(mu), Sigma, height(head));
x_draws = array2table(x_draws_arr);
x_draws.Properties.RowNames = head.Properties.RowNames;
%writetable(x_draws,strcat(outdir,'/x_draws.csv'),"WriteMode","append");

%% Reset some variables
%syms("w_1", "h_1", "w_2", "h_2", "Y", "tau_1", "tau_2", "delta_1", "delta_2", "lambda_1", "lambda_2")

%% generate raw optimal vals
parfor idx = 1:length(hhidvals)

    hhid = cell2mat(hhidvals(idx));
    
    disp(hhid)
    
    % need to grab these from the data
    house_vals = head(hhid,["wage_inc0","wage_inc1", "knlabincly0"]);

    %x_draw = mvnrnd(double(mu), Sigma);
    x_draw = x_draws{hhid,:};
    
    mu_draw = convert(x_draw(1:4))
    
    sub_vars = {"lambda_1", "lambda_2", "delta_1", "delta_2","w_1","w_2","Y"}
    sub_vals = [mu_draw,table2array(house_vals)];

    W_sub = subs(W_C, sub_vars, sub_vals);
    grad_sub = subs(grad_f, sub_vars, sub_vals);
    numObj = matlabFunction(W_sub, grad_sub,"Outputs",{'cost','grad_x'});
    timfun = @(x) numObj(x(1),x(2),x(3),x(4));
    % try to run the minimization with the initial value, change it if unsolvable
    try
		[time_opt,fval] = fminunc(timfun,x0,options);
    catch ER
        disp ER
    end
    household(idx,:) = cat(2,str2double(hhid),time_opt,sub_vals,fval);
    
    disp(strcat("completed: ",hhid))
    % Exploring this output as a parquet
    % because it is so short, this is no longer necessary
    
    % Saving summary stats
    % also no loner necessary
    
    %stats = ["Mean", "Std"];
    %foo = summary(HouseholdDraws);
    %temp.HouseholdId = hhid;
    %for v = vars
    %   for d = stats
    %        %strcat(v,"_",d)
    %        temp.(strcat(v,"_",d)) = foo.(v).(d);
    %    end
    %end

    %ttemp = [true_hours(hhid,:), struct2table(temp)];
    % Save to csv
    
    %writetable(ttemp, strcat(outdir,'/sumstats.csv'),"WriteMode","append");
end
toc
vars = ["hhid","h_1","h_2","tau_1","tau_2", "lambda_1","lambda_2","delta_1","delta_2", "w_1","w_2","Y","fval"];
HouseholdDraws = array2table(household, 'VariableNames',vars);
end