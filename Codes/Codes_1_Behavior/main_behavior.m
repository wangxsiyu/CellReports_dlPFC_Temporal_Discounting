data = W.load('../../TempData/cue');
games = data.games;
%% train model
xfit = {};
parfor gi = 1:length(games)
    RLopt = S_RL;
    RLopt.setup_optimizer('fmincon', 'repeat', 1, 'bound_inf', 20);
    g = games{gi};
    g.reward = zeros(size(g,1),1);
    g.action = 1 + g.choice; % 2 - accept, 1 - reject
    g.is_yellow_1st = strcmp(g.cue1, 'yellow');
    RLopt.load_data(g);
    % model - base
    model = model_base;
    xfit{gi}.model_base = RLopt.train(model);
    % model - basic + YP
    model = model_YP;
    xfit{gi}.model_YP = RLopt.train(model);
    % model - YP time
    model = model_YP_time;
    xfit{gi}.model_YP_time = RLopt.train(model);
end
%% save model
W.save('../../TempData/model_YP', 'xfit', xfit);
% %% calculate value
% xfit = W.load('../../TempData/model_YP');
% DVgames = {};
% parfor xi = 1:length(xfit)
%     xx = xfit{xi}.model_YP;
%     g = games{xi};
%     RLopt = S_RL;
%     g.reward = zeros(size(g,1),1);
%     g.action = 1 + g.choice; % 2 - accept, 1 - reject
%     g.is_yellow_1st = strcmp(g.cue1, 'yellow');
%     RLopt.load_data(g);
%     % calculate value
%     [info] = RLopt.test(xx.params, xx.model);
%     g.DV = info.DV;
%     g.action_likelihood = info.action_likelihood;
%     g.pred_accept = info.action_dist(:,2);
%     DVgames{xi} = g;
% end
% %% save game with DV
% W.save('../../TempData/games_DV', 'DVgames', DVgames);
% %% update cue.mat and go.mat
% DVgames = W.load('../../TempData/games_DV');
% cue = W.load('../../TempData/cue');
% cue.games = DVgames;
% go = W.load('../../TempData/go');
% go.games = DVgames;
% W.save('../../TempData/cue_DV', 'cue', cue);
% W.save('../../TempData/go_DV', 'go', go);
% W.save('../../TempData/data', 'cue', cue, 'go', go);

