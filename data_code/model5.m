function [lik] = model5(P, data)
S = size(P.betafree,1); % number of samples
Q = zeros(S,3);
eta_pos=P.eta_pos;
eta_neg=P.eta_neg;
betafree=P.betafree;
beta_N=P.beta_N;
beta_Q=P.beta_Q;
f_log=@(x)1./(1+exp(-(x))); %logistic function

% loop over all trials in low (=-1)/even (=0) and high(=1) decks and compute choice probabilities  
 for j=1:180 %run over all 180 trials
  if (data.C(j)==1||2) % exclude trials with no choice (data(k).C=Nan)
   V = betafree+beta_N.*data.N(j) + beta_Q .* Q(:,data.D(j)+2);
     if data.C(j)==1
      prob(j,1:S) = f_log(V); %logistic function in case a gamble was taken
     else
      prob(j,1:S) =1-f_log(V); %logistic function in case a gamble was declined 
     end
   % update Q values in case a gamble was taken
   if data.C(j)==1
     if data.O(j)==1  
        delta_pos = data.O(j) - Q(:,data.D(j)+2);
        delta_neg = zeros(S,1);
        delta_neutral=zeros(S,1);  
     elseif data.O(j)==-1
        delta_neg = data.O(j) - Q(:,data.D(j)+2);
        delta_pos = zeros(S,1);
        delta_neutral=zeros(S,1);
     else
        delta_neutral=data.O(j) - Q(:,data.D(j)+2);
        delta_pos = zeros(S,1);
        delta_neg = zeros(S,1);           
     end
     Q(:,data.D(j)+2) = Q(:,data.D(j)+2) + eta_pos.*delta_pos + eta_neg.*delta_neg + ((eta_pos+eta_neg)./2).*delta_neutral;
   end
  end
end
for t=1:S 
lik(t,:)=sum(log(prob(1:180,t))); %creates a vector of LL for all samples
end
end