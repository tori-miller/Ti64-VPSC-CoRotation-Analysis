%% Import mode activity for Ti project (basal, prism, 1st order pyr)

function [activity,a_prism1,a_mix2,a_prism3,a_basal1,a_basal3,a_pyr]= importACT_TiAni(pname,phaseID)

%read raw text
data = importdata([pname '\ACT_PH' num2str(phaseID) '.OUT']);

%parse out the bit we want
activity = data.data(:,3:8);

% separate into separate slip systems
a_prism1 = activity(:,2);
a_prism3 = activity(:,1);
a_basal1 = activity(:,5);
a_basal3 = activity(:,4);
a_pyr = activity(:,6);
a_mix2 = activity(:,3); % Remember basal2 and prism2 are lumped together