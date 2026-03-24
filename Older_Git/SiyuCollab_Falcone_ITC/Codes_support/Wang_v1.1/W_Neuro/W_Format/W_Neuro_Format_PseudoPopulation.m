classdef W_Neuro_Format_PseudoPopulation < handle
    methods(Static)
        function out = pseudo_sampletrials_bycond(cells, cond, n_trial_per_cond)
            games_all = W.tab_vertcat(cells.games{:});
            conds = unique(games_all.(cond));
            tid = W.cond2id(games_all.(cond), conds);
            out = cells;
            out.games = W.randsample_bycond(games_all, tid, n_trial_per_cond);
            out.info_cells.gameID = [];
            for i = 1:length(cells.cells)
                tg = cells.games{cells.info_cells.gameID(i)};
                tid = W.cond2id(tg.(cond), conds);
                out.cells{i} = W.randsample_bycond(cells.cells{i}, tid, n_trial_per_cond);
            end
        end
        function [train, test] = combinedcells_sampletrials_split(cells, p)
            train = cells;
            test = cells;
            id = cell(1, length(cells.games));
            for i = 1:length(cells.games)
                ng = size(cells.games{i}, 1);
                id{i} = zeros(ng, 1);
                id{i}(randperm(ng, round(ng * p))) = 1;
                id{i} = id{i} == 1;
                train.games{i} = cells.games{i}(id{i},:);
                test.games{i} = cells.games{i}(~id{i},:);
            end
            for i = 1:length(cells.cells)
                gid = cells.info_cells.gameID(i);
                train.cells{i} = cells.cells{i}(id{gid},:);
                test.cells{i} = cells.cells{i}(~id{gid},:);
            end
        end
    end
end