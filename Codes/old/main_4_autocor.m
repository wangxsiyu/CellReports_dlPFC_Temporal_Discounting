%%
plt = SW_plt_from_yml('fig.yml');
%% way 1 - autocorr of w2
d = W.load('../Data/anova_nochocie_allcells');
d2 = W.load('../Data/anova_nochocie_shuffled_allcells');
d3 = W.load('../Data/anova_nochocie_allcells_nonsig');
d4 = W.load('../Data/anova_nochocie_shuffled_trial_allcells');
d6 = W.load('../Data/anova_nochocie_shuffled_rate_allcells');
d5 = W.load('../Data/anova_nochocie_non0_allcells');
ds = {d, d3, d4, d2, d5, d6};
dnames = {'data', 'non-sig cells', 'shuffled, trial', 'shuffled, time', 'data, non0', 'shuffled, rate'};
%% all 5 (cells)
clm = [0 1];
plt.figure(2,3,'is_title', 'all', 'matrix_hole', [1 1 1; 1 1 1]);
od = {};
for i = 1:length(ds)
    plt.ax(i);
    td = ds{i};
    w2 = W.cellfun_vertcat(@(x)x.r2, td.cells);
    w2 = w2(~all(isnan(w2), 2),:);
    w2 = w2./max(w2, [],2);
    [~, od{i}] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
    colormap autumn
    h = imagesc(td.anova_setting.time_at, [], w2(od{i},:));
    set(gca, 'CLim', clm);
    plt.dashY(0, [], 'color', 'white');
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', dnames{i});

%     if i == 6
%         h = colorbar('manual');
%         h.Position = [0.75 0.1 0.02 0.3];
%     end
end
plt.update('all5_cellorder');
%% all 5 (cells)
clm = [0 .3];
plt.figure(2,3,'is_title', 'all', 'matrix_hole', [1 1 1;1 1 0], 'gapW_custom', [0 0 0 3]);
od = {};
iii = [1 3 4 5 6];
for ii = 1:5
    i = iii(ii);
    plt.ax(ii);
    td = ds{i};
    w2 = W.cellfun_vertcat(@(x)x.r2, td.cells);
%     w2 = w2./max(w2, [],2);
    if i == 1
        [~, od{i}] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
    end
    colormap autumn
    h = imagesc(td.anova_setting.time_at, [], w2(od{1},:));
    set(gca, 'CLim', clm);
    plt.dashY(0, [], 'color', 'white');
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', dnames{i});

    if i == 5
        h = colorbar('manual');
        h.Position = [0.9 0.1 0.02 0.3];
    end
