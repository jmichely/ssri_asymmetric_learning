function [running_out_current_day1_pos, running_out_current_day1_neg, running_out_current_day2_pos, running_out_current_day2_neg, running_out_all_deck_day1_pos, running_out_all_deck_day1_neg, running_out_all_deck_day2_pos, running_out_all_deck_day2_neg, running_out_last_current_day1_pos, running_out_last_current_day1_neg, running_out_last_current_day2_pos, running_out_last_current_day2_neg] = running_out_070722(A, B, comp_num_day1, comp_num_day2, subj)

%%
%%% normalise regressors individually
norma = 0; %%% 0 = OFF, 1 = ON, z-score; 2 = ON, rescale, [-1 1]
%%% normalise regressors across all subjects
norma_all = 2; %%% 0 = OFF, 1 = ON, z-score; 2 = ON, rescale, [-1 1]
 
%%
%%%% prepare running outcome regressor
%%%  day1 (running outcome calculation, deck-specific)
%
running_out_low_deck_pos = nan(size(comp_num_day1));
running_out_low_deck_neg = nan(size(comp_num_day1));
running_out_med_deck_pos = nan(size(comp_num_day1));
running_out_med_deck_neg = nan(size(comp_num_day1));
running_out_high_deck_pos = nan(size(comp_num_day1));
running_out_high_deck_neg = nan(size(comp_num_day1));
%
running_out_last_low_deck_pos = nan(size(comp_num_day1));
running_out_last_low_deck_neg = nan(size(comp_num_day1));
running_out_last_med_deck_pos = nan(size(comp_num_day1));
running_out_last_med_deck_neg = nan(size(comp_num_day1));
running_out_last_high_deck_pos = nan(size(comp_num_day1));
running_out_last_high_deck_neg = nan(size(comp_num_day1));

% (running outcome calculation, deck-unspecific)
running_out_all_deck_pos = nan(size(comp_num_day1));
running_out_all_deck_neg = nan(size(comp_num_day1));

for i=1:length(subj)
    
