classdef W_Neuro_Epoch_SpikeBinning < handle
    methods(Static)
        %% using designated format
        function out = epoch_spikebinning_by_marker(spikes, trials, event_time0, event_ord, varargin)
            if isempty(spikes) || isempty(trials)
                out = [];
                return;
            end
            tm = W.event_get_timestamps_by_marker(trials, event_time0, event_ord);
            [opt, vars] = W.struct_set_endoptions(W.struct('filter_appearance', false), varargin{:});
            out = W.epoch_spikebinning(spikes.cells, tm, vars{:});
            out.info_cells = spikes.info_cells;
            out.info_session = spikes.info_session;

            if opt.filter_appearance
                tm_range = W.cellfun_vertcat(@(x)[min(x), max(x)], spikes.cells);
                for i = 1:length(out.cells)
                    ntrial = size(out.cells{i});
                    i1 = find(any(tm_range(i,1) <= trials.events.timestamps, 2), 1);
                    i2 = find(any(tm_range(i,2) >= trials.events.timestamps, 2), 1, 'last');
                    is_not_appear = setdiff(1:ntrial, i1:i2);
                    out.cells{i}(is_not_appear,:) = NaN;
                end
            end
        end
        %% epoch all cells
        function out = epoch_spikebinning(spikes, t0, tat, twin)
            spikes = W.encell(spikes);
            ncell = length(spikes);
            cells = cell(1, ncell);
            for ci = 1:ncell
                W.print('epoching spikes %d/%d', ci, ncell);
                [cells{ci}] = W.epoch_spikebinning_cell(spikes{ci}, t0, tat, twin);
            end
            out = W.struct('cells', cells, 'time_at', tat, 'time_win', twin);
        end
        %% epoch single cell
        function [x] = epoch_spikebinning_cell(spikes, t0, tat, twin)
            % st - spike train
            % t0 -  time 0 for each trial
            % tat - time points around t0
            % twin - count firing in twin around tat
            [st] = W.epoch_spiketrains_cell(spikes, t0, min(tat) - twin/2, max(tat) + twin/2);
            ntrial = length(st);
            nbin = length(tat);
            x = zeros(ntrial, nbin);
            t1 = tat - twin/2;
            t2 = tat + twin/2;
            for i = 1:ntrial
                tst = st{i};
                x(i,:) = arrayfun(@(x)sum(tst >= t1(x) & tst < t2(x)) , 1:nbin);
                x(i,nbin) = sum(tst >= t1(nbin) & tst <= t2(nbin));
            end
            x(isnan(t0),:) = NaN;
        end
    end
end