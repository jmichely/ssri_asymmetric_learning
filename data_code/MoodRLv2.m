classdef MoodRLv2 < handle
        
    properties
               
        W; % window        
        AP; % affective priming
        I; % images
        D; % data        
        P; % task parameters
        S; % stimuli       
        Q; % questionnaires
        E; % eye tracking
        
    end
    
    methods
        
        function run(obj, block)
            
            try                
                w = obj.W.w; I = obj.I; S = obj.S; P = obj.P; T = S.Tblock; 
                if ~obj.E; Utilities.ETmessage(['Cards' num2str(block)]); end
                Utilities.SCR(4);  
                Screen('Flip',w);
                
                %% initialize variables
                if block > 0
                    level = S.level;
                    shockord = repmat([false true],3,T/6);
                    for j = 1:2:T/3
                        shockord(1,j:j+1) = shockord(1,j-1+randperm(2));
                        shockord(2,j:j+1) = shockord(2,j-1+randperm(2));
                        shockord(3,j:j+1) = shockord(3,j-1+randperm(2));
                    end
                    
                    probwin = S.probwin;
                    probloss = S.probloss;
                    counterwin = S.counterwin;
                    counterloss = S.counterloss;
                    postponedlosses = S.postponedlosses;
                    Sck = false(T,1);
                else
                    if block==-1
                        T = 60; 
                        deck = 4 + zeros(T, 1);
                        pcnum = randi(9, T, 1);
                        num = randi(9, T, 1);
                    elseif block==0 
                        T = 30;
                        level = 5;
                    end
                end                
                Tfix = zeros(T,1);
                Tdeck = zeros(T,1);
                Tflipstart = zeros(T,1);
                Tflipend = zeros(T,1);
                Tflip = zeros(T,1);
                Tchoice = zeros(T,1);
                Tostart = zeros(T,1);
                Toend = zeros(T,1);
                To = zeros(T,1);
                C = zeros(T,1);
                O = zeros(T,1);
                
                tfix = 0;
                t=0;
                while t<T
                    t=t+1;
                    if block>0 && mod(t,15)==1
                        if t>1
                            inds = t-16 + find(pcnum(t-15:t-1)==level-1 | pcnum(t-15:t-1)==level | pcnum(t-15:t-1)==level+1);
                            sumc = sum(C(inds)==1);
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
                        decks = (1:3)' + 4*(block==0);
                        decktemp([1:level-2 6+(level+2:9)]) = [decks(randperm(3)); decks(randperm(3))];
                        decktemp(level-1:level+7) = [decks; decks; decks];
                        
                        endflag = 0;
                        ts = t:t+14;
                        while ~endflag
                            ord = randperm(15);
                            for c1= 1:3
                                for c2=1:3
                                    c1c2(c1,c2) = sum(diff(decktemp(ord))==c2-c1 & decktemp(ord(1:14))==(c1 + 4*(block==0)));
                                end
                            end
                            if t>1;  c1c2(deck(t-1) - 4*(block==0),decktemp(ord(1)) - 4*(block==0)) =  c1c2(deck(t-1) - 4*(block==0),decktemp(ord(1)) - 4*(block==0)) + 1;     end
                            
                            if all(diag(c1c2)==2) && max(c1c2(:))==2 && min(c1c2(:))>=1; endflag = 1; end
                        end
                        pcnum(ts,1) = pcnumtemp(ord);
                        deck(ts,1) = decktemp(ord);
                    elseif block==0 && mod(t,10)==1
                        two = [1 1 0];
                        lineup(1:3) = two(randperm(3));
                        lineup(4:6) = 2;   
                        lineup(7:9) = two(randperm(3));
                        pcnumtemp = [];
                        for k = 1:length(lineup)
                            pcnumtemp = [pcnumtemp; k*ones(lineup(k),1)];
                        end                       
                        decks = (5:2:7)';
                        decktemp([1:2,9:10],1) = [decks(randperm(2)); decks(randperm(2))];
                        decktemp(3:8) = [decks; decks; decks];
                        
                        ts = t:t+9;
                        ord = randperm(10);
                        pcnum(ts,1) = pcnumtemp(ord);
                        deck(ts,1) = decktemp(ord);
                        nms = [7 5 3 2 1];
                        numtemp(deck(ts,1)==5) = nms(randperm(5));
                        nms = [9 8 7 5 3];
                        numtemp(deck(ts,1)==7) = nms(randperm(5));
                        num(ts,1) = numtemp;                        
                    end
                    
                    
                    
                    %% fixation point
                    Screen('DrawTexture',w, I.fixtxtr);
                    Tfix(t)=Screen(w,'Flip', tfix);
                    if ~obj.E; Utilities.ETmessage('fix'); end                 
                    
                    if block<=0; Tdeck(t)=Tfix(t)+1;
                    else Tdeck(t)=Tfix(t)+obj.P.ITinterval();
                    end

                    %% draw stimuli
                    Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                    obj.drawCard(3,deck(t));
                    Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                    
                    if block <=0; Tflipstart(t) = Screen('Flip', w, Tdeck(t)) + 1; 
                    else Tflipstart(t) = Screen('Flip', w, Tdeck(t)) + P.CDinterval();
                    end
                    if ~obj.E; Utilities.ETmessage('display'); end 
                    Utilities.SCR(1);  
                    
                    for i=2:2:5
                        Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                        obj.drawCard(3,deck(t));
                        Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                        Screen('DrawTexture',w, I.pccard.txtr(1,i), [], [440 160  800 600]);
                        Tflip(t) = Screen('Flip', w, Tflipstart(t));
                    end
                    Utilities.SCR(2); 
                    if ~obj.E; Utilities.ETmessage('flip'); end
                    for i=1:2:5
                        Screen('DrawTexture',w, I.deck.txtr(2),[], [440 160  800 600]);
                        obj.drawCard(3,deck(t));
                        Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                        Screen('DrawTexture',w, I.pcoutcome.txtr(pcnum(t),i),[] , [801 160  1160 600]);
                        Screen('DrawTexture',w, I.choice.txtr(1),[], [801 601  1160 1040]);
                        Tflipend(t) = Screen('Flip', w);
                    end                    
                     
                    

                    %% get choice
                    [key, Tchoice(t)] = Utilities.waitForInput(P.trialkeys, Tflipend(t) + P.TOinterval());
                    if any(key==P.trialkeys(1))
                        C(t)=1;
                    elseif any(key==P.trialkeys(2))
                        C(t)=-1;
                    else
                        C(t)=0;
                    end
                    
                    %% show choice 
                    Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                    Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                    Screen('DrawTexture',w, I.pcoutcome.txtr(pcnum(t),5),[] , [801 160  1160 600]);
                    obj.drawCard(3,deck(t));
                    if block<=0 || C(t)>=0
                        Screen('DrawTexture',w, I.choice.txtr((C(t)==1)*3+(C(t)==-1)*2 + (C(t)==0)*4),[], [801 601 1160 1040]);
                    end
                    Screen('Flip', w);
                    if block <=0; Tostart(t) = Tchoice(t) + 0.6; 
                    elseif C(t)>0; Tostart(t) = Tchoice(t) + 0.6;%P.COinterval();
                    elseif C(t)==0; Tostart(t) = Tchoice(t) + 1.2;%P.COinterval();
                    else Tostart(t) = Tchoice(t);
                    end
                    
                    %% show outcome
                    if block<=0
                        if abs(C(t)) == 1
                            if num(t)>pcnum(t); O(t) = 1 + (C(t)==-1);
                            elseif num(t)<pcnum(t); O(t) = 2 - (C(t)==-1);
                            else O(t) = 3;
                            end
                        else
                            O(t) = 2;
                        end
                    else
                        switch C(t)
                            case -1; O(t) = 0;
                            case 0; O(t) = -1;
                            case 1
                                counter = randi(2);
                                cwin = counterwin(deck(t),counter);
                                closs = counterloss(deck(t),counter);
                                postloss = postponedlosses(deck(t),counter);
                                if cwin + probwin(deck(t), pcnum(t)) > round(cwin)+0.5
                                    O(t) = 1;
                                    if closs + probloss(deck(t),pcnum(t)) > round(closs)+0.5
                                        postloss = postloss + 1;
                                    end
                                elseif closs + probloss(deck(t),pcnum(t)) > round(closs)+0.5
                                    O(t) = -1;
                                elseif postloss > 0 && pcnum(t)>1
                                    postloss = postloss - 1;
                                    O(t) = -1;
                                else
                                    O(t) = 0;
                                end  
                                counterwin(deck(t),counter) = counterwin(deck(t),counter) + probwin(deck(t),pcnum(t));
                                counterloss(deck(t),counter) = counterloss(deck(t),counter) + probloss(deck(t),pcnum(t));
                                postponedlosses(deck(t),counter) = postloss;                                
                        end
                    end 
                        
                    if block<=0 || C(t)==1

                        for i=2:2:5
                            Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                            Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                            Screen('DrawTexture',w, I.pcoutcome.txtr(pcnum(t),5),[] , [801 160  1160 600]);
                            Screen('DrawTexture',w, I.choice.txtr((C(t)==1)*3 + (C(t)==-1)*2 + (C(t)==0)*4),[], [801 601 1160 1040]);
                            obj.drawCard(3,deck(t));
                            obj.drawCard(1,deck(t),i);
                            To(t) = Screen('Flip', w, Tostart(t));
                        end
                    end
                    
                    if block<=0; ind = num(t);
                    else
                        if obj.D.type=='s'
                            if O(t)==-1; ind = 10;
                            elseif O(t)==1; ind = 11;
                            else ind = 12;
                            end
                        else
                            if O(t)==-1; ind = 14;
                            elseif O(t)==1; ind = 13;
                            else ind = 15;
                            end
                        end
                    end
                    
                    if ~obj.E; Utilities.ETmessage('outcome'); end
                    Utilities.SCR(3);  

                    if block<=0 || C(t)==1
                    
                        for i=1:2:5
                            Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                            Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                            Screen('DrawTexture',w, I.pcoutcome.txtr(pcnum(t),5),[] , [801 160  1160 600]);
                            Screen('DrawTexture',w, I.choice.txtr((C(t)==1)*3 + (C(t)==-1)*2 + (C(t)==0)*4),[], [801 601 1160 1040]);
                            obj.drawCard(3,deck(t));
                            obj.drawCard(2,deck(t),i,ind);

                            if i==5
                                if block <= 0
                                    Screen('DrawTexture',w, I.fback.txtr(O(t)), [], [1100 500 1300 700]);
                                end
                            end
                            Toend(t) = Screen('Flip', w);
                        end
                    else   
                        
                        Screen('DrawTexture',w, I.deck.txtr(2), [], [440 160  800 600]);
                        Screen('DrawTexture',w, I.pccard.txtr(1,1), [], [440 160  800 600]);
                        Screen('DrawTexture',w, I.pcoutcome.txtr(pcnum(t),5),[] , [801 160  1160 600]);
                        Screen('DrawTexture',w, I.choice.txtr((C(t)==-1)*2 + (C(t)==0)*4),[], [801 601 1160 1040]);
                        obj.drawCard(3,deck(t));
                        obj.drawCard(2,0,5,ind);
                        Toend(t) = Screen('Flip', w, Tostart(t));
                        
                    end
                    
                    if block <= 0
                        
                    else
                        % shock
                        if obj.D.type == 's' 
                            if O(t)==-1; Utilities.shock; Sck(t) = true;
                            elseif O(t)==0 && shockord(deck(t),sum(O(1:t-1)==0 & deck(1:t-1)==deck(t))+1); Utilities.shock; Sck(t) = true;
                            end
                        end
                    end
                    
                    if block<=0; tfix = Tostart(t) + 1;
                    else tfix = Tostart(t) + P.Ointerval();                            
                    end
                    
                    %% training stop criteria
                    if block==-1 && t>40 && mod(t,10)==0
                        back = 19;
                        pcnums = pcnum(t-back:t);
                        maxscore = sum(abs(pcnums-5)); 
                        score = sum(abs([pcnums(C(t-back:t)==-1 & pcnums>5);  pcnums(C(t-back:t)==1 & pcnums<5)] - 5));
                        str = sprintf('Required performance: %s\n\nYour performance: %s',strcat(num2str(80),'%'),strcat(num2str(round(score/maxscore*100)),'%'));
                        if score<0.8*maxscore 
                            T = T+10;
                            deck(t+1:t+10,1) = 4 + zeros(10, 1);
                            pcnum(t+1:t+10,1) = randi(9, 10, 1);
                            num(t+1:t+10,1) = randi(9, 10, 1);                            
                            str = [str '\n\nPlease adjust your bets to the computer''s nunmbers!'];
                            str = [str '\n\nPress ' obj.P.keycont ' to continue'];
                        else
                            str = [str '\n\nGreat job!'];
                            str = [str '\n\nPress ' obj.P.keycont ' to move on to the next stage'];
                        end
                        if score>=0.8*maxscore || mod(t,20)==0
                            DrawFormattedText(w, str, 'center', 'center', 255);
                            Screen('Flip', obj.W.w);
                            Utilities.waitForInput(obj.P.instkeys(4), inf);
                        end
                    elseif block==0 && t>20 && mod(t,10)==0
                        back = 29;
                        pcnums = pcnum(t-back:t);
                        decks = deck(t-back:t);
                        maxscore = sum(pcnums>3 & pcnums <7 & (decks==5 | decks==7)); 
                        score = sum(C(t-back:t)==1 & decks==7 & pcnums>3 & pcnums <7) + sum(C(t-back:t)==-1 & decks==5  & pcnums>3 & pcnums <7);
                        str = sprintf('Required performance: %s\n\nYour performance: %s',strcat(num2str(80),'%'),strcat(num2str(round(score/maxscore*100)),'%'));
                        if score<0.8*maxscore; 
                            T = T + 10; 
                            str = [str '\n\nPlease adjust your bets to the decks more!'];
                            str = [str '\n\nPress ' obj.P.keycont ' to continue'];
                        else
                            str = [str '\n\nGreat job!'];
                            str = [str '\n\nPress ' obj.P.keycont ' to move on to the next stage'];                            
                        end
                        if score>=0.8*maxscore || mod(t,30)==0
                            DrawFormattedText(w, str, 'center', 'center', 255);
                            Screen('Flip', obj.W.w);
                            Utilities.waitForInput(obj.P.instkeys(4), inf);
                        end
                    end
                    fprintf('Trial %d(%ds): %.2f %.2f %.2f\n', t, round(GetSecs-Tfix(1)), mean(C(deck(1:t)==1)==1), mean(C(deck(1:t)==2)==1), mean(C(deck(1:t)==3)==1));
                 end
                
                %% fixation point
                Screen('DrawTexture',w, I.fixtxtr);
                Screen(w,'Flip', tfix);
                if ~obj.E; Utilities.ETmessage('fix'); end              

                WaitSecs(obj.P.ITinterval());
                if ~obj.E; Utilities.ETmessage('end'); end               
                Utilities.SCR(4);  
                
                %% store data
                if block > 0
                    inds = 1+(block-1)*T:block*T;
                    obj.D.T.fix(inds,1) = Tfix;
                    obj.D.T.deck(inds,1) = Tdeck;
                    obj.D.T.flip(inds,1) = Tflip;
                    obj.D.T.fliprng(inds,1:2) = [Tflipstart Tflipend];
                    obj.D.T.choice(inds,1) = Tchoice;
                    obj.D.T.out(inds,1) = To;
                    obj.D.T.outrng(inds,1:2) = [Tostart Toend];
                    obj.D.T.o(inds,1) = Tostart;
                    obj.D.C(inds,1) = C;
                    obj.D.O(inds,1) = O;

                    obj.S.deck(inds,1) = deck;
                    obj.S.pcnum(inds,1) = pcnum;
                    obj.S.pcnum(inds,1) = pcnum;
                    obj.S.counterwin = counterwin;
                    obj.S.counterloss = counterloss;
                    obj.S.postponedlosses = postponedlosses;
                    obj.S.Sck(inds,1) = Sck;
                    obj.S.level = level;
                    
                else
                    obj.D.Tr(block+2).T.fix = Tfix;
                    obj.D.Tr(block+2).T.deck = Tdeck;
                    obj.D.Tr(block+2).T.flip = Tflip;
                    obj.D.Tr(block+2).T.fliprng = [Tflipstart Tflipend];
                    obj.D.Tr(block+2).T.choice = Tchoice;
                    obj.D.Tr(block+2).T.out = To;
                    obj.D.Tr(block+2).T.outrng = [Tostart Toend];
                    obj.D.Tr(block+2).C = C;
                    obj.D.Tr(block+2).O = O;
                    obj.S.Tr(block+2).deck = deck;
                    obj.S.Tr(block+2).pcnum = pcnum;
                    obj.S.Tr(block+2).num = num;
                end

            catch exception
                if ~exist('Data','file')
                    mkdir('Data');
                end
                save(sprintf('Data/%d_%d-%d-%d_%d-%d-%d-crash_internal.mat',fix(clock)));
                obj.close;
                rethrow(exception);
            end   
            
        end

        function obj = MoodRLv2(type, number, short, keyboard, run)
            addpath(genpath('C:\Users\Eran\Documents\MATLAB\Psychtoolbox'));
            addpath('C:\Users\Eran\Documents\MATLAB\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a\');
            if run==1
                if nargin<4 || isempty(keyboard); keyboard = 0; end
                obj.D.number = number;
                obj.D.type = 'm';

                P.CDinterval = @() (3 + rand*3) * (1-0.8*short);
                P.COinterval = @() (0) * (1-0.6*short);
                P.ITinterval = @() (3 + rand*3) * (1-0.8*short);
                P.TOinterval = (2.5);
                P.Ointerval = (2) * (1);
                obj.P = P;

                %% stimuli
                S.randpattern = [randperm(3) 4:7];
                S.C = 3; S.N = 1; S.R = 1; S.T = 60*3; S.Tblock = 60; S.indc = ones(S.C,1); S.level = 5;
                S.type = 'm';
                S.session = type;
                S.probwin = repmat((8:-1:0)/9, 3, 1);
                S.probwin(3,1:8) = min(S.probwin(3,1:8) + 0.3, 1);
                S.probloss = repmat((0:8)/9, 3, 1);
                S.probloss(3,:) = max(0, S.probloss(3,:) - 0.3);
                S.probloss(1,2:9) = min(S.probloss(1,2:9) + 0.3, 1);
                S.probwin(1,:) = max(0, S.probwin(1,:) - 0.3);
                S.counterwin = zeros(3,2);
                S.counterloss = zeros(3,2);
                S.postponedlosses = zeros(3,2);

                lose = 1 * (((mod(number-1, 4) < 1 | mod(number-1, 4) > 2) & S.type == 's') | ((mod(number-1, 4) > 0 & mod(number-1, 4) < 3) & S.type == 'm'));
                S.wof = 0;
                obj.S = S;

                %% set random stream
                s = RandStream.create('mt19937ar','seed',sum(100*clock));
                try RandStream.setGlobalStream(s);
                catch; RandStream.setDefaultStream(s); %#ok<SETRS>
                end

                %% set screen and colors
                W.colrand = 1:3;   
                for i=1:number; W.colrand = [W.colrand(2:3) W.colrand(1)]; end
                if mod(number-1,6)>=3; W.colrand = W.colrand(3:-1:1); end               
                obj.S.coltype = ~((strcmp(S.session,'first') && mod(number-1,12)>=6) || (strcmp(S.session,'second') && mod(number-1,12)<6));
                W.backcol=[130 130 130]; W.keyboard = keyboard;
                obj.W = W;
                obj.openWindow;  
                W = obj.W;

                %% set keyboard and mouse
                KbName('UnifyKeyNames');
                HideCursor;
                if ~keyboard
                    keys = [KbName('1!') KbName('q') KbName('a') KbName('z')]; keys2 = 2;
                    while any(keys~=keys2) && ~short
                        keys = Utilities.getKeys(W.w, {'top', 'second from the top', 'third from the top', 'bottom'});
                        keys2 = Utilities.getKeys(W.w, {'top', 'second from the top', 'third from the top', 'bottom'});
                    end
                    Screen('Flip',W.w);
                    obj.P.trialkeys = keys(1:2);
                    obj.P.instkeys = keys;
                    obj.P.questkeys = keys;
                    obj.P.keycont = 'the bottom button';
                    obj.P.keybrowse = 'second/top buttons';
                    obj.P.keyup = 'top button';
                    obj.P.keydown = 'second button from the top';
                    obj.P.keyleft = 'the top button';
                    obj.P.keyright = 'the second button from the top';
                    obj.P.keyrightleft = 'top and second buttons';
                    obj.P.keysubmit = 'bottom button';
                    obj.P.keyconfirm = 'second button from the bottom';
                else
                    obj.P.instkeys = [KbName('LeftArrow') KbName('RightArrow') KbName('c') KbName('Space')];
                    obj.P.trialkeys = [KbName('UpArrow') KbName('DownArrow')];
                    obj.P.questkeys = [KbName('1!') KbName('2@') KbName('3#') KbName('4$') KbName('5%') KbName('6^') KbName('7&') KbName('8*') KbName('9(') KbName('delete')];
                    obj.P.keycont = 'space';
                    obj.P.keybrowse = 'left/right arrows';
                    obj.P.keyup = 'up arrow';
                    obj.P.keydown = 'down arrow';
                    obj.P.keyleft = 'left arrows';
                    obj.P.keyright = 'right';
                    obj.P.keyrightleft = 'right and left arrows';
                    obj.P.keysubmit = 'press space';
                    obj.P.keyconfirm = 'press ''c''';
                end
                %ListenChar(2);

                %% load images
                obj.loadImages;

                %% questionnaires
                Q.instOutcomes = Quest(['Questionnaires/inst' S.type 'OutcomesTest.txt'], W.w, obj.P.questkeys);
                Q.instColors = Quest(['Questionnaires/inst' S.type 'ColorsTest.txt'], W.w, obj.P.questkeys); %#ok<*PROP>
                obj.Q = Q;
                %%  set eyetracking 
                obj.E = Utilities.ETinit(sprintf('MRL%3.3d_%d',number,run));
                if obj.E == 0 && ~short
                    Utilities.ETcalibrate(W.w, W.width, W.height, obj.I.fixtxtr, obj.I.fixsz(1), obj.I.fixsz(2));
                    Utilities.ETstart
                    Utilities.ETrecord(W.w, obj.I.fixtxtr);
                end
            else
                files=dir(sprintf(['Data/Sub%02d_%d' type '*.mat'],number,run-1));
                loadobj = load(['Data/' files(end).name]);
                obj = loadobj.EXPT;
                obj.openWindow;
                W = obj.W;
                obj.loadImages;
                obj.E = Utilities.ETinit(sprintf('MRL%3.3d_%d',number,run));
                if obj.E == 0 && ~short
                    Utilities.ETstart
                end
            end
                
        end

        function openWindow(obj)
            W = obj.W;
            S = obj.S;
            if obj.S.coltype; luminance1 = [.403 .405 .33]; luminance2 = [.090 .305 .0575];
            else luminance1 = [.365 .37 .285]; luminance2 = [.32 .316 .1175];end
            for c = 1:S.C
                W.col(c,:) = (hsv2rgb([(c-1+0.5*(~obj.S.coltype))/S.C 1 luminance1(c)])) - luminance2(c);
            end
            screenNumbers=Screen('Screens');
            if length(screenNumbers)>1
                Screen('Preference', 'SkipSyncTests', 1);
                W.w=Screen('OpenWindow',2,W.backcol,[],[],[],[],[]);
            else
                Screen('Preference', 'SkipSyncTests', 0);
                W.w=Screen('OpenWindow',0,W.backcol,[],[],[],[],[]);
            end
            [W.width, W.height] = Screen('WindowSize', W.w);
            W.cx = W.width/2; W.cy = W.height/2;            
            Screen(W.w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('TextFont',W.w, 'Arial');
            Screen('TextStyle', W.w, 0);
            Screen('TextSize', W.w, round(W.height/30));
            for i = 1:S.C; W.colshader(i) = MakeTextureDrawShader(W.w, 'SeparateAlphaChannel', [W.col(W.colrand(i),:) 0]); end            
            obj.W = W;
        end          
        
        function drawCard(obj, type, col, ind, num, rect)
            I = obj.I; w = obj.W.w;
            if col>0 && col<4; shader = obj.W.colshader(col); else shader = []; end
            if nargin>4 && type~=3; col=num; end
            if type==1; Screen('DrawTexture', w, I.card.txtr(col, ind),[],[440 601  800 1040],[],[],[],[],shader);
            elseif type==2; Screen('DrawTexture', w, I.outcome.txtr(col, ind),[],[801 601  1160 1040],[],[],[],[],shader);
            else
                if nargin<6; rect = [440 601  800 1040]; 
                else
                    rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);
                end
                Screen('DrawTexture', w, I.deck.txtr(1),[],rect,[],[],[],[],shader);
                Screen('DrawTexture', w, I.card.txtr(col,1),[],rect,[],[],[],[],shader);
            end
        end
               
        function loadImages(obj)                       
            % Own cards
            files=dir('Images/card_*.PNG');
            for i=1:5
                for j=1:7
                    name=files((i-1)*7 + j).name;
                    [img, ~, alpha] = imread(['Images/' name]); 
                    img(:,:,4)=alpha;
                    obj.I.card.sz(1,1)=size(img,2); %width
                    obj.I.card.sz(1,2)=size(img,1); %height
                    type = obj.S.randpattern(j);
                    obj.I.card.txtr(type,i)=Screen('MakeTexture', obj.W.w, img(601:1040,240:600,:));                
                end
            end

            for i=1:5
                for j=1:15
                    name=files(35 + (i-1)*15 + j).name;
                    [img, ~, alpha] = imread(['Images/' name]); 
                    img(:,:,4)=alpha;
                    obj.I.outcome.sz(1,1)=size(img,2); %width
                    obj.I.outcome.sz(1,2)=size(img,1); %height
                    obj.I.outcome.txtr(j,i)=Screen('MakeTexture', obj.W.w, img(601:1040,601:960,:));                
                end
            end

            % Computer cards
            for i=1:5
                name=files(110 + i).name;
                [img, ~, alpha] = imread(['Images/' name]); 
                img(:,:,4)=alpha;
                obj.I.pccard.sz(1,1)=size(img,2); %width
                obj.I.pccard.sz(1,2)=size(img,1); %height
                obj.I.pccard.txtr(1,i)=Screen('MakeTexture', obj.W.w, img(160:600,240:600,:));                
            end

            for i=1:5
                for j=1:9
                    name=files(115 + (i-1)*9 + j).name;
                    [img, ~, alpha] = imread(['Images/' name]); 
                    img(:,:,4)=alpha;
                    obj.I.pcoutcome.sz(1,1)=size(img,2); %width
                    obj.I.pcoutcome.sz(1,2)=size(img,1); %height
                    obj.I.pcoutcome.txtr(j,i)=Screen('MakeTexture', obj.W.w, img(160:600,601:960,:));                
                end
            end
 
            % Decks
            files=dir('Images/deck*.PNG');
            for i=1:length(files)
                name=files(i).name;
                [img, ~, alpha] = imread(['Images/' name]); 
                img(:,:,4)=alpha;
                obj.I.deck.sz(1,1)=size(img,2); %width
                obj.I.deck.sz(1,2)=size(img,1); %height
                if i==1; obj.I.deck.txtr(i)=Screen('MakeTexture', obj.W.w, img(601:1040,240:600,:));       
                else obj.I.deck.txtr(i)=Screen('MakeTexture', obj.W.w, img(160:600,240:600,:));    
                end
            end          
            
            % Feedback
            files=dir('Images/outcome*.PNG');
            for i=1:length(files)
                name=files(i).name;
                [img, ~, alpha] = imread(['Images/' name]); 
                img(:,:,4)=alpha;
                obj.I.fback.sz(1,1)=size(img,2); %width
                obj.I.fback.sz(1,2)=size(img,1); %height
                obj.I.fback.txtr(i)=Screen('MakeTexture', obj.W.w, img(500:700,900:1100,:));       
            end
            files=dir('Images/choice*.PNG');
            for i=1:length(files)
                name=files(i).name;
                [img, ~, alpha] = imread(['Images/' name]); 
                img(:,:,4)=alpha;
                obj.I.choice.sz(1,1)=size(img,2); %width
                obj.I.choice.sz(1,2)=size(img,1); %height
                obj.I.choice.txtr(i)=Screen('MakeTexture', obj.W.w, img(601:1040,601:960,:));       
            end
            
            %fixation cross
            [img , ~, alpha] = imread('Images/Fix.png');
            img(:,:,4) = alpha;
            obj.I.fixsz(1)=size(img,2);
            obj.I.fixsz(2)=size(img,1);
            obj.I.fixtxtr=Screen('MakeTexture', obj.W.w, img);     
                      
            %Wheel of furtune
            files=dir('Images/WOF*.png');
            for i=1:length(files)
                name=files(i).name;
                [img , ~, alpha] = imread(['Images/' name]); 
                img(:,:,4)=alpha;
                if i == 36 && obj.D.type == 'm'; ind = 1;
                else ind = i; end
                if ind < 36
                    obj.I.wofsz(ind,1)=size(img,2); %width
                    obj.I.wofsz(ind,2)=size(img,1); %height
                    obj.I.woftxtr(ind)=Screen('MakeTexture', obj.W.w, img);       
                end
            end
            
                                    
        end
        
        function instTask(obj)

            height = obj.W.height;
            width = obj.W.width;
            keys = obj.P.instkeys;
            w = obj.W.w;
            
            %opening screen
            Ndots = 10000;
            Screen('DrawDots', w, rand(2,Ndots).*repmat([width;height],1,Ndots), ceil(rand(1,Ndots)*10), rand(3,Ndots)*100, [], 2);
            sz = Screen('TextSize', w, height/10);
            if obj.D.type == 's'
                DrawFormattedText(w, 'The Shocking Cards\n', 'center', 'center', 255);
            else
                DrawFormattedText(w, 'The Rewarding Cards\n', 'center', 'center', 255);
            end
            Screen('TextSize', w, sz);
            DrawFormattedText(w, ['Press ' obj.P.keycont ' to start'], 'center', 4*height/5);
            Screen('Flip', obj.W.w);
            Utilities.waitForInput(keys(4), inf);
            
            count = 1;
            endflag = 0;
            last = 3;
            
            while ~endflag

                DrawFormattedText(w, ['Page ' num2str(count) ' of ' num2str(last) '   '], 8*width/10, height/24, 200);
                DrawFormattedText(w, ['press ' obj.P.keybrowse ' to browse'], 'center', 11*height/12); 

                switch count
                    case 1
                        str = 'In this experiment, you have a deck of cards, and the computer has a deck of cards.';
                        str = [str '\n\nFirst, a card is drawn from the computer''s deck, indicating a number between 1 and 9.'];
                        str = [str '\n\nYour job is to predict whether the card that you will draw from your deck will have a higher number.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);
                    
                    case 2
                        str = 'Let''s try this out with some fast trials.';
                        str = [str '\n\nFirst wait for the computer''s card and then make your prediction.'];
                        str = [str '\n\nUse the ' obj.P.keyup ' to predict that your number will be higher.'];
                        str = [str '\n\nUse the ' obj.P.keydown ' to predict that your number will be lower.'];
                        str = [str '\n\nYou will have two seconds to make your choice.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                        
                    case 3
                        str = 'Traning will continue until you perform well enough.';
                        str = [str '\n\nNote that every card that is drawn is immediately put back into the deck, and the deck is reshuffled before every trial, so in principle, the same card can be drawn twice in a row.'];
                        str = [str '\n\nThat is, all cards of a deck are always equally likely to get drawn.'];
                        str = [str '\n\nPress ' obj.P.keycont ' to begin.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                        
                end
                Screen('Flip', w);
                WaitSecs(0.2);
                key = Utilities.waitForInput(keys, inf);

                switch key(1)
                    case keys(2)
                        count = count + 1;
                        count = min(count, last);
                    case keys(1)
                        count = count - 1;
                        count = max(count, 1);
                    case keys(4)
                        if count==last; endflag=1; end
                end
            end
        end
        
        function res = rate(obj, strs, c)
            w = obj.W.w; wd = obj.W.width; ht = obj.W.height;
            keys = obj.P.instkeys;
            y =  4 * ht / 5;
            x1 = wd / 5; x2 = 4 * wd / 5;
            tsz = Screen('TextSize', w);
            
            res = 0.5; 
            endflag = 0;
            while ~endflag
                               
                if nargin >=3; obj.drawCard(3,c, [], [], [150 -ht/2+50 1250 -ht/2+1150]); end
                Screen('DrawLine', w, 255, x1, y +3, x2, y +3, 6);
                Screen('DrawLine', w, 255, x1, y -3, x2, y -3, 6);
                Screen('TextSize', w, round(2*tsz/3));
                for s=1:length(strs)-1
                    x = x1 + (s-1)/(length(strs)-2)*(x2-x1);
                    DrawFormattedText(w, strs{s}, x - 11 * tsz/8 , y - 3 * tsz, 255, [], [], [],  1.4);
                    Screen('DrawLine', w, 255, x, y * .98 +3, x, y * 1.02 +3, 6);
                    Screen('DrawLine', w, 255, x, y * .98 -3, x, y * 1.02 -3, 6);
                end
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res -6, y * 1.04, 6);
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res, y * 1.04, 6);
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res +6, y * 1.04, 6);
                Screen('TextSize', w, tsz);
                DrawFormattedText(w, strs{end}, 'center', ht/3, 255, [], [], [], 1.4);
                DrawFormattedText(w, ['Use ' obj.P.keyrightleft ' to move black bar\n' obj.P.keysubmit ' to submit'], 'center', ht/2, 200, [], [], [], 1.3);
                Screen('Flip', w);
                
                WaitSecs(0.15);
                key = Utilities.waitForInput(keys, inf);

                switch key(1)
                    case keys(2); res = min(1, res + 0.05);
                    case keys(1); res = max(0, res - 0.05);
                    case keys(4) 
                        if nargin >=3; obj.drawCard(3,c, [], [], [150 -ht/2+50 1250 -ht/2+1150]); end
                        Screen('DrawLine', w, 255, x1, y +3, x2, y +3, 6);
                        Screen('DrawLine', w, 255, x1, y -3, x2, y -3, 6);
                        Screen('DrawLine', w, 255, x2, y * .98 +3, x2, y * 1.02 +3, 6);
                        Screen('DrawLine', w, 255, x2, y * .98 -3, x2, y * 1.02 -3, 6);
                        Screen('TextSize', w, round(2*tsz/3));
                        for s=1:length(strs)-1
                            x = x1 + (s-1)/(length(strs)-2)*(x2-x1);
                            DrawFormattedText(w, strs{s}, x - 11 * tsz/8 , y - 3 * tsz, 255, [], [], [],  1.4);
                            Screen('DrawLine', w, 255, x, y * .98 +3, x, y * 1.02 +3, 6);
                            Screen('DrawLine', w, 255, x, y * .98 -3, x, y * 1.02 -3, 6);
                        end
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res -6, y * 1.04, 6);
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res, y * 1.04, 6);
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res +6, y * 1.04, 6);
                        Screen('TextSize', w, tsz);
                        DrawFormattedText(w, 'Are you sure?', 'center', ht/3, 255, [], [], [], 1.4);
                        DrawFormattedText(w, [obj.P.keysubmit ' to cancel\n' obj.P.keyconfirm ' to confirm'], 'center', ht/2, 200, [], [], [], 1.3);
                        Screen('Flip', w);               
                        WaitSecs(0.3);
                        key = Utilities.waitForInput(keys(3:4), inf);
                        if key == keys(3); endflag=1; end
                end
            end
                
        end

        function res = rateShock(obj)
            w = obj.W.w; wd = obj.W.width; ht = obj.W.height;
            keys = obj.P.instkeys;
            y = 4 * ht / 5;
            x1 = wd / 5; x2 = 4 * wd / 5;
            tsz = Screen('TextSize', w);
            
            strs = {'Can''t feel\na thing', 'Disturbing\nnot painful', 'A little\npainful', 'Very\npainful', 'Can''t\ntolerate!'}; 
            x = [0, 0.25, 0.5, 0.75, 1];
            res = 0;
            endflag = 0;
            while ~endflag
                               
                Screen('DrawLine', w, 255, x1, y -3, x2, y -3, 6);
                Screen('DrawLine', w, 255, x1, y +3, x2, y +3, 6);
                Screen('TextSize', w, tsz/2);
                for i = 1:length(strs)
                    Screen('DrawLine', w, 255, x1 + x(i) * (x2 - x1), y * .98 +3, x1 + x(i) * (x2 - x1), y * 1.02 +3, 6);
                    Screen('DrawLine', w, 255, x1 + x(i) * (x2 - x1), y * .98 -3, x1 + x(i) * (x2 - x1), y * 1.02 -3, 6);
                    str = regexp(strs{i}, '\\n', 'split');
                    for s = 1:length(str)
                        DrawFormattedText(w, str{s}, x1 + x(i) * (x2 - x1) - length(strs{i})*tsz/18, y - (4.2 + length(str)/2 - s) * 1.2 * tsz/2, 255);
                    end
                end
                Screen('TextSize', w, tsz);
                
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res -6, y * 1.04, 6);
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res, y * 1.04, 6);
                Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res +6, y * 1.04, 6);
                
                DrawFormattedText(w, 'How painful was the shock?', 'center', ht/3, 255, [], [], [], 1.4);
                DrawFormattedText(w, ['Use ' obj.P.keyrightleft ' to move black bar\n' obj.P.keysubmit ' to submit'], 'center', ht/2, 200, [], [], [], 1.3);
                Screen('Flip', w);
                
                WaitSecs(0.1);
                key = Utilities.waitForInput(keys, inf);

                switch key(1)
                    case keys(2); res = min(1, res + 0.05);
                    case keys(1); res = max(0, res - 0.05);
                    case keys(4) 
                        Screen('DrawLine', w, 255, x1, y -3, x2, y -3, 6);
                        Screen('DrawLine', w, 255, x1, y +3, x2, y +3, 6);
                        Screen('TextSize', w, tsz/2);
                        for i = 1:length(strs)
                            Screen('DrawLine', w, 255, x1 + x(i) * (x2 - x1), y * .98 +3, x1 + x(i) * (x2 - x1), y * 1.02 +3, 6);
                            Screen('DrawLine', w, 255, x1 + x(i) * (x2 - x1), y * .98 -3, x1 + x(i) * (x2 - x1), y * 1.02 -3, 6);
                            str = regexp(strs{i}, '\\n', 'split');
                            for s = 1:length(str)
                                DrawFormattedText(w, str{s}, x1 + x(i) * (x2 - x1) - length(strs{i})*tsz/18, y - (4.2 + length(str)/2 - s) * 1.2 * tsz/2, 255);
                            end
                        end
                        Screen('TextSize', w, tsz);
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res +6, y * 1.04, 6);
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res, y * 1.04, 6);
                        Screen('DrawLine', w, 0, x1 + (x2 - x1) * res, y * .96, x1 + (x2 - x1) * res -6, y * 1.04, 6);
                        DrawFormattedText(w, 'Are you sure?', 'center', ht/3, 255, [], [], [], 1.4);
                        DrawFormattedText(w, [obj.P.keysubmit ' to cancel\n' obj.P.keyconfirm ' to confirm'], 'center', ht/2, 200, [], [], [], 1.3);
                        Screen('Flip', w);               
                        WaitSecs(0.3);
                        key = Utilities.waitForInput(keys(3:4), inf);
                        if key == keys(3); endflag=1; end
                end
            end
                
        end

        function feeling(obj, ind)
            obj.D.happy(ind) = obj.rate({'Not at all\nhappy', 'Completely\nhappy', 'How happy do you feel right now?'});
            Screen('Flip', obj.W.w);
            WaitSecs(0.5);
            obj.D.anxious(ind) = obj.rate({'Not at all\nanxious', 'Completely\nanxious', 'How anxious do you feel right now?'});
        end            

        function rateDeck(obj)
            Screen('FillRect',obj.W.w, obj.W.backcol);
            for c = 1:obj.S.C
                if ~isfield(obj.D, 'rate'); obj.D.rate(c) = obj.rate({'Always\nlow', 'Low and high\nEqually', 'Always\nhigh', 'Did this deck have more low or more high numbers?'}, c);
                else obj.D.rate(end+1) = obj.rate({'Always\nlow', 'Low and high\nEqually', 'Always\nhigh', 'Did this deck have more low or more high numbers?'}, c);
                end
                Screen('Flip', obj.W.w);
                WaitSecs(0.5);
            end
        end            
        
        function res = calibrateShock(obj, repeat)
            if nargin<2; repeat = 0; end
            keys = obj.P.instkeys(4);
            w = obj.W.w;
            
            if ~repeat
                str = 'We will now ask you to rate how electric shocks of different intensities feel.';
                str = [str '\n\nThe purpose is to reach an intensity that is painful, but not too painful for you to tolerate throughout the experiment.'];
                str = [str '\n\nPress ' obj.P.keycont ' to begin.'];
            else
                str = 'We now ask you to rate again, only once, how the electric shock feels. You will get one reminder shock.';
                str = [str '\n\nPress ' obj.P.keycont ' to continue.'];
            end
            DrawFormattedText(w, str, obj.W.width/10, 'center', 255, 60, [], [], 1.4);
            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);
            
            if ~repeat
                endflag = 0;
                while ~endflag
                    Screen('DrawTexture',w, obj.I.fixtxtr);
                    Screen('Flip', w);
                    key = Utilities.waitForInput([KbName('Space') KbName('e')], inf);
                    if key == KbName('Space'); 
                        Utilities.shock;
                        res = obj.rateShock;
                    else endflag = 1;
                    end
                end
            else
                Utilities.shock;
                obj.D.endshockrate = obj.rateShock;
            end
        end
        
        function instOutcomes(obj)

            height = obj.W.height;
            width = obj.W.width;
            keys = obj.P.instkeys;
            w = obj.W.w; type = obj.S.type;
            I = obj.I;
                        
            count = 1;
            endflag = 0;
            last = 8;
            
            while ~endflag

                if count<last
                    DrawFormattedText(w, ['Page ' num2str(count) ' of ' num2str(last) '   '], 7*width/10, height/24, 200);
                    DrawFormattedText(w, ['press ' obj.P.keybrowse ' to browse'], 'center', 11*height/12); 
                end
                
                switch count
                    case 1
                        str = 'Now the instructions to the real game!';
                        if type == 's'
                            str = [str '\n\nYour task is to bet on whether your number will be higher than the computer''s.'];
                            str = [str '\n\nHowever, your number will not be revealed after you make a choice.'];
                            str = [str ' Instead, you will receive feedback in the form of electrical shocks.'];
                        elseif type == 'm'
                            str = [str '\n\nTo begin with, you receive a bonus of £5 so you have money to gamble with.'];
                            str = [str '\n\nYour task is to gamble whether your number will be higher than the computer''s.'];
                            str = [str '\n\nHowever, your number will not be revealed after you make a gamble.'];
                            str = [str ' Instead, you will only be shown whether you won or lost the gamble.'];
                        end
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                    case 2
                        if type == 's'                        
                            str = 'If you gamble that your number is higher and you are correct, you will not receive a shock.';
                            obj.drawCard(2,4,5,11);
                        elseif type == 'm'
                            str = 'If you decide to gamble and your number is indeed higher, your bonus will increase by £5.';
                            obj.drawCard(2,4,5,13);
                        end
                        str = [str '\n\nThis outcome will be indicated by the symbol shown below.\n\n\n\n\n\n\n\n\n\n'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);
                        obj.drawCard(3,4);
                    case 3
                        if type == 's'                        
                            str = 'But if you are incorrect, you will receive a shock (as shown below).\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,10);
                        elseif type == 'm'
                            str = 'Whereas if the computer''s number is higher, you will lose £5 (as shown below).\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,14);
                        end
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        obj.drawCard(3,4);
                    case 4
                        if type == 's'                        
                            str = 'And if your number is the same as the computer''s, you will receive a shock 50% of the time (as shown below) - it will be randomly determined whether you receive a shock or not.\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,12);
                        elseif type == 'm'
                            str = 'And if your number is the same as the computer''s, your bonus will not change (as shown below).\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,15);
                        end
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        obj.drawCard(3,4);
                    case 5
                        if type == 's'                        
                            str = 'On the other hand, if you bet that your number is lower, you will receive a shock 50% of the time regardless of whether you are correct or incorrect.';
                            obj.drawCard(2,4,5,12);
                        elseif type == 'm'
                            str = 'On the other hand, if you decide not to gamble, your bonus will certainly not change.';
                            obj.drawCard(2,4,5,15);
                        end
                        str = [str '\n\nYou can always decide not to gamble if you think your card is unlikely to be higher than the computer''s\n\n\n\n\n\n\n\n\n\n'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        obj.drawCard(3,4);
                    case 6        
                        str = ['\n\nUse the ' obj.P.keyup ' to gamble that your number will be higher'];
                        str = [str '\n\nUse the ' obj.P.keydown ' to decide not to gamble.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                    case 7
                        if type == 's'                        
                            str = 'Don''t be too slow. Otherwise, you will definitely receive a shock (this will be indicated by the clock sign).\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,10);
                        elseif type == 'm'
                            str = 'Don''t be too slow. Otherwise, you will definitely lose money (this will be indicated by the clock sign).\n\n\n\n\n\n\n\n\n\n';
                            obj.drawCard(2,4,5,14);
                        end
                        Screen('DrawTexture',w, I.fback.txtr(4), [], [1100 500 1300 700]);
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        obj.drawCard(3,4);
                    case 8
                        if type == 's'                        
                            str = [];
                        elseif type == 'm'
                            str = 'The experiment will involve many trials, but the average outcome of only a few of your trials will determine the bonus you will receive.';
                            str = [str '\n\nTo encourage you to do your best on each and every trial, we will not tell you in advance which trials will determine your bonus.\n\n'];
                        end
                        str = [str 'To make sure that you understand the instructions, we ask you to answer a few questions.'];
                        str = [str '\n\nPress ' obj.P.keycont ' to go to the questions.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        
                end
                Screen('Flip', w);
                WaitSecs(0.2);
                key = Utilities.waitForInput(keys, inf);

                switch key(1)
                    case keys(2)
                        count = count + 1;
                        count = min(count, last);
                    case keys(1)
                        count = count - 1;
                        count = max(count, 1);
                    case keys(4)
                        if count==last; endflag=1; end
                end
            end
        end

        function instOutcomesTest(obj)
            obj.instOutcomes;
            obj.Q.instOutcomes.run;
            while obj.Q.instOutcomes.keyScore ~= 1
                obj.instRepeat;
                obj.instOutcomes;
                obj.Q.instOutcomes.run;
            end   
        end
               
        function instRepeat(obj)

            keys = obj.P.instkeys(4);
            w = obj.W.w;
            
            str = 'Sorry, you have not answered all questions correctly';
            str = [str '\n\nPress ' obj.P.keycont ' to review the instructions again'];
            DrawFormattedText(w, str, 'center', 'center', 255, 60, [], [], 1.4);

            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);

        end

        function instSecondblock(obj)

            keys = obj.P.instkeys(4);
            w = obj.W.w;            
            str = 'You have completed the first part\nof the experiment';
            str = [str '\n\nPress ' obj.P.keycont ' to begin the second part'];
            DrawFormattedText(w, str, 'center', 'center', 255, 60, [], [], 1.4);

            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);
            
        end

        function instThirdblock(obj)

            keys = obj.P.instkeys(4);
            w = obj.W.w;            
            
            str = 'You have completed the second part\nof the experiment';
            str = [str '\n\nPress ' obj.P.keycont ' to begin\nthe last main part of the experiment'];
            DrawFormattedText(w, str, 'center', 'center', 255, 60, [], [], 1.4);

            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);
        end

        function instColors(obj)

            height = obj.W.height;
            width = obj.W.width;
            keys = obj.P.instkeys;
            w = obj.W.w;
                        
            count = 1;
            endflag = 0;
            last = 7;
            ord = randperm(3);
            y1 = 300; y2 = 1100;
            
            while ~endflag
                
                DrawFormattedText(w, ['Page ' num2str(count) ' of ' num2str(last) '   '],  7*width/10, height/24, 200); 
                if count<last ;DrawFormattedText(w, ['press ' obj.P.keybrowse ' to browse'], 'center', 11*height/12);  
                else DrawFormattedText(w, ['Press ' obj.P.keycont ' to answer a couple of additional questions'], 'center', 11*height/12);  
                end

                
                switch count
                    case 1
                        str = 'Great! The computer''s cards will be drawn from the same deck as before:\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        
                            rect = [250  280 1450 1480];
                            rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*160/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200]);
                            Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                            Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
                    
                    case 2
                        str = 'But your cards will now be drawn from one of these three decks:\n\n\n\n\n\n\n';
                        str = [str '\n\nThis is important because each deck may contain more low numbers (closer to 1) or more high numbers (closer to 9).'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        for c = 1:3
                            obj.drawCard(3,ord(c),[],[],[0 + (c-1)*400 -250 1200 + (c-1)*400 950]);
                        end
                        
                    case 3
                        str = 'On each trial you will play with only one of the three decks\n\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        c = randi(3);
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        rect(2)=y1-300; rect(4)=y2-300;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                    case 4
                        str = 'Your task is to gamble whether the number you draw from this deck will be higher than the computer''s number\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        c = randi(3);
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        rect(2)=y1-300; rect(4)=y2-300;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                    case 5
                        str = 'Of course, it makes more sense to gamble when you are playing with a deck that has high cards\n\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        c = randi(3);
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        rect(2)=y1-300; rect(4)=y2-300;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                    case 6
                        str = 'So, to perform well, you need to figure out which of your decks has more low numbers or more high numbers\n\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        c = randi(3);
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        rect(2)=y1-300; rect(4)=y2-300;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                    case 7
                        str = 'Pay attention to how frequently you win your gambles with each deck\n\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        c = randi(3);
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        rect(2)=y1-300; rect(4)=y2-300;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);
                                            
                end
                if count >=4 && count <=6
                    c = randi(3);
                    rect = [350, y1, 1150 , y2];
                    obj.drawCard(3,ord(c),[],[],rect);
                    rect = round([rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*960/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);
                    Screen('DrawTexture',w, obj.I.choice.txtr(1), [], rect);
                    rect = [350, y1, 1150 , y2];
                    rect(2)=y1-300; rect(4)=y2-300;
                    rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                    Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                    Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
                    rect = [350, y1, 1150 , y2];
                    rect(2)=y1-300; rect(4)=y2-300;
                    rect = round([rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*960/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);
                    Screen('DrawTexture',w, obj.I.pcoutcome.txtr(5,5), [], rect);
                end                    
                Screen('Flip', w, [],1);
                WaitSecs(0.2);
                key = nan;
                while isnan(key)
                    key = Utilities.waitForInput(keys, GetSecs+1.5);
                    if count >=3 && count <=6
                        newc = randi(2); 
                        if newc>=c; c=newc+1; else c=newc; end
                        rect = [350, y1, 1150 , y2];
                        obj.drawCard(3,ord(c),[],[],rect);
                        Screen('Flip', w, [],1);
                        [key c]
                    end
                    
                end

                switch key(1)
                    case keys(2)
                        count = count + 1;
                        count = min(count, last);
                    case keys(1)
                        count = count - 1;
                        count = max(count, 1);
                    case {keys(3), keys(4)}
                        if count==last; endflag=1; end
                end
                Screen('Flip', w);
            end
            
        end

        function instDecks(obj)

            height = obj.W.height;
            width = obj.W.width;
            keys = obj.P.instkeys;
            w = obj.W.w;
                        
            count = 1;
            endflag = 0;
            last = 6;
            ord = randperm(3);
            
            y1 = 320; y2 = 920;
            
            while ~endflag

                DrawFormattedText(w, ['Page ' num2str(count) ' of ' num2str(last) '   '],  7*width/10, height/24, 200);
                DrawFormattedText(w, ['press ' obj.P.keybrowse ' to browse'], 'center', 11*height/12); 
                
                switch count
                    case 1
                        str = 'We now move on to the 2nd stage of training.\n\nThe computer''s cards will be drawn from the same deck as before:\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        
                            rect = [250  280 1450 1480];
                            rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*160/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200]);
                            Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                            Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
                    case 2
                        str = 'But your cards will now be drawn from one of these 2 decks:\n\n\n\n\n\n\n';
                        str = [str '\n\nOne of these decks has more low numbers and one has more high numbers.'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                
                        for c = 5:2:7
                            obj.drawCard(3,c,[],[],[100 + (c-5)*300 -250 1300 + (c-5)*300 950]);
                        end
                        
                    case 3
                        str = 'Only one of your two decks will appear on each trial\n\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                        for c = 5:2:7
                            rect = [300 + (c-5)*300 y1 900 + (c-5)*300 y2];
                            obj.drawCard(3,c,[],[],rect);
                            rect(2)=y1-200; rect(4)=y2-200;
                            rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                            Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                            Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
                        end
%                     Screen('DrawTexture',w, I.pccard.txtr(1,1),[],[440 160  800 600]);

                    case 4
                        str = 'Your task is as before: bet on whether your card will be higher or lower than the computer''s card\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                    case 5
                        str = 'But to perform well, you need to figure out which of your decks has more low numbers and which has more high numbers\n\n\n\n\n\n\n\n\n\n';
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                    case 6
                        str = '\n\nAnd then adjust your bets according to the deck.\n\n\n\n\n\n\n\n\n';
                        str = [str '\n\nPress ' obj.P.keycont ' to start'];
                        DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);                                                

                                               
                end
                if count >=4 && count <=6
                    for c = 5:2:7
                        rect = [300 + (c-5)*300 y1 900 + (c-5)*300 y2];
                        obj.drawCard(3,c,[],[],rect);
                        rect = round([rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*960/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);
                        Screen('DrawTexture',w, obj.I.choice.txtr(1), [], rect);
                        rect = [300 + (c-5)*300 y1 900 + (c-5)*300 y2];
                        rect(2)=y1-200; rect(4)=y2-200;
                        rect = round([rect(1) + (rect(3)-rect(1))*240/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);

                        Screen('DrawTexture',w, obj.I.deck.txtr(1,2), [], rect);
                        Screen('DrawTexture',w, obj.I.pccard.txtr(1,1), [], rect);
                        rect = [300 + (c-5)*300 y1 900 + (c-5)*300 y2];
                        rect(2)=y1-200; rect(4)=y2-200;
                        rect = round([rect(1) + (rect(3)-rect(1))*601/1200 rect(2) + (rect(4)-rect(2))*600/1200 rect(1) + (rect(3)-rect(1))*960/1200 rect(2) + (rect(4)-rect(2))*1040/1200]);
                        Screen('DrawTexture',w, obj.I.pcoutcome.txtr(5,5), [], rect);
                    end
                end                    
                Screen('Flip', w);
                WaitSecs(0.2);
                key = Utilities.waitForInput(keys, inf);

                switch key(1)
                    case keys(2)
                        count = count + 1;
                        count = min(count, last);
                    case keys(1)
                        count = count - 1;
                        count = max(count, 1);
                    case {keys(3), keys(4)}
                        if count==last; endflag=1; end
                end
            end
        end
        
        function instColorsTest(obj)
            obj.instColors;
            obj.Q.instColors.run;
            while obj.Q.instColors.keyScore ~= 1
                obj.instRepeat;
                obj.instColors;
                obj.Q.instColors.run;
            end    
            obj.instAfterColors;
        end

        function instAfterColors(obj)

            width = obj.W.width;
            keys = obj.P.instkeys(4);
            w = obj.W.w;
            
            NT = obj.S.Tblock;
            NP = (obj.S.T/NT);
            
            str = ['Great! The experiment will consist of ' num2str(NP) ' parts, each involving ' num2str(NT) ' choices.'];
            %str = [str '\n\nTo help us track your eyes, please keep your eyes on the cross at the center of the screen in between trials.'];
            str = [str '\n\nPlease  ' obj.P.keycont ' to continue. '];
            DrawFormattedText(w, str, width/10, 'center', 255, 60, [], [], 1.4);
            
            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);
        end
        
        function instEnd(obj)

            keys = obj.P.instkeys(4);
            w = obj.W.w;
                       
            str = 'Thank you! You have reached the end of the experiment';
            if obj.S.type == 'm'
                obj.D.bonus = round(mean(obj.D.O(~isnan(obj.D.O)))*2) * 2.5 + 5;
                str = [str '\n\nYou have won a bonus of £' num2str(obj.D.bonus)];
                str = [str '\nThis bonus will be paid to you after you complete both sessions of the study'];
            end
            str = [str '\n\nPlease call the experimenter'];
            DrawFormattedText(w, str, 'center', 'center', 255, 60, [], [], 1.4);

            Screen('Flip', w);
            WaitSecs(0.2);
            Utilities.waitForInput(keys, inf);
        end

        function close(obj)
            Screen('CloseAll');
            %ListenChar(0);
            ShowCursor;
            if ~obj.E; Utilities.ETstop; end
        end
        
        function outcol = flickerFusion(obj, ind)
            obj.W.txtcol
            
            w = obj.W.w;
            bcol  = obj.W.backcol;
            fcol = double(obj.W.txtcol(ind,:))/255.0;
            keys = [KbName('1') KbName('1!') KbName('2') KbName('2@') KbName('space')];
            [width, height]= Screen('WindowSize',w);
            
            rect1=[0.2*width 0.2*height 0.8*width 0.8*height];
            rect2=[0 0.9*height width height];
            
            pause(.3);
            frameTime = 0.01;
            delta = frameTime - 0.005;
            q = 0;
            inc = 0.001;
            
            nextFlipTime = GetSecs + frameTime;
            while q == 0
                
                for count = 0:1
                    Screen('FillRect', w, bcol);
                    if count
                        Screen('FillRect', w, (fcol*255), rect1);
                    end
                    Screen('FillRect', w, (fcol*255), rect2);
                    str = 'Press 1 to increase brightness\n\nPress 2 to decrease brightness\n\nPress space-bar when flicker is minimized';
                    DrawFormattedText(w, str, 'center', 20, round(fcol*255));
                    
                    Screen(w, 'Flip', nextFlipTime);
                    nextFlipTime = GetSecs + frameTime;
                    
                    key = Utilities.waitForInput(keys, GetSecs+delta);
                    
                    switch key
                        case {keys(1), keys(2)}
                            fcol = rgb2hsv(fcol);
                            fcol(3) = fcol(3) + inc;
                            fcol = hsv2rgb(fcol);
                        case {keys(3), keys(4)}
                            fcol = rgb2hsv(fcol);
                            fcol(3) = fcol(3) - inc;
                            fcol = hsv2rgb(fcol);
                        case keys(5)
                            q = 1;
                    end
                    
                end
                
            end
            
            outcol = fcol*255;
            
        end 
        
                
    end
    
    methods (Static)
        
    end
    
end
% 
                    
                
            
            