for j = 1:180
    
    %%%deck-unspecific outcomes running
    if A(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_all_deck_pos(j,i) = 0;
                running_out_all_deck_neg(j,i) = 0;
            else
                running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i);               
            end    
   else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_all_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_all_deck_pos(j,i) = 0;
                else
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j)));
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_all_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_all_deck_neg(j,i) = 0;                 
                else  
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_all_deck_pos(j,i) = 0;
                    running_out_all_deck_neg(j,i) = 0;                 
                else  
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i); 
                end
    
            end
    end
    
    
    %%%deck-specific outcomes running (& running only last outcome)
    if A(i).D(j) == 1 %% wenn low deck
        %
        if j==1
            %
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;       
            %
            running_out_last_med_deck_pos(j,i) = 0;
            running_out_last_med_deck_neg(j,i) = 0;
            running_out_last_high_deck_pos(j,i) = 0;
            running_out_last_high_deck_neg(j,i) = 0;                
        else
        %    
        running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i); %% dann kein Update
        running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);
        running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
        running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);
        %
        running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i); %% dann kein Update
        running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i);
        running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
        running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);        
        end
        %
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_low_deck_pos(j,i) = 0;
                running_out_low_deck_neg(j,i) = 0;
                %
                running_out_last_low_deck_pos(j,i) = 0;
                running_out_last_low_deck_neg(j,i) = 0;  
            else
                %
                running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);    
                %
                running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
                running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
                
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1
                    %
                    running_out_low_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_low_deck_pos(j,i) = 0;
                    %
                    running_out_last_low_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_low_deck_pos(j,i) = 0;   
                else
                    %
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j)));
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    
                    %
                    running_out_last_low_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);  
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_low_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_low_deck_neg(j,i) = 0;     
                    %
                    running_out_last_low_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_low_deck_neg(j,i) = 0;     
                else  
                    %
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);  
                    %
                    running_out_last_low_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_low_deck_pos(j,i) = 0;
                    running_out_low_deck_neg(j,i) = 0;     
                    %
                    running_out_last_low_deck_pos(j,i) = 0;
                    running_out_last_low_deck_neg(j,i) = 0;  
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);     
                    running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
                    running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);  
                end                
   
            end  
        end
     
    elseif A(i).D(j) == 2 %% wenn medium deck
        %
        if j==1
            %
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;  
            %
            running_out_last_low_deck_pos(j,i) = 0;
            running_out_last_low_deck_neg(j,i) = 0;
            running_out_last_high_deck_pos(j,i) = 0;
            running_out_last_high_deck_neg(j,i) = 0; 
        else
            %
            running_out_low_deck_pos(j,i) =  running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) =  running_out_low_deck_neg(j-1,i);
            running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);   
            %
            running_out_last_low_deck_pos(j,i) =  running_out_last_low_deck_pos(j-1,i); %% dann kein Update
            running_out_last_low_deck_neg(j,i) =  running_out_last_low_deck_neg(j-1,i);
            running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
            running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
        end
        %        
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_med_deck_pos(j,i) = 0;
                running_out_med_deck_neg(j,i) = 0; 
                %
                running_out_last_med_deck_pos(j,i) = 0;
                running_out_last_med_deck_neg(j,i) = 0; 
            else
                %
                running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);    
                %
                running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1  
                    %
                    running_out_med_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_med_deck_pos(j,i) = 0;
                    %
                    running_out_last_med_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_med_deck_pos(j,i) = 0;
                else
                    %
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j)));
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    %
                    running_out_last_med_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                end 
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_med_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_med_deck_neg(j,i) = 0;
                    %
                    running_out_last_med_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_med_deck_neg(j,i) = 0;
                else
                    %
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);      
                    %
                    running_out_last_med_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i);  
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_med_deck_pos(j,i) = 0;
                    running_out_med_deck_neg(j,i) = 0;   
                    %
                    running_out_last_med_deck_pos(j,i) = 0;
                    running_out_last_med_deck_neg(j,i) = 0;   
                else  
                    %
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);    
                    %
                    running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                    running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
                end     
                
            end  
        end    
    else %% quasi wenn high deck   
        %
        if j==1
            %
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;    
            %
            running_out_last_low_deck_pos(j,i) = 0;
            running_out_last_low_deck_neg(j,i) = 0;
            running_out_last_med_deck_pos(j,i) = 0;
            running_out_last_med_deck_neg(j,i) = 0; 
        else
            %
            running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);
            running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);   
            %
            running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i); %% dann kein Update
            running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
            running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
            running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
        end
        %        
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_high_deck_pos(j,i) = 0;
                running_out_high_deck_neg(j,i) = 0;  
                %
                running_out_last_high_deck_pos(j,i) = 0;
                running_out_last_high_deck_neg(j,i) = 0; 
            else
                %
                running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
                %
                running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
                running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1
                    %
                    running_out_high_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_high_deck_pos(j,i) = 0;
                    %
                    running_out_last_high_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_high_deck_pos(j,i) = 0;
                else
                    %
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j))); 
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);  
                    %
                    running_out_last_high_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);  
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_high_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_high_deck_neg(j,i) = 0;
                    %
                    running_out_last_high_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_high_deck_neg(j,i) = 0;
                else
                    %
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);    
                    %
                    running_out_last_high_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i); 
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_high_deck_pos(j,i) = 0;
                    running_out_high_deck_neg(j,i) = 0;  
                    %
                    running_out_last_high_deck_pos(j,i) = 0;
                    running_out_last_high_deck_neg(j,i) = 0;   
                else  
                    %
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
                    %
                    running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
                    running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
                end 
            end  
        end            
    end
    
    
    
 
    %%%%%%%%%%%%
    if j==1
        %
        running_out_current_day1_pos(j,i) = 0;
        running_out_current_day1_neg(j,i) = 0;
        %
        running_out_last_current_day1_pos(j,i) = 0;
        running_out_last_current_day1_neg(j,i) = 0;
    else
        if A(i).D(j) == 1
            %
            running_out_current_day1_pos(j,i) = running_out_low_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_low_deck_neg(j-1,i);
            %
            running_out_last_current_day1_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
            running_out_last_current_day1_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
        elseif A(i).D(j) == 2
            %
            running_out_current_day1_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_med_deck_neg(j-1,i);
            %
            running_out_last_current_day1_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
            running_out_last_current_day1_neg(j,i) = running_out_last_med_deck_neg(j-1,i);
        else
            %
            running_out_current_day1_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_high_deck_neg(j-1,i);
            %
            running_out_last_current_day1_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
            running_out_last_current_day1_neg(j,i) = running_out_last_high_deck_neg(j-1,i);
        end
    end
     
end

end

%%%%%%%
running_out_all_deck_day1_pos = running_out_all_deck_pos;
running_out_all_deck_day1_neg = running_out_all_deck_neg;




