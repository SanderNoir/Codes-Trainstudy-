function [StepPar]=Stapparameters(SubData,ForceComb,ContactMatrix,SampleFreq);
%% bepaal staplengte, stapduur en stapfrequentie

%% Warning:
disp('WARNING: this routine assumes equal speeds for both belts - NOT yet ready for use in Split-belt research!!')
%% set gait speed
BeltSpeed= input('Wat is snelheid van de loopband (m/s)? >> ');

%% Step length symmetry, Step Width & Double support time symmetry, Single Support Time, Single Support Time Symmetry
for i=1:length(ContactMatrix(:,1)) %Calculate parameters for every stride
    
    % Step Length Left
    PosR                = ForceComb.CopZ(ContactMatrix(i,1));% Position right foot at left heel strike
    PosL                = ForceComb.CopZ(ContactMatrix(i,2));% Position left foot at right toe off
    LatRL               = ContactMatrix(i,2)-ContactMatrix(i,1); % Time passed between left heel strike and right toe off
    DistTravL           = -(LatRL/SampleFreq)*BeltSpeed; % distance travelled by left foot over the course of LatRL
    PosLVirt            = PosL+DistTravL; % virtual position Left foot at left heelstrike
    StepLengthLeft(i)   = (abs(PosR-PosLVirt)) / SubData.LegLength;
    clear PosR PosL LatRL DistTravL PosLVirt
    
    % Step Length Right
    PosL                = ForceComb.CopZ(ContactMatrix(i,3));% Position left foot at right heel strike
    PosR                = ForceComb.CopZ(ContactMatrix(i,4));% Position right foot at left toe off
    LatRL               = ContactMatrix(i,4)-ContactMatrix(i,3); % Time passed between right heel strike and left toe off
    DistTravR           = -(LatRL/SampleFreq)*BeltSpeed; % distance travelled by right foot over the course of LatRL
    PosRVirt            = PosR+DistTravR; % virtual position right foot at right heelstrike
    StepLengthRight(i)  = (abs(PosL-PosRVirt)) / SubData.LegLength;
    clear PosL PosR LatRL DistTravR PosRVirt
    
    % step duration left (left heel contact to right heel contact)
    StepTimeLeft(i)   = ContactMatrix(i,3)- ContactMatrix(i,1);
    StepTimeRight(i)  = ContactMatrix(i,5)- ContactMatrix(i,3);
    StepFreqLeft(i)   = (1000/StepTimeLeft(i))*60;
    StepFreqRight(i)   = (1000/StepTimeRight(i))*60;
end

%% Output
%Output in struct StepPar(Step Parameters) with relevant step parameters
StepPar.SLL     = StepLengthLeft;    %Left step length (m)
StepPar.SLR     = StepLengthRight;   %Right step length (m)
StepPar.STL     = StepTimeLeft;      % step time left
StepPar.STR     = StepTimeRight;      % step time left
StepPar.SFL     = StepFreqLeft;      % step frequency left
StepPar.SFR     = StepFreqRight;      % step frequency right
