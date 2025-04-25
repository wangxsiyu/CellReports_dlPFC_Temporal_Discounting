data = W.load('../../TempData/data');
cue = data.cue;
cue{3} = W.format_combinecells(cue);
plt = SW_plt_from_yml('../fig.yml');
drop = plt.custom_vars.drop;
delay = plt.custom_vars.delay;
timeat = cue{1}.time_at;
ntime = length(timeat);
tlt = {'Monkey 1', 'Monkey 2', 'all data'};
%% cue period
%% ANOVA: drop + delay + interaction + choice (baseline)
factornames = {'drop', 'delay', 'choice'};
model = [1,0,0;0,1,0;1,1,0;0,0,1];
anv = {};
for i = 1:2
    d = cue{i};
    anv{i} = W.anovan_slidingwindow_combinedgames(d, factornames, 'model', model);
end
anv{3} = W.format_combinecells(anv);
W.save('../../TempData/result/anv_drop_delay_interaction_choice', 'anv', anv);
%% Figure - baseline
anv = W.load('../../TempData/result/anv_drop_delay_interaction_choice');
SW_fig(plt, anv{1}, anv{2}, anv{3}, ...
    'axes', 'ax_slidingwindow_ANOVA','ax_slidingwindow_ANOVA','ax_slidingwindow_ANOVA', ...
    'ax_slidingwindow_ANOVA_omega','ax_slidingwindow_ANOVA_omega','ax_slidingwindow_ANOVA_omega', ...
     'data_axes', 1, 2, 3, 1, 2, 3,  ...
     'varargin_axes', {'plottype', 'shade', ...
     'legloc', 'NW', 'xlim', [-500, 1000], 'ylim', [-0.02 0.7], 'ytick', -1:.2:1, 'title', 'Monkey 1'}, ...
     {'plottype', 'shade', ...
     'legloc', 'NW', 'xlim', [-500, 1000], 'ylim', [-0.02 0.7], 'ytick', -1:.2:1, 'title', 'Monkey 2'}, ...
     {'plottype', 'shade', ...
     'legloc', 'NW', 'xlim', [-500, 1000], 'ylim', [-0.02 0.7], 'ytick', -1:.2:1, 'title', ''}, ...
     {'plottype', 'shade', ...
     'legloc', 'NE', 'xlim', [-500, 1000], 'ylim', [-0.001 0.035], 'ytick', [-0.05:0.01:0.05]}, ...
     {'plottype', 'shade', ...
     'legloc', 'NE', 'xlim', [-500, 1000], 'ylim', [-0.001 0.035], 'ytick', [-0.05:0.01:0.05]}, ...
     {'plottype', 'shade', ...
     'legloc', 'NE', 'xlim', [-500, 1000], 'ylim', [-0.001 0.035], 'ytick', [-0.05:0.01:0.05]}, ...
     'ABC_axes', 'ABACDB', 'nx', 2, 'ny', 3, ...
     'varargin_fig', 'is_title', 'all', 'savename', 'ANOVA_drop_delay_interaction_choice');
%%
section_drop_delay;
%%
section_shuffle_drop_delay;
%%
section_drop_delay_dV_wrong;
%%
section_shuffle_drop_delay_wrong;
%%
section_drop_delay_dV;
%%
section_shuffle_drop_delay_dV;
%% decoding analysis
kfold = 5;
results = cell(1,3);
for ai = 1:3
    d = cue{ai};
    d = W.combinedcells_removeNAtrials(d);
    nmin = W.cellfun(@(x)min(W.count_cond(x.condition,1:9)), d.games);
    idx = find(nmin >= 10);
    idcell = ismember(d.info_cells.gameID, idx);
    d.info_cells = d.info_cells(idcell,:);
    d.cells = d.cells(idcell);

    [tr0, te0] = W.combinedcells_kfoldtrials_bycond(d, kfold, 'condition');
    out = cell(1,kfold);
    W.print('loop %d', ai);
    W.print_mute_on;
    for i = 1:kfold
        tr = W.pseudo_sampletrials_bycond(tr0{i}, 'condition', 80);
        te = W.pseudo_sampletrials_bycond(te0{i}, 'condition', 80);

        m1 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.delay, 'SVM', 'train', 'SVMfunc', 'discrete');
        r1 = W.neuro_decode_slidingwindow(te, 'cells', te.games.delay, m1.models, 'test', 'SVMfunc', 'discrete');

        m2 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.drop, 'SVM', 'train', 'SVMfunc', 'discrete');
        r2 = W.neuro_decode_slidingwindow(te, 'cells', te.games.drop, m2.models, 'test', 'SVMfunc', 'discrete');

        m3 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.condition, 'SVM', 'train', 'SVMfunc', 'discrete');
        r3 = W.neuro_decode_slidingwindow(te, 'cells', te.games.condition, m3.models, 'test', 'SVMfunc', 'discrete');

        out{i} = W.struct('r_delay', r1, 'r_drop', r2, 'r_interaction', r3)
    end
    W.print_mute_off;
    results{ai} = out;
