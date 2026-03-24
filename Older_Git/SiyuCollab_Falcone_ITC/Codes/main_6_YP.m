d = W.load('../Data/EPOCH_sigcells_all.mat');
%%
gameinfo = unique(d.info_cells(:, ["animal", "gameID"]), 'rows');

av1 = [];
av2 = [];
se1 = [];
se2 = [];
tid = 1:size(gameinfo,1);
c1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 == "yellow",:), 'condition', 'choice'), d.games(tid));
c2 = W.cellfun_vertcat(@(g)W.cond_average_tab(g(g.cue1 ~= "yellow",:), 'condition', 'choice'), d.games(tid));

[av1(1,:), se1(1,:)] = W.avse(c1.avCHOICE);
[av2(1,:), se2(1,:)] = W.avse(c2.avCHOICE);
v1 = W.cellfun_vertcat(@(g)W.cond_average_tab(g, 'condition', 'DV'), d.games);
v(1,:) = W.avse(v1.avDV);
%%
plt = SW_plt_from_yml('fig.yml');
%%
plt.figure(1,2);
plt.ax(1);
[~, tid] = sort(av1 + av2);
plt.plot(v(tid), av1(tid), se1(tid), 'shade', 'color', 'yellow');
plt.plot(v(tid), av2(tid), se2(tid), 'shade', 'color', 'magenta');
plt.setfig_ax('xlabel', 'DV', 'ylabel', 'p(accept)', 'legend', {'yellow 1st', 'purple 1st'});

%% compute shift in DV dimension
d = W.load('../Data/traj_go_allcells.mat');
beta = d.info_cells.beta_DV;
beta = beta ./ sqrt(sum(beta.^2));
wd = [75 750];
tm = d.time_at;
id = find(tm >= wd(1) & tm <= wd(2));
beta = mean(beta(:, id),2);
d.info_cells.beta = beta;
ncell = length(d.cells);
info = d.info_cells;

traj = [];
for i = 1:54
    td = W.cellfun_vertcat(@(x)x(i,:), d.cells);
    tid = ~all(isnan(td),2);
    if mean(tid) > 0
        traj(i,:) = sum(td(tid,:) .* beta(tid));
    else
        traj(i,:) = NaN(1, 171);
    end
end
%%

plt.figure(1,1);
plt.ax(1);
[~, pp] = ttest(traj(37:45,:) - traj(46:54,:));
[av, se] = W.avse(traj(37:45,:) - traj(46:54,:));
plt.plot(d.time_at, av, se, 'shade');
plt.dashX(0)
plt.sigstar(d.time_at, av - 0.1, pp)
% plt.plot(d.time_at, traj(1:9,:), [], 'line', 'color', 'yellow');
% plt.plot(d.time_at, traj(10:18,:), [], 'line', 'color', 'magenta');
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000], 'title', 'release');
plt.update;
%%
plt.figure(1,2);
plt.ax(1);
[~, pp] = ttest(traj(1:9,:) - traj(10:18,:));
[av, se] = W.avse(traj(1:9,:) - traj(10:18,:));
plt.plot(d.time_at, av, se, 'shade');
plt.dashX(0)
plt.sigstar(d.time_at, av - 0.1, pp)
% plt.plot(d.time_at, traj(1:9,:), [], 'line', 'color', 'yellow');
% plt.plot(d.time_at, traj(10:18,:), [], 'line', 'color', 'magenta');
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000], 'title', 'release');

plt.ax(2);
[~, pp] = ttest(traj(19:27,:) - traj(28:36,:));
[av, se] = W.avse(traj(19:27,:) - traj(28:36,:));
plt.plot(d.time_at, av, se, 'shade');
plt.dashX(0)
plt.sigstar(d.time_at, av - 0.1, pp)
% plt.plot(d.time_at, traj(1:9,:), [], 'line', 'color', 'yellow');
% plt.plot(d.time_at, traj(10:18,:), [], 'line', 'color', 'magenta');
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000], 'title', 'hold');


