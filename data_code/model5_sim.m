function [latents] = model5_sim(P, EXPT)
S = size(P.betafree,1); % number of samples
Q = zeros(S,3);
eta_pos=P.eta_pos;
eta_neg=P.eta_neg;
betafree=P.betafree;
beta_N=P.beta_N;
beta_Q=P.beta_Q;
%%% simulation
probwin =EXPT.S.probwin;
probloss =EXPT.S.probloss;
counterwin =EXPT.S.counterwin;
counterloss =EXPT.S.counterloss;
postponedlosses =EXPT.S.postponedlosses;
level =EXPT.S.level;
%
f_log=@(x)1./(1+exp(-(x))); %logistic function

for j=1:180 %run over all 180 trials
    if mod(j,15)==1 %% main task
        if j>1
            inds = j-16 + find(latents.N(j-15:j-1)==level-1 | latents.N(j-15:j-1)==level | latents.N(j-15:j-1)==level+1);
            sumc = sum(latents.sim_C(inds)==1); 
            if sumc<=3; level = max(level-1, 2); end
            if sumc==0; level = max(level-1, 2); end
            if sumc>=6; level = min(level+1, 8); end
            if sumc==9; level = min(level+1, 8); end
        end

        lineup = ones(9,1);
        lineup(level-1:level+1) = 3;
        pcnumtemp = [];
        for k = 1:length(lineup)
            pcnumtemp = [pcnumtemp; k*ones(lineup(k),1)];
        end                       
        decks = (1:3)';
        decktemp([1:level-2 6+(level+2:9)]) = [decks(randperm(3)); decks(randperm(3))];
        decktemp(level-1:level+7) = [decks; decks; decks];

        endflag = 0;
        ts = j:j+14;
        while ~endflag
            ord = randperm(15);
            for c1= 1:3
                for c2=1:3
                    c1c2(c1,c2) = sum(diff(decktemp(ord))==c2-c1 & decktemp(ord(1:14))==(c1));
                end
            end
            if j>1;  c1c2(latents.D(j-1) ,decktemp(ord(1))) =  c1c2(latents.D(j-1) ,decktemp(ord(1))) + 1;     end
            if all(diag(c1c2)==2) && max(c1c2(:))==2 && min(c1c2(:))>=1; endflag = 1; end
        end
        latents.N(ts,1) = pcnumtemp(ord);
        latents.N_norm(ts,1) = (latents.N(ts,1) - 1) / 8; latents.N_norm(ts,1) = (2 * latents.N_norm(ts,1) - 1)*(-1);
        latents.D(ts,1) = decktemp(ord);
        latents.D_norm(ts,1) = latents.D(ts,1)-2;
    end
    
        %%%%%%%%%%
        V = betafree+beta_N.*latents.N_norm(j) + beta_Q .* Q(:,latents.D(j));
        p = [f_log(V), 1-f_log(V)];  % [probabilty to gamble, probability to decline]
        latents.sim_C(j,1) = mfUtil.randmultinomial(p);      % random choice
            switch latents.sim_C(j,1)
                case 2; latents.O(j) = 0; %% reject gamble
                case 0; latents.O(j) = -1; %% didn't choose
                case 1 %% accept gamble
                    counter = randi(2);
                    cwin = counterwin(latents.D(j),counter);
                    closs = counterloss(latents.D(j),counter);
                    postloss = postponedlosses(latents.D(j),counter);
                    if cwin + probwin(latents.D(j), latents.N(j)) > round(cwin)+0.5
                        latents.O(j) = 1;
                        if closs + probloss(latents.D(j),latents.N(j)) > round(closs)+0.5
                            postloss = postloss + 1;
                        end
                    elseif closs + probloss(latents.D(j),latents.N(j)) > round(closs)+0.5
                        latents.O(j) = -1;
                    elseif postloss > 0 && latents.N(j)>1
                        postloss = postloss - 1;
                        latents.O(j) = -1;
                    else
                        latents.O(j) = 0;
                    end  
                    counterwin(latents.D(j),counter) = counterwin(latents.D(j),counter) + probwin(latents.D(j),latents.N(j));
                    counterloss(latents.D(j),counter) = counterloss(latents.D(j),counter) + probloss(latents.D(j),latents.N(j));
                    postponedlosses(latents.D(j),counter) = postloss;                                
            end            

        % update Q values in case a gamble was taken
        if latents.sim_C(j)==1
            if latents.O(j)==1
                delta_pos = latents.O(j) - Q(:,latents.D(j));
                delta_neg = zeros(S,1);
                delta_neutral=zeros(S,1);  
            elseif latents.O(j)==-1
                delta_neg = latents.O(j) - Q(:,latents.D(j));
                delta_pos = zeros(S,1);
                delta_neutral=zeros(S,1);
            else
                delta_neutral=latents.O(j) - Q(:,latents.D(j));
                delta_pos = zeros(S,1);
                delta_neg = zeros(S,1);
            end  
            Q(:,latents.D(j)) = Q(:,latents.D(j)) + eta_pos.*delta_pos+eta_neg.*delta_neg+((eta_pos+eta_neg)./2).*delta_neutral;
        end
end
 
    


 




