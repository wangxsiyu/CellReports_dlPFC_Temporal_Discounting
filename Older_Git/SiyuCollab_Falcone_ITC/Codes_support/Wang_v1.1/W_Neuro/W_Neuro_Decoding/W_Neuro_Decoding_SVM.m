classdef W_Neuro_Decoding_SVM < handle
    methods(Static)
        function result = neuro_decode_slidingwindow(pcs, label, option_classifier, mode, varargin)
            if ~exist('mode', 'var') || isempty(mode)
                mode = 'cv';
            end
            if isstruct(pcs)
                fn = W.decell(intersect({'pc', 'cells'}, fieldnames(pcs)));
                pcs = pcs.(fn);
            end
            if ~exist('option_classifier', 'var') || isempty(option_classifier)
                option_classifier = 'SVM';
            end
            if W.is_stringorchar(option_classifier)
                func = sprintf('W.neuro_decoding_%s', option_classifier);
                func = str2func(func);
            else
                func = option_classifier;
            end
            pcs = W.cell_NxMK2KxMN(pcs); % cell {trial x time} -> time {trial, cell}
            ntime = length(pcs);
            model = {};
            for ti = 1:ntime % loop over time
                tx = pcs{ti};
                %% decode label
                W.print('classifying at time point #%d/%d', ti, ntime);
                switch mode
                    case 'cv'
                        [result.ac_decode(ti), result.se_decode(ti)] = func(tx, label, 'CrossVal', 'on', varargin{:});
                    case 'train'
                        [result.ac_decode(ti), result.se_decode(ti), model{ti}] = func(tx, label, 'CrossVal', 'off', varargin{:});
                    case 'test'
                        [result.ac_decode(ti), result.se_decode(ti)] = W.avse(func{ti}.predict(tx) == label);
                end
            end
            if strcmp(mode, 'train')
                result.models = model;
            end
        end
        function [av, se, SVMmd] = neuro_decoding_SVM(x, y, varargin)
            if length(unique(y)) == 2
                func = @fitcsvm;
            else
                func = @fitcecoc;
            end
            options = struct('CrossVal', 'on', 'Prior', 'uniform');
            options = W.struct_set(options, varargin{:});
            options = W.struct2cell(options);
            SVMmd = func(x, y, options{:});
            if ismethod(SVMmd, 'kfoldPredict')
                [av, se] = W.avse(SVMmd.kfoldPredict == SVMmd.Y);
            else
                [av, se] = W.avse(SVMmd.predict(x) == SVMmd.Y);
            end
        end
    end
end