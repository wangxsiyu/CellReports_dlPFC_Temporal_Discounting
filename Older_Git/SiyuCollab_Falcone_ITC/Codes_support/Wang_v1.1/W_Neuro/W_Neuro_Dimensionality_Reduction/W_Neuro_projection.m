classdef W_Neuro_projection < handle
    methods(Static)
        function x1D = neuro_project1D_svm_rotatingaxis(pc, label)
            result = W.neuro_decode_slidingwindow(pc, label, 'SVM', 'train');
            fn = W.fieldnames(pc);
            x1D = W.struct_sub(pc, fn(~contains(fn, 'pc')));
            % this does not apply to cells, which is not ideal
            tpc = W.cell_NxMK2KxMN(pc.pc);
            ntrial = size(tpc{1},1);
            ntime = length(tpc);
            %% projection to 1D space
            xx = NaN(ntrial, ntime);
            pcdim = size(tpc{1},2);
            x1D.w_svm = NaN(pcdim, ntime);
            x1D.b_svm = NaN(1,ntime);
            for i = 1:ntime
                tmodel = result.models{i};
                tw = (tmodel.SupportVectorLabels.*tmodel.Alpha)' * tmodel.SupportVectors;
                tb = tmodel.Bias;
                scalefactor = sqrt(tw*tw');
                tw = tw/scalefactor;
                tb = tb/scalefactor;
                x1D.w_svm(:,i) = tw;
                x1D.b_svm(i) = tb;
                xx(:, i) = tpc{i} * tw'+ tb; % needs to double check
            end
            x1D.x1D = xx;
        end
        function x1D = neuro_project1D_svm(pc, label, opt_time, nmaxpoint)
            label = W.num2rank(label)-1; % turn whatever binary label to 0 and 1
            fn = W.fieldnames(pc);
            x1D = W.struct_sub(pc, fn(~contains(fn, 'pc')));
            % this does not apply to cells, which is not ideal
            tpc = W.cell_NxMK2KxMN(pc.pc);
            ntrial = size(tpc{1},1);
            ntime = length(tpc);
            %% projection to 1D space
            xx = NaN(ntrial, ntime);
            %% get appropriate timerange
            if ~isfield(pc, 'time_at')
                pc.time_at = 1:ntime;
            end
            if ~exist('opt_time', 'var') || isempty(opt_time)
                x1D.idx_timerange = 1:ntime;
            else
                x1D.idx_timerange = find(pc.time_at >= opt_time(1) & pc.time_at <= opt_time(2));
            end
            idx_time = x1D.idx_timerange;
            tx = vertcat(tpc{idx_time});
            ty = repmat(label, length(idx_time), 1);
            if exist('nmaxpoint', 'var') && length(tx) > nmaxpoint
                tid = randperm(length(tx), nmaxpoint);
                tx = tx(tid,:);
                ty = ty(tid);
            end
            tmodel = fitcsvm(tx, ty);
            tw = (tmodel.SupportVectorLabels.*tmodel.Alpha)' * tmodel.SupportVectors;
            tb = tmodel.Bias;
            scalefactor = sqrt(tw*tw');
            tw = tw/scalefactor;
            tb = tb/scalefactor;
            x1D.w_svm = tw;
            x1D.b_svm = tb;
            for ti = 1:ntime % loop over time
                xx(:, ti) = tpc{ti} * tw'+ tb; % needs to double check
            end
%             avpos = W.analysis_av_bygroup(tx, ty, [0 1]);
%             x0 = avpos * tw' + tb;
            x1D.x1D = xx;
        end
    end
end