classdef S_looper_folder < handle
    properties
        masterfolder
        folders_fullpath
        folders_names
        masteroutput
        output_fullpath

        nfolder
    end
    methods
        function obj = S_looper_folder(varargin)
            obj.setup_folders(varargin{:});
        end
        function setup_folders(obj, varargin)
            assert(ismember(length(varargin), [1 2 4]));
            if length(varargin) == 4 % all input assigned
                if isempty(varargin{3}) % empty masterfolder
                    varargin{3} = W.file_common_ancester(varargin{1});
                end
                if isempty(varargin{1})
                    varargin{1} = W.ls(varargin{3}, 'folder');
                end
                folders_fullpath = varargin{1};
                masterfolder = varargin{3};
                if isempty(varargin{4})
                    varargin{4} = varargin{3};
                end
                if isempty(varargin{2})
                    varargin{2} = fullfile(varargin{4}, W.basenames(folders_fullpath));
                end
                output_fullpath = varargin{2};
                masteroutput = varargin{4};
            else
                if length(varargin) == 2 % assume masterfolder and masteroutput are set
                    if length(string(varargin{1})) == 1 % 
                        masterfolder = varargin{1};
                        folders_fullpath = W.ls(masterfolder, 'folder');
                    else
                        masterfolder = W.file_common_ancester(varargin{1});
                        folders_fullpath = varargin{1};
                    end
                    if length(string(varargin{2})) == 1 % 
                        masteroutput = varargin{2};
                        output_fullpath = fullfile(masteroutput, W.basenames(folders_fullpath));
                    else
                        masteroutput = W.file_common_ancester(varargin{2});
                        output_fullpath = varargin{2};
                    end

                elseif length(varargin) == 1 
                    if length(string(varargin{1})) == 1 % assume only masterfolder is set
                        masterfolder = varargin{1};
                        folders_fullpath = W.ls(masterfolder, 'folder');
                        masteroutput = masterfolder;
                        output_fullpath = fullfile(masteroutput, W.basenames(folders_fullpath));
                    else
                        masterfolder = W.file_common_ancester(varargin{1});
                        folders_fullpath = varargin{1};
                        masteroutput = masterfolder;
                        output_fullpath = folders_fullpath;
                    end
                end
            end
            obj.folders_fullpath = W.string(folders_fullpath);
            obj.folders_names = W.basenames(obj.folders_fullpath);
            obj.output_fullpath = W.string(output_fullpath);
            obj.masterfolder = W.string(masterfolder);
            obj.masteroutput = W.string(masteroutput);
            assert(length(obj.folders_fullpath) == length(obj.output_fullpath));
            obj.nfolder = length(obj.folders_fullpath);
        end
        function jobs = unpack_job(obj, job, option_input, option_output) 
            if ~exist('option_input', 'var') || isempty(option_input)
                option_input = 'folder';
            end
            if ~exist('option_output', 'var') || isempty(option_output)
                option_output = 'folder';
            end
            switch option_input
                case 'folder'
                    jobs = cell(1, obj.nfolder);
                    for i = 1:obj.nfolder
                        jobs{i} = obj.looper_format_inputoutput(job, obj.folders_fullpath(i), obj.output_fullpath(i));
                    end
                case {'all', 'master'}
                    job.func_read = @(files)obj.looper_loadmix(files, 'celloffiles');
                    switch option_output
                        case 'folder' % one at a time
                            outpaths = obj.output_fullpath;
                            % this only supports a single outputfile per
                            % output folder
                            assert(length(job.outputnames) == 1);
                        case {'all', 'master'}
                            outpaths = obj.masteroutput;
                    end
                    job = obj.looper_format_inputoutput(job, '', outpaths);
                    jobs = W.encell(job);
            end
        end
        %% looper importdata
        function [out] = looper_loadall(obj, filenames_to_load, varargin)
            if nargin < 2
                out = [];
                return;
            end
            [out] = W.load_files_in_folders(obj.folders_fullpath, filenames_to_load, varargin{:});
        end
        function out = looper_loadmix(obj, filenames_to_load, cellorstruct)
            if nargin < 2
                out = [];
                return;
            end
            filenames_to_load = W.string(filenames_to_load);
            tfiles = fullfile(obj.masterfolder, filenames_to_load);
            is_exist = W.file_exists(tfiles);
            data = cell(1, length(filenames_to_load));
            if any(is_exist)
                tid = find(is_exist);
                data(tid) = W.encell(W.load(tfiles(tid)));
            end
            if any(~is_exist)
                tid = find(~is_exist);
                data(tid) = obj.looper_loadall(filenames_to_load(tid), 'celloffiles');
            end
            if exist('cellorstruct', 'var') && cellorstruct == "struct"
                out = W.varargin2struct_namesfirst(W.basenames(filenames_to_load), data);
            else
                out = data;
            end
        end
        %% copy/deletel files
        function looper_copy(obj, fold, fnew)
            if ~exist('fnew', 'var')
                fnew = fold;
            end
            W.copy_files(obj.folders_fullpath, obj.output_fullpath, fold, fnew);
        end
        function looper_delete(obj, str, folder)
            if ~exist('folder', 'var') || isempty(folder)
                folder = obj.folders_fullpath;
            elseif W.is_stringorchar(folder) && strcmp(folder, 'output')
                folder = obj.output_fullpath;
            else
                folder = W.string(folder);
            end
            x = input(sprintf('confirm deleting files ending in %s? Y for delete:', str), 's');
            if x ~= "Y"
                W.print('cancelled')
                return;
            end
            for i = 1:length(folder)
                W.files_delete(fullfile(folder(i), str));
            end
            W.print('delete complete');
        end
        %% save
        function looper_save(obj, celldata, savename, folders)
            if ~exist('folders', 'var') || isempty(folders)
                folders = obj.folders_names;
            end
            folders = W.string(folders);
            od = arrayfun(@(x)find(x == obj.folders_names), folders);
            for i = 1:length(od)
                tsavename = fullfile(obj.output_fullpath(od(i)), savename);
                W.save(tsavename, savename, celldata{i});
            end
        end
        function looper_save_master(obj, data, savename)
            tsavename = fullfile(obj.masteroutput, savename);
            W.save(tsavename, savename, data);
        end
    end
    methods(Access = private)
        function jobnew = looper_format_inputoutput(~, job, inpath, outpath)
            jobnew = job;
            jobnew.files = fullfile(inpath, job.files);
            % use absolute directory for plt
            % abandoned resetting plt.param_setting.savedir
%             if obj.plotmode
%                 tsavedir = job.vars{1}.param_setting.savedir;
%                 tjob.vars{1} = copy(job.vars{1});
%                 tjob.vars{1}.param_setting.savedir = fullfile(tsavedir, obj.folders_names(folderi));
%             end
            jobnew.outputnames = fullfile(outpath, jobnew.outputnames);
        end
    end
end