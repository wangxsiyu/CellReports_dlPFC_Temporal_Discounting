function games = function_value(games, RL, modelname)
    xfit = RL.(modelname);
    %% set up for models
    RLopt = S_RL;
    games.reward = zeros(size(games,1),1);
    games.action = 1 + games.choice; % 2 - accept, 1 - reject
    games.is_yellow_1st = strcmp(games.cue1, 'yellow');
    RLopt.load_data(games);
    %% calculate value
    [info] = RLopt.test(xfit.params, xfit.model);
    games.DV = info.DV;
    games.action_likelihood = info.action_likelihood;
end