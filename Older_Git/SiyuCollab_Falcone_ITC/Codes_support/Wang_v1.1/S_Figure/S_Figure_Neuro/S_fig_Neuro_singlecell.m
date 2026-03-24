classdef S_fig_Neuro_singlecell < handle
    methods(Static)
        function plt = rasterplot(plt, spikes, varargin)
            % This function takes N spike trains and displays them
            % varargin can contain x-lim
            if ~iscell(spikes) && ~istable(spikes)
                error('The input argument should be a cell array or a table');
            end
            width = 0.4;
            if iscell(spikes)
                y = [];
                x = [];
                for i = 1:length(spikes)
                    x = [x, W.horz(spikes{i})];
                    y = [y, i*ones(1,length(spikes{i}))];
                end
                ntrials = length(spikes);
            else
                x = W.horz(spikes.spiketimes);
                y = W.horz(spikes.trialID);
                ntrials = max(y);
            end
            err = width*ones(size(x));
            plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', 'black', ...
                'CapSize', 0, 'MarkerSize', 1);
            plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 ntrials+1], varargin{:});
        end
    end
end