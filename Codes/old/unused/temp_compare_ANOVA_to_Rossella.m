file = '../Results/info_ANOVA.csv';
opts = detectImportOptions(file);
opts.VariableTypes{3} = 'char';
info = W.readtable(file, opts);
%% compare with Rossella's old excel
% rs = W.readtable('../Results/Rossella/2_way_ANOVA.xlsx');
%% compare with Rossella's 2nd excel
rs = W.readtable('../Results/Rossella/ANOVA_FOR_SIYU.xlsx');
rs = rs(W.cellsize(rs.ANIMAL) ~= 0,:);
rs = sortrows(rs, 'ANIMAL');
% rs = rs(rs.ANIMAL == "SEAM" & ismember(rs.ID_CELL, info.cellID), :);
%% compare rs with info
sig_siyu = find(info.perc_significant == 1);
sig_rs = find(any(table2array(rs(:,3:5)) < 0.05,2));
info(setdiff(sig_siyu, sig_rs),:)
info(setdiff(sig_rs, sig_siyu),:)
rs(setdiff(sig_siyu, sig_rs),:)
rs(setdiff(sig_rs, sig_siyu),:)
ismatch = max(abs(table2array(rs(:,3:5)) - table2array(info(:, 5:7))),[],2) < 0.001;
nmatch = sum(ismatch);
info(find(~ismatch),:)
rs(find(~ismatch),:)
%% hack
rest = rs(find(~ismatch),:)
%% compare cells
ep = W.load('../Data/epoch_75_750.mat');
animal = ["T", "S"];
animalfull = ["Tobias", "Seam"];
% st = W.load('../Data/spiketrains');
%% compare ANOVA input
ai = 2;
cellID = 72;
file = sprintf('../Results/Rossella/%s_CELL_%d.xlsx', animalfull(ai), cellID);
rs = W.readtable(file);
cid = find(ep.info_cells.animal == animal(ai) & ep.info_cells.cellID == cellID);
% check trials
length(ep.cells{cid})
length(rs.Var5)
tg = ep.games{ep.info_cells.gameID(cid)};
% tst = st.cells{cid};
t1 = [tg.delay, tg.drop, ep.cells{cid}];
t1 = t1(~isnan(t1(:,3)),:);

t2 = [rs.Var1, rs.Var2, rs.Var5];
t2(:,2) = t2(:,2) - 2020;
delays = [1 5 10];
t2(:,1) = delays(t2(:,1) - 2010);
nmin = min(size(t1,1), size(t2,1));
all(all(t1(1:nmin,:) == t2(1:nmin, :),2))
find(~(all(t1(1:nmin,:) == t2(1:nmin, :),2)), 1)
% check counts
tid = find(ep.cells{cid} ~= rs.Var5);
ep.cells{cid}(tid,:)
rs.Var5(tid)
%% check event code/trial mismatch
session = 'S160719';
session1 = 'seam_190716';
a = W.load(sprintf('../lPFC_DATA/MONKEY_SEAM/EVENTS_FILES_MODIFIED/ALLINEAMENTO_1002/%s.mat', session1));
b = W.load(sprintf('../Data/%s/trials.mat', session));
aa = a.codici(:, [1 2 3 5 6 8]);
bb = b.events.eventmarkers(:, [3 4 6 10 11 14]);
e = W.load(sprintf('../Data/%s/events.mat', session));
find(bb(:,1)~= 1002)
%%
bb = b.events.eventmarkers;
bb = bb(bb(:,42) == 3199,:);