%%
%%%% prepare running outcome regressor
%%%  day2 (running outcome calculation, deck-specific)
%
running_out_low_deck_pos = nan(size(comp_num_day2));
running_out_low_deck_neg = nan(size(comp_num_day2));
running_out_med_deck_pos = nan(size(comp_num_day2));
running_out_med_deck_neg = nan(size(comp_num_day2));
running_out_high_deck_pos = nan(size(comp_num_day2));
running_out_high_deck_neg = nan(size(comp_num_day2));
%
running_out_last_low_deck_pos = nan(size(comp_num_day2));
running_out_last_low_deck_neg = nan(size(comp_num_day2));
running_out_last_med_deck_pos = nan(size(comp_num_day2));
running_out_last_med_deck_neg = nan(size(comp_num_day2));
running_out_last_high_deck_pos = nan(size(comp_num_day2));
running_out_last_high_deck_neg = nan(size(comp_num_day2));

% (running outcome calculation, deck-unspecific)
running_out_all_deck_pos = nan(size(comp_num_day2));
running_out_all_deck_neg = nan(size(comp_num_day2));

for i=1:length(subj)
    
for j = 1:180
    
    
    %%%deck-unspecific outcomes running
    if B(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_all_deck_pos(j,i) = 0;
                running_out_all_deck_neg(j,i) = 0;
            else
                running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i);               
            end    
   else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_all_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_all_deck_pos(j,i) = 0;
                else
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                end
            elseif B(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_all_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_all_deck_neg(j,i) = 0;                 
                else  
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_all_deck_pos(j,i) = 0;
                    running_out_all_deck_neg(j,i) = 0;                 
                else  
                    running_out_all_deck_pos(j,i) = running_out_all_deck_pos(j-1,i);
                    running_out_all_deck_neg(j,i) = running_out_all_deck_neg(j-1,i); 
                end
    
            end
    end
    
    
    %%%deck-specific outcomes running (& running only last outcome)
    if B(i).D(j) == 1 %% wenn low deck
        %
        if j==1
            %
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;       
            %
            running_out_last_med_deck_pos(j,i) = 0;
            running_out_last_med_deck_neg(j,i) = 0;
            running_out_last_high_deck_pos(j,i) = 0;
            running_out_last_high_deck_neg(j,i) = 0;                
        else
        %    
        running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i); %% dann kein Update
        running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);
        running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
        running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);
        %
        running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i); %% dann kein Update
        running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i);
        running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
        running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);        
        end
        %
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_low_deck_pos(j,i) = 0;
                running_out_low_deck_neg(j,i) = 0;
                %
                running_out_last_low_deck_pos(j,i) = 0;
                running_out_last_low_deck_neg(j,i) = 0;  
            else
                %
                running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);    
                %
                running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
                running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
                
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1
                    %
                    running_out_low_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_low_deck_pos(j,i) = 0;
                    %
                    running_out_last_low_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_low_deck_pos(j,i) = 0;   
                else
                    %
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    
                    %
                    running_out_last_low_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);  
                end
            elseif B(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_low_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_low_deck_neg(j,i) = 0;     
                    %
                    running_out_last_low_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_low_deck_neg(j,i) = 0;     
                else  
                    %
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);  
                    %
                    running_out_last_low_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_low_deck_pos(j,i) = 0;
                    running_out_low_deck_neg(j,i) = 0;     
                    %
                    running_out_last_low_deck_pos(j,i) = 0;
                    running_out_last_low_deck_neg(j,i) = 0;  
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);     
                    running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
                    running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);  
                end                
   
            end  
        end
     
    elseif B(i).D(j) == 2 %% wenn medium deck
        %
        if j==1
            %
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;  
            %
            running_out_last_low_deck_pos(j,i) = 0;
            running_out_last_low_deck_neg(j,i) = 0;
            running_out_last_high_deck_pos(j,i) = 0;
            running_out_last_high_deck_neg(j,i) = 0; 
        else
            %
            running_out_low_deck_pos(j,i) =  running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) =  running_out_low_deck_neg(j-1,i);
            running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);   
            %
            running_out_last_low_deck_pos(j,i) =  running_out_last_low_deck_pos(j-1,i); %% dann kein Update
            running_out_last_low_deck_neg(j,i) =  running_out_last_low_deck_neg(j-1,i);
            running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
            running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
        end
        %        
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_med_deck_pos(j,i) = 0;
                running_out_med_deck_neg(j,i) = 0; 
                %
                running_out_last_med_deck_pos(j,i) = 0;
                running_out_last_med_deck_neg(j,i) = 0; 
            else
                %
                running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);    
                %
                running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1  
                    %
                    running_out_med_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_med_deck_pos(j,i) = 0;
                    %
                    running_out_last_med_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_med_deck_pos(j,i) = 0;
                else
                    %
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    %
                    running_out_last_med_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                end 
            elseif B(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_med_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_med_deck_neg(j,i) = 0;
                    %
                    running_out_last_med_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_med_deck_neg(j,i) = 0;
                else
                    %
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);      
                    %
                    running_out_last_med_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i);  
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_med_deck_pos(j,i) = 0;
                    running_out_med_deck_neg(j,i) = 0;   
                    %
                    running_out_last_med_deck_pos(j,i) = 0;
                    running_out_last_med_deck_neg(j,i) = 0;   
                else  
                    %
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);    
                    %
                    running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
                    running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
                end     
                
            end  
        end    
    else %% quasi wenn high deck   
        %
        if j==1
            %
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;    
            %
            running_out_last_low_deck_pos(j,i) = 0;
            running_out_last_low_deck_neg(j,i) = 0;
            running_out_last_med_deck_pos(j,i) = 0;
            running_out_last_med_deck_neg(j,i) = 0; 
        else
            %
            running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);
            running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);   
            %
            running_out_last_low_deck_pos(j,i) = running_out_last_low_deck_pos(j-1,i); %% dann kein Update
            running_out_last_low_deck_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
            running_out_last_med_deck_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
            running_out_last_med_deck_neg(j,i) = running_out_last_med_deck_neg(j-1,i); 
        end
        %        
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                %
                running_out_high_deck_pos(j,i) = 0;
                running_out_high_deck_neg(j,i) = 0;  
                %
                running_out_last_high_deck_pos(j,i) = 0;
                running_out_last_high_deck_neg(j,i) = 0; 
            else
                %
                running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
                %
                running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
                running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1
                    %
                    running_out_high_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_high_deck_pos(j,i) = 0;
                    %
                    running_out_last_high_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_high_deck_pos(j,i) = 0;
                else
                    %
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j))); 
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);  
                    %
                    running_out_last_high_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);  
                end
            elseif B(i).O(j) == 1 %% wenn won
                if j==1
                    %
                    running_out_high_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_high_deck_neg(j,i) = 0;
                    %
                    running_out_last_high_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_high_deck_neg(j,i) = 0;
                else
                    %
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);    
                    %
                    running_out_last_high_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i); 
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    %
                    running_out_high_deck_pos(j,i) = 0;
                    running_out_high_deck_neg(j,i) = 0;  
                    %
                    running_out_last_high_deck_pos(j,i) = 0;
                    running_out_last_high_deck_neg(j,i) = 0;   
                else  
                    %
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
                    %
                    running_out_last_high_deck_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
                    running_out_last_high_deck_neg(j,i) = running_out_last_high_deck_neg(j-1,i);  
                end 
            end  
        end            
    end
    
    
    
 
    %%%%%%%%%%%%
    if j==1
        %
        running_out_current_day2_pos(j,i) = 0;
        running_out_current_day2_neg(j,i) = 0;
        %
        running_out_last_current_day2_pos(j,i) = 0;
        running_out_last_current_day2_neg(j,i) = 0;
    else
        if B(i).D(j) == 1
            %
            running_out_current_day2_pos(j,i) = running_out_low_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_low_deck_neg(j-1,i);
            %
            running_out_last_current_day2_pos(j,i) = running_out_last_low_deck_pos(j-1,i);
            running_out_last_current_day2_neg(j,i) = running_out_last_low_deck_neg(j-1,i);
        elseif B(i).D(j) == 2
            %
            running_out_current_day2_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_med_deck_neg(j-1,i);
            %
            running_out_last_current_day2_pos(j,i) = running_out_last_med_deck_pos(j-1,i);
            running_out_last_current_day2_neg(j,i) = running_out_last_med_deck_neg(j-1,i);
        else
            %
            running_out_current_day2_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_high_deck_neg(j-1,i);
            %
            running_out_last_current_day2_pos(j,i) = running_out_last_high_deck_pos(j-1,i);
            running_out_last_current_day2_neg(j,i) = running_out_last_high_deck_neg(j-1,i);
        end
    end
     
