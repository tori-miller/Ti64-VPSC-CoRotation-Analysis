%% Activity Matrix Clean Up
% remove every other row to line up with orientation data
a_prism1(2:2:41,:) = [];
a_prism3(2:2:41,:) = [];
a_basal1(2:2:41,:) = [];
a_basal3(2:2:41,:) = [];
a_pyr(2:2:41,:) = [];
a_mix2(2:2:41,:) = [];
% add duplicate to last row for strain step #22, still at strain of 1
a_prism1 = [a_prism1; a_prism1(21,:)];
a_prism3 = [a_prism3; a_prism3(21,:)];
a_basal1 = [a_basal1; a_basal1(21,:)];
a_basal3 = [a_basal3; a_basal3(21,:)];
a_pyr = [a_pyr; a_pyr(21,:)];
a_mix2 = [a_mix2; a_mix2(21,:)];

% Create master activity matrix. 
activity(:,:,1) = a_prism1;
activity(:,:,2) = a_prism3;
activity(:,:,3) = a_basal1;
activity(:,:,4) = a_basal3;
activity(:,:,5) = a_pyr;
activity(:,:,6) = a_mix2;
activitySum = activity;
activitySum(:,:,7) = a_prism1 + a_prism3 + a_basal1 + a_basal3 + a_pyr + a_mix2;
basal_prism = a_prism1+a_prism3+a_basal1+a_basal3+a_mix2; %for plotting later