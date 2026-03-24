files = W.ls('../../Data/spikes');
%%
for i = 1:length(files)
    spikes = W.load(files(i));
    trials = W.load(replace(files(i), 'spikes', 'trials'));
    %% epoch continuous
    savename = fullfile('../Data/spiketrains', replace(files(i), 'spikes', 'spiketrains'));
    if ~exist(savename, 'file')
        epochs = W.epoch_spiketrains_by_marker(spikes.spikes, trials.tab.timestamps, trials.tab.eventmarkers, ...
            1199, 1, -600, 1100);
        epochs.spikeID = W.horz(spikes.spikeID);
        W.save(savename, 'spiketrains', epochs);
    end

    %% epoch binned cue
    savename = fullfile('../Data/epoch', replace(files(i), 'spikes', 'epoch_cue'));
    if ~exist(savename, 'file')
        epochs = W.epoch_file(spikes.spikes, trials.eventmarkers, trials.timestamps, ...
            1199, 1, -600, 1100, 10, 100);
        epochs.spikeID = W.horz(spikes.spikeID);
        W.save(savename, 'data', epochs);
    end
    %% epoch binned go
    savename = fullfile('../Data/epoch', replace(files(i), 'spikes', 'epoch_go'));
    if ~exist(savename, 'file')
        epochs = W.epoch_file(spikes.spikes, trials.eventmarkers, trials.timestamps, ...
            [1038 1121], 1, -600, 1100, 10, 100);
        epochs.spikeID = W.horz(spikes.spikeID);
        W.save(savename, 'data', epochs);
    end
end
%%
[spiketrains, files] = W.load('../data/spiketrains');
files = W.basenames(files);
spiketrains = W.combine_epoched_spiketrains(spiketrains, files);
spiketrains.animal = W.strs_selectbetween2patterns(spiketrains.filenames, 'spikes_', '1');
W.save('../Data/spiketrains.mat', 'spiketrains', spiketrains);
%%
[epochs, files] = W.load('../data/epoch/*_go*');
files = W.basenames(files);
epochs = W.combine_epoched_spiketrains(epochs, files);
epochs.animal = W.strs_selectbetween2patterns(epochs.filenames, '_', '1', 2);
epochs.timelock = W.strs_selectbetween2patterns(epochs.filenames, '_', '_',1, 2);
W.save('../Data/epochs_go.mat', 'epochs', epochs);
%%
[epochs, files] = W.load('../data/epoch/*_cue*');
files = W.basenames(files);
epochs = W.combine_epoched_spiketrains(epochs, files);
epochs.animal = W.strs_selectbetween2patterns(epochs.filenames, '_', '1', 2);
epochs.timelock = W.strs_selectbetween2patterns(epochs.filenames, '_', '_',1, 2);
W.save('../Data/epochs_cue.mat', 'epochs', epochs);
%%
%%
id = ~(~ismember(spiketrains.spikeID, list_diverse) & spiketrains.animal == "S");
spiketrains = W.subset_epoched_spiketrains(spiketrains, id);
W.save('../Data/spiketrains_RF.mat', 'spiketrains', spiketrains);
%%
epochs = W.load('../Data/epochs_go.mat');
id = ~(~ismember(epochs.spikeID, list_diverse) & epochs.animal == "S");
epochs = W.subset_epoched_spiketrains(epochs, id);
W.save('../Data/epochs_go_RF.mat', 'epochs', epochs);
%%
epochs = W.load('../Data/epochs_cue.mat');
id = ~(~ismember(epochs.spikeID, list_diverse) & epochs.animal == "S");
epochs = W.subset_epoched_spiketrains(epochs, id);
W.save('../Data/epochs_cue_RF.mat', 'epochs', epochs);