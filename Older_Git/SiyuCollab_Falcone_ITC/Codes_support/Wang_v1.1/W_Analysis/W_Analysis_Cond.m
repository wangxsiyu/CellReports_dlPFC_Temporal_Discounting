classdef W_Analysis_Cond < handle
    methods(Static)
        %% table average by cond
        function out = cond_average_tab(tab, cond, Ys, ismedian, varargin)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            cond = W.str2cell(cond);
            [conds, out] = W.tab_getcombinedID(tab, cond);
            out = unique(out);
            condID = out.combinedID;
            Ys = W.string(Ys);
            for i = 1:length(Ys)
                fn = Ys(i);
                strX = upper(fn);
                if ~W.tab_isfield(tab, fn)
                    W.print('field does not exist: %s', fn);
                    continue;
                end
                [tav, tse, tnum] = ...
                    W.cond_average(tab.(fn), conds, condID, ismedian);
                nam = W.iif(ismedian, 'mid', 'av');
                out.(strcat(nam,strX)) = W.vert(tav);
                if ~ismedian
                    out.(strcat('se',strX)) = W.vert(tse);
                end
                out.(strcat('n',strX)) = W.vert(tnum);
            end
            if length(cond) == 1
                out = W.tab_horz_if_1D(out);
            end
        end
        %% average by cond
        function [av, se, num] = cond_average(x, cond, condnames, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ~exist('condnames', 'var') || isempty(condnames)
                condnames = unique(cond);
            end
            ngroup = length(condnames); 
            av = NaN(ngroup, size(x,2));
            se = NaN(ngroup, size(x,2));
            num = NaN(ngroup, size(x,2));
            x = W.vert(x);
            for i = 1:ngroup
                tid = cond == condnames(i);
                [av(i,:), se(i,:), num(i,:)] = W.avse(x(tid,:), ismedian);
            end
            av = W.horz(av);
            se = W.horz(se);
            num = W.horz(num);
        end
        %% count cond
        function n = count_cond(cond, condnames)
            if ~exist('condnames', 'var') || isempty(condnames)
                condnames = unique(cond);
            end
            n = W.arrayfun(@(x)sum(cond == x), condnames);
            n = W.horz(n);
        end
        %% cond2ID
        function id = cond2id(cond, condnames)
            if ~exist('condnames', 'var') || isempty(condnames)
                condnames = unique(cond);
            end
            id = W.arrayfun(@(x)find(condnames == x), cond);
        end
        %% cell versions
%                 av = {};
%                 se = {};
%                     [av{i}, se{i}] = W.cell_avse(x(cond == i,:), ismedian);
%                     num = [];             
    end
end