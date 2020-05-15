function [running_out_current_day1_pos, running_out_current_day1_neg, running_out_current_day2_pos, running_out_current_day2_neg] = running_out(A, B, comp_num_day1, comp_num_day2, subj)

%%%% prepare running outcome regressor
%%%  day1 (running outcome calculation)
running_out_low_deck_pos = nan(size(comp_num_day1));
running_out_low_deck_neg = nan(size(comp_num_day1));
running_out_med_deck_pos = nan(size(comp_num_day1));
running_out_med_deck_neg = nan(size(comp_num_day1));
running_out_high_deck_pos = nan(size(comp_num_day1));
running_out_high_deck_neg = nan(size(comp_num_day1));

for i=1:length(subj)
    
for j = 1:180

    if A(i).D(j) == 1 %% wenn low deck
        %
        if j==1
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;            
        else
        running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i); %% dann kein Update
        running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);
        running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
        running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);
        end
        %
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_low_deck_pos(j,i) = 0;
                running_out_low_deck_neg(j,i) = 0;
            else
                running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);               
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_low_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_low_deck_pos(j,i) = 0;
                else
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j)));
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_low_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_low_deck_neg(j,i) = 0;                 
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_low_deck_pos(j,i) = 0;
                    running_out_low_deck_neg(j,i) = 0;                 
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);                    
                end                
                 
            end  
        end
     
    elseif A(i).D(j) == 2 %% wenn medium deck
        %
        if j==1
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;    
        else
            running_out_low_deck_pos(j,i) =  running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) =  running_out_low_deck_neg(j-1,i);
            running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);            
        end
        %        
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_med_deck_pos(j,i) = 0;
                running_out_med_deck_neg(j,i) = 0;                
            else
                running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                  
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1  
                    running_out_med_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_med_deck_pos(j,i) = 0;
                else
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j)));
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                end 
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_med_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_med_deck_neg(j,i) = 0;
                else
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_med_deck_pos(j,i) = 0;
                    running_out_med_deck_neg(j,i) = 0;                  
                else  
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                     
                end     
                
            end  
        end    
    else %% quasi wenn high deck   
        %
        if j==1
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;               
        else
            running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);
            running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);   
        end
        %        
        if A(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_high_deck_pos(j,i) = 0;
                running_out_high_deck_neg(j,i) = 0;  
            else
                running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
            end
        else %% quasi wenn gambled
            if A(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_high_deck_neg(j,i) = -1 .* (10-A(i).N(j));
                    running_out_high_deck_pos(j,i) = 0;
                else
                    running_out_high_deck_neg(j,i) =  running_out_high_deck_neg(j-1,i) + (-1 .* (10-A(i).N(j))); 
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);  
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_high_deck_pos(j,i) = 1 .* A(i).N(j);
                    running_out_high_deck_neg(j,i) = 0;
                else
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i) + (1 .* A(i).N(j));
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);                      
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_high_deck_pos(j,i) = 0;
                    running_out_high_deck_neg(j,i) = 0;                  
                else  
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);                  
                end 
            end  
        end            
    end
 
    
    if j==1
        running_out_current_day1_pos(j,i) = 0;
        running_out_current_day1_neg(j,i) = 0;
    else
        if A(i).D(j) == 1
            running_out_current_day1_pos(j,i) = running_out_low_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_low_deck_neg(j-1,i);
        elseif A(i).D(j) == 2
            running_out_current_day1_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_med_deck_neg(j-1,i);
        else
            running_out_current_day1_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_current_day1_neg(j,i) = running_out_high_deck_neg(j-1,i);
        end
    end
     
end

end

%%%  day2 (running outcome calculation)
running_out_low_deck_pos = nan(size(comp_num_day2));
running_out_low_deck_neg = nan(size(comp_num_day2));
running_out_med_deck_pos = nan(size(comp_num_day2));
running_out_med_deck_neg = nan(size(comp_num_day2));
running_out_high_deck_pos = nan(size(comp_num_day2));
running_out_high_deck_neg = nan(size(comp_num_day2));

for i=1:length(subj)
    
