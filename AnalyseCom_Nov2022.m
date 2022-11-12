function [ComOut] = AnalyseCom_Nov2022(ForceComb,Force,marker_data,ContactMatrix,BeltSpeed,SampleFreq,SubData,PertZijde)

%%  Calculate CoM, XCoM, and MoS
% Input
% ForceComb - A struct containing simulated single forceplate data
% Force     - A struct containing forceplate data
% ContactMatrix   - Contact matrix with heelstrikes and toe-offs
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
% Messed up further by Rob den Otter (November 2022)

% declare variables for testing:
% ContactMatrix=ContMat;
% SampleFreq=Force.sf;
% PertZijde=1
%% update Oct. 2021
% AP MOS was computed as XCOM-MOS, this equation is wrong in the first
% article. In addition, for both ML and AP MOS leg length was first divided
% by g before multiplied with 1.2 or 1.34. This was wrong.

%% get toe en heel data from 'markerdata'-cell:
LinkerTeen_AP=marker_data{33};
LinkerTeen_AP=LinkerTeen_AP(2,:);

RechterTeen_AP=marker_data{39};
RechterTeen_AP=RechterTeen_AP(2,:);

% zet teensignalen om in een signaal met dezelfde sf als de fp-data: 
temp=zeros(length(LinkerTeen_AP)*10,1);
temp_2=zeros(10,1);
for i=1:length(LinkerTeen_AP)
    temp_2(1:10)=LinkerTeen_AP(i);
    temp((i*10)-9:i*10)=temp_2;
end
LinkerTeen_AP=temp;

% zet teensignalen om in een signaal met dezelfde sf als de fp-data: 
temp=zeros(length(RechterTeen_AP)*10,1);
temp_2=zeros(10,1);
for i=1:length(RechterTeen_AP)
    temp_2(1:10)=RechterTeen_AP(i);
    temp((i*10)-9:i*10)=temp_2;
end
RechterTeen_AP=temp;

% dan de hielsignalen (nodig voor staplengtes):
LinkerHiel_AP=marker_data{32};
LinkerHiel_AP=LinkerHiel_AP(2,:);

RechterHiel_AP=marker_data{38};
RechterHiel_AP=RechterHiel_AP(2,:);

% zet teensignalen om in een signaal met dezelfde sf als de fp-data: 
temp=zeros(length(LinkerHiel_AP)*10,1);
temp_2=zeros(10,1);
for i=1:length(LinkerHiel_AP)
    temp_2(1:10)=LinkerHiel_AP(i);
    temp((i*10)-9:i*10)=temp_2;
end
LinkerHiel_AP=temp;

% zet teensignalen om in een signaal met dezelfde sf als de fp-data: 
temp=zeros(length(RechterHiel_AP)*10,1);
temp_2=zeros(10,1);
for i=1:length(RechterHiel_AP)
    temp_2(1:10)=RechterHiel_AP(i);
    temp((i*10)-9:i*10)=temp_2;
end
RechterHiel_AP=temp;
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
for i=1:length(BeltSpeed)

    XComAP(i) = FuseComZ(i) +  VelZ(i)/(sqrt(9.80665/(SubData.LegLength*1.34))) - BeltSpeed(i); %Trochanter height * 1.2 See Hof 2005 and cite Winter 1979
    % NOTE: belt speed wordt eraf getrokken ivm orientatie Z-richting (voor
    % = negatief)
    XComML(i) = FuseComX(i) +  VelX(i)/(sqrt(9.80665/(SubData.LegLength*1.2)));

end
    APMos_To(1,1)=XComAP(ContactMatrix(1,2)) - ForceComb.CopZ(ContactMatrix(1,2));
    APMos_To(1,2)=XComAP(ContactMatrix(1,4)) - ForceComb.CopZ(ContactMatrix(1,4));
    APMos_To(2,1)=XComAP(ContactMatrix(2,2)) - ForceComb.CopZ(ContactMatrix(2,2));
    APMos_To(2,2)=XComAP(ContactMatrix(2,4)) - ForceComb.CopZ(ContactMatrix(2,4));
    APMos_To(3,1)=XComAP(ContactMatrix(3,2)) - ForceComb.CopZ(ContactMatrix(3,2));
    APMos_To(3,2)=XComAP(ContactMatrix(3,4)) - ForceComb.CopZ(ContactMatrix(3,4));
    
if PertZijde==1
    APMos(1,1)= (XComAP(ContactMatrix(1,1))*1000 - LinkerHiel_AP(ContactMatrix(1,1)));
    APMos(1,2)= (XComAP(ContactMatrix(1,3))*1000 - RechterHiel_AP(ContactMatrix(1,3)));
    APMos(2,1)= (XComAP(ContactMatrix(2,1))*1000 - LinkerHiel_AP(ContactMatrix(2,1)));
    APMos(2,2)= (XComAP(ContactMatrix(2,3))*1000 - RechterHiel_AP(ContactMatrix(2,3)));
    APMos(3,1)= (XComAP(ContactMatrix(3,1))*1000 - LinkerHiel_AP(ContactMatrix(3,1)));
    APMos(3,2)= (XComAP(ContactMatrix(3,3))*1000 - RechterHiel_AP(ContactMatrix(3,3)));
