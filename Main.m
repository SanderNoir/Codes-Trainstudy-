%% clear workspace
clear; close all;

%% call on leg length and weight
SubData.Weight      = input('What is the Subjects weight (Kg)? ');
SubData.LegLength   = input('What is the Subjects leg length (m)? ');

%% haal de marker- en forcedata binnen + soorteer en benoem de markerdata en calibreer de forcedata (hiervoor is de file 'UMCG_MatrixTranspose.mat' nodig):
[file,path] = uigetfile('*.mat','Kies bestand met marker- en forcedata'); 
load([path file]);
OrganizeC3DData;

%% haal de bandsnelheid (*.txt file) binnen:
[file,path] = uigetfile('*.txt','Kies bestand met de bandsnelheden (o.a. nodig voor het bepalen v.d. verstoringen)');
RawForceDataAllDupl     = dlmread([path file],'\t',1,0); % read data
OrganizeBeltspeedData;

%% vraag de samplefrequentie van de krachtplaatdata aan de gebruiker:
Force.sf = input('Wat is de samplefrequentie voor de krachtplaatdata? >> ');

%% simuleer een enkele krachtplaat uit data van de twee krachtplaten:
[Force,ForceComb] = SimulateSingleFP(Force);

%% vraag de filterfrequentie van de krachtplaatdata en filter de data:
cf = input('Op welke frequentie wil je de krachtplaatdata filteren (15Hz is aan te raden) >> ');
FilterForceData;

%% bepaal de verstoringsmomenten (begin en einde) op basis van de 100Hz snelheid (+check deze visueel):
[Perturbation] = DeterminePertChar_Okt2022(Force);

%% Detect left and right heelstrikes and toe-offs from forceplate data
% HSL
Treshold        = 50;
windowlengte    = 55;
% SampleFreq      = Force.sf; % sf = 1000 Hz

%% Maak een vector met bandsnelheden op 1000hz (hier zitten dus duplicaten in, in series van 10 samples):
temp=zeros(length(Force.FP1Vel)*10,1);
temp_2=zeros(10,1);
for i=1:length(Force.FP1Vel)
    temp_2(1:10)=Force.FP1Vel(i);
    temp((i*10)-9:i*10)=temp_2;
end
BeltSpeed=temp;

%% bepaal contacten en uitkomstparameters voor iedere trial:
for i=1:length(Perturbation.Initiation)
    SamplesBefore                   = 5000;
    SamplesAfter                    = 4000;
    StartWindow                     = (Perturbation.Initiation(i)*10)-SamplesBefore;
    EndWindow                       = (Perturbation.Initiation(i)*10)+SamplesAfter;
    TempData                        = [Force.FP1ForY(StartWindow:EndWindow),Force.FP2ForY(StartWindow:EndWindow)];
    [HeelstrikeL_temp,~]            = DetectHeelstrikeL(Force.FP1ForY(StartWindow:EndWindow),Treshold,windowlengte);    HeelstrikeL_temp(2,:)=1; % Detect Heelstrikes automatically
    [HeelstrikeR_temp,~]            = DetectHeelstrikeR(Force.FP2ForY(StartWindow:EndWindow),Treshold,windowlengte);    HeelstrikeR_temp(2,:)=3; % Detect Heelstrikes automatically
    [ToeoffL_temp,~]                = DetectToeOffL(Force.FP1ForY(StartWindow:EndWindow),Treshold,windowlengte);        ToeoffL_temp(2,:)=4;
    [ToeoffR_temp,~]                = DetectToeOffR(Force.FP2ForY(StartWindow:EndWindow),Treshold,windowlengte);        ToeoffR_temp(2,:)=2;
    ContactVector_temp              = [HeelstrikeL_temp ToeoffR_temp HeelstrikeR_temp ToeoffL_temp];
    [ContactVector_sorted,index]    = sort(ContactVector_temp(1,:));
    ContactVector_sorted(2,:)       = ContactVector_temp(2,index);
    FirstHeelstrikeL                = min(find(ContactVector_sorted(2,:)==1)); ContactVector_sorted=ContactVector_sorted(:,FirstHeelstrikeL:end);%zorg dat contacten altijd beginnen op heelstrike links
    
    [ContactVector_temp]    = AddRemoveHeelstrikes_WindowsVersion2(Force.FP1ForY(StartWindow:EndWindow),Force.FP2ForY(StartWindow:EndWindow),ContactVector_sorted,0,Force.sf,SamplesBefore);
    temp                    = ContactVector_temp;
    temp(1,:)               = temp(1,:)-SamplesBefore;
    [~,temp_ind]            = find(temp(1,:)<=0);
    IndPert                 = max(temp_ind);% IndPert is de index van het laatste GAIT EVENT voor de verstoring
    PertFase(i)             = ContactVector_temp(2,IndPert);clear temp; % type gait event v.h. laatste event voor de verstoring: 1=ds1, 2=ss left, 3=ds2, 4=sw left (contactmatrix(1,1) is altijd IC links, zie line 59)
    temp                    = ContactVector_temp(:,1:IndPert);
    [~,temp_ind]            = find(temp(2,:)==1 | temp(2,:)==3);
    PertStrideInd           = max(temp_ind);%PertStrideInd is de laatste HEELSTRIKE voor de verstoring
    
    % bepaal de zijde van de verstoring:
    if ContactVector_temp(2,PertStrideInd)==1
        PertZijde(i)=1;%linkerschrede
    elseif ContactVector_temp(2,PertStrideInd)==3
        PertZijde(i)=2;%rechterschrede
    end
    
    % make contact matrix with second row starting with last heelstrike
    % before perturbation (2,1) and (2,3) being the fisrt heelstrike post
    % perturbation
    ContMat(2,:) = ContactVector_temp(1,PertStrideInd:PertStrideInd+4);%perturbed stride
    ContMat(1,:) = ContactVector_temp(1,PertStrideInd-4:PertStrideInd);%last stride before perturbation
    ContMat(3,:) = ContactVector_temp(1,PertStrideInd+4:PertStrideInd+8);% first stride post perturbation
    ContMat      = ContMat+StartWindow; %contactindices die overeenstemmen met time code van de krachtplaatdata
    close all;
    [ComOut(i)] = AnalyseCom_Nov2022(ForceComb,Force,marker_data,ContMat,BeltSpeed,Force.sf,SubData,PertZijde(i));
    ReactieTijd(i) = ContMat(2,3)-(Perturbation.Initiation(i)*10);