end
plt.update('all5_cellorder1');
%% all 5 (heat maps)
plt.figure(6,3, 'is_title',1, 'gapW_custom', [1 0 0 3]);
for i = 1:3
    for j = 1:6
        plt.ax(j,i);
        td = ds{j};
        tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), td.cells);
        [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
        tcor(pcor > 0.05) = NaN;
        colormap jet
        h = imagesc(td.anova_setting.time_at, td.anova_setting.time_at, tcor);
        set(gca, 'YDir', 'normal', 'CLim', [0 1]);
        set(h, 'AlphaData', ~isnan(tcor))
        if j == 1
            tlt = d.anova_setting.factornames_anova(i);
        else
            tlt = '';
        end
        if i == 1
            ylab = {dnames{j}, 'Time (ms)'};
        else
            ylab = 'Time (ms)';
        end
        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', ylab, 'title', tlt);
        if i == 3
            h = colorbar('manual');
            h.Position = [0.93 -0.16 + j * 0.195 0.02 0.15];
        end
    end
end
plt.update('all5_autocor');
% %%
% clm = [0 .1];
% plt.figure(3,1,'is_title', 'all', 'gapW_custom', [0 3]);
% plt.ax(1);
% w2 = W.cellfun_vertcat(@(x)x.r2, d.cells);
% % w2 = w2./max(w2, [],2);
% [~, od1] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
% colormap autumn
% h = imagesc(d.anova_setting.time_at, [], w2(od1,:))
% set(gca, 'CLim', clm);
% plt.dashY(0, [], 'color', 'white');
% plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', 'data');
% h = colorbar('manual');
% h.Position = [0.83 0.73 0.02 0.2];
% 
% plt.ax(2);
% w2 = W.cellfun_vertcat(@(x)x.r2, d2.cells);
% % w2 = w2./max(w2, [],2);
% [~, od2] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
% colormap autumn
% h = imagesc(d.anova_setting.time_at, [], w2(od2,:))
% set(gca, 'CLim', clm);
% plt.dashY(0, [], 'color', 'white');
% plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', 'shuffled');
% h = colorbar('manual');
% h.Position = [0.83 0.4 0.02 0.2];
% 
% 
% plt.ax(3);
% w2 = W.cellfun_vertcat(@(x)x.r2, d3.cells);
% % w2 = w2./max(w2, [],2);
% [~, od3] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
% colormap autumn
% h = imagesc(d.anova_setting.time_at, [], w2(od3,:))
% set(gca, 'CLim', clm);
% plt.dashY(0, [], 'color', 'white');
% plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', 'Non-sig cells');
% h = colorbar('manual');
% h.Position = [0.83 0.08 0.02 0.2];
% plt.update('cellorder');
% %% not useful
% clm = [0 .1];
% plt.figure(1,1,'is_title', 'all', 'gapW_custom', [0 3]);
% w2 = W.cellfun_vertcat(@(x)x.r2, d2.cells);
% % w2 = w2./max(w2, [],2);
% [~, od2] = sort(arrayfun(@(x)find(w2(x,:) == max(w2(x,:)), 1, 'first'), 1:size(w2,1)));
% colormap autumn
% h = imagesc(d.anova_setting.time_at, [], w2(od1,:))
% set(gca, 'CLim', clm);
% plt.dashY(0, [], 'color', 'white');
% plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'Cells', 'title', 'shuffled');
% h = colorbar('manual');
% h.Position = [0.83 0.2 0.02 0.6];
% plt.update('cellorder1');
%%
plt.figure(1,3, 'gapW_custom', [0 0 0 3]);
for i = 1:3
    plt.ax(i);
    tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d.cells);
    [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
    tcor(pcor > 0.05) = NaN;
    colormap jet
    h = imagesc(d.anova_setting.time_at, d.anova_setting.time_at, tcor);
    set(gca, 'YDir', 'normal', 'CLim', [0 1]);
    set(h, 'AlphaData', ~isnan(tcor))
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Time (ms)', 'title', d.anova_setting.factornames_anova(i));
    h = colorbar('manual');
    h.Position = [0.93 0.2 0.02 0.6];
end
plt.update('autocor_w2');
%%
plt.figure(1,3, 'gapW_custom', [0 0 0 3]);
for i = 1:3
    plt.ax(i);
    tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d2.cells);
    [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
    tcor(pcor > 0.05) = NaN;
    colormap jet
    h = imagesc(d2.anova_setting.time_at, d2.anova_setting.time_at, tcor);
    set(gca, 'YDir', 'normal', 'CLim', [0 1]);
    set(h, 'AlphaData', ~isnan(tcor))
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Time (ms)', 'title', d2.anova_setting.factornames_anova(i));
    h = colorbar('manual');
    h.Position = [0.93 0.2 0.02 0.6];
end
plt.update('autocor_w2_shuffled');
%%
plt.figure(1,3, 'gapW_custom', [0 0 0 3]);
for i = 1:3
    plt.ax(i);
    tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d3.cells);
    [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
    tcor(pcor > 0.05) = NaN;
    colormap jet
    h = imagesc(d3.anova_setting.time_at, d3.anova_setting.time_at, tcor);
    set(gca, 'YDir', 'normal', 'CLim', [0 1]);
    set(h, 'AlphaData', ~isnan(tcor))
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Time (ms)', 'title', d3.anova_setting.factornames_anova(i));
    h = colorbar('manual');
    h.Position = [0.93 0.2 0.02 0.6];
end
plt.update('autocor_w2_nonsig');
%% example
time_at = d.anova_setting.time_at;
tm2idx = @(x)find(d.anova_setting.time_at == x);
i = 3;
tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d.cells);
[tcor, pcor] = corr(tf, 'Rows', 'pairwise');
thres = linspace(1, 0.5, 100);
ts = [-300, 300];
plt.figure(1,2);
cols = {'AZred', 'AZblue'};
for i = 1:2
    tt = ts(i);
    tcurve = tcor(tm2idx(tt),:);
    plt.ax(1);
    plt.plot(time_at, tcurve, [], 'line', 'color', cols{i});
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'R(autocor)', 'xlim', [-500 1000]);
    plt.dashX(0.8);
    plt.ax(2);
    span = W.arrayfun(@(x)diff(time_at(getspan(tcurve, tm2idx(tt), x))), thres);
