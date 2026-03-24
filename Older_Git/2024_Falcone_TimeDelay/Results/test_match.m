file = 'animal2_cell56';
a0 = load(sprintf('%s.mat', file));
a1 = a0.st_unsorted;
a2 = a0.st;
g = a0.games;
b1 = xlsread(sprintf('RF_%s.xlsx', file), 'NOT SORTED');
b2 = xlsread(sprintf('RF_%s.xlsx', file), 'SORTED');
%%
n = max(max(W.cellsize(a1)), size(b2,2));
a1 = W.cell_vertcat_cellfun(@(x)W.extend(x', n), a1);
a2 = W.cell_vertcat_cellfun(@(x)W.extend(x', n), a2);
%%
b = W.extend(b, n);
%%
[~, od] = sort(g.rt_cueon_to_cue1, 'descend');

figure, plot(g.rt_cueon_to_cue1, b1(:,1))
plt = W_plt; plt.figure; str = plt.scatter(od, b2(:,1), 'dot'); plt.setfig_ax('title', str); plt.update;
figure, plot(g.rt_cueon_to_cue1(od)*1000,'LineWidth', 2); hold on; plot(b1(b2(:,1),1))
%%
c1 = a1(:, 1:end-1);
c2 = b1(:, 2:end);
df = abs(c1 - c2/1000);
ismatch = mean(isnan(df) | df < 0.001,2)
mean(ismatch == 1)

df2 = abs(c1(ismatch < 1,1:end-1) - c2(ismatch < 1,2:end)/1000);
ismatch2 = mean(isnan(df2) | df2 < 0.001,2);
tid = find(ismatch < 1) .* (1~=ismatch2);
tid = tid(tid ~= 0);

c1(tid,:)
c2(tid,:)