end

end

%%%%%%%
running_out_all_deck_day2_pos = running_out_all_deck_pos;
running_out_all_deck_day2_neg = running_out_all_deck_neg;






%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% normalise regressors individually
if norma == 1
%%%% z-scoring
running_out_current_day1_pos = zscore(running_out_current_day1_pos);
running_out_current_day1_neg = zscore(running_out_current_day1_neg);
running_out_current_day2_pos = zscore(running_out_current_day2_pos);
running_out_current_day2_neg = zscore(running_out_current_day2_neg);    
    
elseif norma == 2    
%%%%% rescale [-1 1]
colmin_day1_pos = min(running_out_current_day1_pos);
colmax_day1_pos = max(running_out_current_day1_pos);
running_out_current_day1_pos = rescale(running_out_current_day1_pos, -1, 1, 'InputMin',colmin_day1_pos,'InputMax',colmax_day1_pos);
colmin_day1_neg = min(running_out_current_day1_neg);
colmax_day1_neg = max(running_out_current_day1_neg);
running_out_current_day1_neg = rescale(running_out_current_day1_neg, -1, 1, 'InputMin',colmin_day1_neg,'InputMax',colmax_day1_neg);
colmin_day2_pos = min(running_out_current_day2_pos);
colmax_day2_pos = max(running_out_current_day2_pos);
running_out_current_day2_pos = rescale(running_out_current_day2_pos, -1, 1, 'InputMin',colmin_day2_pos,'InputMax',colmax_day2_pos);
colmin_day2_neg = min(running_out_current_day2_neg);
colmax_day2_neg = max(running_out_current_day2_neg);
running_out_current_day2_neg = rescale(running_out_current_day2_neg, -1, 1, 'InputMin',colmin_day2_neg,'InputMax',colmax_day2_neg);
else
end

