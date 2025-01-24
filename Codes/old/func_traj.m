function out = func_traj(cells, games, anova)
    cond2av = games.cue1 == "yellow";
    release1 = games.release1 == 1;
    cells.cells = W.encell(cells.cells);
    trajs = W.trajectory_bycond(cells.cells, cond2av * 9 + games.condition + 18 * release1, 1:36);
    trajs2 = W.trajectory_bycond(cells.cells, cond2av * 9 + games.condition, 1:18);
    out = rmfield(cells, "cells");
    out.cells = W.arrayfun(@(x)vertcat(trajs{x}, trajs2{x}), 1:length(trajs));
    out.info_cells.beta_DV = W.cellfun_vertcat(@(x)x.coef_factors_terms(4,:), anova.cells);
end