end

% selecteer de variabelen voor de eerste verstoring:
Output.Reactietijd_first=ReactieTijd(1);
Output.StapLengtes_first=[ComOut(1).StapLengtes(1,1) ComOut(1).StapLengtes(1,2) ComOut(1).StapLengtes(2,1) ComOut(1).StapLengtes(2,2) ComOut(1).StapLengtes(3,1) ComOut(1).StapLengtes(3,2)];
Output.Stapduren_first=[ComOut(1).Stapduren(1,1) ComOut(1).Stapduren(1,2) ComOut(1).Stapduren(2,1) ComOut(1).Stapduren(2,2) ComOut(1).Stapduren(3,1) ComOut(1).Stapduren(3,2)];
Output.APMos_Tofirst=[ComOut(1).APMos_To(1,1) ComOut(1).APMos_To(1,2) ComOut(1).APMos_To(2,1) ComOut(1).APMos_To(2,2) ComOut(1).APMos_To(3,1) ComOut(1).APMos_To(3,2)];% volgorde: [-3 -2 -1 pert +1 +2];
Output.APMos_first=[ComOut(1).APMos(1,1) ComOut(1).APMos(1,2) ComOut(1).APMos(2,1) ComOut(1).APMos(2,2) ComOut(1).APMos(3,1) ComOut(1).APMos(3,2)];% volgorde: [-3 -2 -1 pert +1 +2];
Ouput.MaxXComAP_first=ComOut(1).MaxXComAP;

% selecteer de variabelen voor de laatste verstoring:
Output.Reactietijd_final=ReactieTijd(21);
Output.StapLengtes_final=[ComOut(21).StapLengtes(1,1) ComOut(21).StapLengtes(1,2) ComOut(21).StapLengtes(2,1) ComOut(21).StapLengtes(2,2) ComOut(21).StapLengtes(3,1) ComOut(21).StapLengtes(3,2)];
Output.Stapduren_final=[ComOut(21).Stapduren(1,1) ComOut(21).Stapduren(1,2) ComOut(21).Stapduren(2,1) ComOut(21).Stapduren(2,2) ComOut(21).Stapduren(3,1) ComOut(21).Stapduren(3,2)];
Output.APMos_Tofinal=[ComOut(21).APMos_To(1,1) ComOut(21).APMos_To(1,2) ComOut(21).APMos_To(2,1) ComOut(21).APMos_To(2,2) ComOut(21).APMos_To(3,1) ComOut(21).APMos_To(3,2)];% volgorde: [-3 -2 -1 pert +1 +2];
Output.APMos_final=[ComOut(21).APMos(1,1) ComOut(21).APMos(1,2) ComOut(21).APMos(2,1) ComOut(21).APMos(2,2) ComOut(21).APMos(3,1) ComOut(21).APMos(3,2)];% volgorde: [-3 -2 -1 pert +1 +2];
Ouput.MaxXComAP_final=ComOut(21).MaxXComAP;

