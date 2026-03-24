[games] = W.load_as_struct('../Data/games','csv');
games.files = W.strs_selectbetween2patterns(games.files, 'games_', '.csv');
%%
spikes = W.load('../Data/spiketrains_RF.mat');
spikes.filenames = W.strs_selectbetween2patterns(spikes.filenames, 'spikes_', '.mat');
spikes = W.merge_spiketrains_games(spikes, games, spikes.filenames, games.files);
W.save('../Data/data_RF.mat', 'data', spikes);
%%
epochs = W.load('../Data/epochs_go_RF.mat');
epochs.filenames = W.strs_selectbetween2patterns(epochs.filenames, '_', [], 2);
epochs = W.merge_spiketrains_games(epochs, games, epochs.filenames, games.files);
W.save('../Data/data_epoched_go_RF.mat', 'data', epochs);
%%
epochs = W.load('../Data/epochs_cue_RF.mat');
epochs.filenames = W.strs_selectbetween2patterns(epochs.filenames, '_', [], 2);
epochs = W.merge_spiketrains_games(epochs, games, epochs.filenames, games.files);
W.save('../Data/data_epoched_cue_RF.mat', 'data', epochs);
%% send merged file to separate folders
data = W.load('../Data/data_epoched_cue_RF.mat');
sessions = unique(data.idx_game);
for si = 1:length(sessions)
    tid = sessions(si) == data.idx_game;
    out = W.subset_epoched_spiketrains(data, tid);
    out.games = data.games{sessions(si)};
    out.timelock = unique(data.timelock(tid));
    out.filenames = unique(out.filenames);
    out = rmfield(out, 'idx_game');
    W.save(fullfile('../Data/datafinal', out.filenames, 'data_cue.mat'), 'data', out);
end
%% send merged file to separate folders
data = W.load('../Data/data_epoched_go_RF.mat');
sessions = unique(data.idx_game);
for si = 1:length(sessions)
    tid = sessions(si) == data.idx_game;
    out = W.subset_epoched_spiketrains(data, tid);
    out.games = data.games{sessions(si)};
    out.timelock = unique(data.timelock(tid));
    out.filenames = unique(out.filenames);
    out = rmfield(out, 'idx_game');
    W.save(fullfile('../Data/datafinal', out.filenames, 'data_go.mat'), 'data', out);
end