%%%%% normalise regressors across all subjects
% all subjects in one column
running_out_current_day1_pos = running_out_current_day1_pos(:);           
running_out_current_day1_neg = running_out_current_day1_neg(:); 
running_out_current_day2_pos = running_out_current_day2_pos(:);         
running_out_current_day2_neg = running_out_current_day2_neg(:); 
%
running_out_last_current_day1_pos = running_out_last_current_day1_pos(:);           
running_out_last_current_day1_neg = running_out_last_current_day1_neg(:); 
running_out_last_current_day2_pos = running_out_last_current_day2_pos(:);         
running_out_last_current_day2_neg = running_out_last_current_day2_neg(:); 
%
running_out_all_deck_day1_pos = running_out_all_deck_day1_pos(:);           
running_out_all_deck_day1_neg = running_out_all_deck_day1_neg(:); 
running_out_all_deck_day2_pos = running_out_all_deck_day2_pos(:);           
running_out_all_deck_day2_neg = running_out_all_deck_day2_neg(:);

if norma_all == 1
%%%% z-scoring
running_out_current_day1_pos = zscore(running_out_current_day1_pos);
running_out_current_day1_neg = zscore(running_out_current_day1_neg);
running_out_current_day2_pos = zscore(running_out_current_day2_pos);
running_out_current_day2_neg = zscore(running_out_current_day2_neg);

elseif norma_all == 2
%%%%% rescale [-1 1]
%
running_out_current_day1_pos = rescale(running_out_current_day1_pos, -1, 1);
running_out_current_day1_neg = rescale(running_out_current_day1_neg, -1, 1);
running_out_current_day2_pos = rescale(running_out_current_day2_pos, -1, 1);
running_out_current_day2_neg = rescale(running_out_current_day2_neg, -1, 1);
%
running_out_last_current_day1_pos = rescale(running_out_last_current_day1_pos, -1, 1);
running_out_last_current_day1_neg = rescale(running_out_last_current_day1_neg, -1, 1);
running_out_last_current_day2_pos = rescale(running_out_last_current_day2_pos, -1, 1);
running_out_last_current_day2_neg = rescale(running_out_last_current_day2_neg, -1, 1);
%
running_out_all_deck_day1_pos = rescale(running_out_all_deck_day1_pos, -1, 1);
running_out_all_deck_day1_neg = rescale(running_out_all_deck_day1_neg, -1, 1);
running_out_all_deck_day2_pos = rescale(running_out_all_deck_day2_pos, -1, 1);
running_out_all_deck_day2_neg = rescale(running_out_all_deck_day2_neg, -1, 1);


else
end