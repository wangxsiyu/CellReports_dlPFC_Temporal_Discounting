function out = func_traj2(cells, games, anova)
    cond2av = games.cue1 == "yellow";
    release1 = games.release1 == 1;
    cells.cells = W.encell(cells.cells);
    trajs = W.trajectory_bycond(cells.cells, 1 + cond2av * 2 + release1, 1:4);
    % 1 - hold purple - reject
    % 2 - release purple - accept
    % 3 - hold yellow - accept
    % 4 - release yellow - reject
    out = rmfield(cells, "cells");
    out.cells = trajs;
    out.info_cells.beta_DV = W.cellfun_vertcat(@(x)x.coef_factors_terms(4,:), anova.cells);
end