end
W.save('decoding', 'result', results);
%%
plt.figure(3,3, 'is_title', 'all')
for ai = 1:3
    r0 = results{ai};
    r = cell(1,3);
    r{1} = W.cellfun_vertcat(@(x)x.r_delay.ac_decode, r0);
    r{2} = W.cellfun_vertcat(@(x)x.r_drop.ac_decode, r0);
    r{3} = W.cellfun_vertcat(@(x)x.r_interaction.ac_decode, r0);
    chance = [1/3, 1/3, 1/9];
%     tlt = {'drop', 'delay', 'Drop x Delay'};
    for i = 1:3
        plt.ax(i, ai);
        [av, se] = W.avse(r{i});
        plt.plot(timeat, av, se, 'shade', 'color', plt.custom_vars.color_anova{i});
        plt.dashX(chance(i));
        plt.dashY(0, [0 1]);
        plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'decoding accuracy', 'title', tlt{ai}, ...
            'xlim', [-500 1000]);
        if i == 3
            [av1, se1] = W.avse(r{1}.*r{2});
            [p] = W.stat_ttest(r{1}.*r{2}, r{3});
            tid = find(timeat > -500 & timeat < 1000);
            plt.plot(timeat, av1, se1, 'shade', 'color', 'black');
            plt.sigstar(timeat(tid), av(tid) + se(tid) + 0.01, p(tid), 'dx', 25)
            plt.setfig_ax('legend', {'data','independence'}, 'ylim', [0 1]);
        else
            plt.setfig_ax('ylim', [0 1]);
        end
    end
end
plt.update('decode');
%% SVM decoder for drop, delay, value

kfold = 2;
results = cell(1,3);
for ai = 1:3
    d = cue{ai};
    d = W.combinedcells_removeNAtrials(d);
    nmin = W.cellfun(@(x)min(W.count_cond(x.condition,1:9)), d.games);
    idx = find(nmin >= 10);
    idcell = ismember(d.info_cells.gameID, idx);
    d.info_cells = d.info_cells(idcell,:);
    d.cells = d.cells(idcell);

    [tr0, te0] = W.combinedcells_kfoldtrials_bycond(d, kfold, 'condition');
    out = cell(1,kfold);
    W.print('loop %d', ai);
    W.print_mute_on;
    for i = 1
        tr = W.pseudo_sampletrials_bycond(tr0{i}, 'condition', 80);
        te = W.pseudo_sampletrials_bycond(te0{i}, 'condition', 80);

        m1 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.delay, 'SVM', 'train', 'SVMfunc', 'continuous');
        r1 = W.neuro_decode_slidingwindow(te, 'cells', te.games.delay, m1.models, 'test', 'SVMfunc', 'continuous');

        m2 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.drop, 'SVM', 'train', 'SVMfunc', 'continuous');
        r2 = W.neuro_decode_slidingwindow(te, 'cells', te.games.drop, m2.models, 'test', 'SVMfunc', 'continuous');

        m3 = W.neuro_decode_slidingwindow(tr, 'cells', tr.games.condition, 'SVM', 'train', 'SVMfunc', 'continuous');
        r3 = W.neuro_decode_slidingwindow(te, 'cells', te.games.condition, m3.models, 'test', 'SVMfunc', 'continuous');

        out{i} = W.struct('r_delay', r1, 'r_drop', r2, 'r_interaction', r3)
    end
    W.print_mute_off;
    results{ai} = out;
end
W.save('decodingC', 'result', results);