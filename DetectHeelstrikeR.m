function[HeelstrikeR,Detect]=DetectHeelstrikeR(Data,Treshold,windowlengte)
% Function to detect heel strikes
% Input:
% Data - Array with vertical ground reaction forces
% Treshold - Detection treshold
% windowlengte - Window size 
% Standard:
% Treshold=100;
% windowlengte=75;
%
% Output:
% HeelstrikeR - Array with heelstrikes
%
% Created by Tom Buurke & Rob den Otter (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version

% Data=butterfilterlow(2,300,15,Data);

[a,~]       = find(Data>Treshold);
Detect      = zeros(length(Data),1);
Detect(a)   = 1;

Temp            = diff(Detect);
[Heelstrike,~]  = find(Temp==1);

%% Loop through the vertical GRF to identify heel strikes right
j = 1;

for i = 1 : length(Heelstrike)
    
    if (Heelstrike(i)+windowlengte) <= length(Detect)
        [b,~] = find(Detect(Heelstrike(i) : (Heelstrike(i)+windowlengte)) > Detect(Heelstrike(i)));% de waarde op heelstrike is 0
        
        if length(b) == windowlengte
            newstrike(j) = Heelstrike(i);
            j = j+1;
            clear b;
        end
        
    end
    
end

%% output
HeelstrikeR = newstrike;

end