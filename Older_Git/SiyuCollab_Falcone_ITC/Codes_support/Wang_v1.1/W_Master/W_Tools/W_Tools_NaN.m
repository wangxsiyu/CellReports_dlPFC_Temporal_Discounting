classdef W_Tools_NaN < handle
    methods(Static)
        %% nan - changem
        function a = changem(a, new, old)
            if ~exist('old', 'var') || isempty(old)
                old = NaN;
            end
            idnan = isnan(old);
            assert(sum(idnan) <= 1); % should not be more than 1 NaN in old
            if any(idnan)
                a(isnan(a)) = new(idnan);
            end
            if exist('changem', 'file')
                a = changem(a, new(~idnan), old(~idnan));
            else
                aold = a;
                new = new(~idnan);
                old = old(~idnan);
                for i = 1:length(new)
                    a(aold == old(i)) = new(i);
                end
            end
        end
        %% nan - select array
        function out = nan_array_select(a, varargin)
            id = [varargin{:}];
            dtype = class(a);
            out = W.create_dtype(dtype, [size(id)]);
            tid = ~isnan(id);
            out(tid) = a(id(tid));
        end
        %% nan - exclude NaNs in front and end of a 1-D array
        function [a0, tid] = nan_exclude_prepost(a)
            bound1 = find(diff(isnan(a)) == -1, 1);
            if isempty(bound1)
                bound1 = 0;
            end
            bound2 = find(diff(isnan(a)) == 1, 1, 'last') + 1;
            if isempty(bound2)
                bound2 = length(a) + 1;
            end
            tid = [bound1+1:bound2-1];
            a0 = a(tid);
        end
        %% NaNs - equal
        function out = nan_equal(a, b)
%             a = W.horz(a);
%             b = W.horz(b);
            out = 0 + (a == b);
            tid = isnan(a) | isnan(b);
            out(tid) = NaN;
        end
    end
end