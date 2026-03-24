classdef W_IO_filename < handle
    methods(Static)
        %% filenames
        % basenames, foldernames
        function out = foldernames(files)
            out = W.func('fileparts', 1, files);
        end
        function out = basenames(files, is_include_ext)
            if ~exist('isext', 'var') 
                is_include_ext = 0;
            end
            out = W.func('fileparts', 2, files);
            if is_include_ext
                ext = W.func('fileparts', 3, files);
                out = strcat(out, ext);
            end
        end
        % single file - filepart
        function [folder, name, ext] = filepart(file, isext)
            if ~exist('isext', 'var') || isempty(isext)
                isext = 1; % some filenames has . in it, in that case, whether the last . indicates an extension is noted by isext
            end
            file = replace(file, '\\','\');
            file = replace(file, '\','/');
            if ~contains(file, '/')
                folder = "";
                file = strcat('./', file);
            else
                folder = W.strs_selectbetween2patterns(file, [], '/', [], -1);
            end
            filename = W.strs_selectbetween2patterns(file, '/',[], -1,[]);
            if contains(filename, '.') && isext
                ext = strcat('.', W.strs_selectbetween2patterns(filename, '.', [], -1, []));
            else
                ext = "";
                filename = strcat(filename, '.');
            end
            name = W.strs_selectbetween2patterns(filename, [], '.', 1, -1);
        end
        %% prefix suffix
        function str = file_prefix(str, pfx, sep)
            if W.isempty(pfx)
                return;
            end
            if ~exist('sep','var')
                sep = '_';
            end
            [p, n, ext] = W.fileparts(str);
            n = W.strcat(pfx, sep, n, ext);
            str = fullfile(p, n);
        end
        function str = file_suffix(str, sfx, sep)
            if W.isempty(sfx)
                return;
            end
            if ~exist('sep','var')
                sep = '_';
            end
            [p, n, ext] = W.fileparts(str);
            n = W.strcat(n, sep, sfx, ext);
            str = fullfile(p, n);
        end
        function str = file_getprefix(str)
            str = W.basenames(str);
            str = W.strs_selectbetween2patterns(str, [], '_', 1,1);
        end
        function str = file_getsuffix(str)
            str = W.basenames(str);
            str = W.strs_selectbetween2patterns(str, '_', [], 1,1);
        end
        
        function str = file_deprefix(str, varargin)
            [p, f] = W.fileparts(str, varargin{:});
            str = W.strs_selectbetween2patterns(f, '_',[],1);
            str = fullfile(p, str);
        end
        function str = file_desuffix(str)
            str = replace(str, '/', '\');
            deext = W.deext(str);
            deext_new = W.strs_selectbetween2patterns(deext, [], '_',[],-1);
            str = replace(str, deext, deext_new);
        end
        %% extension
        % single file - add/delete extension
        function out = deext(file)
            if W.isempty(file)
                out = "";
                return
            end
            file = W.string(file);
            [p, n] = W.fileparts(file);
            out = fullfile(p, n);
        end
        function out = enext(file, ext)
            if W.isempty(file)
                out = '';
                return;
            end
            file = W.deext(file);
            if contains(ext, '.')
                out = strcat(file, ext);
            else
                out = strcat(file, ".", ext);
            end
        end
        function out = files_deext(files)
            files = W.string(files);
            out = arrayfun(@(x)W.deext(x), files);
        end
        function out = files_enext(files, varargin)
            files = W.string(files);
            out = arrayfun(@(x)W.enext(x, varargin{:}), files);
        end
        % select extensions
        function out = files_select_ext(files, extname)
            tid = W.files_is_ext(files, extname);
            out = files(tid);
            out = W.enext(out, extname);
        end
        function [id] = files_is_ext(files, extname)
            extname = char(extname);
            if extname(1) ~= '.' % use .ext 
                extname = ['.' extname];
            end
            text = W.files_get_ext(files);
            text(text == "") = ".mat";
            id = strcmp(text, extname);
        end
        function files = files_noext2mat(files)
            text = W.files_get_ext(files);
            files(text == "") = W.files_enext(files(text == ""), 'mat'); 
        end
        function out = files_get_ext(files, isomitdot)
            files = W.string(files);
            out = W.func('fileparts', 3, files);
            out = W.string(out);
            if exist('isomitdot', 'var') && ~isempty(isomitdot) && isomitdot
                out = W.arrayfun(@(x)extractAfter(x, 1), out);
            end
        end
        %% multiple files
        % fileparts
        function [folder, name, ext] = fileparts(file, varargin)
            file = W.string(file);
            nfile = length(file);
            folder = repmat("", 1, nfile);
            name = repmat("", 1, nfile);
            ext = repmat("", 1, nfile);
            for i = 1:nfile
                [folder(i), name(i), ext(i)] = W.filepart(file(i), varargin{:});
            end
        end
    end
end