classdef W_Neuro_Import_mksort < handle
    methods(Static)
        function [output] = mksort_import(files, is_sorted, name_animal, name_session)
            if ~exist('is_sorted', 'var') || isempty(is_sorted)
                is_sorted = true;
            end
            if ~is_sorted
                W.warning('importing unsorted data:');
                W.print_ellipsis(files, 'warning');
            end
            count = 0;
            wtb = waitbar(0, 'Starting');
            files = W.string(files);
            if length(files) == 1 && isfolder(files)
                files = W.ls(fullfile(files, 'waveforms*'));
            end 
            output = W.struct('cells',{}, 'info_cells', table);
            channelID = [];
            rater_confidence = [];
            for fi = 1:length(files)
                waitbar(fi/length(files), wtb, ...
                    sprintf("importing channel %d", fi));
                td0 = importdata(files(fi));
                if isfield(td0, 'waveforms')
                    td = td0.waveforms;
                    raterconf = td0.rater_confidence;
                else
                    td = td0;
                    raterconf = NaN(1,10); % why 10?, maximal 10 neurons
                end
                if is_sorted
                    tunits = unique(td.units);
                    tunits = tunits(tunits > 0); % ignore noise and unsorted ones
                else 
                    td.units = td.units * 0; % ignore online sorting from mksort
                    tunits = 0;
                end
                for ti = 1:length(tunits)
                    count = count + 1;
                    tid = td.units == tunits(ti);
                    output.cells{count} = td.spikeTimes(tid); % unit ms
                    channelID(count,1) = str2double(W.str_selectbetween2patterns(files(fi), '_', '.mat', -1, 1));
                    if tunits(ti) > 0
                        rater_confidence(count,1) = raterconf(tunits(ti));
                    else
                        rater_confidence(count,1) = NaN;
                    end
                end
            end
            close(wtb);
            output.info_cells = table(channelID, rater_confidence);
            output.info_cells = W.tab_fill_ID(output.info_cells, 'cellID');
            output.info_session = W.struct('is_sorted', is_sorted + 0);
            output.info_cells = W.tab_fill(output.info_cells, 'is_sorted', is_sorted + 0);
            if exist('name_animal', 'var') && ~isempty(name_animal)
                output.info_cells = W.tab_fill(output.info_cells, 'animal', W.string(name_animal));
                output.info_session.animal = W.string(name_animal);
            end
            if exist('name_session', 'var') && ~isempty(name_session)
                output.info_cells = W.tab_fill(output.info_cells, 'sessionID', W.string(name_session));
                output.info_session.sessionID = W.string(name_session);
            end
        end
    end
end