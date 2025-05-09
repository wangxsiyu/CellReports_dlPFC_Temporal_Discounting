data = W.load('../../TempData/data');
cue = data.cue;
god = data.go;
cue{3} = W.format_combinecells(cue);
plt = SW_plt_from_yml('../fig.yml');
drop = plt.custom_vars.drop;
delay = plt.custom_vars.delay;
timeat = cue{1}.time_at;
ntime = length(timeat);
tlt = {'Monkey 1', 'Monkey 2', 'all data'};
%%
tid = timeat >= 0 & timeat <= 1000;
%% compute population trajectory
pc = {};
pcgo = {};
dvs = {};
for ai = 1:2
    cs = cue{ai}.cells;
    gos = god{ai}.cells;
    gs = W.arrayfun(@(x)cue{ai}.games{x},cue{ai}.info_cells.gameID)';
    nc = length(cs);
    av = cell(1, nc);
    avgo = cell(1, nc);
    dv = cell(1, nc);
    for ci = 1:nc
        c = cs{ci};
        cg = gos{ci};
        g = gs{ci};
        av{ci} = W.cond_average(c, g.condition,1:9);
        avgo{ci} = W.cond_average(cg, g.condition,1:9);
        dv{ci} = W.cond_average(g.DV, g.condition, 1:9);
    end
    dvs{ai} = mean(vertcat(dv{:}));
    % find population activity per cond
    pp = W.cell_transpose(W.cell_NxMK2KxMN(W.cell_transpose(av)));
    ppgo = W.cell_transpose(W.cell_NxMK2KxMN(W.cell_transpose(avgo)));
    % find PCA space
    tpp = W.cellfun(@(x)x(:, tid),pp);
    alld = horzcat(tpp{:});
    pcinfo = W.pca(alld');
    %% project to pca
    pc{ai} = W.cellfun(@(x)W.pca_project(pcinfo, x', 10), pp);
    pcgo{ai} = W.cellfun(@(x)W.pca_project(pcinfo, x', 10), ppgo);
end
%%
%% plot first 10 pc
% plt = S_plt;
% plt.figure(3,4);
% for i = 1:10
%     plt.ax(i);
%     te = W.cellfun_vertcat(@(x)x(tid, i)', pc);
%     plt.plot([], te, [], 'line', 'color', cols);
% end
%% plot 3d 3pc
plt.figure(2,2);
for ai = 1:2
    tid1 = timeat >= 0 & timeat <= 1000;
    plt.ax(1,ai);
    cc = W.cond_average_tab(gs{1}, {'condition'}, {'choice','DV','drop', 'delay'});
    dv = dvs{ai};
    [~, od] = sort(dv);
    cols = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dv), dv(od(5)), max(dv)], x), dv);
    x = {};
    for i = 1:3
        x{i} = W.cellfun_vertcat(@(x)W.smooth1d([],x(tid1, i)',5), pc{ai});
    end
    % plt.plot3(x{1},x{2},x{3}, 'color', cols);
    plt.plot(x{1},x{2},[],'line', 'color', cols);

    tid2 = timeat >= -200 & timeat <= 0;
    plt.ax(2,ai);
    x = {};
    for i = 1:3
        x{i} = W.cellfun_vertcat(@(x)W.smooth1d([],x(tid2, i)',5), pcgo{ai});
    end
    % plt.plot3(x{1},x{2},x{3}, 'color', cols);
    plt.plot(x{1},x{2},[],'line', 'color', cols);
end
plt.unify_lims({[1 1],[2 1]}, {[1 1],[2 1]})
plt.unify_lims({[1 2],[2 2]}, {[1 2],[2 2]})
plt.update;

