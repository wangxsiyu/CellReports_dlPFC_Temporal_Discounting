infiles = {'EPOCH_sigcells', 'EPOCH_nonsigcells', 'EPOCH_sigcells_shuffled_trial', ...
    'EPOCH_sigcells_shuffled', ...
    'EPOCH_sigcells_final_non0', ...
    'EPOCH_sigcells_shuffled_rate'};
% for i = 1:length(infiles)
%     ds{i} = W.load(fullfile('../Data', W.file_suffix(infiles{i}, 'all')));
% end
dnames = {'data', 'non-sig cells', 'shuffled, trial', 'shuffled, time', 'data, non0', 'shuffled, rate'};
%%
fullin = fullfile('../Data', W.file_suffix(infiles, 'all'));
jobs = S_jobs;
for i = 1:length(infiles)
    for repi = 1:10
        outname = fullfile(replace(fullin{i}, 'EPOCH_', 'cv/'), ...
            sprintf('rep%d', repi));
        outname = replace(outname, 'Data', 'Results');
        jobs.add_jobs_withrank(1, 'decode_singlerun', {fullin{i}}, ...
            {.75, 60, 20}, outname);
    end
end
jobs.parfor_on;
jobs.run;
%%
plt = SW_plt_from_yml('fig.yml');
%%
time_at = [-600:10:1100];
plt.param_scale(1);
plt.figure(3, 6, 'is_title','1','scalefactor', 1);
outfiles = W.ls('../Results/cv');
outfiles = outfiles([2, 1, 6, 4, 3, 5]);
for ii = 1:6
    r0 = W.load(outfiles{ii});
    r0 = r0(1:10);
    r1 = W.cellfun(@(x)x.r_delay, r0, false);
    r2 = W.cellfun(@(x)x.r_drop, r0, false);
    r3 = W.cellfun(@(x)x.r_interaction, r0, false);
    r = cell(1,3);
    r{1} = W.cellfun_vertcat(@(x)x.ac_decode, r1);
    r{2} = W.cellfun_vertcat(@(x)x.ac_decode, r2);
    r{3} = W.cellfun_vertcat(@(x)x.ac_decode, r3);
    chance = [1/3, 1/3, 1/9];
    tlt = {'drop', 'delay', 'Drop x Delay'};
    for i = 1:3
        plt.ax(i, ii);
        [av, se] = W.avse(r{i});
        plt.plot(time_at, av, se, 'shade', 'color', plt.custom_vars.color_anova{i});
        plt.dashX(chance(i));
        plt.dashY(0, [0 1]);
        plt.setfig_ax('xlabel', 'time (ms)', 'title', W.iif(i == 1, dnames{ii}, ''), ...
            'ylabel', tlt{i}, ...
            'xlim', [-500 1000]);
        if i == 3
            [av1, se1] = W.avse(r{1}.*r{2});
            [p] = W.stat_ttest(r{1}.*r{2}, r{3});
            tid = find(time_at > -500 & time_at < 1000);
            plt.plot(time_at, av1, se1, 'shade', 'color', 'black');
            plt.sigstar(time_at(tid), av(tid) + se(tid) + 0.01, p(tid), 'dx', 25)
            plt.setfig_ax('legend', {'data','independence'}, 'ylim', [0 1]);
        else
            plt.setfig_ax('ylim', [0 1]);
        end
    end
end
plt.update('decode_all');
%%
%%
r0 = W.load('../Results/cv/sigcells_all');
r0 = r0(1:10);
% r1 = r.r_delay;
% r2 = r.r_drop;
% r3 = r.r_interaction;
plt.figure(1,3)
r = cell(1,3);
r{1} = W.cellfun_vertcat(@(x)x.r_delay.ac_decode, r0);
r{2} = W.cellfun_vertcat(@(x)x.r_drop.ac_decode, r0);
r{3} = W.cellfun_vertcat(@(x)x.r_interaction.ac_decode, r0);
chance = [1/3, 1/3, 1/9];
tlt = {'drop', 'delay', 'Drop x Delay'};
for i = 1:3
    plt.ax(i);
    [av, se] = W.avse(r{i});
    plt.plot(time_at, av, se, 'shade', 'color', plt.custom_vars.color_anova{i});
    plt.dashX(chance(i));
    plt.dashY(0, [0 1]);
    plt.setfig_ax('xlabel', 'time (ms)', 'ylabel', 'decoding accuracy', 'title', tlt{i}, ...
        'xlim', [-500 1000]);
    if i == 3
        [av1, se1] = W.avse(r{1}.*r{2});
        [p] = W.stat_ttest(r{1}.*r{2}, r{3});
        tid = find(time_at > -500 & time_at < 1000);
        plt.plot(time_at, av1, se1, 'shade', 'color', 'black');
        plt.sigstar(time_at(tid), av(tid) + se(tid) + 0.01, p(tid), 'dx', 25)
        plt.setfig_ax('legend', {'data','independence'}, 'ylim', [0 1]);
    else
        plt.setfig_ax('ylim', [0 1]);
    end
end
plt.update('decode');