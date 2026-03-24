classdef W_Neuro_Epoch_SpikeTrains < handle
    methods(Static)
        %% using designated format
        function out = epoch_spiketrains_by_marker(spikes, trials, event_time0, event_ord, varargin)
            if isempty(spikes) || isempty(trials)
                out = [];
                return;
            end
            tm = W.event_get_timestamps_by_marker(trials, event_time0, event_ord);
            out = W.epoch_spiketrains(spikes.cells, tm, varargin{:});
            out.info_cells = spikes.info_cells;
            out.info_session = spikes.info_session;
        end
        %% epoch all cells
        function out = epoch_spiketrains(spikes, t0, t_pre, t_post, varargin)
            nunits = length(spikes);
            cells = cell(1,nunits);
            for si = 1:nunits
                W.print('epoching spikes %d/%d', si, nunits);
                [cells{si}] = W.epoch_spiketrains_table(spikes{si}, t0, t_pre, t_post, varargin{:});
            end
            out = W.struct('cells', cells, 'epoch_window', [t_pre t_post]);
        end
        %% epoch single cell
        function [x] = epoch_spiketrains_cell(st, t0, tpre, tpost, compression_ndigit)
            % st - spike train
            % t0 - time 0 for each trial
            ntrial = length(t0);
            st = W.vert(st);
            t0 = W.vert(t0);
            t1 = t0 + tpre;
            t2 = t0 + tpost;
            x = W.arrayfun(@(x)st(st >= t1(x) & st <= t2(x)) - t0(x), 1:ntrial, false);
            if exist('compression_ndigit', 'var') && ~isempty(compression_ndigit)
                x = W.cellfun(@(x)round(x, compression_ndigit), x, false);
            end
        end   
        function [x] = epoch_spiketrains_table(varargin)
%             if length(varargin) == 1 % if not spiketrains_cell
%                 x = varargin{1};
%             else
            [x] = W.epoch_spiketrains_cell(varargin{:});
%             end
            id = W.arrayfun(@(i)ones(size(x{i})) * i, 1:length(x), false);
            x = table(vertcat(id{:}), vertcat(x{:}), 'VariableNames',{'trialID', 'spiketimes'});
        end
    end
end