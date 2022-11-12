%% Script to find heelstrikes and toe-offs and manually add or remove points
% Tom Buurke - February 2017
% Changed by Sander - Jan 2019

% Instructions using a mouse:
% Left mouseclick: Add point
% Right mouseclick: Remove point
% Scroll click: Next frame
% Click 'p': Previous frame
% Click 'q': Go to next variable (dont use this)
%
% Instruction using no mouse (mac, default)
% Click 'a' : Add point
% Click 'r' : Remove point
% Click '.>': Next frame
% Click 'p' : Previous frame
% Click 'q' : Go to next variable (dont use this)

% In this file, we assess the footcontacts, which are need to compute gait variables. 
% Foot contacts include heel strikes (i.e., when you put your foot on the
% ground) and toe-offs (i.e., when you lift your foot of the ground). 

%% identify Heel Strikes and toe-offs
% Detection treshold: 50N (for atleast 75 samples)
% We use the unfiltered force data (with sf = 1000 Hz) to detect foot contacts
% Change 'window' variable in AddRemoveHeelstrikes.m when unfiltered force data sampled at 100 Hz is used. 
Treshold        = 50;
windowlengte    = 55;
SampleFreq      = Force.sf; % sf = 1000 Hz


%% Detect left and right heelstrikes and toe-offs from forceplate data
% HSL
DataInput                = 1; 
[Force.HeelstrikeL,~]    = DetectHeelstrikeL(Force.FP1ForY,Treshold,windowlengte); % Detect Heelstrikes automatically
[Force.HeelstrikeL]      = AddRemoveHeelstrikes_WindowsVersion(Force.FP1ForY,Force.HeelstrikeL,DataInput,0,SampleFreq); % Manual correction of found heelstrikes (see instructions)

% TOL
clear DataInput
DataInput                = 2;
[Force.ToeoffL,~]        = DetectToeOffL(Force.FP1ForY,Treshold,windowlengte);
[Force.ToeoffL]          = AddRemoveHeelstrikes_WindowsVersion(Force.FP1ForY,Force.ToeoffL,DataInput,0,SampleFreq);

% HSR
clear DataInput
DataInput                = 3;
[Force.HeelstrikeR,~]    = DetectHeelstrikeR(Force.FP2ForY,Treshold,windowlengte);
[Force.HeelstrikeR]      = AddRemoveHeelstrikes_WindowsVersion(Force.FP2ForY,Force.HeelstrikeR,DataInput,0,SampleFreq);

% TOR
clear DataInput
DataInput                = 4;
[Force.ToeoffR,~]        = DetectToeOffR(Force.FP2ForY,Treshold,windowlengte);
[Force.ToeoffR]          = AddRemoveHeelstrikes_WindowsVersion(Force.FP2ForY,Force.ToeoffR,DataInput,0,SampleFreq);

%% Round the time point of the added Heelstrikes / Toe off's 
Force.HeelstrikeL   = round(Force.HeelstrikeL);
Force.HeelstrikeR   = round(Force.HeelstrikeR);
Force.ToeoffL       = round(Force.ToeoffL);
Force.ToeoffR       = round(Force.ToeoffR);

%% Check whether everything's gone right
% disp(['Left Heelstrikes: ' num2str(length(Force.HeelstrikeL)) ' || Left Toe Offs : ' num2str(length(Force.ToeoffL))])
% disp(['Right Heelstrikes: ' num2str(length(Force.HeelstrikeR)) ' || Right Toe Offs : ' num2str(length(Force.ToeoffR))])
% 
% %% Save
% if input('Do you want to save this workspace? Y/N >> ','s') == 'Y'
%     save(['P' num2str(Subject) '.mat']); %Save to .mat file again
%     disp(['Workspace saved to P' num2str(Subject) '.mat']);
% end
%% maak hier een kloppende matrix van met contacten:
[ContactMatrix]= MakeContactMatrix(Force.HeelstrikeL,Force.ToeoffR,Force.HeelstrikeR,Force.ToeoffL);