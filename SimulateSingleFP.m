function [Force,ForceComb] = SimulateSingleFP(Force)
%%
%% WARNING! This function must be used with raw (unfiltered) data!
%%
%% Function that combines data of two forceplates to simulate a single forceplate(ForceComb).
% Input
% Force      - Struct with forceplate data
%
% Output
% Force      - Struct with forceplate data
% ForceComb  - Struct with simulated single forceplate data
%
% Created by Tom Buurke (2017)
% University of Groningen, University Medical Center Groningen, Center for
% Human Movement Sciences, The Netherlands
%
% Version 1.0 - Changelog (August 15 2017):
% First version
%
%

%%% Toegevoegd door Sander %%%
%% Orientation
Force.FP1MomZ = -1 * Force.FP1MomZ;
Force.FP2MomZ = -1 * Force.FP2MomZ;
%%% Toegevoegd door Sander %%%


%% Summate forces
ForceComb.ForX=Force.FP1ForX+Force.FP2ForX; %Simple addition of forces
ForceComb.ForY=Force.FP1ForY+Force.FP2ForY;
ForceComb.ForZ=Force.FP1ForZ+Force.FP2ForZ;

%% Calculate CoP (D-Flow CoP output is wrong)
% clearvars Force.FP1CopX Force.FP2CopX Force.FP1CopZ Force.FP2CopZ Force.FP1CopY Force.FP2CopY %Clean up D-Flow's COPs
% fields = {'FP1CopX','FP2CopX','FP1CopZ','FP2CopZ','FP1CopY','FP2CopY'};
% Force = rmfield(Force,fields);

for i=1:length(Force.FP1ForY)
    if Force.FP1ForY(i)<10 %Only take Forces under 10N into account when calculating CoP %Forceplate 1 (left)
        Force.FP1CopX(i,1)=0;
        Force.FP1CopZ(i,1)=0;
    else %Actual calculation
        %         Force.FP1CopX(i,1)= Force.FP1MomZ(i)./Force.FP1ForY(i);
        %         Force.FP1CopZ(i,1)=-Force.FP1MomX(i)./Force.FP1ForY(i);
        
        %%% Toegevoegd door Sander %%%
        Force.FP1CopX(i,1)= -Force.FP1MomZ(i)./Force.FP1ForY(i);
        Force.FP1CopZ(i,1)= Force.FP1MomX(i)./Force.FP1ForY(i);
        %%% Toegevoegd door Sander %%%
        
    end
    
    if Force.FP2ForY(i)<10 %Forceplate 2 (right)
        Force.FP2CopX(i,1)=0;
        Force.FP2CopZ(i,1)=0;
    else %Actual calculation
        %         Force.FP2CopX(i,1)= Force.FP2MomZ(i)./Force.FP2ForY(i);
        %         Force.FP2CopZ(i,1)=-Force.FP2MomX(i)./Force.FP2ForY(i);
        
        %%% Toegevoegd door Sander %%%
        Force.FP2CopX(i,1)= -Force.FP2MomZ(i)./Force.FP2ForY(i);
        Force.FP2CopZ(i,1)= Force.FP2MomX(i)./Force.FP2ForY(i);
        %%% Toegevoegd door Sander %%%
    end
end

Force.FP1CopY = zeros(size(Force.FP1CopX));
Force.FP2CopY = zeros(size(Force.FP2CopX));

%% Calculate simulated Single Forceplate
ForceComb.CopX = (Force.FP1ForY .* Force.FP1CopX + Force.FP2ForY .* Force.FP2CopX) ./ (Force.FP1ForY + Force.FP2ForY);
ForceComb.CopY = zeros(size(ForceComb.CopX));
ForceComb.CopZ = (Force.FP1ForY .* Force.FP1CopZ + Force.FP2ForY .* Force.FP2CopZ) ./ (Force.FP1ForY + Force.FP2ForY);

%% Remove eventual NaNs
ForceComb.ForX(isnan(ForceComb.CopX)) = [];
ForceComb.ForY(isnan(ForceComb.CopX)) = [];
ForceComb.ForZ(isnan(ForceComb.CopX)) = [];
ForceComb.CopY(isnan(ForceComb.CopX)) = [];
ForceComb.CopX(isnan(ForceComb.CopX)) = [];
ForceComb.CopZ(isnan(ForceComb.CopZ)) = [];


