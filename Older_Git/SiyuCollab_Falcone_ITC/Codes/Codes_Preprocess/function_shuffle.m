function st = function_shuffle(st)
    win = st.epoch_window;
    for ci = 1:length(st.cells)
        cl = st.cells{ci};
        tid = unique(cl.trialID);
        for i = 1:length(tid)
            idx = cl.trialID == tid(i);
            tst = cl(idx,:).spiketimes;
            
            tstp = tst(tst > 0);
            if isempty(tstp)
                continue;
            end
            tstn = tst(tst <= 0);
            if isempty(tstn) % tst = tstp
%                 t0 = rand* (tst(1)-0 + win(2) - tst(end)) + 0;
                t0 = tstp(1);
                tstnew = [0;cumsum(W.shuffle(diff(tstp)))] + t0;
            else
%                 t0 = tstn(end);
%                 tstl = [t0; tstp];
%                 tstnew = [cumsum(W.shuffle(diff(tstl)))] + t0;
%                 tstnew = [tstn; tstnew];
                t0 = tstp(1);
                tstnew = [0;cumsum(W.shuffle(diff(tstp)))] + t0;
                tstnew = [tstn; tstnew];
            end
            cl.spiketimes(idx) = tstnew;
        end
        st.cells{ci} = cl;
    end
end