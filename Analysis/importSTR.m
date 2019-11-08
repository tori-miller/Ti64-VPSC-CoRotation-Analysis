%% Function to import stress-strain data

function [strain, stress]=importSTR(pname)

data = importdata([pname '\STR_STR.OUT']);

strain = data.data(:,1);
stress = data.data(:,2);

