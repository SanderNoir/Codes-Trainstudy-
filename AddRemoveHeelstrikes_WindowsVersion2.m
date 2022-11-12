function [Heelstrike]=AddRemoveHeelstrikes_WindowsVersion2(DataLinks,DataRechts,Heelstrike,Method,SampleFreq,SamplesBefore);
% Function to manually add and remove missing heelstrikes
% Input:
% DataLinks - Array with vertical ground reaction forces left force plate
% DataRight - Array with vertical ground reaction forces right force plate
% 
% Output:
% Heelstrike - Array with heelstrikes/toe-offs
%
% Output:
% Heelstrike - Array with new heelstrikes/toe-offs
%
% Template created by Tom Buurke (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version
% Changed by Sander Swart (feb, 2019)
% F***ed up by Rob den Otter (November 2022)

%% filter force plate data:
DataLinks    = butterfilterlow(2,SampleFreq,15,DataLinks);
DataRechts    = butterfilterlow(2,SampleFreq,15,DataRechts);
Window  = 10000; % = the xlim in the figures

%% add and/or remove IC's and TO's
    scrollPress = 0;
    fig = figure;
    set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]); % maximize figure window
    set(gca, 'color', 'w');
    
     while scrollPress < 1 %nodig om scherm te verversen
        
        plot(DataLinks,'k');hold on;
        plot(DataRechts,'r');
        plot([SamplesBefore SamplesBefore],[-200 1000],'b');
        for i=1:length(Heelstrike(1,:))
            if Heelstrike(2,i)==1
                plot(Heelstrike(1,i),0,'o','MarkerFaceColor','r');
            elseif Heelstrike(2,i)==2
                plot(Heelstrike(1,i),0,'o','MarkerFaceColor','y');
            elseif Heelstrike(2,i)==3
                plot(Heelstrike(1,i),0,'o','MarkerFaceColor','b');
            elseif Heelstrike(2,i)==4
                plot(Heelstrike(1,i),0,'o','MarkerFaceColor','g');
            end
        end
        title('Left mouse click to add, right mouse click to delete, click scroll button for next frame (L=black R=red) (1=HSL=Red; 2=TOR=Yellow; 3=HSR=Blue; 4=TOL=Green)');
        
       [add,~, button] = ginput(1); %this calls the graphic input function
       add=round(add);
              
       NewCont=Heelstrike;
       
       if button== 097%1 %add stuff
           ContactType=getkey; %indicatie type contact% 1=heelstrike links; 2 = toe off rechts; 3= heelstrike rechts; 4= toe off links
           if ContactType == 49
            temp=[add;1];
            NewCont=[NewCont temp];
           elseif ContactType == 50
            temp=[add;2];
            NewCont=[NewCont temp];
           elseif ContactType == 51
            temp=[add;3];
            NewCont=[NewCont temp];
           elseif ContactType == 52
            temp=[add;4];
            NewCont=[NewCont temp];
           end
             Heelstrike=NewCont;
             clf;
       elseif button==114%3 %remove stuff
           [dummy,RemoveInd]=min(abs(Heelstrike(1,:)-add));
           Heelstrike(:,RemoveInd)=0;
           Heelstrike=[nonzeros(Heelstrike(1,:)) nonzeros(Heelstrike(2,:))]';
           clf;
              
       elseif button==46%2 % windows, scroll click for next frame
            scrollPress = 1;
            close;
         break
     end
           

 end

