% Michely et al.: 'SSRIs modulate asymmetric learning from reward and punishment'
%
% Reproduces computational modelling analysis, including data simulation,
% and model recovery (cf. settings below)
%
% Note that 'do_analysis' has to be run first, to create data structure for
% modelling analysis ('data1.mat' and 'data2.mat')
%
% Uses 'data1.mat' and 'data2.mat' as well as functions: 'mfUtil.m',
% 'model1.m' to 'model6.m', or 'model1_sim.m' to 'model6_sim.m',
% respectively
% 
% Jochen Michely (and Alon Erdman, Eran Eldar)
% jochen.michely@charite.de
% 2020

%%
clear all; close all; clc;
%% settings
simul = 0; %% simul=0: fit to real data; simul=1: do simulation; simul=2: re-fit to simulated data!
ses = 1; %% ses=1: day 1 data; ses=2: day 2 data;
%
simul_multiple = 100; %%% only relevant if simul == 1;
simulated_model = 1; %%% only relevant if simul == 1;
%
S = 100000; % number of samples; %%% options: [10000; 100000]
%% load data
%
if simul == 0 %%% load real data (needed for model fitting to real data)
    %
    if ses == 1
        load('data1.mat');
        data = data1;
    else %% quasi ses == 2
        load('data2.mat');
        data = data2;
    end
    
elseif simul == 1 %%% load real data (needed for simulation) & model to use for simulation
    %
    if ses == 1
        load('data1.mat');
        data = data1;
    else %% quasi ses == 2
        load('data2.mat');
        data = data2;
    end
%     load('XXX.mat') %%% insert model used for simulation here   
    
else %%% quasi simul = 2 %%% load simulated data (needed for re-fitting)
    %
%     load('XXX.mat') %%% enter simulated data used for re-fitting here
    %%% display what is running
%     disp('re-fitting for model XXX data using 100T')

end

%% fit models          
if simul ~= 1
      
%%%%%%%%%%%%%%%%model fitting to real data       
if simul == 0
%%% display what is running    
disp('fitting to real data') 

%%%% initialize models
d = 1;

% model 1 (no learning; 1 parameter)
model{d}.lik_func = @model1;
model{d}.lik_func_sim = @model1_sim;
model{d}.name = 'model1';
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;
% 
% model 2 (no learning; 2 parameters)
model{d}.lik_func = @model2;
model{d}.lik_func_sim = @model2_sim;
model{d}.name = 'model2';
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 3 (Q-learning; 4 parameters)
model{d}.lik_func = @model3;
model{d}.lik_func_sim = @model3_sim;
model{d}.name = 'model3';
model{d}.spec.eta.type = 'beta'; %eta: LR
model{d}.spec.eta.val = [1 1];
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 4 (adjusted Q-learning; 4 parameters)
model{d}.lik_func = @model4;
model{d}.lik_func_sim = @model4_sim;
model{d}.name = 'model4';
model{d}.spec.eta.type = 'beta'; %eta: LR
model{d}.spec.eta.val = [1 1];
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 5 (Q-learning, dual LRs; 5 parameters)
model{d}.lik_func = @model5;
model{d}.lik_func_sim = @model5_sim;
model{d}.name = 'model5';
model{d}.spec.eta_pos.type = 'beta'; %eta_pos: LR from positive outcomes
model{d}.spec.eta_pos.val = [1 1];
model{d}.spec.eta_neg.type = 'beta'; %eta_neg: LR from negative outcomes
model{d}.spec.eta_neg.val = [1 1]; 
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 6 (adjusted Q-learning, dual LRs; 5 parameters)
model{d}.lik_func = @model6;
model{d}.lik_func_sim = @model6_sim;
model{d}.name = 'model6';
model{d}.spec.eta_pos.type = 'beta'; %eta_pos: LR from positive outcomes
model{d}.spec.eta_pos.val = [1 1];
model{d}.spec.eta_neg.type = 'beta'; %eta_neg: LR from negative outcomes
model{d}.spec.eta_neg.val = [1 1]; 
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

%% fitting process for real data
for m = 1:length(model)
    
    improvement = nan;
    while ~(improvement < 0) % repeat until fit stops improving
        oldbic = model{m}.bic;

        for n = 1:length(data) %running over each subject
            model{m} = mfUtil.randomP(model{m}, S); % sample random parameter values
            lik = model{m}.lik_func(model{m}.P, data(n)); % compute log-likelihood for each sample
            model{m} = mfUtil.computeEstimates(lik, model{m}, n); % resample parameter values with each sample weighted by its likelihoods
        end

        % fit prior to resampled parameters
        model{m} = mfUtil.fit_prior(model{m});

        % compute goodness-of-fit measures 
        Nparams = 2*length(fieldnames(model{m}.spec)); % number of hyperparameters (assumes 2 hyperparameters per parameter)
        Ndatapoints = numel([data.C]); % total number of datapoints 
        model{m}.evidence = sum([model{m}.fit.evidence]); % total evidence
        model{m}.bic = -2*model{m}.evidence + Nparams*log(Ndatapoints); % Bayesian Information Criterion
        improvement = oldbic - model{m}.bic; % compute improvement of fit
        fprintf('%s - %s    old: %.2f       new: %.2f      \n', model{m}.name, 'bic', oldbic, model{m}.bic)
    end
    
end



%%%%%%%%%%%%%%%%%%%%% model re-fitting to simulated data    
elseif simul == 2

for z=1:size(multiple,2)

        sim_data = multiple(z).sim_data;
             
