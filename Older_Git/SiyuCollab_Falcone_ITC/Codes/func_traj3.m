function out = func_traj3(cells, games, anova)
    cond2av = games.cue1 == "yellow";
    release1 = games.release1 == 1;
    cells.cells = W.encell(cells.cells);

    cond = (cond2av * 2 + release1) * 9 + games.condition;
    ncond = arrayfun(@(x) sum(x == cond), 1:36);
    trajs = W.trajectory_bycond(cells.cells, cond, 1:36);
    for i = 1:length(trajs)
        trajs{i}(ncond < 10,:) = NaN;
    end


    % 1 - hold purple - reject
    % 2 - release purple - accept
    % 3 - hold yellow - accept
    % 4 - release yellow - reject
    out = rmfield(cells, "cells");
    out.cells = trajs;
    out.info_cells.beta_DV = W.cellfun_vertcat(@(x)x.coef_factors_terms(4,:), anova.cells);
end