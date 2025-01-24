function out = getspan(curve, t0, thres)
    isover = curve >= thres;
    i = t0;
    while i+1 <= length(curve) && isover(i+1) 
        i = i + 1;
    end
    j = t0;
    while j-1 >= 1 && isover(j-1)
        j = j - 1;
    end
    out = [j, i];
end