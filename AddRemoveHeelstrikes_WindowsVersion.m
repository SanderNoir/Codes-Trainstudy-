function [Heelstrike]=AddRemoveHeelstrikes(Data,Heelstrike,DataInput,Method, SampleFreq)
% Function to manually add and remove missing heelstrikes
% Input:
% Data - Array with vertical ground reaction forces
% Heelstrike - Array with heelstrikes/toe-offs
%
% Output:
% Heelstrike - Array with new heelstrikes/toe-offs
%
% Created by Tom Buurke (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version
% Changed by Sander (feb, 2019)

%% plot settings
Data    = butterfilterlow(2,SampleFreq,15,Data);
Window  = 25000; % = the xlim in the figures

%% add or remove
for i = 1:Window:length(Data)
    scrollPress = 0;
    
    while scrollPress < 1
        
        % Figure specifications
        fig = figure;
        set(fig, 'Units', 'normalized', 'Position', [0,0,1,1]); % maximize figure window
        set(gca, 'color', 'w');
        
        hold on
        if length(Data)>i+Window
            plot(i:i+Window,Data(i:i+Window)); %plot y-force data
            area(i:i+Window,Data(i:i+Window),'basevalue',-200,'FaceColor','k','FaceAlpha',0.05);
        else
            plot(i:length(Data),Data(i:end)); %plot last part of y-force data
            area(i:length(Data),Data(i:end),'basevalue',-200,'FaceColor','k','FaceAlpha',0.05);
        end
        
        start   = find(Heelstrike>i-1,1); %plot the corresponding heelstrikes
        stop    = find(Heelstrike>i+Window,1)-1;
        
        if (stop <= start), stop = start+1;end

        if isempty(stop) == 0
            
            % change color according to input
            if DataInput == 1
                plot(Heelstrike(start:stop),10,'r*');
            elseif DataInput == 2
                plot(Heelstrike(start:stop),10,'b*');
            elseif DataInput == 3
                plot(Heelstrike(start:stop),10,'r*');
            elseif DataInput == 4
                plot(Heelstrike(start:stop),10,'b*');
            end
            
        elseif isempty(stop)==1
            
            if isempty(start)==0
                
                % Change color according to input
                if DataInput == 1
                    plot(Heelstrike(start:end),10,'r*');
                elseif DataInput == 2
                    plot(Heelstrike(start:end),10,'b*');
                elseif DataInput == 3
                    plot(Heelstrike(start:end),10,'r*');
                elseif DataInput == 4
                    plot(Heelstrike(start:end),10,'b*');
                end
                
            end
        end
        set(gca,'XLim',[i i+Window]);
        
        if DataInput == 1
            title('Left mouse click to add, right mouse click to delete, click scroll button for next frame. Heel Strike Left')
        elseif DataInput == 2
            title('Left mouse click to add, right mouse click to delete, click scroll button for next frame. Toe off Left')
        elseif DataInput == 3
            title('Left mouse click to add, right mouse click to delete, click scroll button for next frame. Heel Strike Right')
        elseif DataInput == 4
            title('Left mouse click to add, right mouse click to delete, click scroll button for next frame. Toe off Right')
        end
        hold off
        
        [add,~, button] = ginput(1); %this calls the graphic input function
        
        % manipulate click position
%         if button==097 % mac setting, press 'a' to add
        if button==1 % windows setting, Left mouse click to add
            
            % Define window, i.e. 100 samples around click location (add)
            ClickPos = 50;
            ClickNeg = -50;
            
            % Get the force plate data from corresponding click window
            for j = 1 : length(Data)
                
                if j >= (add+ClickNeg) && j <= (add+ClickPos)
                    DataWindow(j,1) = Data(j);
                else
                    DataWindow(j,1) = NaN;  % outside range --> NaN
                end
                
            end
            
            % Substract treshold from data, and take minimal value (i.e. point of interest)
            ChangeDataWindow = round(abs(DataWindow-50));
            [x,~] = find(ChangeDataWindow < 25);    % find lowest points, min function does not work correct
            [~,Point] = (min(abs(x - add)));        % find the lowest value closest to your click position
            
            if Method == 1
                Xpos = x(Point);
            else
                Xpos = add;
            end
            
            clear x Point
            
            % 'add' here is replaced by Xpos
            pos = find(Heelstrike>Xpos,1);
            if pos == 1 %If-statement for when the new position is the first in the heelstrike array
                NewHeelstrike(pos) = Xpos;
                NewHeelstrike(pos+1:length(Heelstrike)+1) = Heelstrike(pos:end);
            elseif length(pos) == 0
                NewHeelstrike = Heelstrike;
                NewHeelstrike(end+1) = Xpos;
            else %All other new positions
                NewHeelstrike(1:pos-1) = Heelstrike(1:pos-1);
                NewHeelstrike(pos) = Xpos;
                NewHeelstrike(pos+1:length(Heelstrike)+1) = Heelstrike(pos:end);
            end
            
            clear Heelstrike;
            Heelstrike = NewHeelstrike;
            clear NewHeelstrike;
            
        elseif button==2 % windows, scroll click for next frame
%         elseif button == 46 % mac setting, press '>'(the .) for next frame
            scrollPress = 1;
            
        elseif button==3 % windows, right mouse click to remove
%         elseif button == 114 % mac, press 'r' to remove
            
            pos = find(Heelstrike>add,1);
            if pos == 1%If-statement for when the new position is the first in the heelstrike array
                NewHeelstrike(pos:length(Heelstrike)-1) = Heelstrike(pos+1:end);
            elseif length(pos) == 0 %Last heelstrike
                NewHeelstrike = Heelstrike(1:end-1);
            else %all other heelstrikes
                NewHeelstrike(1:pos-1) = Heelstrike(1:pos-1);
                NewHeelstrike(pos:length(Heelstrike)-1) = Heelstrike(pos+1:end);
            end
            
            clear Heelstrike;
            Heelstrike = NewHeelstrike;
            clear NewHeelstrike;
            
        elseif button == 112 % press 'p' for previous frame
            i = i-Window;
            
        elseif button == 113 % press 'q' to go to next data set
            break
        end
        
        close;
        
    end
    if button == 113
        close;
        break
    end
end

end
