function moments = moms(s)
    moments = table();
    % avg_h1
    moments.avg_h1 = mean(s.h_1);
    % avg_h2
    moments.avg_h2 = mean(s.h_2);
    % avg_tau1
    moments.avg_tau1 = mean(s.tau_1);
    % avg_tau2
    moments.avg_tau2 = mean(s.tau_2);
    % sd_h1
    moments.sd_h1 = std(s.h_1);
    % sd_h2
    moments.sd_h2 = std(s.h_2);
    % sd_tau1
    moments.sd_tau1 = std(s.tau_1);
    % sd_tau2
    moments.sd_tau2 = std(s.tau_2);
    % avg_h1h2
    moments.avg_h1h2 = dot(s.h_1,s.h_2)/height(s);
    % avg_h1Y
    moments.avg_h1Y = dot(s.h_1,s.Y)/height(s);
    % avg_h2Y
    moments.avg_h2Y = dot(s.h_2,s.Y)/height(s);
    % avg_h1w1
    moments.avg_h1w1 = dot(s.h_1,s.w_1)/height(s);
    % avg_h2w2
    moments.avg_h2w2 = dot(s.h_2,s.w_2)/height(s);
    % avg_tau1Y
    moments.avg_tau1Y = dot(s.tau_1,s.Y)/height(s);
    % avg_tau2Y
    moments.avg_tau2Y = dot(s.tau_2,s.Y)/height(s);
    % avg_h1w2
    moments.avg_h1w2 = dot(s.h_1,s.w_2)/height(s);
    % avg_h2w1
    moments.avg_h2w1 = dot(s.h_2,s.w_1)/height(s);
    % avg_h1 >= 40
    moments.avg_h1GT40 = mean(s.h_1>=40);
    % avg_h2 >= 40
    moments.avg_h2GT40 = mean(s.h_2>=40);
    % avg_h1 >= 25 & 40 > h1
    moments.avg_40GTh1GTE25 = mean(and(s.h_1<40, s.h_1>=25));
    % avg_h2 >= 25 & 40 > h2
    moments.avg_40GTh2GTE25 = mean(and(s.h_2<40, s.h_2>=25));

end