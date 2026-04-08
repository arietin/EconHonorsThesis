function mu_draw= convert(x_draw)
    mu_1 = 1/(1+exp(-x_draw(1)));
    mu_2 = 1/(1+exp(-x_draw(2)));
    mu_3 = exp(x_draw(3))/(1+exp(x_draw(3))+exp(x_draw(4)));
    mu_4 = exp(x_draw(4))/(1+exp(x_draw(3))+exp(x_draw(4)));
    mu_draw = [mu_1, mu_2, mu_3, mu_4];
end