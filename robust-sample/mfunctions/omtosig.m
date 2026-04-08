function Sigma = omtosig(Sig)
lt = tril(reshape(1:16,[4,4]));
mask = lt(lt ~=0);
C = changem(lt, Sig,mask.').';
Sigma = C.'*C;
end