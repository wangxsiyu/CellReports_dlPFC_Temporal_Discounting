classdef W_Neuro_Import_bhv < handle
    methods(Static)
        function load_monkeylogic()
            if ~exist('monkeylogic', 'file')
                files = matlab.apputil.getInstalledAppInfo;
                basedir = files.location;
                addpath(basedir);
            end
        end
        function bhv = import_bhv(file, savename)
            W.load_monkeylogic();
            [data,MLConfig,TrialRecord] = mlread(char(file));
            bhv = W.struct('data', data, 'MLConfig', MLConfig, 'TrialRecord', TrialRecord);
            if W.files_get_ext(file,1) == "bhv2"
%                 mlexportstim(fullfile(savedir, 'Stimuli'), file);
                fid = mlfileopen(file);
                Stimuli = fid.read('Stimuli');
                close(fid);
                if ~W.isempty(Stimuli)
                    savedir = W.foldernames(savename);
                    dest_dir = W.mkdir(fullfile(savedir, 'Stimuli'));
                    nstim = length(Stimuli);
                    stim_path = cell(nstim,1);
                    for m=1:nstim
                        stim_path{m} = fullfile(dest_dir, Stimuli(m).name);
                        fid = fopen(stim_path{m},'w');
                        if -1==fid, continue, end
                        fwrite(fid,Stimuli(m).contents);
                        fclose(fid);
                    end
                end
            end
        end
    end
end