plt.update('trajYP');
%%
plt.figure(3,3, 'is_title', 'all');
for i =1:9
plt.ax(i);
plt.plot(d.time_at, traj(i,:), [], 'line', 'color', 'yellow');
plt.plot(d.time_at, traj(i+9,:), [], 'line', 'color', 'magenta');
plt.plot(d.time_at, traj(i,:) -traj(i+9,:), [], 'line', 'color', 'black');
plt.dashX(0)
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
delays = [1 5 10];
plt.setfig_ax('title', sprintf('release: delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));
end
plt.update;
%%
plt.figure(3,3, 'is_title', 'all');
for i =1:9
plt.ax(i);
plt.plot(d.time_at, traj(i+36,:), [], 'line', 'color', 'yellow');
plt.plot(d.time_at, traj(i+9+36,:), [], 'line', 'color', 'magenta');
plt.plot(d.time_at, traj(i+36,:) -traj(i+9+36,:), [], 'line', 'color', 'black');
plt.dashX(0)
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
delays = [1 5 10];
plt.setfig_ax('title', sprintf('release: delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));
end
plt.update('trajYP_all');
%%
plt.figure(3,3, 'is_title', 'all');
for i =1:9
plt.ax(i);
plt.plot(d.time_at, traj(i+18,:), [], 'line', 'color', 'yellow');
plt.plot(d.time_at, traj(i+9+18,:), [], 'line', 'color', 'magenta');
plt.plot(d.time_at, traj(i+18,:) -traj(i+9+18,:), [], 'line', 'color', 'black');
plt.dashX(0)
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
delays = [1 5 10];
plt.setfig_ax('title', sprintf('hold: delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));
end
plt.update('trajYP_all');

%% 11/11

d = W.load('../Data/traj_go2_allcells.mat');
beta = d.info_cells.beta_DV;
beta = beta ./ sqrt(sum(beta.^2));
wd = [75 750];
tm = d.time_at;
id = find(tm >= wd(1) & tm <= wd(2));
beta = mean(beta(:, id),2);
ncell = length(d.cells);

traj = [];
for i = 1:4
    td = W.cellfun_vertcat(@(x)x(i,:), d.cells);
    tid = ~all(isnan(td),2);
    if mean(tid) > 0
        traj(i,:) = sum(td(tid,:) .* beta(tid));
    else
        traj(i,:) = NaN(1, 171);
    end
end
%%
plt.figure(1,1);
plt.ax(1);

plt.plot(d.time_at, traj, [], 'line', 'color', {'AZmesa', 'magenta', 'AZsand', 'yellow'});
plt.dashX(0)
plt.setfig_ax('legend', {'hold purple - reject', ...
    'release purple - accept', ...
    'hold yellow - accept', ...
    'release yellow - reject'});
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
plt.update;

%%

d = W.load('../Data/traj_go3_allcells.mat');
beta = d.info_cells.beta_DV;
beta = beta ./ sqrt(sum(beta.^2));
wd = [75 750];
tm = d.time_at;
id = find(tm >= wd(1) & tm <= wd(2));
beta = mean(beta(:, id),2);
ncell = length(d.cells);

traj = [];
for i = 1:36
    td = W.cellfun_vertcat(@(x)x(i,:), d.cells);
    tid = ~all(isnan(td),2);
    if mean(tid) > 0
        traj(i,:) = sum(td(tid,:) .* beta(tid));
    else
        traj(i,:) = NaN(1, 171);
    end
end
%%
plt.figure(3,3, 'is_title', 'all');
for i =1:9
    plt.ax(i);
    id = [i i+9 i+18 i+27];
    tt = traj(id,:);    
    tid = ~all(isnan(tt),[2]);
    cols = {'AZmesa', 'magenta', 'AZsand', 'yellow'};
    legs = {'hold purple - reject', ...
        'release purple - accept', ...
        'hold yellow - accept', ...
        'release yellow - reject'};
    plt.plot(d.time_at, tt(tid,:), [], 'line', 'color', cols(tid));
    
%     plt.plot(d.time_at, traj(i+18,:) -traj(i+9+18,:), [], 'line', 'color', 'black');
    plt.dashX(0)
    plt.setfig_ax('legend', legs(tid));
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
    delays = [1 5 10];
    plt.setfig_ax('title', sprintf('delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));
end
plt.update;

%%
p_y = traj([1:9] + 9,:) - traj([1:9] + 18,:);
[av, se] = W.avse(p_y);
plt.figure;
plt.plot(d.time_at, av, se, 'shade', 'color', 'k');
plt.dashX(0)
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
plt.update;

%%
[cc, pp] = corr(p_y, av2' - av1');

plt.figure;
plt.plot(d.time_at, cc', [], 'line', 'color', 'k');
plt.dashX(0);
plt.sigstar(d.time_at, cc' - 0.1, pp')
plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'correlation with behavioral change', 'xlim', [-500 1000]);
%%
plt.figure(3,3, 'is_title', 'all');
for i =1:9
    plt.ax(i);
    id = [i i+9 i+18 i+27];
    tt = traj(id,:);    
    tid = [2 3];
    cols = {'AZmesa', 'magenta', 'AZsand', 'yellow'};
    legs = {'hold purple - reject', ...
        'release purple - accept', ...
        'hold yellow - accept', ...
        'release yellow - reject'};
    plt.plot(d.time_at, tt(tid,:), [], 'line', 'color', cols(tid));
    
    plt.plot(d.time_at, traj(i+9,:) -traj(i+18,:), [], 'line', 'color', 'black');
    plt.dashX(0)
    plt.setfig_ax('legend', [legs(tid) {'diff'}]);
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'population activity of DV', 'xlim', [-500 1000]);
    delays = [1 5 10];
    plt.setfig_ax('title', sprintf('delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));
end
plt.update;
%%
anv = W.load('../data/anova_go_allcells_formatted.mat');
anv1 = W.load('../data/anova_go_allcells.mat');
anv2 = W.load('../data/anova_nochocie_allcells.mat');
p0 = W.cellfun_horzcat(@(x)mean(x.is_significant(:,anv.anova_setting.time_at <= 0),2),anv.cells)';
p1 = W.cellfun_horzcat(@(x)mean(x.is_significant(:,anv.anova_setting.time_at > 0 & anv.anova_setting.time_at <= 500),2),anv.cells)';
p2 = W.cellfun_horzcat(@(x)mean(x.is_significant(:,anv1.anova_setting.time_at > 0 & anv1.anova_setting.time_at <= 500),2),anv1.cells)';
[~,tod] = sort(p2(:,3));
info = anv.info_cells;
info.p0 = p0;
info.p1 = p1;
info = info(tod,:);
%% motor only
id_motor = find(p1(:,2) > 0.05 & p1(:,3) < 0.05 & p1(:,4) < 0.05 & p0(:,2) < 0.05);
info(id_motor,:)
%% cue only
id_gocue = find(p1(:,4) > 0.05 & p1(:,3) < 0.05 & p1(:,2) < 0.05 & p0(:,4) < 0.05);
info(id_gocue,:)
%% choice only
id_choice = find(p1(:,3) > 0.05 & p1(:,4) < 0.05 & p1(:,2) < 0.05 & p0(:,3) < 0.05);
info(id_choice,:)
%% value/cue only
id_cue = find(p1(:,2) < 0.05 & p1(:,3)< 0.05 & p1(:,4)< 0.05 & p0(:,1) > 0.05);
info(id_cue,:)
%%
raws{1} = W.load('../data/spiketrains.mat');
alls{1} = W.load('../data/EPOCH_sigcells_all.mat');
raws{2} = W.load('../data/spiketrains_GO.mat');
alls{2} = W.load('../data/EPOCH_sigcells_go_all.mat');
%%
plt = S_plt('savedir', './figures', 'issave',1);

cellID = 30;
animal = "S";
%%
plt.figure(2,2, 'gapW_custom', [0 0 5]);
tlt = {'cue on', 'go cue'};
for fi = 1:2
    all = alls{fi};
    raw = raws{fi};
    tid = find(all.info_cells.cellID == cellID & all.info_cells.animal == animal);
    ep = all.cells{tid};
    tid2 = find(raw.info_cells.cellID == cellID & raw.info_cells.animal == animal);
    st = raw.cells{tid2};
    g = all.games{all.info_cells.gameID(tid)};
    cc = W.cond_average_tab(g, {'condition'}, {'choice','DV','drop', 'delay'});
    dv = cc.avDV;
    [~, od] = sort(dv);
    trials = W.arrayfun(@(x)find(g.condition == x), od);
    plt.ax(1,fi);
    cols = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dv), dv(od(5)), max(dv)], x), dv(od));

    for i = 1:9
        [av, se] = W.avse(ep(trials{i},:));
        plt.plot(all.time_at, av, [], 'line', 'color', cols{i});
    end
    legs = W.iif(fi == 2,W.arrayfun(@(x)sprintf('dv = %.2f', x), dv(od)), []);
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'firing rate', ...
        'xlim', [-500 1000], 'legend', legs, 'legloc', 'NEO', ...
        'title', tlt{fi});
    plt.ax(2,fi);
    width = 0.4;
    x0 = 0;
    for i = 9:-1:1
        tst = st(ismember(st.trialID, trials{i}),:);
        x = W.horz(tst.spiketimes);
        tnt = length(unique(tst.trialID));
        tst.trialID = W.num2rank(tst.trialID);
        y = W.horz(tst.trialID) + x0;
        x0 = x0 + tnt;

        err = width*ones(size(x));
        plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', cols{i}, ...
            'CapSize', 0, 'MarkerSize', 1);
    end

    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 x0+1], ...
        'xlim', [-500 1000]);
end
% plt.unify_lims([],[0 1])
plt.update('cell1');
%% all cells 1
plt.figure(1,2, 'gapW_custom', [0 0 5]);
tlt = {'cue on', 'go cue'};
for fi = 1:2
    all = alls{fi};
    raw = raws{fi};
    all.info_cells = W.tab_join(all.info_cells, info);
    plt.ax(1,fi);
    out = cell(1, size(all.info_cells,1));
    dvall = [];
    for celli = 1:size(all.info_cells,1)
        tid = celli; %find(all.info_cells.cellID == cellID & all.info_cells.animal == animal);
        ep = all.cells{tid};
        g = all.games{all.info_cells.gameID(tid)};
        cc = W.cond_average_tab(g, {'condition'}, {'choice','DV','drop', 'delay'});
        dv = cc.avDV;
        [~, od] = sort(dv);
        dvall = [dvall; dv];
        od = 1:9;
        trials = W.arrayfun(@(x)find(g.condition == x), od);
        av = [];
        for i = 1:9
            [av(i,:), se] = W.avse(ep(trials{i},:));
        end
        out{celli} = av;
    end
    pop = W.cellfun_horzcat(@(y)y * all.info_cells.beta, W.cell_NxMK2KxMN(W.cellfun(@(x)x', out)));
    dvall = mean(dvall);
    % od = [     3     6     2     9     5     8     1     4     7];
    % od = 1:9;
    % dv = av1+ av2;
    cols = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dvall), dvall(5), max(dvall)], x), dvall);
    for i = 1:9
        av = pop(:, i)';
        plt.plot(all.time_at, av, [], 'line', 'color', cols{i});
    end
    legs = W.iif(fi == 2,W.arrayfun(@(x)sprintf('dv = %.2f', x), dvall), []);
    plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'firing rate', ...
        'xlim', [-500 1000], 'legend', legs, 'legloc', 'NEO', ...
        'title', tlt{fi});
    
