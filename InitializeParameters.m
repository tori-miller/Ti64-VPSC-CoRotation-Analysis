%% Set Crystal Symmetries for alpha and beta phases

CSa = crystalSymmetry('622', [2.95 2.95 4.68], 'X||a', 'Y||b*', 'Z||c', 'color', 'light blue');
CSb = crystalSymmetry('432', [3.24 3.24 3.24], 'mineral', 'Titanium - Beta', 'color', 'light green');

SS = specimenSymmetry('-1');

%Preset Starting Orientation
ori_a0 = orientation('Euler',135*degree,90*degree,325*degree,CSa);
ori_b0 = orientation('Euler',0*degree,0*degree,0*degree,CSb);

% Number of strain states in str_str file
segments = 22;

%If ODF is used instead of deterministic approach
%psi = deLaValeePoussinKernel('halfwidth',5*degree);

%% Generate all loading directions
% In reality, what I am doing is generating rotation matrices to be applied
% to the initial orientation, *not* actually generating a bunch of loading
% directions. 

%Set number of degrees between each data point in hemisphere.
% 333 rotations  = 10
% 915 rotations  = 6
% 1387 rotations = 5
% 2093 rotations = 4

resolution = 90; %degrees

r = plotS2Grid('resolution',resolution*degree,'upper');

rot  = rotation('map',zvector,r);
rot2 = rotation('map',r,zvector);

dataSet = length(r(:));

%% Initialize matrices to run faster later
a_prism1 = zeros(41,dataSet);
a_prism3 = zeros(41,dataSet);
a_basal1 = zeros(41,dataSet);
a_basal3 = zeros(41,dataSet);
a_pyr = zeros(41,dataSet);
a_mix2 = zeros(41,dataSet);
activity = zeros(segments,dataSet,6);

%% Add Dependency Folders to Matlab Path
% Path addition with addpath only adds to the pathe for the cyrrent Matlab
% session.

addpath(genpath([pwd filesep 'Analysis']));
addpath(genpath([pwd filesep 'ExternalTools']));