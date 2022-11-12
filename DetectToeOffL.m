function[ToeoffL,Detect]=DetectToeOffL(Data,Treshold,windowlengte)
% Function to detect toe offs
% Input:
% Data - Array with vertical ground reaction forces
% Treshold - Detection treshold
% windowlengte - Window size 
% Standard:
% Treshold=100;
% windowlengte=75;
%
% Output:
% Toeoff - Array with toe-offs
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

Temp        = diff(Detect);
[Toeoff,~]  = find(Temp==-1);

%% Loop through the vertical GRF to identify toe off left
j = 1;

for i = 1:length(Toeoff)
    
    if (Toeoff(i)-windowlengte) >= 1
        [b,~] = find(Detect((Toeoff(i)-windowlengte) : Toeoff(i)) == Detect(Toeoff(i)));% de waarde op heelstrike is 0
        
        if length(b) == windowlengte + 1
            newtoeoff(j) = Toeoff(i);
            j = j+1;
            clear b;
        end
    end
    
end

%% Output
ToeoffL=newtoeoff;

end
