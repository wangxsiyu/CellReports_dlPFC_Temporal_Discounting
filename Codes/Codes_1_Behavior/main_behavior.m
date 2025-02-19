data = W.load('../../TempData/cue');
games = data.games;
%% train model per session
modelname = '../../TempData/modelfit_session.mat';
if exist(modelname, 'file')
    xfit = W.load(modelname);
else
    xfit = {};
end
for gi = 1:length(games)
    RLopt = S_RL;
    RLopt.setup_optimizer('fmincon', 'repeat', 1, 'bound_inf', 20);
    g = games{gi};
    g.reward = zeros(size(g,1),1);
    g.action = 1 + g.choice; % 2 - accept, 1 - reject
    g.is_yellow_1st = strcmp(g.cue1, 'yellow');
    RLopt.load_data(g);
    % model - base
    if ~isfield(xfit{gi}, 'model_base') || xfit{gi}.model_base.LL < -500
        model = model_base;
        xfit{gi}.model_base = RLopt.train(model);
    end
    % model - basic + YP
    if ~isfield(xfit{gi}, 'model_YP') || xfit{gi}.model_YP.LL < -500
        model = model_YP;
        xfit{gi}.model_YP = RLopt.train(model);
    end
    % model - YP time
    if ~isfield(xfit{gi}, 'model_YP_time') || xfit{gi}.model_YP_time.LL < -500
        model = model_YP_time;
        xfit{gi}.model_YP_time = RLopt.train(model);
    end
end
%% check model fits
W.cellfun_vertcat(@(x)[x.model_base.LL, x.model_YP.LL, x.model_YP_time.LL], xfit)
%% save model
W.save(modelname, 'xfit', xfit);
%% train model overall
ani_gm = unique(data.info_cells(:, ["animal", "gameID"]));
animals = ["S","S","S","T","T","T"];
models = ["model_base", "model_YP", "model_YP_time","model_base", "model_YP", "model_YP_time"];
xfit = {};
parfor repi = 1:6
    animal = animals(repi);
    md = models(repi);
    xfit{repi}.animal = animal;
    xfit{repi}.modelname = md;
    g = vertcat(games{ani_gm.animal == animal});

    RLopt = S_RL;
    RLopt.setup_optimizer('fmincon', 'repeat', 2, 'bound_inf', 20);
    g.reward = zeros(size(g,1),1);
    g.action = 1 + g.choice; % 2 - accept, 1 - reject
    g.is_yellow_1st = strcmp(g.cue1, 'yellow');
    RLopt.load_data(g);
    switch md
        case "model_base"
            model = model_base;
            xfit{repi}.model_base = RLopt.train(model);
        case 'model_YP'
            model = model_YP;
            xfit{repi}.model_YP = RLopt.train(model);
        case 'model_YP_time'
            model = model_YP_time;
            xfit{repi}.model_YP_time = RLopt.train(model);
    end
end
W.save('../../TempData/modelfit_overall.mat', 'xfit', xfit);



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

