function DV = comp_DV(k, drop, delay, option)
    switch option
        case 'hyperbolic'
            DV = drop./(1 + k * delay);
        case 'exponential'
            DV = drop./exp(k * delay);
    end
end