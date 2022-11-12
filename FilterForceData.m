% script FilterForceData (voor het filteren van de krachtplaatdata):
[Force.FP1ForX] = butterfilterlow(2,Force.sf,cf,Force.FP1ForX); % 2th order butterlow filter, sf=300 Hz
[Force.FP1ForY] = butterfilterlow(2,Force.sf,cf,Force.FP1ForY);
[Force.FP1ForZ] = butterfilterlow(2,Force.sf,cf,Force.FP1ForZ);

[Force.FP2ForX] = butterfilterlow(2,Force.sf,cf,Force.FP2ForX);
[Force.FP2ForY] = butterfilterlow(2,Force.sf,cf,Force.FP2ForY);
[Force.FP2ForZ] = butterfilterlow(2,Force.sf,cf,Force.FP2ForZ);

[Force.FP1MomX] = butterfilterlow(2,Force.sf,cf,Force.FP1MomX);
[Force.FP1MomY] = butterfilterlow(2,Force.sf,cf,Force.FP1MomY);
[Force.FP1MomZ] = butterfilterlow(2,Force.sf,cf,Force.FP1MomZ);

[Force.FP2MomX] = butterfilterlow(2,Force.sf,cf,Force.FP2MomX);
[Force.FP2MomY] = butterfilterlow(2,Force.sf,cf,Force.FP2MomY);
[Force.FP2MomZ] = butterfilterlow(2,Force.sf,cf,Force.FP2MomZ);

[Force.FP1CopX] = butterfilterlow(2,Force.sf,cf,Force.FP1CopX);
[Force.FP1CopY] = butterfilterlow(2,Force.sf,cf,Force.FP1CopY);
[Force.FP1CopZ] = butterfilterlow(2,Force.sf,cf,Force.FP1CopZ);

[Force.FP2CopX] = butterfilterlow(2,Force.sf,cf,Force.FP2CopX);
[Force.FP2CopY] = butterfilterlow(2,Force.sf,cf,Force.FP2CopY);
[Force.FP2CopZ] = butterfilterlow(2,Force.sf,cf,Force.FP2CopZ);

[ForceComb.ForX] = butterfilterlow(2,Force.sf,cf,ForceComb.ForX);
[ForceComb.ForY] = butterfilterlow(2,Force.sf,cf,ForceComb.ForY);
[ForceComb.ForZ] = butterfilterlow(2,Force.sf,cf,ForceComb.ForZ);

[ForceComb.CopX] = butterfilterlow(2,Force.sf,cf,ForceComb.CopX);
[ForceComb.CopY] = butterfilterlow(2,Force.sf,cf,ForceComb.CopY);
[ForceComb.CopZ] = butterfilterlow(2,Force.sf,cf,ForceComb.CopZ);
