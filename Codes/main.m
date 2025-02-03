looper = S_looper_folder('../Data/');
jobs = S_jobs();
jobs.set_loopers({'folder'}, {looper});
% jobs.power_off;
% %% value
% modelnames = "YP";
% i = 1;
% jobs.add_jobs_with_looper_folder([], 'function_model', ...
%     {'games_cue'}, {1}, {sprintf('result_RL_%s', modelnames(i))});
% jobs.add_jobs_with_looper_folder([], 'function_value', ...
%     {'games_cue', 'result_RL_YP'}, {'model_base'}, ...
%     {'games_value'});
% %% continuous ANOVA
% factornames = {'drop', 'delay', 'DV'};
factornames = {'DV', 'release1', 'choice', 'cue1'};
jobs.add_jobs_with_looper_folder([], 'W.anovan_slidingwindow', ...
    {'EPOCH_cue', 'games_value'}, ...
    {factornames, 'window_significance', [75 750], 'continuous', [1,2,3,4]}, ...
    {'anova_value_cont_normalized'});
jobs.add_jobs_with_looper_folder({'all', 'all'}, 'W.format_combinecells', ...
    {'anova_value_cont_normalized'}, {}, 'anova_value_cont_allcells_normalized');

factornames = {'DV', 'release1', 'choice', 'cue1'};
jobs.add_jobs_with_looper_folder([], 'W.anovan_slidingwindow', ...
    {'EPOCH_go', 'games_value'}, ...
    {factornames, 'window_significance', [75 750], 'continuous', [1,2,3,4]}, ...
    {'anova_GOvalue_cont_normalized'});
jobs.add_jobs_with_looper_folder({'all', 'all'}, 'W.format_combinecells', ...
    {'anova_GOvalue_cont_normalized'}, {}, 'anova_GOvalue_cont_allcells_normalized');
