classdef W_Analysis_CellMath < handle
    methods(Static)
        function [av, se, n] = cell_avse(a, ismedian, varargin)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ismedian
                [av, n] = W.cell_median(a, varargin{:});
                se = NaN * n;
            else
                [av, n] = W.cell_mean(a, varargin{:});
                [se, ~] = W.cell_se(a, varargin{:});
            end
        end
        function [b, n] = cell_mean(a, varargin)
            [b, n] = W.cell_sum(a, varargin{:});
            b = b./n;
        end
        function [b, n] = cell_se(a, varargin)
            [b, n] = W.cell_sd(a, varargin{:});
            b = b./sqrt(n);
        end
        function [b, n] = cell_sum(a, opt_nan)
            if ~exist('opt_nan', 'var') || isempty(opt_nan)
                opt_nan = 'omitnan';
            end
            a = W.encell(a);
            if isequal(opt_nan, 'omitnan')
                idnotnan = W.cellfun(@(x)~isnan(x), a, false);
                a = W.cellfun(@(x)W.changem(x, 0, NaN), a, false);
            else
                idnotnan = W.cellfun(@(x)ones(size(x)), a, false);
            end
            b = a{1};
            n = idnotnan{1} + 0;
            for i = 2:length(a)
                b = b + a{i};
                n = n + idnotnan{i};
            end
        end
        function [b, n] = cell_sd(a, varargin)
            [av, n] = W.cell_mean(a, varargin{:});
            ss = W.cell_sum(W.cellfun(@(x) (x- av).^2, a, false), varargin{:});
            ss = ss./(n - 1);
            b = sqrt(ss);
        end
        function [mid, n] = cell_median(a, varargin)
            sz = size(a{1});
            mid = NaN(sz);
            n = NaN(sz);
            for i = 1:sz(1)
                for j = 1:sz(2)
                    td = cellfun(@(x)x(i,j), a);
                    n(i,j) = sum(~isnan(td), 'all');
                    mid(i,j) = median(td, 'all', 'omitnan');
                end
            end
        end
        
    end
end