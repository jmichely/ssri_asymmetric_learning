% Michely et al.: 'Serotonin modulates asymmetric learning from reward and punishment'
%
% Reproduces analyses of average gambling over time (Fig. 1C/D, and
% trial-by-trial regression (Fig. 2)
%
% Uses function 'running_out_070722.m'
%
% Jochen Michely (and Alon Erdman, Eran Eldar)
% jochen.michely@charite.de
% 2022

%%
clear all; close all; clc;
%%
list = dir('Sub*');
subj = zeros(1,length(list));
for i=1:length(list)
subj(i) = str2num(list(i).name(4:6));
end
subj = unique(subj);
%
load('ssri_drug_coding_id.mat');
number_of_trials=180;
A(length(subj)).Subject =[]; A(length(subj)).C =[];A(length(subj)).O =[];A(length(subj)).D =[];A(length(subj)).N =[];A(length(subj)).Drugs =[]; %stucture of day1 data
B(length(subj)).Subject =[]; B(length(subj)).C =[];B(length(subj)).O =[];B(length(subj)).D =[];B(length(subj)).N =[];B(length(subj)).Drugs =[]; %structure of day2 data
%%
for i=1:length(subj)
    %
    load(['Sub' num2str(subj(i)) '_1.mat']);
    A(i).Subject=subj(i);
    A(i).C=[EXPT.D.C]; %A=first session data
    A(i).O=[EXPT.D.O];
    A(i).D=[EXPT.S.deck];
    A(i).N=[EXPT.S.pcnum];
    A(i).rate=[EXPT.D.rate];
    A(i).Drugs=ssri_drug_coding(i,2);
    %
    load(['Sub' num2str(subj(i)) '_2.mat']);
    B(i).Subject=subj(i);
    B(i).C=[EXPT.D.C]; %B=second session data
    B(i).O=[EXPT.D.O]; 
    B(i).D=[EXPT.S.deck];
    B(i).N=[EXPT.S.pcnum];
    B(i).rate=[EXPT.D.rate];
    B(i).Drugs=ssri_drug_coding(i,2);
end
choice_day1=[A(1:length(subj)).C];
choice_day1=choice_day1(:);
deck_day1=[A(1:length(subj)).D];
deck_day1=deck_day1(:);
outcome_day1=[A(1:length(subj)).O];
outcome_day1=outcome_day1(:);
choice_deck_day1=[choice_day1,deck_day1];
choice_day2=[B(1:length(subj)).C];
choice_day2=choice_day2(:);
deck_day2=[B(1:length(subj)).D];
deck_day2=deck_day2(:);
outcome_day2=[B(1:length(subj)).O];
outcome_day2=outcome_day2(:);
choice_deck_day2=[choice_day2,deck_day2];
gambels_taken_low_deck_day1=nan(length(choice_day1)./15,1);gambels_taken_even_deck_day1=nan(length(choice_day1)./15,1);gambels_taken_high_deck_day1=nan(length(choice_day1)./15,1);
gambels_taken_low_deck_day2=nan(length(choice_day2)./15,1);gambels_taken_even_deck_day2=nan(length(choice_day2)./15,1);gambels_taken_high_deck_day2=nan(length(choice_day2)./15,1);
gambels_taken_overall_day1=nan(length(choice_day1)./15,1);gambels_taken_overall_day2=nan(length(choice_day1)./15,1);
drugs_index1=[A(1:length(subj)).Drugs];
drugs_index2=[B(1:length(subj)).Drugs];
%% Analysis 1: gambles taken over time
j=1;
for k=0:15:length(choice_day1)-15 %percentage calculation every 15 trials in each deck type (deck type is represented in the second column of choice_deck_day1/2. The first column represents a choice to gamble if equals 1).   
    gambels_taken_low_deck_day1(j)=((sum((choice_deck_day1(k+1:k+15)==1)'&(choice_deck_day1(k+1:k+15,2)==1)))/sum(choice_deck_day1(k+1:k+15,2)==1))*100;
    gambels_taken_even_deck_day1(j)=((sum((choice_deck_day1(k+1:k+15)==1)'&(choice_deck_day1(k+1:k+15,2)==2)))/sum(choice_deck_day1(k+1:k+15,2)==2))*100;
    gambels_taken_high_deck_day1(j)=((sum((choice_deck_day1(k+1:k+15)==1)'&(choice_deck_day1(k+1:k+15,2)==3)))/sum(choice_deck_day1(k+1:k+15,2)==3))*100;
    gambels_taken_low_deck_day2(j)=((sum((choice_deck_day2(k+1:k+15)==1)'&(choice_deck_day2(k+1:k+15,2)==1)))/sum(choice_deck_day2(k+1:k+15,2)==1))*100;
    gambels_taken_even_deck_day2(j)=((sum((choice_deck_day2(k+1:k+15)==1)'&(choice_deck_day2(k+1:k+15,2)==2)))/sum(choice_deck_day2(k+1:k+15,2)==2))*100;
    gambels_taken_high_deck_day2(j)=((sum((choice_deck_day2(k+1:k+15)==1)'&(choice_deck_day2(k+1:k+15,2)==3)))/sum(choice_deck_day2(k+1:k+15,2)==3))*100;
    %
    gambels_taken_overall_day1(j) = sum(choice_deck_day1(k+1:k+15)==1) / 15;
    gambels_taken_overall_day2(j) = sum(choice_deck_day2(k+1:k+15)==1) / 15;
    %
    j=j+1;
end
% 
twelve_samples_low_deck_day1=nan(12,1);twelve_samples_even_deck_day1=nan(12,1);twelve_samples_high_deck_day1=nan(12,1);
twelve_samples_low_deck_day2=nan(12,1);twelve_samples_even_deck_day2=nan(12,1);twelve_samples_high_deck_day2=nan(12,1);
%
gambles_taken_low_deck_day1=nan(length(subj),12);gambles_taken_even_deck_day1=nan(length(subj),12);gambles_taken_high_deck_day1=nan(length(subj),12);
gambles_taken_low_deck_day2=nan(length(subj),12);gambles_taken_even_deck_day2=nan(length(subj),12);gambles_taken_high_deck_day2=nan(length(subj),12);
gambles_taken_overall_day1=nan(length(subj),12);gambles_taken_overall_day2=nan(length(subj),12);
for i=1:12
% averages
twelve_samples_low_deck_day1(i)=mean(gambels_taken_low_deck_day1(i:12:end));
twelve_samples_even_deck_day1(i)=mean(gambels_taken_even_deck_day1(i:12:end));
twelve_samples_high_deck_day1(i)=mean(gambels_taken_high_deck_day1(i:12:end));
twelve_samples_low_deck_day2(i)=mean(gambels_taken_low_deck_day2(i:12:end));
twelve_samples_even_deck_day2(i)=mean(gambels_taken_even_deck_day2(i:12:end));
twelve_samples_high_deck_day2(i)=mean(gambels_taken_high_deck_day2(i:12:end));

% single subject level (mean/SEM/figures can be computed from this)
gambles_taken_low_deck_day1(:,i) = gambels_taken_low_deck_day1(i:12:end);
gambles_taken_even_deck_day1(:,i)=gambels_taken_even_deck_day1(i:12:end);
gambles_taken_high_deck_day1(:,i)=gambels_taken_high_deck_day1(i:12:end);
gambles_taken_low_deck_day2(:,i)=gambels_taken_low_deck_day2(i:12:end);
gambles_taken_even_deck_day2(:,i)=gambels_taken_even_deck_day2(i:12:end);
gambles_taken_high_deck_day2(:,i)=gambels_taken_high_deck_day2(i:12:end);
gambles_taken_overall_day1(:,i)=gambels_taken_overall_day1(i:12:end);
gambles_taken_overall_day2(:,i)=gambels_taken_overall_day2(i:12:end);
end

%% Analysis 2: regression
comp_num_day1=[A(1:length(subj)).N]; 
range = max(comp_num_day1(:)) - min(comp_num_day1(:));
comp_num_day1_norm = (comp_num_day1 - min(comp_num_day1(:))) / range;
comp_num_day1_norm = (2 * comp_num_day1_norm - 1)*(-1);
comp_num_day1_norm=comp_num_day1_norm(:);%normalize between -1 to 1 (9=-1; 1=1)
comp_num_day2=[B(1:length(subj)).N];
comp_num_day2_norm = (comp_num_day2 - min(comp_num_day2(:))) / range;
comp_num_day2_norm = (2 * comp_num_day2_norm - 1)*(-1);
comp_num_day2_norm=comp_num_day2_norm(:);%normalize between -1 to 1 (9=-1; 1=1)
deck_day1_norm=deck_day1; 
idx_1=(deck_day1_norm==1);
idx_2=(deck_day1_norm==2);
idx_3=(deck_day1_norm==3);
deck_day1_norm(idx_1)=-1; deck_day1_norm(idx_2)=0; deck_day1_norm(idx_3)=1;
deck_day2_norm=deck_day2;
idx_1=(deck_day2_norm==1);
idx_2=(deck_day2_norm==2);
idx_3=(deck_day2_norm==3);
deck_day2_norm(idx_1)=-1; deck_day2_norm(idx_2)=0; deck_day2_norm(idx_3)=1;
idx_minus_1=(choice_day1==-1);idx_0=(choice_day1==0);
choice_day1_positive=choice_day1;choice_day1_positive(idx_minus_1)=2;choice_day1_positive(idx_0)=nan; 
idx_minus_1=(choice_day2==-1);idx_0=(choice_day2==0);
choice_day2_positive=choice_day2;choice_day2_positive(idx_minus_1)=2;choice_day2_positive(idx_0)=nan;



%% regression analysis

%%% prepare data for regression analysis (running out function)
[running_out_current_day1_pos, running_out_current_day1_neg, running_out_current_day2_pos, running_out_current_day2_neg, running_out_all_deck_day1_pos, running_out_all_deck_day1_neg, running_out_all_deck_day2_pos, running_out_all_deck_day2_neg, running_out_last_current_day1_pos, running_out_last_current_day1_neg, running_out_last_current_day2_pos, running_out_last_current_day2_neg] = running_out_070722(A, B, comp_num_day1, comp_num_day2, subj);

%%% regression for paper (reduced version, i.e., without deck)
reg_matrix_reduc_day1=[choice_day1_positive,comp_num_day1_norm,running_out_current_day1_pos,running_out_current_day1_neg];
reg_matrix_reduc_day2=[choice_day2_positive,comp_num_day2_norm,running_out_current_day2_pos,running_out_current_day2_neg];

%
i=1;
for k=0:number_of_trials:length(choice_day1)-number_of_trials %logistic regression for each subject (every 180 trials)
    %
    [coeff_reduc_day1(i,1:4), dev_reduc_day1(i), stats] = mnrfit(reg_matrix_reduc_day1(k+1:k+number_of_trials,2:4),reg_matrix_reduc_day1(k+1:k+number_of_trials,1));   
    %
    i=i+1;
end

%
i=1;
for k=0:number_of_trials:length(choice_day2)-number_of_trials %logistic regression for each subject (every 180 trials) 
    %
    [coeff_reduc_day2(i,1:4), dev_reduc_day2(i), stats] = mnrfit(reg_matrix_reduc_day2(k+1:k+number_of_trials,2:4),reg_matrix_reduc_day2(k+1:k+number_of_trials,1));   
    %
    i=i+1;
end


%% Results summary
%
results.subj.id = subj';
results.subj.drugs = drugs_index1';
%
results.gambles_taken.day1.low_deck = gambles_taken_low_deck_day1;
results.gambles_taken.day1.even_deck = gambles_taken_even_deck_day1;
results.gambles_taken.day1.high_deck = gambles_taken_high_deck_day1;
results.gambles_taken.day2.low_deck = gambles_taken_low_deck_day2;
results.gambles_taken.day2.even_deck = gambles_taken_even_deck_day2;
results.gambles_taken.day2.high_deck = gambles_taken_high_deck_day2;
results.gambles_taken.day1.overall = gambles_taken_overall_day1;
results.gambles_taken.day2.overall = gambles_taken_overall_day2;
%
results.log_reg.day1.coeff.reduc = coeff_reduc_day1;
results.log_reg.day2.coeff.reduc = coeff_reduc_day2;
results.log_reg.day1.dev.reduc = dev_reduc_day1;
results.log_reg.day2.dev.reduc = dev_reduc_day2;

%% create data structures for modelling of day1 and day2 (used in the fitting process)
i=1;
for k=0:number_of_trials:length(deck_day1_norm)-number_of_trials
    data1(i).D=deck_day1_norm(k+1:k+number_of_trials);
    data1(i).N=comp_num_day1_norm(k+1:k+number_of_trials);
    data1(i).C=choice_day1_positive(k+1:k+number_of_trials);
    data1(i).O=outcome_day1(k+1:k+number_of_trials);
    data2(i).D=deck_day2_norm(k+1:k+number_of_trials);
    data2(i).N=comp_num_day2_norm(k+1:k+number_of_trials);
    data2(i).C=choice_day2_positive(k+1:k+number_of_trials);
    data2(i).O=outcome_day2(k+1:k+number_of_trials);
    i=i+1;
end
%%
clearvars -except results data1 data2;
drug = results.subj.drugs;
save ('data1','data1');
save ('data2','data2');

%%
results.log_reg.day1.coeff.reduc(17,:) = NaN;
% mean regression weigths per drug group
placebo.regression.day1 = nanmean(results.log_reg.day1.coeff.reduc(drug==0,:));
placebo.regression.day2 = nanmean(results.log_reg.day2.coeff.reduc(drug==0,:));
ssri.regression.day1 = nanmean(results.log_reg.day1.coeff.reduc(drug==1,:));
ssri.regression.day2 = nanmean(results.log_reg.day2.coeff.reduc(drug==1,:));