classdef W_Analysis_Consecutives < handle
    methods(Static)
        %% get consecutives table
        function y = get_consecutives(x)
            vs = unique(x);
            y = table;
            for vi = 1:length(vs)
                ty = W.get_consecutive0(x ~= vs(vi));
                ty = W.tab_fill(ty, 'label', vs(vi));
                y = vertcat(y, ty);
            end
            y = sortrows(y,2);
        end
        function out = get_consecutive0(x)
            out = table;
            trow = find(x==0);
            if isempty(trow)
                out.start = NaN;
                out.end = NaN;
                out.duration = NaN;
            elseif length(trow) == 1
                out.start = trow;
                out.end = trow;
                out.duration = 1;
            else
                tjump = W.vert(find(diff(trow) > 1));
                if isempty(tjump)
                    out.start = trow(1);
                    out.end = trow(end);
                    out.duration = length(trow);
                else
                    tstart = [0; tjump] + 1;
                    out.duration = W.vert(diff([tstart; length(trow)+1]));
                    out.start = W.vert(trow(tstart));
                    out.end = out.start + out.duration -1;
                end
            end
        end
    end
end