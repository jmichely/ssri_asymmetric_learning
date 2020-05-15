function [lik] = model1(P, data)
S = size(P.betafree,1); % number of samples
betafree=P.betafree;
f_log=@(x)1./(1+exp(-(x))); %logistic function

% loop over all trials in low (=-1)/even (=0) and high(=1) decks and compute choice probabilities  
 for j=1:180 %run over all 180 trials
  if (data.C(j)==1||2) % exclude trials with no choice (data(k).C=Nan)
   V = betafree;
     if data.C(j)==1
      prob(j,1:S) = f_log(V); %logistic function in case a gamble was taken
     else
      prob(j,1:S) =1-f_log(V); %logistic function in case a gamble was declined 
     end
   end
end
for t=1:S 
lik(t,:)=sum(log(prob(1:180,t))); %creates a vector of LL for all samples
end
end