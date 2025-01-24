function st = function_shuffle_rate(st, games)
    for ci = 1:length(st.cells)
        cl = st.cells{ci};
        conds = unique(games.condition);
        ncond = length(conds);
        ntrial = size(games,1);
        rates = W.arrayfun(@(x)sum(cl.trialID == x), 1:ntrial);
        ratesnew = W.shuffle(rates);

        clnew = table;
        for i = 1:ntrial
            rold = rates(i);
            rnew = ratesnew(i);
            if rnew == 0 || rold == 0
                continue;
            end
            tt = cl.spiketimes(cl.trialID == i);
            if rnew < rold
                tspikes = sort(randsample(tt,rnew));
            elseif rnew == rold
                tspikes = tt;
            elseif rnew > rold
                tq = floor(rnew/rold);
                tr = rnew - rold * tq;
                tspikes = sort([randsample(tt,tr); repmat(tt, tq, 1)]);
            end
            ttab = W.table('trialID',ones(rnew,1) * i,'spiketimes', tspikes);
            clnew = W.tab_vertcat(clnew, ttab);
        end

%         times = cell(1, ncond);
%         for i = 1:ncond
%             tid = find(games.condition == conds(i));
%             tcl = cl(ismember(cl.trialID, tid),:);
%             times{i} = tcl.spiketimes;
%         end
%         clnew = table;
%         for i = 1:ntrial
%             tr = rates(i);
%             if tr == 0
%                 continue;
%             end
%             tc = games.condition(i);
%             tt = times{tc};
%             if tr <= length(tt)
%                 tspikes = sort(randsample(tt,tr));
%             else
%                 tspikes = sort(randsample(tt,tr, true));
%             end
%             ttab = W.table('trialID',ones(tr,1) * i,'spiketimes', tspikes);
%             clnew = W.tab_vertcat(clnew, ttab);
%         end
        st.cells{ci} = clnew;
    end
end