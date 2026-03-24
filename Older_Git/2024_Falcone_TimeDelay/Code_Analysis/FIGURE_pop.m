function FIGURE_pop(plt, figdata, data)
    option = sprintf('anova_%s', 'dv');
    figdata = W.cellfun(@(x)x.(option), figdata, false);
    figdata = W.cell_squeeze(figdata);
    figdata = W.neuro_ANOVA_mergesessions(figdata);
    figdata.anova_setting.time_at = [-600:10:1100];
    
    betas = W.cellfun(@(x)x.coef_factors_terms, figdata.result);
    fterms = figdata.result{1}.name_factors_terms;
    
    betas = W.cellfun(@(x) x(2:5,:), betas, false);
    tm = figdata.anova_setting.time_at;
    
    traj = W.cellfun(@(x)W.cellfun(@(t)W.analysis_av_bygroup(t, x.games.condition,1:9), x.spikes, false), data, false);
    traj = horzcat(traj{:});
    
    avt = W.convert_NcellMK2KcellMN(W.cellfun(@(x)x',traj));
    
    bb = W.convert_NcellMK2KcellMN(W.cellfun(@(x)x',betas));
    
    pp = figdata.perc_significant;
    [~, tid] = max(pp,[],2);
    
    bbb = W.cell_vertcat_arrayfun(@(x) bb{x}(tid(x),:), 1:4);
    
    m = W.arrayfun(@(t)W.cell_horzcat_cellfun(@(x)x * bbb(t,:)', avt), 1:4);
    %%
%     plt.figure(2,2);
%     plt.setfig('title', W.str2cell(figdata.name_factors));
%     for i = 1:4
%         plt.ax(i);
%         plt.plot(tm, m{i}', [], 'line');
%     end
    plt.figure;
%     plot3(m{2}, m{3}, m{4})
    
%%    
%     plt.setfig_ax('legloc', 'NW', 'xlim', [-500, 1000]);
%     plt = W_plt_neuro.ax_slidingwindow_ANOVA(plt, figdata);
    plt.update;
end
