function game = preprocess_trials(trials)  
    %% trial idx
    [indices] = W.eventmarker2names(trials, ...
        'starttrial', 1002, ...
        'bartouched', 1001, 'cueon', 1199, 'condition', [4000:4018], ...
        'choiceperiod', [1039 1038 1141 1121], ...
        'acceptdone', 1030, 'error', [1034 1035 1040 1041], 'errorall', 1031, ...
        'drop', [2022 2024 2026], 'delay', [2011 2012 2013]);
    %% include complete trials only
    ntrial = size(trials.events,1);
    game = table;
    idx_marker = indices.idx_marker;
    game.is_error = (idx_marker.error | idx_marker.errorall) + 0;
    game.is_post_error = ([false; game.is_error(1:end-1)]) + 0;

    cs = indices.selected_marker.choiceperiod;
    game.is_complete = ((ismember(cs(:, 2), [1039 1141]) |  ismember(cs(:, 4), [1039 1141])) & ...
        indices.idx_marker.starttrial) + 0; % starttrial is to match Rossella
    %% choice 
    game.cue1 = repmat("", ntrial, 1);
    game.cue1(cs(:,1) == 1038) = "yellow";
    game.cue1(cs(:,1) == 1121) = "purple";

    game.cue2 = repmat("", ntrial, 1);
    game.cue2(cs(:,3) == 1038) = "yellow";
    game.cue2(cs(:,3) == 1121) = "purple";

    game.release1 = ismember(cs(:,2), [1039 1141]) + 0;
    game.release2 = ismember(cs(:,4), [1039 1141]) + 0;

    game.choice = NaN(ntrial, 1); % accept
    game.choice(cs(:,2) == 1039 | cs(:,4) == 1039) = 0; % reject
    game.choice(cs(:,2) == 1141 | cs(:,4) == 1141) = 1;

    tdrop = indices.selected_marker.drop - 2020;
    tdelay = indices.selected_marker.delay - 2010;
    game.drop = tdrop;
    game.delay = W.nan_array_select([1 5 10], tdelay);
    game.condition = round(tdrop * 3/2 + tdelay - 3);
    %% compute reaction time
    if W.tab_isfield(indices, 'selected_timestamps')
        rts = indices.selected_timestamps;
        game.rt_bar2cue = rts.cueon - rts.bartouched;
        game.rt_cueon_to_cue1 = rts.choiceperiod(:,1) - rts.cueon;
        game.rt_release1 = rts.choiceperiod(:,2) - rts.choiceperiod(:,1);
        game.rt_cue1_to_cue2 = rts.choiceperiod(:,3) - rts.choiceperiod(:,1);
        game.rt_release2 = rts.choiceperiod(:,4) - rts.choiceperiod(:,3);
    end
end