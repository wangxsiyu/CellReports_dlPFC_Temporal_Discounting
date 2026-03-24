classdef W_Neuro_RepairBinaryCodes < handle
    methods(Static)
        %% repair lists of code pairs
        function [mk] = RepairBinaryCode_lists(mk1, mk2)
            % repairs eventmarkers if one of them is a binary suffix of the
            % other one, e.g. 11000 vs 101011000
            mk = NaN(length(mk1),1);
            tid = mk1 == mk2;
            mk(tid) = mk1(tid);
            tid_nan = isnan(mk1) | isnan(mk2);
            mk(tid_nan) = mean([mk1(tid_nan),mk2(tid_nan)], 2, 'omitnan');
            idxs = find(~tid & ~tid_nan);
            if ~isempty(idxs)
                for i = 1:length(idxs)
                    idx = idxs(i);
                    [ismatch, mk(idx)] = W.RepairBinaryCode_ismatch(mk1(idx), mk2(idx), false);
                    if ~ismatch
                        % mismatch
                        W.error('eventmarkers mismatch: two different markers occur at the same time, MUST check!');
                        W.error('eventmarkers mismatch: unable to repair %d vs %d, skipped', mk1(idx), mk2(idx));
                    end
                end
            end
        end
        %% check if d1 matches with one of ds
        function [ismatch, d] = RepairBinaryCode_isamong(d1, ds, varargin)
            ismatch =  arrayfun(@(x)W.RepairBinaryCode_ismatch(d1, x, varargin{:}), ds);
            if sum(ismatch) == 1 % only one match
                [~, d] = W.RepairBinaryCode_ismatch(d1, ds(ismatch), varargin{:});
            else
                d = NaN;
            end
        end
        %% repair single code/check ismatch
        function [ismatch, d] = RepairBinaryCode_ismatch(d1, d2, option_fix1)
            if ~exist('option_fix1', 'var') || isempty(option_fix1)
                option_fix1 = true; % 1 - fix first or 0 - fix either
            end
            b1 = dec2bin(d1);
            b2 = dec2bin(d2);
            len_min = min(length(b1), length(b2));
            ismatch_min = strcmp(W.select(b1, len_min, 'right'), W.select(b2, len_min, 'right'));
            if option_fix1
                ismatch = ismatch_min && (length(b1) <= length(b2));
                dmatch = d2;
            else
                ismatch = ismatch_min;
                dmatch = max(d1, d2);
            end
            if ismatch && nargout == 2 % match
                W.print('repaired markers %d vs %d', d1, d2);
                d = dmatch;
            else
                d = NaN;
            end
        end
    end
end