%%
jobs.parfor_on;
jobs.overwrite_on;
jobs.run()
%%
% dp = coef(:,1);
% dl = coef(:,2);
% dv = coef(:,3);
% %% get average firing per condition for each cell. 
% cue = W.load('../Data/cue_all');
% go = W.load('../Data/go_all');
% ddd = W.unique(cue.games{1}(:, ["condition", "drop","delay"]));
% %%
% AAA = inv(coef' * coef) * coef';
% 
% allcue = get_all_traj(cue);
% Xcue = W.cellfun(@(x)AAA * x', allcue)';
% Xcue = W.cell_NxMK2KxMN(W.cellfun(@(x)x',Xcue));
% 
% 
% allgo = get_all_traj(go);
% Xgo = W.cellfun(@(x)AAA * x', allgo)';
% Xgo = W.cell_NxMK2KxMN(W.cellfun(@(x)x',Xgo));
% %% delay decoded
% plt = SW_plt_from_yml('fig.yml');
% plt.figure(2,3, 'gapW_custom', [0 0 0 7]);
% tlts = {'drop', 'delay', 'DV'};
% for i = 1:3
%     plt.ax(1,i);
%     cols = ["AZred20","AZcactus20","AZblue20", "AZred50","AZcactus50","AZblue50", "AZred","AZcactus","AZblue"];
%     plt.plot(cue.time_at, Xcue{i}', [], 'line', 'color', cols);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue');
%     plt.ax(2,i);
%     plt.plot(go.time_at, Xgo{i}', [], 'line', 'color', cols);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go');
%     if i == 3
%         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
%         plt.setfig_ax('legend', legs, 'legloc', 'EO');
%     end
% end
% plt.update('decoded_traj');
% %%
% plt.figure(1,2, 'gapW_custom', [0.5 0 0.5]);
% names = d.anova_setting.factornames_anova;
% for i = 1:2
%     ii = setdiff(1:3, 3-i);
%     tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
%     plt.ax(i);
%     plt.scatter(AAA(ii(1),:)', AAA(ii(2),:)', 'corr');
%     plt.setfig_ax('ylabel', ['Coding dimension for ' names(ii(1))], 'xlabel', 'Coding dimension for discounted value', ...
%         'title', tlt);
% end
% plt.update('DV vs drop delay inv');
% %%
% YP = cell(2,2);
% op = ["hold","unhold"];%"YP", "release", "accept"];
% for i = 1:2
%     allcueYP = get_all_trajYP(cue,op(i));
%     XcueYP = W.cellfun(@(x)AAA * W.changem(x, 0)', allcueYP)';
%     YP{1,i} = W.cell_NxMK2KxMN(W.cellfun(@(x)x',XcueYP));
% 
% 
%     allgoYP = get_all_trajYP(go,op(i));
%     XgoYP = W.cellfun(@(x)AAA * W.changem(x, 0)', allgoYP)';
%     YP{2,i} = W.cell_NxMK2KxMN(W.cellfun(@(x)x',XgoYP));
% end
% %%
% 
% plt.figure(4,3, 'gapW_custom', [0 0 0 0]);
% tlts = {'drop', 'delay', 'DV'};
% ylms = {[-2,2], [-4,4], [-1,1]};
% for i = 1:3
%     plt.ax(1,i);
%     cols = 'black';
%     [av,se] = W.avse(YP{1,1}{i}');
%     plt.plot(cue.time_at, av, se, 'shade', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
%     plt.setfig_ax('ylim', ylms{i});
%     plt.ax(2,i);
%     [av,se] = W.avse(YP{2,1}{i}');
%     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
% %     if i == 3
% %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
% %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
% %     end
%     plt.setfig_ax('ylim', ylms{i});
% 
% 
%     plt.ax(3,i);
%     [av,se] = W.avse(YP{1,2}{i}');
%     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (release)');
%     plt.setfig_ax('ylim', ylms{i});
%     plt.ax(4,i);
%     [av,se] = W.avse(YP{2,2}{i}');
%     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (release)');
%     plt.setfig_ax('ylim', ylms{i});
% %     plt.ax(4,i);
% %     [av,se] = W.avse(YP{2,3}{i}');
% %     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
% %     plt.dashX(0);
% %     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (accept)');
% %     plt.setfig_ax('ylim', ylms{i});
% end
% plt.update('YP');
% 
% %%
% 
% plt.figure(4,3, 'gapW_custom', [0 0 0 0]);
% tlts = {'drop', 'delay', 'DV'};
% ylms = {[-2,2], [-4,4], [-1,1]};
% for i = 1:3
%     plt.ax(1,i);
%     cols = ["AZred20","AZcactus20","AZblue20", "AZred50","AZcactus50","AZblue50", "AZred","AZcactus","AZblue"];
%     se = [];
%     av = YP{1,1}{i}';
%     plt.plot(cue.time_at, av, se, 'line', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
% %     plt.setfig_ax('ylim', ylms{i});
%     plt.ax(2,i);
%     av = YP{2,1}{i}';
%     plt.plot(go.time_at, av, se, 'line', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
% %     if i == 3
% %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
% %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
% %     end
% %     plt.setfig_ax('ylim', ylms{i});
% 
% 
%     plt.ax(3,i);
%     av = YP{1,2}{i}';
%     plt.plot(go.time_at, av, se, 'line', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (release)');
% %     plt.setfig_ax('ylim', ylms{i});
%     plt.ax(4,i);
%     av = YP{2,2}{i}';
%     plt.plot(go.time_at, av, se, 'line', 'color', cols);
%     plt.dashX(0);
%     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (release)');
% %     plt.setfig_ax('ylim', ylms{i});
% %     plt.ax(4,i);
% %     [av,se] = W.avse(YP{2,3}{i}');
% %     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
% %     plt.dashX(0);
% %     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (accept)');
% %     plt.setfig_ax('ylim', ylms{i});
% end
% plt.update('YP2');
