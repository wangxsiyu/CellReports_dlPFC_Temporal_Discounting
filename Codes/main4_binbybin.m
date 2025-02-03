animals = {"S","T", ["S","T"]};
saveanimals = ["S", "T", "all"];
for ai = 1:3
    d = W.load('../Data/anova_GOvalue_cont_allcells_normalized');
    d2 = W.load('../Data/anova_value_cont_allcells_normalized');
    cue = W.load('../Data/cue_all');
    go = W.load('../Data/go_all');
    idcell = ismember(d.info_cells.animal, animals{ai});
    ago = W.select_cells(d, idcell);
    acue = W.select_cells(d2, idcell);
    cue = W.select_cells(cue, idcell);
    go = W.select_cells(go, idcell);
    ddd = W.unique(cue.games{1}(:, ["condition", "drop","delay"]));

    tm = acue.anova_setting.time_at;
    coef = NaN(sum(idcell), 4);

    for i = 1:4
        ddcue{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), acue.cells);
        ddgo{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), ago.cells);
    end

    allcue = get_all_traj(cue);  
    allgo = get_all_traj(go);
    Xcue = repmat({NaN(4,171)},1,9);
    Xgo = repmat({NaN(4,171)},1,9);
    for ti = 1:171
        coef = W.arrayfun_horzcat(@(x)ddcue{x}(:, ti), 1:4);
        AAA = inv(coef' * coef) * coef';
        coef = W.arrayfun_horzcat(@(x)ddgo{x}(:, ti), 1:4);
        BBB = inv(coef' * coef) * coef';
        for j = 1:9
            Xcue{j}(:,ti) = AAA * allcue{j}(ti,:)';
            Xgo{j}(:,ti) = BBB * allgo{j}(ti,:)';
        end
    end
    Xcue = W.cell_NxMK2KxMN(W.cellfun(@(x)x',Xcue));
    Xgo = W.cell_NxMK2KxMN(W.cellfun(@(x)x',Xgo));

    %% delay decoded
    plt = SW_plt_from_yml('fig.yml');
    plt.figure(2,4, 'gapW_custom', [0 0 0 0 7]);
    tlts = {'DV', 'release', 'choice', 'cue'};
    for i = 1:4
        plt.ax(1,i);
        cols = ["AZred20","AZcactus20","AZblue20", "AZred50","AZcactus50","AZblue50", "AZred","AZcactus","AZblue"];
        plt.plot(cue.time_at, Xcue{i}', [], 'line', 'color', cols);
        plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue');
        plt.ax(2,i);
        plt.plot(go.time_at, Xgo{i}', [], 'line', 'color', cols);
        plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go');
        if i == 4
            legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
            plt.setfig_ax('legend', legs, 'legloc', 'EO');
        end
    end
    plt.update(W.file_prefix('%s_decoded_traj', saveanimals(ai)));
    %%
    plt.figure(1,3, 'gapW_custom', [0.5 0 0 0.5]);
    names = d.anova_setting.factornames_anova;
    for i = 1:3
        ii = [1 i+1];%setdiff(1:3, 3-i);
        tlt = sprintf('%s vs %s', names(ii(1)), names(ii(2)));
        plt.ax(i);
        plt.scatter(AAA(ii(1),:)', AAA(ii(2),:)', 'corr');
        plt.setfig_ax('ylabel', ['Coding dimension for ' names(ii(1))], 'xlabel', 'Coding dimension for discounted value', ...
            'title', tlt);
    end
    plt.update(W.file_prefix('%s_DV vs drop delay inv', saveanimals(ai)));
%     %%
%     YP = cell(2,1);
%     op = ["accept"];
%     for i = 1:1
%         allcueYP = get_all_trajYP(cue,op(i));
%         XcueYP = W.cellfun(@(x)AAA * W.changem(x, 0)', allcueYP)';
%         YP{1,i} = W.cell_NxMK2KxMN(W.cellfun(@(x)x',XcueYP));
% 
% 
%         allgoYP = get_all_trajYP(go,op(i));
%         XgoYP = W.cellfun(@(x)AAA * W.changem(x, 0)', allgoYP)';
%         YP{2,i} = W.cell_NxMK2KxMN(W.cellfun(@(x)x',XgoYP));
%     end
    %%
% 
%     plt.figure(2,5, 'gapW_custom', [0 0 0 0 0 0]);
%     tlts = {'drop', 'delay', 'DV', 'release', 'choice'};
%     ylms = {[-2,2], [-4,4], [-1,1]};
%     for i = 1:5
%         plt.ax(1,i);
%         cols = ["AZred20","AZcactus20","AZblue20", "AZred50","AZcactus50","AZblue50", "AZred","AZcactus","AZblue"];
%         se = [];
%         av = YP{1,1}{i}';
%         plt.plot(cue.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
%         %     plt.setfig_ax('ylim', ylms{i});
%         plt.ax(2,i);
%         av = YP{2,1}{i}';
%         plt.plot(go.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
%         %     if i == 3
%         %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
%         %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
%         %     end
%         %     plt.setfig_ax('ylim', ylms{i});
%     end
%     plt.update(W.file_prefix('%s_YP2accept', saveanimals(ai)));
%     %%
%     plt.figure(2,5, 'gapW_custom', [0 0 0 0 0 0]);
%     tlts = {'drop', 'delay', 'DV', 'release', 'choice'};
%     ylms = {[-2,2], [-4,4], [-1,1], [], []};
%     for i = 1:5
%         plt.ax(1,i);
%         cols = 'black';
%         [av,se] = W.avse(YP{1,1}{i}');
%         plt.plot(cue.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
%         plt.setfig_ax('ylim', ylms{i});
%         plt.ax(2,i);
%         [av,se] = W.avse(YP{2,1}{i}');
%         plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
%         %     if i == 3
%         %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
%         %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
%         %     end
%         plt.setfig_ax('ylim', ylms{i});
% 
% 
%     end
%     plt.update(W.file_prefix('%s_YP', saveanimals(ai)));

    %%
% 
%     plt.figure(4,3, 'gapW_custom', [0 0 0 0]);
%     tlts = {'drop', 'delay', 'DV'};
%     ylms = {[-2,2], [-4,4], [-1,1]};
%     for i = 1:3
%         plt.ax(1,i);
%         cols = 'black';
%         [av,se] = W.avse(YP{1,1}{i}');
%         plt.plot(cue.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
%         plt.setfig_ax('ylim', ylms{i});
%         plt.ax(2,i);
%         [av,se] = W.avse(YP{2,1}{i}');
%         plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
%         %     if i == 3
%         %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
%         %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
%         %     end
%         plt.setfig_ax('ylim', ylms{i});
% 
% 
%         plt.ax(3,i);
%         [av,se] = W.avse(YP{1,2}{i}');
%         plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (release)');
%         plt.setfig_ax('ylim', ylms{i});
%         plt.ax(4,i);
%         [av,se] = W.avse(YP{2,2}{i}');
%         plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (release)');
%         plt.setfig_ax('ylim', ylms{i});
%         %     plt.ax(4,i);
%         %     [av,se] = W.avse(YP{2,3}{i}');
%         %     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         %     plt.dashX(0);
%         %     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (accept)');
%         %     plt.setfig_ax('ylim', ylms{i});
%     end
%     plt.update('YP');
% 
%     %%
%     %
%     plt.figure(4,3, 'gapW_custom', [0 0 0 0]);
%     tlts = {'drop', 'delay', 'DV'};
%     ylms = {[-2,2], [-4,4], [-1,1]};
%     for i = 1:3
%         plt.ax(1,i);
%         cols = ["AZred20","AZcactus20","AZblue20", "AZred50","AZcactus50","AZblue50", "AZred","AZcactus","AZblue"];
%         se = [];
%         av = YP{1,1}{i}';
%         plt.plot(cue.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (hold)');
%         %     plt.setfig_ax('ylim', ylms{i});
%         plt.ax(2,i);
%         av = YP{2,1}{i}';
%         plt.plot(go.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (hold)');
%         %     if i == 3
%         %         legs = arrayfun(@(x)sprintf("drop = %d, delay = %d", ddd.drop(x), ddd.delay(x)), 1:9);
%         %         plt.setfig_ax('legend', legs, 'legloc', 'EO');
%         %     end
%         %     plt.setfig_ax('ylim', ylms{i});
% 
% 
%         plt.ax(3,i);
%         av = YP{1,2}{i}';
%         plt.plot(go.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'cue (release)');
%         %     plt.setfig_ax('ylim', ylms{i});
%         plt.ax(4,i);
%         av = YP{2,2}{i}';
%         plt.plot(go.time_at, av, se, 'line', 'color', cols);
%         plt.dashX(0);
%         plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (release)');
%         %     plt.setfig_ax('ylim', ylms{i});
%         %     plt.ax(4,i);
%         %     [av,se] = W.avse(YP{2,3}{i}');
%         %     plt.plot(go.time_at, av, se, 'shade', 'color', cols);
%         %     plt.dashX(0);
%         %     plt.setfig_ax('xlim', [-500 1000], 'title', tlts{i}, 'ylabel', 'go (accept)');
%         %     plt.setfig_ax('ylim', ylms{i});
%     end
%     plt.update('YP2');
end