end
plt.update('all_cell1');

%% 
plt.figure(4,9, 'is_title', 'all');
tlt = {'cue on', 'go cue'};
curve_yellowpurple = cell(2,2);
for fi = 1:2
    all = alls{fi};
    raw = raws{fi};
    tid = find(all.info_cells.cellID == cellID & all.info_cells.animal == animal);
    ep = all.cells{tid};
    tid2 = find(raw.info_cells.cellID == cellID & raw.info_cells.animal == animal);
    st = raw.cells{tid2};
    g = all.games{all.info_cells.gameID(tid)};
    cc = W.cond_average_tab(g, {'condition'}, {'choice','DV','drop', 'delay'});
    dv = cc.avDV;
    [~, od] = sort(dv);
    trials_cond = {};
    trials_cond{1} = W.arrayfun(@(x)find(g.condition == x & g.cue1 == "yellow"), od);
    trials_cond{2} = W.arrayfun(@(x)find(g.condition == x & g.cue1 == "purple"), od);
%     cols = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dv), dv(od(5)), max(dv)], x), dv(od));
    cols = {'yellow', 'magenta'};
    for i = 1:9
        plt.ax(fi*2-1, i);
        av = [];
        se = [];
        for j = 1:2
            [av(j,:), se(j,:)] = W.avse(ep(trials_cond{j}{i},:));
            curve_yellowpurple{fi,j}(i,:) = av(j,:);
        end
        plt.plot(all.time_at, av, [], 'line', 'color', cols);
        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'firing rate', ...
            'xlim', [-500 1000], 'legend', {'yellow', 'purple'}, 'legloc', 'NEO', ...
            'title', tlt{fi});


        plt.ax(fi*2,i);
        width = 0.4;
        x0 = 0;
        for j = 1:2
            tst = st(ismember(st.trialID, trials_cond{j}{i}),:);
            x = W.horz(tst.spiketimes);
            tnt = length(unique(tst.trialID));
            tst.trialID = W.num2rank(tst.trialID);
            y = W.horz(tst.trialID) + x0;
            x0 = x0 + tnt;
            err = width*ones(size(x));
            plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', cols{j}, ...
                'CapSize', 0, 'MarkerSize', 1);
        end

        delays = [1 5 10];
        plt.setfig_ax('title', sprintf('delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));

        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 x0+1], ...
            'xlim', [-500 1000]);
    end
