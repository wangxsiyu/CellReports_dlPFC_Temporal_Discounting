kfold = 2;
results = cell(1,2);
plt.figure(3,2)
for ai = 1:2
    d = cue{ai};
    d = W.combinedcells_removeNAtrials(d);
    nmin = W.cellfun(@(x)min(W.count_cond(x.condition,1:9)), d.games);
    idx = find(nmin >= 10);
    idcell = ismember(d.info_cells.gameID, idx);
    d.info_cells = d.info_cells(idcell,:);
    d.cells = d.cells(idcell);

    [tr0, te0] = W.combinedcells_kfoldtrials_bycond(d, kfold, 'condition');
    W.print('loop %d', ai);
    W.print_mute_on;
    for i = 1:1
        tr = W.pseudo_sampletrials_bycond(tr0{i}, 'condition', 80);
        te = W.pseudo_sampletrials_bycond(te0{i}, 'condition', 80);
        factornames = {'drop', 'delay', 'choice'};
        model = [1,0,0;0,1,0;1,1,0;0,0,1];
        anv1 = W.anovan_slidingwindow(tr, tr.games, factornames, 'continuous', [1 2], 'is_normalize', false);
        anv2 = W.anovan_slidingwindow(te, te.games, factornames, 'continuous', [1 2], 'is_normalize', false);

        ncell = length(tr.cells);
        ntime = size(tr.cells{1},2);
        vdrop1 = NaN(ncell, ntime);
        vdelay1 = NaN(ncell, ntime);

        vdrop2 = NaN(ncell, ntime);
        vdelay2 = NaN(ncell, ntime);
        for ti = 1:ntime
            vdrop1(:, ti) = W.cellfun(@(x)x.coef_factors_terms(2,ti), anv1.cells)';
            vdelay1(:, ti) = W.cellfun(@(x)x.coef_factors_terms(3,ti), anv1.cells)';

            vdrop2(:, ti) = W.cellfun(@(x)x.coef_factors_terms(2,ti), anv2.cells)';
            vdelay2(:, ti) = W.cellfun(@(x)x.coef_factors_terms(3,ti), anv2.cells)';
        end

        results{ai} = W.struct('vdrop1', vdrop1, 'vdrop2', vdrop2, 'vdelay1', vdelay1, 'vdelay2', vdelay2);
        plt.ax(1,ai);
        [r, p] = corr(vdrop1, vdrop2);
        plt.imagesc(timeat, timeat, r, 'AlphaData', p < 0.05);
        plt.setfig_ax('xlabel', 'drop', 'ylabel', 'drop', 'title', tlt{ai});
        plt.ax(2,ai);
        [r, p] = corr(vdelay1, vdelay2);
        plt.imagesc(timeat, timeat, r, 'AlphaData', p < 0.05);
        plt.setfig_ax('xlabel', 'delay', 'ylabel', 'delay')
        plt.ax(3,ai);
        [r, p] = corr([vdelay1;vdelay2], [vdrop2;vdrop1]);
        plt.imagesc(timeat, timeat, r, 'AlphaData', p < 0.05);
        plt.setfig_ax('xlabel', 'drop', 'ylabel', 'delay')

    end
end
plt.update;