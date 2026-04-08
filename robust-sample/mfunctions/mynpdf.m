function d = mynpdf(x,mu,Sigma)
    d = (norm(Sigma) * (2*pi)^height(x))^(-0.5) *exp(-0.5*(x-mu)'*(Sigma^-1)*(x-mu)) ;
end