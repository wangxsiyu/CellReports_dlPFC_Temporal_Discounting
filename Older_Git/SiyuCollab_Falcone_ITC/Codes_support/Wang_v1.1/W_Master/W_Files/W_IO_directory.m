classdef W_IO_directory < handle
    methods(Static)
        %% directory
        % change directory to current file
        function cd()
            folder = fileparts(matlab.desktop.editor.getActiveFilename);
            if ~isempty(folder)
                cd(folder);
                W.print('change directory to: %s', folder);
            else
                W.print('cd: no Matlab scripts open');
            end
        end
        % mkdir
        function folder = mkdir(folder)
            if ~exist(folder, 'dir') && ~W.isempty(folder)
                W.print('creating directory: %s', folder);
                mkdir(folder);
            end
        end
        %% ancester
        function folderpaths = file_common_ancester(folderpaths)
            folderpaths = W.decell(folderpaths);
            folderpaths = W.str2cell(folderpaths);
            while length(folderpaths) > 1
                folderpaths = W.unique(W.foldernames(folderpaths));
            end
            folderpaths = char(folderpaths);
            if ~W.isempty(W.files_get_ext(folderpaths))
                folderpaths = W.foldernames(folderpaths);
            end
        end
    end
end