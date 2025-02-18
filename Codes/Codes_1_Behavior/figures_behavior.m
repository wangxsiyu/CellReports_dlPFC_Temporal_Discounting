gs = W.load('../../TempData/games_DV');
xfit = W.load('../../TempData/model_YP');
%% compute p(accept) separated by yellow/purple
c0 = W.cellfun_vertcat(@(g)W.cond_average_tab(g, 'condition', 'choice'), gs);
c1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 == "yellow",:), 'condition', 'choice'), gs);
c2 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 ~= "yellow",:), 'condition', 'choice'), gs);
[av0, se0] = W.avse(c0.avCHOICE);
av = []; se= [];
[av(1,:), se(1,:)] = W.avse(c1.avCHOICE);
[av(2,:), se(2,:)] = W.avse(c2.avCHOICE);
v1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g, 'condition', 'DV'), gs);
v(1,:) = W.avse(v1.avDV);
%% plot
plt = SW_plt_from_yml('../fig.yml');
drop = plt.custom_vars.drop;
delay = plt.custom_vars.delay;
%%
plt.figure(1,2);
plt.ax(1);
plt.scatter(v1.avDV(:,tid), c0.avCHOICE(:, tid), 'dot', 'color', 'gray');
plt.plot(v(:,tid), av0(:, tid), se0(:, tid), 'line', 'color', 'black', 'LineStyle', 'o');

plt.ax(2);
[~, tid] = sort(sum(av));
plt.plot(1:length(tid), av(:, tid), se(:, tid), 'bar', 'color', {'yellow','magenta'});
plt.setfig_ax('xlabel', 'DV', 'ylabel', 'p(accept)', 'legend', {'yellow 1st', 'purple 1st'});
