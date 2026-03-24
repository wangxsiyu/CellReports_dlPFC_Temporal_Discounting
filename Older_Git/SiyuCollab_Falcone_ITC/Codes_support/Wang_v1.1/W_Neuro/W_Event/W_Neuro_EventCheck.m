classdef W_Neuro_EventCheck < handle
    methods(Static)
        function [ev1, ev2] = repair_eventcodes(ev1, ev2, eps)
            if ~exist('eps', 'var')
                eps = 1; % 1ms
            end
            if W.check_ismatch_eventcodes(ev1, ev2, eps)
                return;
            end
            t1 = ev1.timestamps;
            t2 = ev2.timestamps;
            n_min = min(n1, n2);
            tm_diff = mean(t1(1:n_min)- t2(1:n_min));
            t2adjusted = t2 + tm_diff;
            if ~(n1 == n2 && max(abs(t1 - t2adjusted)) < eps) % timing does not match
                W.warning('eventmarkers mismatch: adjusting markers by timing');
                % function that checks if each point in t is in t0
                func_tm_match = @(t, t0) arrayfun(@(x)min(abs(x-t0)) < eps, t);
                id_extra = ~func_tm_match(t2adjusted, t1);
                tm_all = sort([t1; t2adjusted(id_extra)]);
                n_total = length(tm_all);
                ev1new = table;
                ev1new.timestamps = NaN(n_total,1);
                ev1new.eventmarkers = NaN(n_total,1);
                ev2new = table;
                ev2new.timestamps = NaN(n_total,1);
                ev2new.eventmarkers = NaN(n_total,1);
                % function that checks where each point in t is in t0,
                % return NaN if a point in t is not in t0
                find_tm_match = @(t, t0) arrayfun(@(x)W.func('min',2,abs(x-t0)), t);
                id1 = find_tm_match(t1, tm_all);
                ev1new.eventmarkers(id1) = ev1.eventmarkers;
                ev1new.timestamps(id1) = t1;
                id2 = find_tm_match(t2adjusted, tm_all);
                ev2new.eventmarkers(id2) = ev2.eventmarkers;
                ev2new.timestamps(id2) = t2;
                ev1 = ev1new;
                ev2 = ev2new;
            end
            if ~all(ev1.eventmarkers == ev2.eventmarkers)
                W.warning('eventmarkers mismatch: reparing possible binary codes');
                [tev] = W.RepairBinaryCode_lists(ev1.eventmarkers, ev2.eventmarkers);
                ev1.eventmarkers = tev;
                ev2.eventmarkers = tev;
            end
        end
        function [ismatch] = check_ismatch_eventcodes(ev1, ev2, eps)
            if ~exist('eps', 'var')
                eps = 1; % 1ms
            end
            n1 = size(ev1,1);
            n2 = size(ev2,1);
            t1 = ev1.timestamps;
            t2 = ev2.timestamps;
            n_min = min(n1, n2);
            tm_diff = mean(t1(1:n_min)- t2(1:n_min));
            t2adjusted = t2 + tm_diff;
            if n1 == n2 && all(ev1.eventmarkers == ev2.eventmarkers) && max(abs(t1 - t2adjusted)) < eps % timing matches
                ismatch = 1;
            else
                ismatch = 0;
            end
        end
    end
end