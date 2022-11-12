function [ComOut] = AnalyseCom(ForceComb,Force,ContMat,SubData)
%%  Calculate CoM, XCoM, and MoS
% Input
% ForceComb - A struct containing simulated single forceplate data
% Force     - A struct containing forceplate data
% ContMat   - Contact matrix with heelstrikes and toe-offs
%
% Output
% ComOut    - A struct containing CoM position, XcoM position and Left/Right MoS
%           - Anterior-posterior (At Heel strike)
%           - Medial-lateral (At Heel strike)
%
% Created by Tom Buurke (2017)
% Center for Human Movement Sciences, University Medical Center Groningen,
% University of Groningen, the Netherlands
%
% Changed: jan 2019, Sander
%
%% update Oct. 2021
% AP MOS was computed as XCOM-MOS, this equation is wrong in the first
% article. In addition, for both ML and AP MOS leg length was first divided
% by g before multiplied with 1.2 or 1.34. This was wrong.

%% PP3 has zeros at end of array. As a result ForceComb contained NaNs, which were removed in SimulateSingleFP (see bottom). Therefore, we need new time variable
Force.Time = (0 : 1/Force.sf : length(ForceComb.ForX)/Force.sf)';
Force.Time = Force.Time(1:length(ForceComb.ForX)); % make sure length force.time is the same as forces


%% Fusion integration method (Schepers et al. 2007)
%Settings
cf=.2; %Cut-off frequency for the filters
% Z = anterior -  (AP)
% X = medial - lateral (ML)

% Step 1 - Integrate CoM acceleration twice
AccZ = ForceComb.ForZ/SubData.Weight; %From Force to Acceleration (Acc)
AccX = ForceComb.ForX/SubData.Weight;

VelZ = cumtrapz(Force.Time,AccZ); % Integrate to obtain velocity (Vel)
VelZ = butterfilterhigh(2,Force.sf,cf,VelZ); %Filter
VelX = cumtrapz(Force.Time,AccX); 
VelX = butterfilterhigh(2,Force.sf,cf,VelX); 

PosZ = cumtrapz(Force.Time,VelZ); % Integrate second time to obtain position (Pos)
PosX = cumtrapz(Force.Time,VelX);

% Step 2 - High pass filter center of mass (CoM) position
ComPosZ = butterfilterhigh(2,Force.sf,cf,PosZ); %Filter
ComPosX = butterfilterhigh(2,Force.sf,cf,PosX);

% Step 3 - Low pass filter CoP position
CopPosZ = butterfilterlow(2,Force.sf,cf,ForceComb.CopZ); %Filter CoP data at same frequency
CopPosX = butterfilterlow(2,Force.sf,cf,ForceComb.CopX);

% Step 4 - Fuse it
FuseComZ = ComPosZ+CopPosZ; %Add low-frequency component to get the CoM position
FuseComX = ComPosX+CopPosX;

% Step 5 - Calculate Extrapolated CoM (XCoM)
XComAP = FuseComZ +  VelZ/(sqrt(9.80665/(SubData.LegLength*1.34))); %Trochanter height * 1.2 See Hof 2005 and cite Winter 1979
XComML = FuseComX +  VelX/(sqrt(9.80665/(SubData.LegLength*1.2)));


% Step 6a - Calculate Margin of Stability (Mos) at contralateral toe-off
for i=1:length(ContMat(:,1))
    
    MLMosL(i) = XComML(ContMat(i,2)) - ForceComb.CopX(ContMat(i,2));
    MLMosR(i) = ForceComb.CopX(ContMat(i,4)) - XComML(ContMat(i,4));
    
    APMosL(i) = XComAP(ContMat(i,2)) - ForceComb.CopZ(ContMat(i,2));
    APMosR(i) = XComAP(ContMat(i,4)) - ForceComb.CopZ(ContMat(i,4));
    
end

        
%% Output
% anterior- posterior
ComOut.ComAP    = FuseComZ;          % CoM position (m)
ComOut.XComAP   = XComAP;            % XcoM position (m)
ComOut.APMosL   = APMosL;            % Left MoS (m)
ComOut.APMosR   = APMosR;            % Right MoS (m)

% medial lateral
ComOut.ComML    = FuseComX;          % CoM position (m)
ComOut.XComML   = XComML;            % XcoM position (m)
ComOut.MLMosL   = MLMosL;            % Left MoS (m)
ComOut.MLMosR   = MLMosR;            % Right MoS (m)


end