function [Perturbation] = DeterminePertChar_Okt2022(Force)

%% Function to determine when the perturbation starts and ends
% 
% Output: Perturbation.Initiation: sample (sf = 100 Hz) at which belts iniate slip


%% Settings
WidthThreshold  = 50;    % N
SpeedThreshold  = 1.12;  % m/s
LoopStart       = 5000; % to make sure that the initial ramp up period is excluded
StartOfPer      = zeros(1,length(Force.FP2Vel));
EndOfPer        = zeros(1,length(Force.FP2Vel));

%% Identify the perturbations
for i = LoopStart : length(Force.FP2Vel)
    
    if Force.FP2Vel(i) < 1.19   % deviation from gait speed, value depends on variability velocity signal
        StartOfPer(i) = 1;
    else
        StartOfPer(i) = 0;  
    end
    
end

[~,PerStart,Width] = findpeaks(StartOfPer); % Coordinates Perturbations

% When we look at when the velocity is lower than 0.99 to identify
% perturbations, we get a lot of values. Therefore, we look at the distance
% (Width variable) between alleged perturbations (i.e., check whether it is large enough)
for i = 1 : length(Width)
    
    if Width(i) < WidthThreshold
        PerStart(i) = NaN; 
    else 
        PerStart(i) = PerStart(i); 
    end
    
end

ind                     = ~isnan(PerStart); % remove instances not corresponding to perturbation starts
Perturbation.Initiation = PerStart(ind);


%% Identify perturbation end
for i = LoopStart : length(Force.FP2Vel)
    
    if Force.FP2Vel(i) > SpeedThreshold
        EndOfPer(i) = 1;
    else
        EndOfPer(i) = 0;
    end
    
end

EndOfPer(end)       = 0; % to identify last perturbation
[~,PerEnd]          = findpeaks(EndOfPer);
Perturbation.End    = PerEnd(2:end); % the first index represents the rampup period

% and find perturbation termination:
temp=Force.FP1Vel;
zooi=find(temp>-0.02);
temp=zeros(length(Force.FP1Vel),1);
temp(zooi)=1;difftemp=diff(temp);
[~,Perturbation.Term]=findpeaks(difftemp);
Perturbation.Term=Perturbation.Term';

figure;
plot(Force.FP2Vel);hold on;
for i=1:length(Perturbation.Initiation)
    plot(Perturbation.Initiation(i),Force.FP2Vel(Perturbation.Initiation(i)),'*r');
end
end