for j = 1:180

    if B(i).D(j) == 1 %% wenn low deck
        %
        if j==1
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;            
        else
        running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i); %% dann kein Update
        running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);
        running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
        running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);
        end
        %
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_low_deck_pos(j,i) = 0;
                running_out_low_deck_neg(j,i) = 0;
            else
                running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);               
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_low_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_low_deck_pos(j,i) = 0;
                else
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                end
            elseif B(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_low_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_low_deck_neg(j,i) = 0;                  
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_low_deck_pos(j,i) = 0;
                    running_out_low_deck_neg(j,i) = 0;                 
                else  
                    running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i);
                    running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);                    
                end
            end  
        end
     
    elseif B(i).D(j) == 2 %% wenn medium deck
        %
        if j==1
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_high_deck_pos(j,i) = 0;
            running_out_high_deck_neg(j,i) = 0;    
        else
            running_out_low_deck_pos(j,i) =  running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) =  running_out_low_deck_neg(j-1,i);
            running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);            
        end
        %        
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_med_deck_pos(j,i) = 0;
                running_out_med_deck_neg(j,i) = 0;                
            else
                running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                  
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1  
                    running_out_med_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_med_deck_pos(j,i) = 0;
                else
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                end 
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_med_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_med_deck_neg(j,i) = 0;
                else
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                    
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_med_deck_pos(j,i) = 0;
                    running_out_med_deck_neg(j,i) = 0;                
                else  
                    running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
                    running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);                  
                end 
            end  
        end    
    else %% quasi wenn high deck   
        %
        if j==1
            running_out_low_deck_pos(j,i) = 0;
            running_out_low_deck_neg(j,i) = 0;
            running_out_med_deck_pos(j,i) = 0;
            running_out_med_deck_neg(j,i) = 0;               
        else
            running_out_low_deck_pos(j,i) = running_out_low_deck_pos(j-1,i); %% dann kein Update
            running_out_low_deck_neg(j,i) = running_out_low_deck_neg(j-1,i);
            running_out_med_deck_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_med_deck_neg(j,i) = running_out_med_deck_neg(j-1,i);   
        end
        %        
        if B(i).C(j) == -1 %% wenn declined
            if j==1
                running_out_high_deck_pos(j,i) = 0;
                running_out_high_deck_neg(j,i) = 0;  
            else
                running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);  
            end
        else %% quasi wenn gambled
            if B(i).O(j) == -1 %% wenn lost
                if j==1
                    running_out_high_deck_neg(j,i) = -1 .* (10-B(i).N(j));
                    running_out_high_deck_pos(j,i) = 0; 
                else
                    running_out_high_deck_neg(j,i) =  running_out_high_deck_neg(j-1,i) + (-1 .* (10-B(i).N(j)));
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);  
                end
            elseif A(i).O(j) == 1 %% wenn won
                if j==1
                    running_out_high_deck_pos(j,i) = 1 .* B(i).N(j);
                    running_out_high_deck_neg(j,i) = 0;
                else
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i) + (1 .* B(i).N(j));
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);                      
                end
                
            else %% quasi wenn neutral outcome
                if j==1
                    running_out_high_deck_pos(j,i) = 0;
                    running_out_high_deck_neg(j,i) = 0;                 
                else  
                    running_out_high_deck_pos(j,i) = running_out_high_deck_pos(j-1,i);
                    running_out_high_deck_neg(j,i) = running_out_high_deck_neg(j-1,i);                    
                end 
            end  
        end            
    end
 
    
    if j==1
        running_out_current_day2_pos(j,i) = 0;
        running_out_current_day2_neg(j,i) = 0;
    else
        if B(i).D(j) == 1
            running_out_current_day2_pos(j,i) = running_out_low_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_low_deck_neg(j-1,i);
        elseif B(i).D(j) == 2
            running_out_current_day2_pos(j,i) = running_out_med_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_med_deck_neg(j-1,i);
        else
            running_out_current_day2_pos(j,i) = running_out_high_deck_pos(j-1,i);
            running_out_current_day2_neg(j,i) = running_out_high_deck_neg(j-1,i);
        end
    end
     
end

end

%
running_out_current_day1_pos = running_out_current_day1_pos(:);           
running_out_current_day1_neg = running_out_current_day1_neg(:); 
running_out_current_day2_pos = running_out_current_day2_pos(:);         
running_out_current_day2_neg = running_out_current_day2_neg(:); 