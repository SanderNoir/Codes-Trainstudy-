%% c3d data
%
% Data is imported using procedures described "guide to install ezc3d on MacOS Monterey
%
%
%% squeeze the data
n_markers       = c3d.header.points.size; %%% nb, not number of markers, but number of output variables from VICON 
marker_names    = strings(1,n_markers);

%for-loop to create a variable marker_data that includes all (squeezed)
%marker data for better overview
for i = 1 : n_markers
    marker_names(i) = c3d.parameters.POINT.LABELS.DATA{i}; %%% contains the names of data
    marker_data{i}  = squeeze(c3d.data.points(:,i,:)); %%% contains the data (3D) --> can now be plotted
end


%% Calculate force data (at 1000 Hz)
% output VICON is analog data. Therefore, multiply by calibration matrix first
load('UMCG_MatrixTranspose.mat')
Outcomes = c3d.data.analogs*MatrixTranspose'; % caluclate Forces X/Y/Z forceplate 1 & 2 and Moments X Y Z forceplate 1 & 2


%% Assign data to struct Force 
Force.FP1ForX = Outcomes(:,1);
Force.FP1ForY = Outcomes(:,2);
Force.FP1ForZ = Outcomes(:,3);

Force.FP1MomX = Outcomes(:,4);
Force.FP1MomY = Outcomes(:,5);
Force.FP1MomZ = Outcomes(:,6);

Force.FP2ForX = Outcomes(:,7);
Force.FP2ForY = Outcomes(:,8);
Force.FP2ForZ = Outcomes(:,9);

Force.FP2MomX = Outcomes(:,10);
Force.FP2MomY = Outcomes(:,11);
Force.FP2MomZ = Outcomes(:,12);

clear Outcomes;