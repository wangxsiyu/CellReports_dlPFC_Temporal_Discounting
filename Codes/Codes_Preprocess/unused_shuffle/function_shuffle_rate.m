function st = function_shuffle_rate(st)
    for ci = 1:length(st.cells)
        cl = st.cells{ci};
        rates = sum(cl, 2);
        ratesnew = W.shuffle(rates);
        ntrial = size(rates, 1);
        clnew = cl * NaN;
        for i = 1:ntrial
            rold = rates(i);
            rnew = ratesnew(i);
            if rold == 0
                clnew(i,:) = NaN;
            else
                clnew(i,:) = cl(i,:) * rnew / rold;
            end
        end
        st.cells{ci} = clnew;
    end
end