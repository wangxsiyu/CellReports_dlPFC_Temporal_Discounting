function LL = acceptprob(a,b,k, drop, delay)
    DV = comp_DV(k, drop, delay, 'hyperbolic');
    cp = 1./ ( 1 + exp(-a * DV - b));
    LL = nanmean(log(cp));
end