end

plt.update('3by3_1');
%% 
plt.figure(4,9, 'is_title', 'all');
tlt = {'cue on', 'go cue'};
tl2 = {'release', 'hold'};
curve_releasehold = cell(2,2);
for fi = 1:2
    all = alls{fi};
    raw = raws{fi};
    tid = find(all.info_cells.cellID == cellID & all.info_cells.animal == animal);
    ep = all.cells{tid};
    tid2 = find(raw.info_cells.cellID == cellID & raw.info_cells.animal == animal);
    st = raw.cells{tid2};
    g = all.games{all.info_cells.gameID(tid)};
    cc = W.cond_average_tab(g, {'condition'}, {'choice','DV','drop', 'delay'});
    dv = cc.avDV;
    [~, od] = sort(dv);
    trials_cond = {};
    trials_cond{1} = W.arrayfun(@(x)find(g.condition == x & g.release1 == 1), od);
    trials_cond{2} = W.arrayfun(@(x)find(g.condition == x & g.release1 == 0), od);
    cols0 = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dv), dv(od(5)), max(dv)], x), dv(od));
    for i = 1:9
        cols = {cols0{i}, 'black'};
        plt.ax(fi*2-1, i);
        av = [];
        se = [];
        for j = 1:2
            [av(j,:), se(j,:)] = W.avse(ep(trials_cond{j}{i},:));
            curve_releasehold{fi,j}(i,:) = av(j,:);
        end
        plt.plot(all.time_at, av, [], 'line', 'color', cols);
        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'firing rate', ...
            'xlim', [-500 1000], 'legend', tl2, 'legloc', 'NEO', ...
            'title', tlt{fi});


        plt.ax(fi*2,i);
        width = 0.4;
        x0 = 0;
        for j = 1:2
            tst = st(ismember(st.trialID, trials_cond{j}{i}),:);
            x = W.horz(tst.spiketimes);
            tnt = length(unique(tst.trialID));
            tst.trialID = W.num2rank(tst.trialID);
            y = W.horz(tst.trialID) + x0;
            x0 = x0 + tnt;
            err = width*ones(size(x));
            plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', cols{j}, ...
                'CapSize', 0, 'MarkerSize', 1);
        end

        delays = [1 5 10];
        plt.setfig_ax('title', sprintf('delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));

        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 x0+1], ...
            'xlim', [-500 1000]);
    end
