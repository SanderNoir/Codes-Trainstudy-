function[HeelstrikeL,Detect]=DetectHeelstrikeL(Data,Treshold,windowlengte)
% Function to detect heel strikes
% Input:
% Data - Array with vertical ground reaction forces
% Treshold - Detection treshold
% windowlengte - Window size 
%
% Standard Settings:
% Treshold=100;
% windowlengte=75;
%
% Output:
% HeelstrikeL - Array with heelstrikes
%
% Created by Tom Buurke & Rob den Otter (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version

% Data=butterfilterlow(2,300,15,Data);

% creates array 'Detect' which has a value of 1 when the force exceeds the
% imposed treshold, and 0 when it doesnt. By differentiating, the time
% point can be assessed where 'Detect' goes from 0 to 1 (i.e., alleged HS),
% hence by searching Temp==1, these can be assessed.
[a,~]       = find(Data>Treshold);
Detect      = zeros(length(Data),1);
Detect(a)   = 1; 

Temp            = diff(Detect); % differentiate the data
[Heelstrike,~]  = find(Temp==1);

%% Loop through the vertical GRF to identify heel strikes left 
j = 1;

for i = 1 : length(Heelstrike)
    
    if (Heelstrike(i)+windowlengte) <= length(Detect)
        [b,~] = find(Detect(Heelstrike(i) : (Heelstrike(i)+windowlengte)) > Detect(Heelstrike(i)));% de waarde op heelstrike is 0
        
        if length(b) == windowlengte
            newstrike(j) = Heelstrike(i);
            j=j+1;
            clear b;
        end
        
    end
    
end

%% output
HeelstrikeL=newstrike;

end