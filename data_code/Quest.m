classdef Quest < handle
        
    properties
        
        w;
        quest;
        height;
        width;
        top;
        key;
        c;
        x;
        wrap;
        refkeys;
        
    end
    
    methods
        
        function obj = Quest(file, w, keys)
            obj.w = w;
            str = fileread(file);
            obj.quest=regexp(str, '\n', 'split');
            keystr = obj.quest{1};
            if strcmp(keystr(1:5),'Key: ')
                keystr = char(keystr(6:end));
                keystr = regexp(keystr, ' ', 'split');
                for i = 1:length(keystr)
                    obj.key(i) = str2double(keystr{i});
                end
                obj.quest = obj.quest(2:end);
            else
                obj.key = [];
            end            
            obj.top = obj.quest{1};
            if strcmp(obj.top(1:5),'top: ')
                obj.top = char(obj.top(6:end));
                obj.quest = obj.quest(2:end);
            else
                obj.top = [];
            end
            [obj.width, obj.height] = Screen('WindowSize',w);
            obj.x = obj.width/10;
            obj.width
            obj.wrap = round(60 * (1200 / obj.height));
            obj.refkeys = keys;

        end
        
        function run(obj)
            
            w = obj.w; quest = obj.quest; x = obj.x; wrap = obj.wrap; width = obj.width;
            
            Screen('Flip',w);
            
            nq=0;
            for i=1:length(quest)
                qc=char(quest(i));
                if qc(1)>57 || qc(1)<48
                    nq=nq+1;
                end
            end
            c=zeros(1,nq);
            iq=1;
            il=1;
            KbName('UnifyKeyNames');
            refkeys = [obj.refkeys KbName('LeftArrow')];
            
            while il<=length(quest)
                
                q=char(quest(il));
                il=il+1;
                na=0;
                ac=char(quest(il));
                a={};
                while il<=length(quest) && ac(1)<58 && ac(1)>47
                    na=na+1;
                    a(na,1)=quest(il); %#ok<AGROW>
                    il=il+1;
                    if il<=length(quest)
                        ac=char(quest(il));
                    end
                end
                
                y = zeros(1,length(a)+2) + round(3*obj.height/16);
                if ~isempty(obj.top)
                    [~, y(1)] = DrawFormattedText(w, obj.top, x, y(1), 200, wrap, [], [], 1.4);
                    y(1) = y(1) + 40 + Screen('TextSize', w);
                end
                txtsize = Screen('TextSize', w);
                Screen('TextSize', w, round(txtsize*1.3));
                [~, y(2)] = DrawFormattedText(w, q, x, y(1), 255, wrap/1.6, [], [], 1.4);
                y(2) = y(2) + 60 + Screen('TextSize', w);
                Screen('TextSize', w, txtsize);
                for ia=1:length(a)
                    [~, y(ia+2)] = DrawFormattedText(w, char(a(ia)), x, y(ia+1), 200, wrap, [], [], 1.3);
                    y(ia+2) = y(ia+2) + 40 + Screen('TextSize', w);
                end
                DrawFormattedText(w, 'To return to the previous question, press left arrow key ', 'center', obj.height-Screen('TextSize', w)*2, 200, wrap);
                DrawFormattedText(w, ['question ' num2str(iq) ' out of ' num2str(nq) '   '],  6.5*width/10, Screen('TextSize', w), 200, wrap);
                Screen('Flip',w,[],1);
                WaitSecs(0.4);
                
                % keys
                keys = refkeys(1:length(a));
                keys(end + 1) = refkeys(end);
                
                % get choice
                key=Utilities.waitForInput(keys, inf);
                if key==keys(end)
                    il=il-length(a)-2;
                    iq=iq-1;
                    if iq<1
                        il=1;
                        iq=1;
                    else
                        Screen('Flip',obj.w);
                        qc=char(quest(il));
                        while qc(1)>47 && qc(1)<58
                            il=il-1;
                            qc=char(quest(il));
                        end
                    end
                else
                    if ~isempty(find(keys == key(1)))
                        for ia=1:length(a)
                            if key(1)==keys(ia)
                                DrawFormattedText(w, char(a(ia)), x, y(ia+1), 255, wrap, [], [], 1.3);
                            end
                        end
                        c(iq)= find(keys == key(1));
                        iq=iq+1;
                        Screen('Flip',w);
                        WaitSecs(0.2);
                    end                    
                end
                
            end
            
            txtsize = Screen('TextSize', w);
            Screen('TextSize', w, txtsize*2);
            DrawFormattedText(w, 'Thank you', 'center', 'center', 255);
            Screen('TextSize', w, txtsize);
            Screen('Flip',w);
            WaitSecs(1);
            
            obj.c=c;
        end
        
        function [res, names]=PANASanalyze(obj)
            neg = [1 3 6 7 10 12 14 16 17 20];
            pos = setdiff(1:20, neg);
            neg = (mean(obj.c(neg))-1)/4;
            pos = (mean(obj.c(pos))-1)/4;
            res = [neg, pos];
            names = {'Negative Emotion', 'Positive Emotion'};
        end
        
        function [basd, basf, basr, bis]=BISBASanalyze(obj)
            basd = [3 9 12 21];
            basf = [5 10 15 20];
            basr = [4 7 14 18 23];
            bis = [2 8 13 16 19 22 24];
            c = obj.c;
            c([1 3:21 23:24]) = 5 - c([1 3:21 23:24]); %#ok<*PROP>
            basd = mean(c(basd));
            basf = mean(c(basf));
            basr = mean(c(basr));
            bis = mean(c(bis));
        end
        
        function [hps, ext, neu, opn, agr, con]=IPIPanalyze(obj)
            extpos = [1 13 26 38 51];
            extneg = [7 19 32 45 57];
            neupos = [2 8 27 33 58];
            neuneg = [14 21 39 46 52];
            opnpos = [3 15 28 41 53];
            opnneg = [9 22 34 47 59];
            agrpos = [4 10 29 35 60];
            agrneg = [16 23 42 48 54];
            hpspos = [5 17 24 30 40 43 49 55];
            hpsneg = [11 20 36 61];
            conpos = [6 12 31 37 62];
            conneg = [18 25 44 50 56];
            c = obj.c;
            ext = mean([c(extpos) 6-c(extneg)]);
            neu = mean([c(neupos) 6-c(neuneg)]);
            opn = mean([c(opnpos) 6-c(opnneg)]);
            agr = mean([c(agrpos) 6-c(agrneg)]);
            hps = mean([c(hpspos) 6-c(hpsneg)]);
            con = mean([c(conpos) 6-c(conneg)]);
        end
        
        function score = keyScore(obj)
            c = obj.c; key = obj.key;
            score = mean(c==key);
        end
        
        function [hps, names] = HPSanalyze(obj)
            hpspos = [1 3 5 6 8 9 10 11];
            hpsneg = [2 4 7 12];
            c = obj.c;
            hps = (mean([c(hpspos) 6-c(hpsneg)]) - 1) / 4;
            names = {'Hypomanic Personality Scale'};
        end
        
        function [stai, names] = STAIanalyze(obj)
            staipos = [2 4 5 8 9 11 12 15 17 18 20];
            staineg = [1 3 6 7 10 13 14 16 19];
            c = obj.c;
            stai = (mean([c(staipos) 5-c(staineg)]) - 1) / 3;
            names = {'Trait Anxiety'};
        end
        
        function [mtsd, names] = MTSDanalyze(obj)
            mtsdpos = 1:18;
            mtsdneg = [];
            c = obj.c;
            mtsd = (mean([c(mtsdpos) 6-c(mtsdneg)]) - 1) / 4;
            names = {'Trait Depression'};
        end
        
        function [bpq, names] = BPQanalyze(obj)
            bpqneg = 6;
            bpqpos = [1:5 7:10];
            c = obj.c;
            bpq = (mean([c(bpqpos) 6-c(bpqneg)]) - 1) / 4;
            names = {'Affective Instability'};
        end
        
        
    end
end

                