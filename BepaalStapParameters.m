function [StepPar]=BepaalStapParameters(SubData,ForceComb,ContMat,SampleFreq);
%%  Calculate Contact Matrix & Step Parameters

% Input
% ForceComb  - Struct with simulated single forceplate data
% Subdata    - Weight and leg length, needed to e.g. normalize step length

% Output

% StepPar - Struct with the following parameters:
%           DSSym   - Double support symmetry
%           SLL     - Left step length (m)
%           SLR     - Right step length (m)
%           SLSym   - Step length symmetry
%           SW      - Step width (m)
%           SSL     - left single support time (sec)
%           SSR     - Right single support time (sec)
%           SSSym   - Single support time symmetry / swing time symmetry
%
% Created by Rob den Otter & Tom Buurke (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
% 
% Version 1.0 - Changelog (2019, Sander):
% First version

%% Warning:
disp('WARNING: this routine assumes equal speeds for both belts - NOT yet ready for use in Split-belt research!!')
%% set gait speed
BeltSpeed= input('Wat is snelheid van de loopband (m/s)? >> ');

%% Step length symmetry, Step Width & Double support time symmetry, Single Support Time, Single Support Time Symmetry
for i=1:length(ContMat(:,1)) %Calculate parameters for every stride
    
    DoubleSupportFirst(i) = ContMat(i,2)-ContMat(i,1); %Calculate first double support time in a stride
    DoubleSupportSecond(i) = ContMat(i,4)-ContMat(i,3); %Calculate second double support time in a stride
    
    SingleSupportLeft(i) = ((ContMat(i,3)-ContMat(i,2))/SampleFreq) / sqrt(SubData.LegLength/9.81); %Calculate left single support time
    SingleSupportRight(i) = (((ContMat(i,5)+1)-ContMat(i,4))/SampleFreq) / sqrt(SubData.LegLength/9.81); %Calculate right single support time
    
    % Step Length Left
    PosR                = ForceComb.CopZ(ContMat(i,1));% Position right foot at left heel strike
    PosL                = ForceComb.CopZ(ContMat(i,2));% Position left foot at right toe off
    LatRL               = ContMat(i,2)-ContMat(i,1); % Time passed between left heel strike and right toe off
    DistTravL           = -(LatRL/SampleFreq)*BeltSpeed; % distance travelled by left foot over the course of LatRL
    PosLVirt            = PosL+DistTravL; % virtual position Left foot at left heelstrike
    StepLengthLeft(i)   = (abs(PosR-PosLVirt)) / SubData.LegLength;
    clear PosR PosL LatRL DistTravL PosLVirt
    
    % Step Length Right
    PosL                = ForceComb.CopZ(ContMat(i,3));% Position left foot at right heel strike
    PosR                = ForceComb.CopZ(ContMat(i,4));% Position right foot at left toe off
    LatRL               = ContMat(i,4)-ContMat(i,3); % Time passed between right heel strike and left toe off
    DistTravR           = -(LatRL/SampleFreq)*BeltSpeed; % distance travelled by right foot over the course of LatRL
    PosRVirt            = PosR+DistTravR; % virtual position right foot at right heelstrike
    StepLengthRight(i)  = (abs(PosL-PosRVirt)) / SubData.LegLength;
    clear PosL PosR LatRL DistTravR PosRVirt
    
    % Step widht, see Buurke et al., (2018)
    if i<length(ContMat(:,1))
        StepWidth(i*2-1)    = abs(min(ForceComb.CopX(ContMat(i,2):ContMat(i,3))) - max(ForceComb.CopX(ContMat(i,4):ContMat(i+1,1))));
        StepWidth(i*2)      = abs(max(ForceComb.CopX(ContMat(i,4):ContMat(i+1,1))) - min(ForceComb.CopX(ContMat(i+1,2):ContMat(i+1,3))));
        
    end
end

SLSym = (StepLengthLeft - StepLengthRight)./(StepLengthLeft + StepLengthRight); %Calculate step length symmetry
STSym = (SingleSupportLeft - SingleSupportRight)./(SingleSupportLeft + SingleSupportRight); %Calculate Swing time symmetry, singlesupportleft=swingtimeright
DSSym = (DoubleSupportFirst - DoubleSupportSecond)./(DoubleSupportFirst + DoubleSupportSecond); %Calculate double support time symmetry

%% Output
%Output in struct StepPar(Step Parameters) with relevant step parameters
StepPar.DSSym   = DSSym;             %Double support duration symmetry
StepPar.DS1     = DoubleSupportFirst;
StepPar.DS2     = DoubleSupportSecond;
StepPar.SLL     = StepLengthLeft;    %Left step length (m)
StepPar.SLR     = StepLengthRight;   %Right step length (m)
StepPar.SLSym   = SLSym;             %Step length symmetry
StepPar.SW      = StepWidth;         %Step width (m)
StepPar.SSL     = SingleSupportLeft; %Left single support time (sec)
StepPar.SSR     = SingleSupportRight;%Right single support time (sec)
StepPar.STSym   = STSym;             %Swing time symmetry


end