%%%% initialize models
d = 1;

% model 1 (no learning; 1 parameter)
model{d}.lik_func = @model1;
model{d}.lik_func_sim = @model1_sim;
model{d}.name = 'model1';
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 2 (no learning; 2 parameters)
model{d}.lik_func = @model2;
model{d}.lik_func_sim = @model2_sim;
model{d}.name = 'model2';
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 3 (Q-learning; 4 parameters)
model{d}.lik_func = @model3;
model{d}.lik_func_sim = @model3_sim;
model{d}.name = 'model3';
model{d}.spec.eta.type = 'beta'; %eta: LR
model{d}.spec.eta.val = [1 1];
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 4 (adjusted Q-learning; 4 parameters)
model{d}.lik_func = @model4;
model{d}.lik_func_sim = @model4_sim;
model{d}.name = 'model4';
model{d}.spec.eta.type = 'beta'; %eta: LR
model{d}.spec.eta.val = [1 1];
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 5 (Q-learning, dual LRs; 5 parameters)
model{d}.lik_func = @model5;
model{d}.lik_func_sim = @model5_sim;
model{d}.name = 'model5';
model{d}.spec.eta_pos.type = 'beta'; %eta_pos: LR from positive outcomes
model{d}.spec.eta_pos.val = [1 1];
model{d}.spec.eta_neg.type = 'beta'; %eta_neg: LR from negative outcomes
model{d}.spec.eta_neg.val = [1 1]; 
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;

% model 6 (adjusted Q-learning, dual LRs; 5 parameters)
model{d}.lik_func = @model6;
model{d}.lik_func_sim = @model6_sim;
model{d}.name = 'model6';
model{d}.spec.eta_pos.type = 'beta'; %eta_pos: LR from positive outcomes
model{d}.spec.eta_pos.val = [1 1];
model{d}.spec.eta_neg.type = 'beta'; %eta_neg: LR from negative outcomes
model{d}.spec.eta_neg.val = [1 1]; 
model{d}.spec.beta_N.type = 'gamma'; % beta_N: PC number 
model{d}.spec.beta_N.val = [1 1];
model{d}.spec.beta_Q.type = 'gamma'; % beta_Q: expected value
model{d}.spec.beta_Q.val = [1 1];
model{d}.spec.betafree.type = 'norm';  % betafree: general tendency to gamble
model{d}.spec.betafree.val = [0 1];
model{d}.bic = nan;
d = d+1;      
        
%%%%%% fitting process for simulated data        
for m = 1:length(model)
    
    improvement = nan;
    while ~(improvement < 0) % repeat until fit stops improving
        oldbic = model{m}.bic;

        for n = 1:length(sim_data) %running over each subject
            model{m} = mfUtil.randomP(model{m}, S); % sample random parameter values
            lik = model{m}.lik_func(model{m}.P, sim_data(n)); % compute log-likelihood for each sample
            model{m} = mfUtil.computeEstimates(lik, model{m}, n); % resample parameter values with each sample weighted by its likelihoods
        end

        % fit prior to resampled parameters
        model{m} = mfUtil.fit_prior(model{m});

        % compute goodness-of-fit measures 
        Nparams = 2*length(fieldnames(model{m}.spec)); % number of hyperparameters (assumes 2 hyperparameters per parameter)
        Ndatapoints = numel([sim_data.C]); % total number of datapoints 
        model{m}.evidence = sum([model{m}.fit.evidence]); % total evidence
        model{m}.bic = -2*model{m}.evidence + Nparams*log(Ndatapoints); % Bayesian Information Criterion
        improvement = oldbic - model{m}.bic; % compute improvement of fit
        fprintf('%s - %s    old: %.2f       new: %.2f      \n', model{m}.name, 'bic', oldbic, model{m}.bic)
    end
    
end            
        refit_multiple(z).model = model;
end
    
else
end

%%%%%%%%%%%%% simulate data
elseif simul == 1
    
%%% display what is running
disp(['simulating' ' ' num2str(simul_multiple) ' ' 'data sets'])
    
%
load('EXPT.mat');
    
for z = 1:simul_multiple  
        
% simulate data from fitted parameters
k=0;
for n = 1:length(data)
   %
   P = mfUtil.fit2P(model{simulated_model}.fit(n));% take model parameters for each subject
   [latents] = model{simulated_model}.lik_func_sim(P, EXPT); % simulate choices for each subject
   %
   sim_data(n).C = latents.sim_C; % all simulated choices
   sim_data(n).D = latents.D_norm; % all simulated decks
   sim_data(n).N = latents.N_norm; % all simulated numbers
   sim_data(n).O = latents.O; % all simulated outcomes
   %
   sim_meanC(n,1) = mean(latents.sim_C); % average choice for simulated data
   real_meanC(n,1) = nanmean(data(n).C); % average choice for real subject  
   %
   sim_data_all.choice_simulated(k+1:k+180,:)=latents.sim_C; %save a vector with all simulated choices 
   sim_data_all.deck_norm_simulated(k+1:k+180,:)=latents.D_norm; % save a vector with all simulated decks 
   sim_data_all.comp_num_norm_simulated(k+1:k+180,:)=latents.N_norm; % save a vector with all simulated numbers
   sim_data_all.outcome_simulated(k+1:k+180,:)=(latents.O)'; % save a vector with all simulated outcomes
   k=k+180;
end

%%% when simulating multiple data sets, save here as:
multiple(z).sim_data = sim_data;
multiple_all(z).sim_data = sim_data_all;
end
    
else
end
