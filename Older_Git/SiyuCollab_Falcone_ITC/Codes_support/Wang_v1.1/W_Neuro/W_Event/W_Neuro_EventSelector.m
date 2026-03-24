classdef W_Neuro_EventSelector < handle
    methods(Static)
        %% get timestamps by marker
        function tm = event_get_timestamps_by_marker(trials, event_time0, event_ord)
            template = trials.event_template;
            if iscell(template)
                id_col = cellfun(@(x)any(ismember(x, event_time0)), template);
            else
                id_col = any(ismember(template, event_time0));
            end
            id_col = find(id_col, event_ord, 'first');
            if length(id_col) ~= event_ord
                W.warning('epoch: event %d at event_ord %d does not exist, check!', event_time0, event_ord);
                return;
            end
            id_col = id_col(end);
            idx_lb = ismember(trials.events.eventmarkers(:, id_col), event_time0);
            tm = nan(length(idx_lb),1);
            tm(idx_lb) = trials.events.timestamps(idx_lb, id_col);
        end
        %% get eventmarker indices
        function [output] = eventmarker2names(markers, varargin)
            if isstruct(markers) && isfield(markers, 'event_template')
                findid = @(x)find(cellfun(@(t)any(ismember(x, t)), markers.event_template));
                timestamps = markers.events.timestamps;
                markers = markers.events.eventmarkers;
            else
                findid = @(x)find(arrayfun(@(t)any(ismember(x, markers(:,t))), 1:size(markers,2)));
                timestamps = [];
            end
            vars = W.varargin2struct(varargin{:});
            fnms = fieldnames(vars);
            output = W.varargin2struct('idx_col', struct, 'idx_marker', table, 'selected_marker', table);
            if ~isempty(timestamps)
                output.selected_timestamps = table;
            end
            for i = 1:length(fnms)
                fn = fnms{i};
                tid = findid(vars.(fn));
                output.idx_col.(fn) = tid;
                ismk = ismember(markers(:, tid), vars.(fn));
                output.idx_marker.(fn) = ismk;
                tmk = markers(:, tid);
                tmk(~ismk) = NaN;
                output.selected_marker.(fn) = tmk;

                if ~isempty(timestamps)
                    ttm = timestamps(:, tid);
                    ttm(~ismk) = NaN;
                    output.selected_timestamps.(fn) = ttm;
                end
            end
        end
    end
end