end

plt.update('3by3_2');
%% only hold
plt.figure(4,9, 'is_title', 'all');
tlt = {'cue on', 'go cue'};
curve_yellowpurple2 = cell(2,2);
for fi = 1:2
    all = alls{fi};
    raw = raws{fi};
    tid = find(all.info_cells.cellID == cellID & all.info_cells.animal == animal);
    ep = all.cells{tid};
    tid2 = find(raw.info_cells.cellID == cellID & raw.info_cells.animal == animal);
    st = raw.cells{tid2};
    g = all.games{all.info_cells.gameID(tid)};
    cc = W.cond_average_tab(g, {'condition'}, {'choice','DV','drop', 'delay'});
    dv = cc.avDV;
    [~, od] = sort(dv);
    trials_cond = {};
    trials_cond{1} = W.arrayfun(@(x)find(g.condition == x & g.cue1 == "yellow" & g.release1 == 0), od);
    trials_cond{2} = W.arrayfun(@(x)find(g.condition == x & g.cue1 == "purple" & g.release1 == 0), od);
%     cols = W.arrayfun(@(x)plt.interpolatecolors({'RSred', 'yellow', 'RSgreen'}, [min(dv), dv(od(5)), max(dv)], x), dv(od));
    cols = {'yellow', 'magenta'};
    for i = 1:9
        plt.ax(fi*2-1, i);
        av = [];
        se = [];
        for j = 1:2
            [av(j,:), se(j,:)] = W.avse(ep(trials_cond{j}{i},:));
            curve_yellowpurple2{fi,j}(i,:) = av(j,:);
        end
        plt.plot(all.time_at, av, [], 'line', 'color', cols);
        if ~any(isnan(av))
            plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'firing rate', ...
                'xlim', [-500 1000], 'legend', {'yellow', 'purple'}, ...
                'title', tlt{fi});
        end


        plt.ax(fi*2,i);
        width = 0.4;
        x0 = 0;
        for j = 1:2
            tst = st(ismember(st.trialID, trials_cond{j}{i}),:);
            x = W.horz(tst.spiketimes);
            tnt = length(unique(tst.trialID));
            tst.trialID = W.num2rank(tst.trialID);
            y = W.horz(tst.trialID) + x0;
            x0 = x0 + tnt;
            err = width*ones(size(x));
            plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', cols{j}, ...
                'CapSize', 0, 'MarkerSize', 1);
        end

        delays = [1 5 10];
        plt.setfig_ax('title', sprintf('delay %d, drop %d', delays(W.mod0(i, 3)), ceil(i/3)*2));

        plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 x0+1], ...
            'xlim', [-500 1000]);
    end
