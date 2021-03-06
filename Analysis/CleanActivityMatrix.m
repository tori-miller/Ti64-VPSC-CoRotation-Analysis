%% Activity Matrix Clean Up
% This is accounting for the fact that we only output VPSC textures every
% other deformation step. 

% remove every other row to line up with orientation data
a_prism1(2:2:41,:) = [];
a_prism2(2:2:41,:) = [];
a_prism3(2:2:41,:) = [];
a_basal1(2:2:41,:) = [];
a_basal2(2:2:41,:) = [];
a_basal3(2:2:41,:) = [];
a_pyr(2:2:41,:) = [];
%a_mix2(2:2:41,:) = [];
% add duplicate to last row for strain step #22, still at strain of 1
a_prism1 = [a_prism1; a_prism1(21,:)];
a_prism2 = [a_prism2; a_prism2(21,:)];
a_prism3 = [a_prism3; a_prism3(21,:)];
a_basal1 = [a_basal1; a_basal1(21,:)];
a_basal2 = [a_basal2; a_basal2(21,:)];
a_basal3 = [a_basal3; a_basal3(21,:)];
a_pyr = [a_pyr; a_pyr(21,:)];
%a_mix2 = [a_mix2; a_mix2(21,:)];

% Create master activity matrix. 
activity = zeros(segments,dataSet,7);
activity(:,:,1) = a_prism1;
activity(:,:,2) = a_prism2;
activity(:,:,3) = a_prism3;
activity(:,:,4) = a_basal1;
activity(:,:,5) = a_basal2;
activity(:,:,6) = a_basal3;
activity(:,:,7) = a_pyr;
%activity(:,:,6) = a_mix2;
activitySum = activity;
activitySum(:,:,7) = a_prism1 + a_prism2 + a_prism3 + a_basal1 + a_basal2 + a_basal3 + a_pyr;
basal_prism = a_prism1 + a_prism2 + a_prism3 + a_basal1 + a_basal2 + a_basal3; %for plotting later