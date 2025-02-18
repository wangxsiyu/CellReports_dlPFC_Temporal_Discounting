d = W.load('./anova_GOvalue_cont_allcells_normalized');
% idcell = ismember(d.info_cells.animal, animals{ai});
% d = W.select_cells(d, idcell);
tm = d.anova_setting.time_at;
dd = cell(1,3);
for i = 1:4
    dd{i} = W.cellfun_vertcat(@(x)x.coef_factors_terms(i+1,:), d.cells);
end
rr = {}; pp = {};
for i = 1:length(tm)
    coef = W.cellfun_horzcat(@(x)x(:, i), dd);
    % AAA = inv(coef' * coef) * coef';
    [rr{i}, pp{i}] = corr(coef, coef);
end

rrr = {}; ppp = {};
for i = 1:4
    for j = 1:4
        rrr{i,j} = W.cellfun(@(x)x(i,j), rr);
        ppp{i,j} = W.cellfun(@(x)x(i,j), pp);
    end
end

%%

plt.figure(3,3,'matrix_hole', [1 1 1; 0 1 1; 0 0 1]);%, 'gapW_custom', [0.5 0 0.5]);
names = d.anova_setting.factornames_anova;
for i = 1:3
    for j = (i+1):4
        plt.ax(i, j-1);
        
        tlt = sprintf('%s vs %s', names(i), names(j));
        plt.plot(tm, rrr{i,j}, [], 'line');
        plt.sigstar(tm, 0 * tm, ppp{i,j});
        plt.setfig_ax('ylabel', ['Coding dimension for ' names(j)], ...
            'xlabel', ['Coding dimension for ' names(i)], ...
            'title', tlt);
    end
end
plt.update(W.file_prefix('%s_DV vs drop delay inv', 'all'));