end

plt.update('onlyhold');
%% single cell summary
curve = curve_yellowpurple2;
av = {}; se = {};
pp = cell(1,2);
for i = 1:2
    for j = 1:2
        [av{i,j}, se{i,j}] = W.avse(curve{i,j});
    end
    [av{i,3}, se{i,3}] = W.avse(curve{i, 2} - curve{i, 1});
    [~, pp{i}] = ttest(curve{i, 2} - curve{i, 1});
end
plt.figure(2,2);
tlt = {'cue on', 'go cue'};
for fi = 1:2
    plt.ax(1, fi);
    cols = {'yellow', 'magenta'};
    plt.plot(all.time_at, [av{fi,1}; av{fi,2}], [se{fi,1}; se{fi,2}], 'shade', 'color', cols);
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'firing rate', 'xlim', [-500 1000], ...
        'legend', {'yellow', 'purple'}, 'title', tlt{fi});
    
    plt.ax(2, fi);
    plt.plot(all.time_at, [av{fi,3}], se{fi,3}, 'shade', 'color', 'black');
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'iff firing rate', 'xlim', [-500 1000]);

    plt.dashX(0);
    plt.sigstar(all.time_at, ones(size(all.time_at)) * min(av{fi,3} - se{fi,3}), pp{fi});
end
plt.update('summaryonlyhold');

%% single cell summary
curve = curve_releasehold;
av = {}; se = {};
pp = cell(1,2);
for i = 1:2
    for j = 1:2
        [av{i,j}, se{i,j}] = W.avse(curve{i,j});
    end
    [av{i,3}, se{i,3}] = W.avse(curve{i, 2} - curve{i, 1});
    [~, pp{i}] = ttest(curve{i, 2} - curve{i, 1});
end
plt.figure(2,2);
tlt = {'cue on', 'go cue'};
for fi = 1:2
    plt.ax(1, fi);
    cols = {'blue', 'black'};
    plt.plot(all.time_at, [av{fi,1}; av{fi,2}], [se{fi,1}; se{fi,2}], 'shade', 'color', cols);
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'firing rate', 'xlim', [-500 1000], ...
        'legend', {'release', 'hold'}, 'title', tlt{fi});
    
    plt.ax(2, fi);
    plt.plot(all.time_at, [av{fi,3}], se{fi,3}, 'shade', 'color', 'black');
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'iff firing rate', 'xlim', [-500 1000]);

    plt.dashX(0);
    plt.sigstar(all.time_at, ones(size(all.time_at)) * min(av{fi,3} - se{fi,3}), pp{fi});
end
plt.update('summary2');