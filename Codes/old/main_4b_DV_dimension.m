%%
plt = SW_plt_from_yml('fig.yml');
%% way 2 - autocorr of beta
d = W.load('../Data/anova_value_cont_allcells_normalized');
dd = cell(1,3);
coef = NaN(170, 3);
wd = [75 750];
tm = d.anova_setting.time_at;
id = find(tm >= wd(1) & tm <= wd(2));
for i = 1:3
    dd{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), d.cells);
    coef(:,i) = mean(dd{i}(:, id),2);
end
rr = W.cellfun_vertcat(@(x)x.r2, d.cells);
r2 = nanmean(rr(:, id),2);
%%
plt.figure(1,1);
names = d.anova_setting.factornames_anova;
ylims =  [-0.04 0.04;-0.02 0.02;-0.1 0.1];
for i = 1:3
    [av, se] = W.avse(dd{i});
%     plt.ax(i);
    plt.plot(tm, av, se, 'shade', 'color', plt.custom_vars.color_anova(i));
end
plt.dashX(0)
plt.setfig_ax('legend', [names], 'xlabel', 'time', ...
        'ylabel', 'average beta', 'xlim', [-500 1000], 'ylim', [-0.06,0.06]);
plt.update('beta over time');
%% 
plt.figure(1,3, 'pixel_w', 50, 'pixel_gap_w', -5);
% od = 1:121;
[~, od] = sort(r2, 'ascend');
% [~, od] = sort(coef(:,3), 'descend');
for i = 1:3
    plt.ax(i);
    barh(coef(od, i));
    plt.setfig_ax('xlabel', W.iif(i == 2,'beta',''), 'ylabel', W.iif(i == 1,'neuron ID',''), ...
        'title', names{i});
end
plt.update('beta vs neuron');
%%
plt.figure(1,2, 'gapW_custom', [0.5 0 0.5]);
names = d.anova_setting.factornames_anova;
for i = 1:2
    ii = setdiff(1:3, 3-i);
    tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
    plt.ax(i);
    plt.scatter(coef(:, ii(1)), coef(:, ii(2)), 'corr');
    plt.setfig_ax('ylabel', ['Coding dimension for ' names(ii(1))], 'xlabel', 'Coding dimension for discounted value', ...
        'title', tlt);
end
plt.update('DV vs drop delay');
%%
plt.figure(1,2, 'gapW_custom', [0 0 3]);
names = d.anova_setting.factornames_anova;
for i = 1:2
    ii = setdiff(1:3, 3-i);
    tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
    plt.ax(i);
    [tcor, pcor] = corr(dd{ii(1)}, dd{ii(2)}, 'Rows', 'pairwise');
    tcor(pcor > 0.05) = NaN;
    colormap jet
    h = imagesc(d.anova_setting.time_at, d.anova_setting.time_at, tcor);
    set(gca, 'YDir', 'normal', 'CLim', [-1 1]);
    set(h, 'AlphaData', ~isnan(tcor))
    plt.setfig_ax('ylabel', names(ii(1)), 'xlabel', 'Discounted value', ...
        'title', tlt);
    h = colorbar('manual');
    h.Position = [0.93 0.2 0.02 0.6];
end
plt.update('supplementary - DV vs drop delay');
% %%
% plt.figure(1,3);
% for i = 1:3
%     plt.ax(i);
%     tf = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), d.cells);
%     [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
%     tcor(pcor > 0.05) = NaN;
%     colormap jet
%     h = imagesc(d.anova_setting.time_at, d.anova_setting.time_at, tcor);
%     set(gca, 'YDir', 'normal', 'CLim', [0 1]);
%     set(h, 'AlphaData', ~isnan(tcor))
%     plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Time (ms)', 'title', d.anova_setting.factornames_anova(i));
% end
% plt.update('autocor_beta');
% %%
% plt.figure(1,3);
% dd = cell(1,3);
% for i = 1:3
%     dd{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), d.cells);
% end
% names = d.anova_setting.factornames_anova;
% for i = 1:3
%     ii = setdiff(1:3, i);
%     tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
%     plt.ax(i);
%     [tcor, pcor] = corr(dd{ii(1)}, dd{ii(2)}, 'Rows', 'pairwise');
%     tcor(pcor > 0.05) = NaN;
%     colormap jet
%     h = imagesc(d.anova_setting.time_at, d.anova_setting.time_at, tcor);
%     set(gca, 'YDir', 'normal', 'CLim', [-1 1]);
%     set(h, 'AlphaData', ~isnan(tcor))
%     plt.setfig_ax('ylabel', names(ii(1)), 'xlabel', names(ii(2)), ...
%         'title', tlt);
% end
% plt.update('crosscor_beta');
% %%
% plt.figure(1,1);
% dd = cell(1,3);
% for i = 1:3
%     dd{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), d.cells);
% end
% names = d.anova_setting.factornames_anova;
% for i = 1:3
%     ii = setdiff(1:3, i);
%     tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
% %     plt.ax(1);
%     [tcor, pcor] = corr(dd{ii(1)}, dd{ii(2)}, 'Rows', 'pairwise');
%     tcor = diag(tcor);
%     pcor = diag(pcor);
% %     tcor(pcor > 0.05) = NaN;
% %     colormap jet
% %     h = imagesc(d.anova_setting.time_at, d.anova_setting.time_at, tcor);
% %     set(gca, 'YDir', 'normal', 'CLim', [-1 1]);
% %     set(h, 'AlphaData', ~isnan(tcor))
%     plt.plot(time_at, tcor', [], 'line');
% end
% plt.setfig_ax('ylabel', 'cor', 'xlabel', 'time (ms)', ...
%     'legend', {'delay vs DV', 'drop vs DV', 'delay vs drop'});
% plt.update('crosscor_beta_line');