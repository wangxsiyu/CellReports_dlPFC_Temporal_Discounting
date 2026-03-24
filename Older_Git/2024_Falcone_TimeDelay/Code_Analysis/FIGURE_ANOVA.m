function FIGURE_ANOVA(plt, option, figdata)
    option = sprintf('anova_%s', option);
    figdata = W.cellfun(@(x)x.(option), figdata, false);
    figdata = W.cell_squeeze(figdata);
    figdata = W.neuro_ANOVA_mergesessions(figdata);
    figdata.anova_setting.time_at = [-600:10:1100];
    plt.figure;
    plt.setfig_ax('legloc', 'NW', 'xlim', [-500, 1000]);
    plt = W_plt_neuro.ax_slidingwindow_ANOVA(plt, figdata);
    plt.update;
end
