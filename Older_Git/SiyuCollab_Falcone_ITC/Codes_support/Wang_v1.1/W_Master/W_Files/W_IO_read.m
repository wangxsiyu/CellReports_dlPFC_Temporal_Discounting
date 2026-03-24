classdef W_IO_read < handle
    methods(Static)
        function [out, files] = load_files_in_cell(files, option, varargin)
            % if 1st input is a folder, load all files inside of it
            files = W.ls_if_dir(files, 'file'); % get all files
            % if contains '*', select masked files
            if any(contains(files, '*'))
                files = W.ls(files, 'file');
            end
            if exist('option', 'var') && ~W.isempty(option)
                files = W.files_select_ext(files, option);
            end
            files = W.string(files);
            nfile = length(files);
            out = cell(1, nfile);
            for fi = 1:nfile
                W.print('import data: %s', files(fi));
                ext = W.str_dedot(W.files_get_ext(files(fi)),'');
                ext = W.iif(W.isempty(ext), "mat", ext);
                tfile = W.enext(files(fi), ext);
                if exist(tfile, 'file')
                    switch ext
                        case "mat"
                            out{fi} = importdata(tfile);
                        case "csv"
                            out{fi} = W.readtable(tfile, varargin{:});
                        case {'jpg', 'png'}
                            out{fi} = imread(tfile);
                        otherwise
                            W.error('unknown input option:%s', ext);
                    end
                else
                    W.warning('file doesn''t exist: %s', tfile);
                    out{fi} = [];
                end
            end
        end
        function [out, files] = load(varargin)
            [out, files] = W.load_files_in_cell(varargin{:});
            out = W.decell(out);
        end 
        %% read functions
        function [out] = load_files_in_folders(folders, files, cellorstruct, varargin)
            if ~exist('cellorstruct', 'var') || isempty(cellorstruct)
                cellorstruct = 'struct';
                % options
                % cell cell(folder_i, file_j)
                % cellofstruct cell(struct)
                % celloffolder/nestedcell cell(cell(1, file_j), 1, folder_i)
                % celloffiles cell(cell(1, folder_i), 1, file_j)
                % struct struct.(file_j) = cell(folder_i)
            end
            folders = W.string(folders);
            files = W.string(files);
            nfolder = length(folders);
            nfile = length(files);
            switch string(cellorstruct)
                case "struct"
                    out = struct;
                    name_structs = W.basenames(files);
                    for j = 1:nfile
                        out.(name_structs(j)) = cell(1, nfolder);
                    end
                case "cellofstruct"
                    name_structs = W.basenames(files);
                    out = repmat({struct}, 1, nfolder);
                case "cell"
                    out = cell(nfolder, nfile);
                case {"nestedcell","celloffolder"}
                    out = cell(1,nfolder);
                case "celloffiles"
                    out = cell(1,nfile);
            end
            for i = 1:nfolder
                W.print('load folder %d/%d', i, nfolder);
                [tout] = W.load_files_in_cell(fullfile(folders(i), files), varargin{:});
                switch string(cellorstruct)
                    case "struct"
%                         tout = W.encell(tout);
                        for j = 1:nfile
                            out.(name_structs(j)){i} = tout{j};
                        end
                    case "cellofstruct"
%                         tout = W.encell(tout);
                        for j = 1:nfile
                            out{i}.(name_structs(j)) = tout{j};
                        end
                    case "cell"
%                         tout = W.encell(tout);
                        out(i, :) = tout;
                    case {"nestedcell","celloffolder"}
                        out{i} = W.horz(tout);
                    case "celloffiles"
%                         tout = W.encell(tout);
                        for j = 1:nfile
                            out{j}{i} = tout{j};
                        end
                end
            end
        end
    end
end