data = W.load('../../TempData/data');
session = data.cue{1}.info_session.info_combinedsessions;
gs = data.cue{1}.games;
gs = {gs(session.animal == "S"), gs(session.animal == "T")};
xfit = W.load('../../TempData/modelfit_overall');
params = {xfit{1}.model_base.params_table, xfit{4}.model_base.params_table};
%% compute choice curve, and condition means
gs_all = {vertcat(gs{1}{:}), vertcat(gs{2}{:})};
c0 = W.cellfun_vertcat(@(g)W.cond_average_tab(g, 'condition', 'choice'), gs_all);
v1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g, 'condition', 'DV'), gs_all);
%% compute p(accept) separated by yellow/purple
c1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 == "yellow",:), 'condition', 'choice'), gs_all);
c2 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 ~= "yellow",:), 'condition', 'choice'), gs_all);
%% plot
plt = SW_plt_from_yml('../fig.yml');
drop = plt.custom_vars.drop;
delay = plt.custom_vars.delay;
%%
plt.figure(2,2, 'is_title', 'all', 'gapW_custom', [0 0 4]);
xlms = {[0 2], [0 4]};
for i = 1:2
    plt.ax(1, i);
    xs = 0:0.01:5;
    x = params{i};
    f = @(V)W.col_select(W_RL.softmax_binary(x.thres, V, x.beta),2);
    cp = arrayfun(@(x)f(x), xs);
    plt.plot(xs, cp, [], 'line', 'color', 'black', 'LineWidth', 1);
    sp = 'ooosssddd';
    col = 'brgbrgbrg';
%     plt.plot(v1.avDV(i,:), c0.avCHOICE(i, :), c0.seCHOICE(i, :), 'line', 'color', 'black', 'LineStyle', 'o');
    for j = 1:9
        plt.scatter(v1.avDV(i,j), c0.avCHOICE(i, j), [], 'shape', sp(j), ...
            'dotsize', 7, 'color', col(j));

    end
    plt.setfig_ax('ylabel', 'Accept Rate (%)', 'xlabel', 'Discounted Value', 'ylim', [0 1], ...
        'ytick', [0:.1:1], 'title', ['Monkey ' num2str(i)], 'xlim', xlms{i});
    plt.ax(2, i);
    av = [c1.avCHOICE(i,:); c2.avCHOICE(i,:)];
    se = [c1.seCHOICE(i,:); c2.seCHOICE(i,:)];
    [~, tid] = sort(c0.avCHOICE(i, :));
    plt.plot(1:length(tid), av(:, tid), se(:, tid), 'bar', 'color', {'yellow','magenta'});
    plt.setfig_ax('xlabel', '', 'ylabel', 'Accept Rate (%)', ...
        'xlim', [0 10], 'xtick', 1:9, ...
        'xticklabel', W.arrayfun(@(x)sprintf('%d\\newline%d', drop(x), delay(x)), tid, false));
    if i == 2
        plt.setfig_ax('legend', {'yellow 1st', 'purple 1st'}, ...
        'legloc', 'SEO');
    end
end
plt.update('behavior');