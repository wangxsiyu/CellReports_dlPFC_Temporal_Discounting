function out = function_ANOVA(data)
    out = struct;
    if length(data.spikes) == 0
        out.anova_fullmodel = [];
        out.anova_choice = [];
        out.anova_nochoice = [];
        out.anova_dv = [];
        return;
    end
    tid = data.games.is_complete == 1;
    data.spikes = W.select_trials(data.spikes, tid);
    data.games = data.games(tid,:);
    
    
    X0 = [0,0,0];
    LB = [-10,-10, -10];
    UB = [10,10,10];
    xfit = fmincon(@(x)-acceptprob(x(1), x(2), x(3), data.games.drop, data.games.delay), X0, [],[],[],[], LB, UB);
    
    data.games.DV = comp_DV(xfit(3), data.games.drop, data.games.delay, 'hyperbolic');
    factornames = {'choice', 'drop', 'delay', 'DV'};
    out.anova_dv = W.neuro_ANOVA_slidingwindow(data.spikes, data.games, factornames, ...
        'window_significance', [0 1000], 'continuous', [1 2 3 4]);

    
    
%     factornames = {'choice', 'drop', 'delay', 'motor', 'color'};
%     factornames_in_data = {'choice', 'drop', 'delay', 'release1', 'color'};
%     model = [1,0,0,0,0; ...
%         0,1,0,0,0; ...
%         0,0,1,0,0; ...
%         0,1,1,0,0; ...
%         0,0,0,1,0; ...
%         0,0,0,0,1];    
%     data.games.color = strcmp(data.games.cue1, 'yellow') + strcmp(data.games.cue1, 'pu didrple') * 2;
%     out.anova_fullmodel = W.neuro_ANOVA_slidingwindow(data.spikes, data.games, factornames, ...
%         'factornames_in_data', factornames_in_data, 'window_significance', [0 1000], 'model', model);
% 
%     factornames = {'choice', 'drop', 'delay'};
%     model = [1,0,0;0,1,0;0,0,1;0,1,1];
%     out.anova_choice = W.neuro_ANOVA_slidingwindow(data.spikes, data.games, factornames, ...
%         'window_significance', [0 1000], 'model', model);
% 
%     factornames = {'drop', 'delay'};
%     model = [1,0;0,1;1,1];
%     out.anova_nochoice = W.neuro_ANOVA_slidingwindow(data.spikes, data.games, factornames, ...
%         'window_significance', [0 1000], 'model', model);

end
