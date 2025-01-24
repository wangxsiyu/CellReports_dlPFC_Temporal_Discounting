data_go = W.load('../Data/go_all.mat');
data_cue = W.load('../Data/cue_all.mat');
plt = S_plt;
% yellow release = reject
% purple release = accept
%% for each cell, calculate its response for yellow/purple, for hold/release trials separately
ncell = length(data_go.cells);
info = data_go.info_cells;
result = info;
result.FR_yellow_hold = cell(ncell, 1);
result.FR_yellow_release = cell(ncell, 1);
result.FR_purple_hold = cell(ncell, 1);
result.FR_purple_release = cell(ncell, 1);
result.FR_cue = cell(ncell, 1);
for ci = 1:ncell
    sp_go = data_go.cells{ci};
    sp_cue = data_cue.cells{ci};
    g = data_go.games{info.gameID(ci)};

    id_yellow = g.cue1 == "yellow";
    id_hold = g.release1 == 0;
    for cuei = 1:9
        id_cue = g.condition == cuei;
        % hold
        result.n_yellow_hold(ci, cuei) = sum(id_yellow & id_hold & id_cue);
        result.n_purple_hold(ci, cuei) = sum(~id_yellow & id_hold & id_cue);
        result.FR_yellow_hold{ci}(cuei,:) = mean(sp_go(id_yellow & id_hold & id_cue,:), 1);
        result.FR_purple_hold{ci}(cuei,:) = mean(sp_go(~id_yellow & id_hold & id_cue,:), 1);
        % release
        result.n_yellow_release(ci, cuei) = sum(id_yellow & ~id_hold & id_cue);
        result.n_purple_release(ci, cuei) = sum(~id_yellow & ~id_hold & id_cue);
        result.FR_yellow_release{ci}(cuei,:) = mean(sp_go(id_yellow & ~id_hold & id_cue,:), 1);
        result.FR_purple_release{ci}(cuei,:) = mean(sp_go(~id_yellow & ~id_hold & id_cue,:), 1);


        result.FR_cue{ci}(cuei,:) = mean(sp_go(id_cue,:), 1);
    end
end
seam = result(result.animal == "S",:);
tobias = result(result.animal == "T",:);
results = {seam, tobias};
delays = [1 5 10 1 5 10 1 5 10];
drop = [2 2 2 4 4 4 6 6 6];
%% behavior
plt.figure(1,2);
for ai = 1:2
    plt.ax(ai);
    result = results{ai};
    p_release_yellow = result.n_yellow_release ./ (result.n_yellow_hold + result.n_yellow_release);
    [av1, se1] = W.avse(p_release_yellow);
    p_release_purple = result.n_purple_release ./ (result.n_purple_hold + result.n_purple_release);
    [av2, se2] = W.avse(p_release_purple);
    plt.plot(1:9, [av1;av2], [se1;se2], 'line', 'color', {'yellow', 'magenta'});
    plt.setfig_ax('ylabel', 'p(release)', 'xtick', 1:9, ...
        'xticklabel', {'1s,2','5s,2','10s,2','1s,4','5s,4','10s,4','1s,6','5s,6','10s,6'});
end
plt.setfig('title', {'S', 'T'});
plt.update;
%% yellow - purple difference
plt.figure(2,2);
for ai = 1:2
    result = results{ai};
    n = size(result,1);
    pa = (result.n_purple_release + result.n_yellow_hold)./(result.n_purple_release + result.n_yellow_hold + result.n_yellow_release + result.n_purple_hold);
   
    sgn = [];
    for i = 1:n
        idt = data_cue.time_at > 0;
        fr_cue = result.FR_cue{i};
        tfr = fr_cue(:, idt);
        sgn(i) = sign(nanmean(corr(tfr, pa(i,:)')));           
    end

    fr_release_yellow_minus_purple = W.arrayfun(@(x)nanmean(sign(result.FR_yellow_release{x} - result.FR_purple_hold{x}) * sgn(x)), 1:n);
    fr_hold_yellow_minus_purple = W.arrayfun(@(x)nanmean(sign(result.FR_yellow_hold{x} - result.FR_purple_release{x}) * sgn(x)), 1:n);
    plt.ax(1,ai);
    [av, se] = W.cell_avse(fr_release_yellow_minus_purple);
    plt.plot(data_cue.time_at, av, se, 'line');
    plt.dashX(0)
    plt.ax(2,ai);
    [av, se] = W.cell_avse(fr_hold_yellow_minus_purple);
    plt.plot(data_cue.time_at, av, se, 'line');
    plt.dashX(0)
end
% plt.setfig('title', {'S', 'T'});
plt.update;