% en voor de andere 19 verstoringen:

% maak onderscheid DS en SS verstoringen (negeer li en re):
[dummy,DS_ind] = find(PertFase(2:20)==1 | PertFase(2:20)==3);%DS
[dummy,SS_ind] = find(PertFase(2:20)==2 | PertFase(2:20)==4);%DS
DS_ind=DS_ind+1;
SS_ind=SS_ind+1;
Output.ReactieTijd_DS=ReactieTijd(DS_ind);
Output.ReactieTijd_SS=ReactieTijd(SS_ind);

% variabelen klaar maken voor export en middeling (voor DS en SS verstoringen apart; reminder links is hieronder altijd de verstoorde voet, heeft met rganisatie van de contactmatrix te maken):
for i=1:length(DS_ind)
    Output.APMos_To_DS(i,:)=[ComOut(DS_ind(i)).APMos_To(1,1) ComOut(DS_ind(i)).APMos_To(1,2) ComOut(DS_ind(i)).APMos_To(2,1) ComOut(DS_ind(i)).APMos_To(2,2) ComOut(DS_ind(i)).APMos_To(3,1) ComOut(DS_ind(i)).APMos_To(3,2)];% volgorde: [-3 -2 -1 pert +1 +2]
    Output.APMos_DS(i,:)=[ComOut(DS_ind(i)).APMos(1,1) ComOut(DS_ind(i)).APMos(1) ComOut(DS_ind(i)).APMos(2) ComOut(DS_ind(i)).APMos(2) ComOut(DS_ind(i)).APMos(3) ComOut(DS_ind(i)).APMos(3)];% volgorde: [-3 -2 -1 pert +1 +2]
    Output.Staplengtes_DS(i,:)=[ComOut(DS_ind(i)).StapLengtes(1,1) ComOut(DS_ind(i)).StapLengtes(1,2) ComOut(DS_ind(i)).StapLengtes(2,1) ComOut(DS_ind(i)).StapLengtes(2,2) ComOut(DS_ind(i)).StapLengtes(3,1) ComOut(DS_ind(i)).StapLengtes(3,2)];
    Output.Stapduren_DS(i,:)=[ComOut(DS_ind(i)).Stapduren(1,1) ComOut(DS_ind(i)).Stapduren(1,2) ComOut(DS_ind(i)).Stapduren(2,1) ComOut(DS_ind(i)).Stapduren(2,2) ComOut(DS_ind(i)).Stapduren(3,1) ComOut(DS_ind(i)).Stapduren(3,2)];
    Ouput.MaxXComAP_DS(i)=ComOut(DS_ind(i)).MaxXComAP;
end

for i=1:length(SS_ind)
    Output.APMos_To_SS(i,:)=[ComOut(SS_ind(i)).APMos_To(1,1) ComOut(SS_ind(i)).APMos_To(1,2) ComOut(SS_ind(i)).APMos_To(2,1) ComOut(SS_ind(i)).APMos_To(2,2) ComOut(SS_ind(i)).APMos_To(3,1) ComOut(SS_ind(i)).APMos_To(3,2)];% volgorde: [-3 -2 -1 pert +1 +2]
    Output.APMos_SS(i,:)=[ComOut(i).APMos(1,1) ComOut(i).APMos(1,2) ComOut(i).APMos(2,1) ComOut(i).APMos(2,2) ComOut(i).APMos(3,1) ComOut(i).APMos(3,2)];
    Output.Staplengtes_SS(i,:)=[ComOut(i).StapLengtes(1,1) ComOut(i).StapLengtes(1,2) ComOut(i).StapLengtes(2,1) ComOut(i).StapLengtes(2,2) ComOut(i).StapLengtes(3,1) ComOut(i).StapLengtes(3,2)];
    Output.Stapduren_SS(i,:)=[ComOut(SS_ind(i)).Stapduren(1,1) ComOut(SS_ind(i)).Stapduren(1,2) ComOut(SS_ind(i)).Stapduren(2,1) ComOut(SS_ind(i)).Stapduren(2,2) ComOut(SS_ind(i)).Stapduren(3,1) ComOut(SS_ind(i)).Stapduren(3,2)];
    Ouput.MaxXComAP_SS(i)=ComOut(SS_ind(i)).MaxXComAP;
end

Output.PertZijde=PertZijde;

uisave({'Output'},'Proefpersoon_Groep');

% Pertzjde klopt niet: 1 =rechts en 2 = links


