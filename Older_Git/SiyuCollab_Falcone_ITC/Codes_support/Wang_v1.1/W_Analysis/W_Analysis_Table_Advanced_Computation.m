classdef W_Analysis_Table_Advanced_Computation < handle
    methods(Static)
        function gp = tab_autoaverage(sub, switch_paircompare, additional_compare, suffix_compare)
            if ~exist('switch_paircompare', 'var') || isempty(switch_paircompare)
                switch_paircompare = true;
            end
            if ~exist('additional_compare', 'var') || isempty(additional_compare)
                additional_compare = {};
            end
            if ~exist('suffix_compare', 'var') || isempty(suffix_compare)
                suffix_compare = [];
            end
            gp = struct;
            sub = W.tab_autofieldcombine(sub);
            sub = W.tab_denested(sub, true);
            fnms = W.fieldnames(sub);
            for fi = 1:length(fnms) % ex. regular av/se
                fn = char(fnms(fi));
                td = sub.(fn);
                if isnumeric(td) || islogical(td)
                    [gp.(['GPav_' fn]), gp.(['GPse_' fn])] = W.avse(td);
                    % pvalue of pairs
                    if switch_paircompare && size(td,2) == 2 % compare any two column fields
                        [gp.(['GPpval_' fn]), gp.(['GPtstat_' fn]), gp.(['GPcohend_' fn])] = ...
                            W.stat_ttest(td(:,1), td(:,2), 'paired');
                    end
                elseif (iscell(td) && all(cellfun(@(x)isnumeric(x) || islogical(x), td), 'all'))
                    for tyi = 1:size(td,2) % loop over columns of cells
                        [nx, ny] = size(td{1,tyi});
                        issamesz = cellfun(@(x) size(x,1) == nx && size(x,2) == ny, td(:, tyi));
                        if any(~issamesz)
                            W.warning('ignored %s[%d], cells of different size', fn, tyi);
                            continue;
                        end
                        [gp.(['GPav_' fn]){tyi}, gp.(['GPse_' fn]){tyi}] = W.cell_avse(td(:, tyi));
                    end
                elseif size(W.unique(td, 'rows'),1) == 1 % all elements are the same
                    gp.(fn) = W.unique(td, 'rows');
%                 elseif ~any(strcmpi(fn, {'filename','time','comment','csv_filename','subjectid'}))
%                     W.warning(sprintf('ignored %s, format not supported', fn));
                end
            end
            for ai = 1:length(additional_compare) % ex. _h1 vs _h6
                tfn = W.encell(additional_compare{ai});
                tds =  W.cellfun(@(x)sub.(x), tfn, false);
                isnums =  cellfun(@(x)isnumeric(x) || islogical(x), tds);
                if ~all(isnums)
                    continue;
                end
                if length(tds) == 2
                    tpval = NaN(1, size(tds{1},2));
                    tstat = NaN(1, size(tds{1},2));
                    tcohend = NaN(1, size(tds{1},2));
                    for ci = 1:size(tds{1},2)
                        [tpval(ci), tstat(ci), tcohend(ci)] = W.stat_ttest(tds{1}(:,ci), tds{2}(:,ci), 'paired');
                    end
                    gp.(['GPpval_', strjoin(tfn,'_vs_')]) = tpval;
                    gp.(['GPtstat_', strjoin(tfn,'_vs_')]) = tstat;
                    gp.(['GPcohend_', strjoin(tfn,'_vs_')]) = tcohend;
                elseif length(tds) == 1
                    tds = tds{1};
                    tpval = NaN(1, size(tds,2));
                    tstat = NaN(1, size(tds,2));
                    tcohend = NaN(1, size(tds,2));
                    for ci = 1:size(tds,2)
                        [tpval(ci), tstat(ci), tcohend(ci)] = W.stat_ttest(tds(:, ci), [], 'onesample');
                    end
                    gp.(['GPpval_', tfn{1},'_vs0']) = tpval;
                    gp.(['GPtstat_', tfn{1},'_vs0']) = tstat;
                    gp.(['GPcohend_', tfn{1},'_vs0']) = tcohend;
                else
                    W.warning('>2 variables comparison has not been implemented here, to be done');
                end
            end
            for ai = 1:length(suffix_compare) % ex. _h1 vs _h6
                tfn0 = char(suffix_compare{ai});
                tfn = fnms(contains(fnms, [tfn0 '_' ]));
                ntfn0 = length(tfn0);
                tfn = tfn(cellfun(@(x)strcmp(x(1:ntfn0), tfn0), tfn));
                tds =  W.cellfun(@(x)sub.(x), tfn, false);
                isnums =  cellfun(@(x)isnumeric(x) || islogical(x), tds);
                if ~all(isnums)
                    W.print('suffix compare: not all numeric, ignored: %s', tfn0);
                    continue;
                end
                if length(tds) == 2
                    tpval = NaN(1, size(tds{1},2));
                    tstat = NaN(1, size(tds{1},2));
                    tcohend = NaN(1, size(tds{1},2));
                    for ci = 1:size(tds{1},2)
                        [tpval(ci), tstat(ci), tcohend(ci)] = W.stat_ttest(tds{1}(:,ci), tds{2}(:,ci), 'paired');
                    end
                else
                    tpval = [];
                    tstat = [];
                    tcohend = [];
                    W.warning('ANOVA has not been implemented here, to be done');
                end
                gp.(['GPpval_suffix_' tfn0]) = tpval;
                gp.(['GPtstat_suffix_' tfn0]) = tstat;
                gp.(['GPcohend_suffix_' tfn0]) = tcohend;
            end
            gp = struct2table(gp);
            gp.GPn_subject = size(sub,1);
        end
    end
end