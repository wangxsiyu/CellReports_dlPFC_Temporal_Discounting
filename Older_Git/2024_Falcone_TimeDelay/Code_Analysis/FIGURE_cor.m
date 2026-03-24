function FIGURE_cor(plt, option, figdata)
    option = sprintf('anova_%s', 'dv');
    figdata = W.cellfun(@(x)x.(option), figdata, false);
    figdata = W.cell_squeeze(figdata);
    figdata = W.neuro_ANOVA_mergesessions(figdata);
    figdata.anova_setting.time_at = [-600:10:1100];
    
    betas = W.cellfun(@(x)x.coef_factors_terms, figdata.result);
    fterms = figdata.result{1}.name_factors_terms;
    
    tm = figdata.anova_setting.time_at;
    %%
    plt.figure(2,2);
    plt.setfig('title', W.str2cell(figdata.name_factors));
    alpha = 0.001 / 171/171;
    plt.ax(1);
    c = W.cell_vertcat_cellfun(@(x)x(contains(fterms, 'choice'),:), betas);
     [c, p] = corr(c);
    c = c.*((p < alpha) + eye(size(c)));
    c(c == 0) = NaN;
    imagesc(tm,tm,c, [-1,1]);
    set(gca,'YDir','normal') 

    
    plt.ax(4);
    c = W.cell_vertcat_cellfun(@(x)x(contains(fterms, 'DV'),:), betas);
 [c, p] = corr(c);
    c = c.*((p < alpha) + eye(size(c)));
    c(c == 0) = NaN;
    imagesc(tm,tm,c, [-1,1]);
    set(gca,'YDir','normal') 
    
    plt.ax(2);
    c = W.cell_vertcat_cellfun(@(x)x(contains(fterms, 'drop') & ~ contains(fterms, 'delay'),:), betas);
 [c, p] = corr(c);
    c = c.*((p < alpha) + eye(size(c)));
    c(c == 0) = NaN;
    imagesc(tm,tm,c, [-1,1]);
    set(gca,'YDir','normal') 
    
    plt.ax(3);
    c = W.cell_vertcat_cellfun(@(x)x(contains(fterms, 'delay')  & ~ contains(fterms, 'drop'),:), betas);
    [c, p] = corr(c);
    c = c.*((p < alpha) + eye(size(c)));
    c(c == 0) = NaN;
    imagesc(tm,tm,c, [-1,1]);
    set(gca,'YDir','normal') 
%%    
%     plt.setfig_ax('legloc', 'NW', 'xlim', [-500, 1000]);
%     plt = W_plt_neuro.ax_slidingwindow_ANOVA(plt, figdata);
    plt.update;
end
