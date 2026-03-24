classdef W_Neuro_Events2Trials < W_Neuro_RepairBinaryCodes
    methods(Static)
        function output = events2trials(events, template, mkignore, varargin)
            fnms = W.fieldnames(events);
            tid = find(contains(fnms, 'event'));
            if length(tid) == 1
                fn = fnms(tid);
            else
                fn = "eventmarkers";
                assert(ismember(fn, fnms));
            end
            
            if exist('mkignore', 'var') && ~isempty(mkignore)
                id_ignore = ismember(events.(fn), mkignore);
                if any(id_ignore)
                    W.print('#%d markers ignored, %.2f %%', sum(id_ignore), 100 * mean(id_ignore));
                    events = events(~id_ignore,:);
                end
            end

            [events.(fn), trialID, pos_event] = W.events2template(events.(fn), template, varargin{:});
            
            ntrial = max(trialID);
            nevent = length(pos_event);
            nmks = length(template);
            events = W.tab_decombine(events);

            W.print('converting events to trials');
            tab = table;
            
            for fi = 1:length(fnms)
                fn = fnms{fi};
                if (W.is_stringorchar(events.(fn)) || iscell(events.(fn))) && ...
                        (length(unique(events.(fn))) == 1) 
                    % assuming char/cell of chars
                    tab.(fn) = repmat(unique(events.(fn)), ntrial, 1);
                else
                    if isnumeric(events.(fn))
                        tab.(fn) = NaN(ntrial, nmks);
                    else
                        tab.(fn) = repmat("",ntrial, nmks);
                    end
                    for i = 1:nevent
                        if ~isnan(pos_event(i))
                            tab.(fn)(trialID(i), pos_event(i)) = events.(fn)(i);
                        end
                    end
                end
            end
            tab = W.tab_fill_ID(tab, 'trialID');
            output = W.struct('events', tab, 'event_template', template);    
        end
        function [events, trialID, pos_event] = events2template(events, template, usenext, is_fix_bin)
            if ~exist('usenext', 'var') || isempty(usenext)
                usenext = [];
            end
            if ~exist('is_fix_bin', 'var') || isempty(is_fix_bin) % fix binary code errors
                is_fix_bin = true;
            end
            % this function can't deal with cases where almost an entire trial is
            % missing. (for example, cases where a marker in a previous trial is
            % followed by the next marker in the next trial).
            W.print('matching eventmarkers to template');
            events = W.vert(events);
            nevent = length(events);
            nmks = length(template);
            pos_event = NaN(nevent, 1);
            % find which bins each marker belongs to
            findbins = @(x, mks)find(cellfun(@(t)ismember(x, t), mks));
            bins = W.arrayfun(@(x)findbins(x, template), events, false);
            id_1bin = W.cell_length(bins) == 1;
            pos_event(id_1bin) = [bins{id_1bin}];
            flag_repeat = any(isnan(pos_event));
            while flag_repeat
                id_tofill = W.get_consecutive0(~isnan(pos_event)); 
                % check every consecutive segments
                for ii = 1:size(id_tofill,1) 
                    st = id_tofill.start(ii);
                    ed = id_tofill.end(ii);
                    ln = id_tofill.duration(ii);
                    ev = events(st:ed);
                    if st-1 == 0
                        pos1 = 1;
                    else
                        pos1 = W.cycle_fwd(pos_event(st-1), nmks);
                    end
                    if ed+1 > nevent
                        pos2 = nmks;
                    else
                        pos2 = W.cycle_bwd(pos_event(ed+1), nmks);
                    end
                    tps0 = W.cycle_arange(pos1, pos2, nmks);
                    tmks0 = template(tps0);

                    assert(length(tmks0) >= ln);

                    isupdate = false;

                    % check if any code seems to be incomplete
                    id0 = find(W.cell_length(bins(st:ed)) == 0);
                    for jjj = 1:length(id0)
                        jj = id0(jjj);
                        if is_fix_bin
                            [ismatch, tcode] = W.RepairBinaryCode_isamong(ev(jj), unique([tmks0{:}]));
                        else
                            ismatch = 0;
                        end
                        if sum(ismatch) == 1
                            isupdate = true;
                            ev(jj) = tcode;
                            bins{st+jj-1} = findbins(tcode, template);
                            events(st+jj-1) = tcode;
                        elseif sum(ismatch) == 0 % zero match
                            W.warning('extra code: %d', ev(jj));
                        end
                    end
                    % check if there happens to be ln events
                    if length(tmks0) == ln
                        for jj = 1:ln
                            if ismember(ev(jj), tmks0{jj})
                                isupdate = true;
                                pos_event(st+jj-1) = tps0(jj);
                            else
                                if is_fix_bin
                                    [ismatch, tcode] = W.RepairBinaryCode_isamong(ev(jj), tmks0{jj});
                                else
                                    ismatch = 0;
                                end
                                if sum(ismatch) == 1
                                    isupdate = true;
                                    ev(jj) = tcode;
                                    bins{st+jj-1} = findbins(tcode, template);
                                    events(st+jj-1) = tcode;
                                    pos_event(st+jj-1) = tps0(jj);
                                elseif sum(ismatch) == 0 % zero match
                                    W.warning('extra code: %d', ev(jj));
                                else
                                    W.warning('code %d has more than 2 matches for potential repair, ignored', ev(jj));
                                    disp(tmks0{jj}(ismatch));
                                end
                            end
                        end
                    end

                    % check if there are any single matches
                    for jj = 1:ln
                        tid = find(cellfun(@(x)ismember(ev(jj), x), tmks0));
                        if length(tid) == 1
                            isupdate = true;
                            pos_event(st+jj-1) = tps0(jj);
                        end
                    end

                    if isupdate
                        continue;
                    end

                    tps = tps0(ismember(tps0, unique([bins{st:ed}])));
                    tmks = template(tps);

                    % check if there happen to be ln matches (this assumes
                    % binary codes are all complete)
                    if length(tmks) == ln
                        ismatch_consecutive_in_template = all(arrayfun(@(x)ismember(ev(x), tmks{x}), 1:ln));
                        if ismatch_consecutive_in_template
                            % perfectly match
                            pos_event(st:ed) = tps(1:ln);
                        else
                            W.error('this should not happen, check! marker doesn''t match with template');                               
                            pause;
                        end
                    else
                        assert(length(tmks) > ln);
                        % loop over every marker
                        kk = 1;
                        for jj = 1:ln 
                            tid_ev = find(cellfun(@(x)ismember(ev(jj), x), tmks(kk:end))) + kk - 1;
                            if ismember(ev(jj), usenext)
                                tid_ev = tid_ev(1);
                            end
                            if length(tid_ev) == 1 % unique placement, or usenext
                                pos_event(st + jj - 1) = tps(tid_ev);
                                kk = tid_ev + 1;
                            elseif length(tid_ev) == 0
                                W.error('this should not happen, check! marker doesn''t match with template');
                                pause;
                            elseif length(tid_ev) > 1
                                W.warning('check: markers do not uniquely map to template, more than 1 position is possible');
                                pause;
                            end
                        end
                    end
                end
                flag_repeat = any(isnan(pos_event));
            end
            % - calc trialID ----------------------------------------------
            trialID = zeros(nevent,1);
            id_trialstart = [0; find(diff(pos_event) < 0)] + 1;
            trialID(id_trialstart) = 1;
            trialID = cumsum(trialID);
        end
    end
end