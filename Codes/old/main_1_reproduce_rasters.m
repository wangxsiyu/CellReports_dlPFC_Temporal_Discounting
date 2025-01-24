data = W.load('../Data/spiketrains.mat');
%% 1-T, 2-S
animals = [2,1,2,1,1,2,1];
units = [56,11,52,52,14,53,58];
%%
plt = S_plt('savedir', '../Figures', 'issave', 1);
%%
for i = 1:length(animals)
    switch animals(i)
        case 1
            animal = "T";
        case 2
            animal = "S";
    end
    unit = units(i);
    uid = find(data.info_cells.cellID == unit & data.info_cells.animal == animal);
    st = data.cells{uid};
    g = data.games{data.info_cells.gameID(uid)};
    [~, od] = sort(g.rt_cueon_to_cue1, 'descend');
    straw = st;
    st.trialID = W.changem(st.trialID, 1:size(g,1), od);

    plt.figure;
    SW_ax(plt, 'rasterplot', st, 'xlim', [-500 1000]);
    savename = sprintf('animal%d_cell%d', animals(i), unit);
    plt.update(savename);
    W.save(fullfile('../Results/',savename), 'st', st, 'st_unsorted', straw, 'games',g);
end
%%
d1 = W.load('../Data/EPOCH_sigcells_all.mat');
%%
varargin = {'xlim', [-500 1000]};
uid = find(data.info_cells.cellID == 9 & data.info_cells.animal == "S");
st = data.cells{uid};
g = d1.games{data.info_cells.gameID(uid)};
spikes = st;
[~, od] = sort(g.DV, 'descend');
spikes.trialID = W.changem(st.trialID, 1:size(g,1), od);
plt.figure;
width = 0.4;
if iscell(spikes)
    y = [];
    x = [];
    for i = 1:length(spikes)
        x = [x, W.horz(spikes{i})];
        y = [y, i*ones(1,length(spikes{i}))];
    end
    ntrials = length(spikes);
else
    x = W.horz(spikes.spiketimes);
    y = W.horz(spikes.trialID);
    ntrials = max(y);
end
err = width*ones(size(x));
plt.plot(x, y, err, 'line', 'LineStyle', '.', 'color', 'black', ...
    'CapSize', 0, 'MarkerSize', 1);
plt.setfig_ax('xlabel', 'Time (ms)', 'ylabel', 'Trial No.', 'ylim', [0 ntrials+1], varargin{:});
plt.update;