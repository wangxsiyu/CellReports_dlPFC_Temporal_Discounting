classdef W_Analysis_Stats < handle
    properties
    end
    methods(Static)
        function [p, tstat, d, allstats] = stat_ttest(x, y, ttesttype, varargin)
            if ~exist('y', 'var') || isempty(y)
                y = [];
                ttesttype = 'onesample';
            end
            if ~exist('ttesttype', 'var') || isempty(ttesttype)
                ttesttype = 'independent';
            end
            W.library('tools_cohend');
            switch ttesttype
                case 'onesample'
                    [~, p, ~, tstat] = ttest(x, [], varargin{:});
                    d = NaN;
                case 'independent'
                    [~, p, ~, tstat] = ttest2(x, y, varargin{:});
                    d = computeCohen_d(x, y, 'independent');
                case 'paired'
                    [~, p, ~, tstat] = ttest(y-x, varargin{:});
                    d = computeCohen_d(x, y, 'paired');
            end
            tstat = tstat.tstat;
            allstats = struct('p', p, 't', tstat, 'cohend', d);
        end
        function [r, p, str] = stat_cor(x, y)
            d = [x, y];
            d = d(~isnan(x) & ~isnan(y), :);
            [r, p] = corr(d(:,1), d(:,2));
            str = sprintf('R = %.2f, p = %.2f', r, p);
        end
        function result = anovan(varargin)
            [tp_factor, tb, tstats] = anovan(varargin{:});
            result.p_factors = tp_factor;
            result.coef_factors_terms = tstats.coeffs;
            result.name_factors = W.horz(W.string(tb(2:end-2,1)));
            result.name_factors_terms = tstats.coeffnames;

%             ssq = [tb{2:end-2, 2}];
            df = [tb{2:end-2, 3}];
            msq = [tb{2:end-2, 5}];
            sse = tb{end-1, 2};
            mse = tb{end-1, 5};
            sst = tb{end, 2};
            nfactor = length(df);
            w2 = nan(1, nfactor);
            for i = 1:nfactor
                w2(i) = df(i) * (msq(i) - mse)/(sst + mse);
            end
            result.w2_factors = W.vert(w2);
            result.r2 = (sst - sse)/sst;
        end
    end
end