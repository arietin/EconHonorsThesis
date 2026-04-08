function out = test(func_f, y_int)
    rng("default")
    num = rand(1,7)
    
    f_sub = subs(func_f,{"lambda_1", "lambda_2", "delta_1", "delta_2","w_1","w_2","Y"},num)
    out = f_sub(y_int(1),y_int(2),y_int(3),y_int(4))
end