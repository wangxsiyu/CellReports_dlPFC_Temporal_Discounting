function out = decode_singlerun(d, p, n_train, n_test)
    d = W.combinedcells_removeNAtrials(d);
    nmin = W.cellfun(@(x)min(W.count_cond(x.condition,1:9)), d.games);
    idx = find(nmin >= 10);
    idcell = ismember(d.info_cells.gameID, idx);
    d.info_cells = d.info_cells(idcell,:);
    d.cells = d.cells(idcell);

    [tr, te] = W.combinedcells_sampletrials_split_bycond(d, 0.75, 'condition');
    tr = W.pseudo_sampletrials_bycond(tr, 'condition', n_train);
    te = W.pseudo_sampletrials_bycond(te, 'condition', n_test);

    m1 = W.neuro_decode_slidingwindow(tr.cells, tr.games.delay, 'SVM', 'train');
    r1 = W.neuro_decode_slidingwindow(te.cells, te.games.delay, m1.models, 'test');

    m2 = W.neuro_decode_slidingwindow(tr.cells, tr.games.drop, 'SVM', 'train');
    r2 = W.neuro_decode_slidingwindow(te.cells, te.games.drop, m2.models, 'test');

    m3 = W.neuro_decode_slidingwindow(tr.cells, tr.games.condition, 'SVM', 'train');
    r3 = W.neuro_decode_slidingwindow(te.cells, te.games.condition, m3.models, 'test');
    
    out = W.struct('r_delay', r1, 'r_drop', r2, 'r_interaction', r3)
end