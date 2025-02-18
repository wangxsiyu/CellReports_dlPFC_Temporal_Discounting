function xfit = function_model(games, modeli)
    %% 
    RLopt = S_RL;
    RLopt.setup_optimizer('fmincon', 'repeat', 1, 'bound_inf', 20);
    games.reward = zeros(size(games,1),1);
    games.action = 1 + games.choice; % 2 - accept, 1 - reject
    games.is_yellow_1st = strcmp(games.cue1, 'yellow');
    RLopt.load_data(games);
    switch modeli
        case 1
            %% model 1 - basic
            model1 = model_base;
            xfit.model_base = RLopt.train(model1);
        case 2
            %% model 2 - basic + YP
            model2 = model_YP;
            xfit.model_YP = RLopt.train(model2);
    end
end