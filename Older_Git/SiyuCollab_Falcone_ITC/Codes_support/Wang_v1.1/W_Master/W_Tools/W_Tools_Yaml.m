classdef W_Tools_Yaml < handle
    methods(Static)
        function [out] = yaml_load(files, outputformat)
            if ~exist('outputformat', 'var') || isempty(outputformat)
                outputformat = 'default';
            end
            W.library('yaml');
            files = W.string(files);
            a = cell(1, length(files));
            for fi = 1:length(files)
                a{fi} = yaml.loadFile(files(fi), "ConvertToArray", true);
            end
            switch outputformat
                case 'cell'
                    out = a;
                case 'struct'
                    out = struct;
                    for fi = 1:length(files)
                        fn = W.basenames(files(fi));
                        out.(fn) = a{fi};
                    end
                otherwise
                    out = W.decell(a);
            end
        end
    end
end