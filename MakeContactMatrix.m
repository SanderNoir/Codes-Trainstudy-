function[ContactMatrix]= MakeContactMatrix(HeelstrikeL,ToeoffR,HeelstrikeR,ToeoffL);

%% maak een contactmatrix met 5 rijen
% rij 1: heelstrike links 
% rij 2: toe off rechts
% rij 3 heelstrike rechts
% rij 4 toe off links 
% rij 5: laatste sample voor volgende heelstrike links)

j=1;
for i=1:length(HeelstrikeL)
    to_index=min(find(ToeoffR>HeelstrikeL(i)));
    if isempty(to_index)==0
       ContactMatrix(j,:)=[HeelstrikeL(i) ToeoffR(to_index)];
       j=j+1;
    end
    clear to_index;
end

% Voor de derde rij:
j=1;
for i=1:length(ContactMatrix(:,1))
    hs_index=min(find(HeelstrikeR>ContactMatrix(i,2)));
    if isempty(hs_index)==0
       ContactMatrix(j,3)=[HeelstrikeR(hs_index)];
       j=j+1;
    end
    clear hs_index;
end

% Voor de vierde rij:
j=1;
for i=1:length(ContactMatrix(:,1))
    to_index=min(find(ToeoffL>ContactMatrix(i,3)));
    if isempty(to_index)==0
       ContactMatrix(j,4)=ToeoffL(to_index);
    end
    j=j+1;
    clear to_index;
end

% de laatste rij:
temp=ContactMatrix(2:end,1)-1;
ContactMatrix=ContactMatrix(1:end-1,:);%haal de laatste rij weg
ContactMatrix(:,5)=temp;