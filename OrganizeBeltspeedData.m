RawForceDataDuplUsed    = RawForceDataAllDupl(:,1:3); % Select only the first 3 channels (belt speeds)

% Belt speed (300 Hz, but contains duplicates, so actually 100 Hz after
% duplicate removal), so: Erase the duplicates from speed struct:
j = 1; Check = RawForceDataAllDupl(:,5); % We use ForY to check the duplicates (speed is sometimes too alike, e.g., start is always 0)
for i = 2 : length(RawForceDataAllDupl(:,5))
    
    if Check(i) - Check(i-1) ~= 0
        
        Force.Time_100(j)   = RawForceDataDuplUsed(i,1);
        Force.FP1Vel(j)     = RawForceDataDuplUsed(i,2); %%% velocity still contains some duplicates (forces and moments have duplicates at same position)
        Force.FP2Vel(j)     = RawForceDataDuplUsed(i,3);
        test(j) = RawForceDataAllDupl(i,5);
        j = j + 1;
        
    end
    
end

%%% Correct orientation (just so it is consistent with other data in struct)
Force.FP1Vel    = Force.FP1Vel';
Force.FP2Vel    = Force.FP2Vel';
Force.Time_100  = Force.Time_100';
Force.Time_100  = (Force.Time_100-Force.Time_100(1));