classdef W_Analysis_Bin < handle
    methods(Static)
        function out = bin_average_tab(tab, X, Ys, binx, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            X = tab.(X);
            b2 = W.bin_1to2(binx);
            bm = W.bin_middle(binx);
            out = W.table('B1', b2(:,1), 'B2', b2(:,2), 'x', W.vert(bm));
            Ys = W.string(Ys);
            for i = 1:length(Ys)
                fn = Ys(i);
                strY = upper(fn);
                if ~W.tab_isfield(tab, fn)
                    W.print('field does not exist: %s', fn);
                    continue;
                end
                [tav, tse, tnum] = ...
                    W.bin_avY_byX(tab.(fn), X, binx, ismedian);
                nam = W.iif(ismedian, 'mid', 'av');
                out.(strcat(nam, strY)) = W.vert(tav);
                if ~ismedian
                    out.(strcat('se',strY)) = W.vert(tse);
                end
                out.(strcat('n',strY)) = W.vert(tnum);
            end
            out = W.tab_horz_if_1D(out);
        end
        function [av, se, num] = bin_avY_byX(y, x, binx, ismedian)
            % only works for 1-D y and x
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ~exist('x', 'var') || isempty(x)
                x = 1:length(y);
            end
            y = W.vert(y);
            binx = W.bin_1to2(binx);
            nbin = size(binx,1);
            num = NaN(1, nbin);
            av = NaN(1, nbin);
            se = NaN(1, nbin);
            for bi = 1:nbin
                idx = x >= binx(bi,1) & x < binx(bi,2);
                if ~any(idx)
                    num(bi) = 0;
                else
                    [av(bi), se(bi), num(bi)] = W.avse(y(idx), ismedian);
                end
            end
        end
        function [sm, num] = bin_sumY_byX(varargin)
            [av, ~, num] = W.bin_avY_byX(varargin{:});
            sm = av .*num;
        end
        function bin = bin_1to2(bin)
            if size(bin,1) > 1 && size(bin,2) > 1
                return;
            end
            bin = horzcat(W.vert(bin(1:end-1)), W.vert(bin(2:end)));
        end
        function out = bin_middle(bin)
            bin = W.bin_1to2(bin);
            out = W.horz(mean(bin, 2));
        end
    end
end