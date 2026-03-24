classdef W < W_Master & ...
        W_Neuro & ...
        W_Analysis
    methods(Static)
        function library(str, is_subfolder)
            if ~exist('is_subfolder', 'var') || isempty(is_subfolder)
                is_subfolder = false;
            end
            str = W.string(str);
            global W_library_lists
            if isempty(W_library_lists)
                W_library_lists = string([]);
            end
            if W.strs_have_matches(str, W_library_lists)
                return;
            else
                W_library_lists(end+1) = str;
                mdir = fileparts(W.W_codes_fullpath);
                mdir = fullfile(mdir,'MATLAB_packages',str);
                if is_subfolder
                    addpath(genpath(mdir));
                else
                    addpath(mdir);
                end
                W.print('loaded library %s:%s', str, mdir);
            end
        end
        function out = W_codes_fullpath()
            out = fileparts(mfilename('fullpath')); 
        end
    end
end