%     md = fitlm(thres', span');
%     md.Coefficients.Estimate(2)
    plt.plot(thres, span, [], 'line', 'color', cols{i});
    plt.setfig_ax('xlabel', 'threshold', 'ylabel', 'time span');
    plt.dashY(0.8);
    set(gca, 'XDir', 'reverse');
end
plt.update('supplementary-stability index');
%%
plt.figure(1,1);
thres = linspace(1, 0.5, 100);
tm2idx = @(x)find(d.anova_setting.time_at == x);
for i = 1:3
%     plt.ax(i);
    tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d.cells);
    [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
    coef = [];
    for ti = 1:size(tcor, 2)
        tcurve = tcor(ti,:);
        span = W.arrayfun(@(x)diff(time_at(getspan(tcurve, ti, x))), thres);
%         md = fitlm(thres', span');
%         coef(ti) = abs(md.Coefficients.Estimate(2));
        coef(ti) = mean(span);
    end
    plt.plot(time_at, coef, [], 'line', 'color', plt.custom_vars.color_anova(i));
end

    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'stability index (a.u.)', ...
        'legend', d.anova_setting.factornames_anova,...
        'xlim', [-500 1000], 'legloc', 'NW');
    plt.unify_lims()
plt.update('autocor_span');
%%
plt.figure(1,3);
threses = 0:.02:0.99;
for i = 1:3
    plt.ax(i);
    coef = [];
    for j = 1:length(threses)
        thres = linspace(1, threses(j), 100);
        tm2idx = @(x)find(d.anova_setting.time_at == x);

        tf = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d.cells);
        [tcor, pcor] = corr(tf, 'Rows', 'pairwise');
        for ti = 1:size(tcor, 2)
            tcurve = tcor(ti,:);
            span = W.arrayfun(@(x)diff(time_at(getspan(tcurve, ti, x))), thres);
            %         md = fitlm(thres', span');
            %         coef(ti) = abs(md.Coefficients.Estimate(2));
            coef(j,ti) = mean(span);
        end
        coef(j,:)  = coef(j,:)./max(coef(j,:));
    end
    imagesc(time_at, threses, coef);
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'stability index (a.u.)', ...
        'title', d.anova_setting.factornames_anova(i),...
        'xlim', [-500 1000]);
end

    plt.unify_lims()
plt.update('autocor_span_allthres');
% %%
% plt.figure(1,3);
% dd = cell(1,3);
% for i = 1:3
%     dd{i} = W.cellfun_vertcat(@(x)x.w2_factors(i,:), d.cells);
% end
% names = d.anova_setting.factornames_anova;
% names(3) = "Interaction";
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
% plt.update('crosscor_w2');
