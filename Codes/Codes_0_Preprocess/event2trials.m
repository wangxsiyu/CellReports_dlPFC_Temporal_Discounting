function trials = event2trials(events, sessionname)
    template = {2321:2322, ... % not sure what this is
        2121:2138, ... % define next condition
        1002, ... % start trial
        1001, ... % 500ms after bar touched
        1003, ... % hold bar (background PERIOD between 1001 e 1003) - not sure what this means
        1100, ... % Ask red on
        2222, ... % red really on the screen - not sure what this means
        2201, ... % 500ms after red is on
        4001:4018, ... % condition
        2011:2013, ... % delay time
        2022:2:2026, ... % drop size
        1198, ... % ask CUE ON
        1400, ... % (unknown)
        1199, ... % this is to verify that CUE is ON (use 1198 as CUE ON)
        4001:4018, ... % condition
        1111, ... % unknown
        [1038,1121] ... % YELLOW ON or PURPLE ON
        [1039,1141] ... % choice - reject or accept
        [1038,1121], ... % YELLOW ON or PURPLE ON
        [1039,1141] ... % choice - reject or accept
        1123, ... % (potentially for feedback on)
        1022, ... % feedback off
        1400, ... % (unknown)
        1190, ... % all off
        1023, 1124, ... % drop #1-#6
        1024, 1124, ...
        1025, 1124, ...
        1026, 1124, ...
        1027, 1124, ...
        1028, 1124, ...
        1030, ... % trial accepted
        [1040 1041 1034 1035], ... % error codes
        1031, ... %
        1032, ... %
        1400, ... %
        3199}; %
    % 8892 - start
    % 10 - end
    % 1050/1051 touch/release bars
    usenext = [1038, 1039, 1121, 1141, 1124, 1400];
    f = @(a)extract(W.basenames(W.foldernames(a)), 1);
    animal = f(sessionname); 
    switch animal
        case "T"
            code_ignore = [1050 1051];
        case "S"
            code_ignore = [1050 1051 10 8892 0 800 801, ...
                1006:1011 1402:1408 1648 ...
                200 2001:2005 2084 2116 ...
                33063 33071 33081 33094 33095 33113 33121 33131 ...
                4000 4255 512 ...
                601:604 65424 65533 63020 14 2 4 144 ...
                233 117 ...
                97 254 100 234]; 
            % ignore binary fix to match Rossella's trials
    end
    if W.basenames(W.foldernames(sessionname)) == "S160719"
        code_ignore = setdiff(code_ignore, [233 117]);
        trials = W.events2trials(events, template, code_ignore, usenext, true);
    else
        trials = W.events2trials(events, template, code_ignore, usenext, false);
    end
    if W.basenames(W.foldernames(sessionname)) == "S160704"
        % ~ismember(1024, trials.events.eventmarkers(end,:))
        trials.events = trials.events(1:end-1,:); % remove last trial to match Rossella's trials
    end
    if W.basenames(W.foldernames(sessionname)) == "S160709"
        trials.events = trials.events([1:504],:); % rossella's note says jump   
        trials.events = trials.events([1:end-1],:); % remove last trial to match Rossella's trials
    end
    if W.basenames(W.foldernames(sessionname)) == "S160705"
        trials.events = trials.events([1:end-1],:); % remove last trial to match Rossella's trials
    end
    if W.basenames(W.foldernames(sessionname)) == "S160715"
        % can't remember why remove 362
        trials.events = trials.events([1:361 363:end-1],:); % remove last trial to match Rossella's trials
    end

end