elseif PertZijde==2
    APMos(1,1)= (XComAP(ContactMatrix(1,1))*1000 - RechterHiel_AP(ContactMatrix(1,1)));
    APMos(1,2)= (XComAP(ContactMatrix(1,3))*1000 - LinkerHiel_AP(ContactMatrix(1,3)));
    APMos(2,1)= (XComAP(ContactMatrix(2,1))*1000 - RechterHiel_AP(ContactMatrix(2,1)));
    APMos(2,2)= (XComAP(ContactMatrix(2,3))*1000 - LinkerHiel_AP(ContactMatrix(2,3)));
    APMos(3,1)= (XComAP(ContactMatrix(3,1))*1000 - RechterHiel_AP(ContactMatrix(3,1)));
    APMos(3,2)= (XComAP(ContactMatrix(3,3))*1000 - LinkerHiel_AP(ContactMatrix(3,3)));
end

MaxXComAP=-max(XComAP(ContactMatrix(2,1):ContactMatrix(2,5)));
%% LET OP: L EN R ZIJN NU NIET MEER LINKS EN RECHTS! (HANGT AF VAN DE ZIJDE VAN DE VERSTORING)
% DE EERSTE KOLOM VD CONTACTMATRIX IS DUS ALTIJD VAN HET BEEN WAARVAN HET
% LAATSTE HIELCONTACT VOOR DE VERSTORING PLAATSVOND
%% Staplengtes (bepaald op basis van markerdata; het Cop van individuele forceplates is namelijk niet stabiel op het moment van initial contact):

if PertZijde==1
    StapLengtes(1,1)=(LinkerHiel_AP(ContactMatrix(1,3))-RechterHiel_AP(ContactMatrix(1,3)));% ziet er gek uit, maar hier wordt gecorrigeerd voor de vreemde orientatie van de Z-as in Vicon/DFlow
    StapLengtes(1,2)=-1*(LinkerHiel_AP(ContactMatrix(1,5))-RechterHiel_AP(ContactMatrix(1,5)));
    StapLengtes(2,1)=(LinkerHiel_AP(ContactMatrix(2,3))-RechterHiel_AP(ContactMatrix(2,3)));
    StapLengtes(2,2)=-1*(LinkerHiel_AP(ContactMatrix(2,5))-RechterHiel_AP(ContactMatrix(2,5)));
    StapLengtes(3,1)=(LinkerHiel_AP(ContactMatrix(3,3))-RechterHiel_AP(ContactMatrix(3,3)));
    StapLengtes(3,2)=-1*(LinkerHiel_AP(ContactMatrix(3,5))-RechterHiel_AP(ContactMatrix(3,5)));
elseif PertZijde==2
    StapLengtes(1,1)=(RechterHiel_AP(ContactMatrix(1,3))-LinkerHiel_AP(ContactMatrix(1,3)));
    StapLengtes(1,2)=-1*(RechterHiel_AP(ContactMatrix(1,5))-LinkerHiel_AP(ContactMatrix(1,5)));
    StapLengtes(2,1)=(RechterHiel_AP(ContactMatrix(2,3))-LinkerHiel_AP(ContactMatrix(2,3)));
    StapLengtes(2,2)=-1*(RechterHiel_AP(ContactMatrix(2,5))-LinkerHiel_AP(ContactMatrix(2,5)));
    StapLengtes(3,1)=(RechterHiel_AP(ContactMatrix(3,3))-LinkerHiel_AP(ContactMatrix(3,3)));
    StapLengtes(3,2)=-1*(RechterHiel_AP(ContactMatrix(3,5))-LinkerHiel_AP(ContactMatrix(3,5)));
end
%staplengte (2,2) is de lengte van de eerste stap na de verstoring
%% stapduren:
Stapduur(1,1)=ContactMatrix(1,3)-ContactMatrix(1,1);
Stapduur(1,2)=ContactMatrix(1,5)-ContactMatrix(1,3);
Stapduur(2,1)=ContactMatrix(2,3)-ContactMatrix(2,1);
Stapduur(2,2)=ContactMatrix(2,5)-ContactMatrix(2,3);
Stapduur(3,1)=ContactMatrix(3,3)-ContactMatrix(3,1);
Stapduur(3,2)=ContactMatrix(3,5)-ContactMatrix(3,3);
%staplengte (2,1) is de lengte van de eerste stap na de verstoring
%% Output
% anterior- posterior
ComOut.ComAP    = FuseComZ;          % CoM position (m)
ComOut.XComAP   = XComAP;            % XcoM position (m)
ComOut.APMos   = -APMos;            % MoS (m) @ heelstrike (based on markerdata)
ComOut.APMos_To   = -APMos_To;            % MoS (m) @ toe off
ComOut.StapLengtes=StapLengtes;
ComOut.Stapduren=Stapduur;
ComOut.MaxXComAP=MaxXComAP;


end