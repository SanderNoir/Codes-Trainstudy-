function[ContactMatrix_Corrected]=CheckContactMatrix(ContactMatrix);
% CHECK 1: check of alle contacten in een schrede op de juiste volgorde zitten:
k=1;
errorNR=[];
for i=1:length(ContactMatrix(:,1))
    errors=zeros(4,1);
    j=1;
    error(1)=ContactMatrix(i,j)<ContactMatrix(i,j+1);
    error(2)=ContactMatrix(i,j+1)<ContactMatrix(i,j+2);
    error(3)=ContactMatrix(i,j+2)<ContactMatrix(i,j+3);
    error(4)=ContactMatrix(i,j+3)<ContactMatrix(i,j+4);
    if sum(error)<4
        errorNR(k)=i;
        k=k+1;
    end
end

% CHECK 2: 
for i=1:length(ContactMatrix(:,1))
    ContactStapDuur(i)=ContactMatrix(i,5)-ContactMatrix(i,1);
end

Suspect = isoutlier(ContactStapDuur);
Suspect = isoutlier(ContactStapDuur,"gesd")
figure;plot(ContactStapDuur);hold on;
for i=1:length(Suspect)
    if Suspect(i)==1
        plot(i,ContactStapDuur(i),'r*');
    end
end
Verdacht=find(Suspect);

% rapportage:
disp(['Voor de volgende schrede(-s) klopt de volgorde van de gait events niet: ' num2str(errorNR)]);
disp(['De duur van de volgende schrede(-s) is verdacht: ' num2str(Verdacht)]);

ToBeExcluded = input('Want to exclude strides? (provide as follows, e.g. [3 67 127]) ');
ContactMatrix_Corrected=ContactMatrix;
ContactMatrix_Corrected(ToBeExcluded,:)=[];
