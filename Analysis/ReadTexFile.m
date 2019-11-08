function [Tex_Euler, Axes_Euler, Axes_Aspect, strain] = ReadTexFile(pname, it_start, it_end,phase_index)
% Reads texture and morphology matrices from TEX_PH#.OUT files for each
% step
%  Input:
%   pname: path to texture files for a given point
%   it_start: the first deformation iteration
%   it_end: the final deformation iteration
%   phase_index: VPSC phase number
%  Output: 
%   Tex_Euler: nIter+1 x 3

nIter = it_end - it_start;

% Initialize outputs (except Tex_Euler, because we don't have nGrain yet)
Axes_Euler = zeros(nIter+1,3);
Axes_Aspect = zeros(nIter+1,3);
strain = zeros(nIter+1,1);

% Read the first file outside loop to get appropriate variables
fname = [pname filesep 'TEX_PH' num2str(phase_index) '_SEG' num2str(it_start) '.OUT'];

fID = fopen(fname);

tline = fgetl(fID); %discard line 1
tline = fgetl(fID); %get line 2
Axes_Aspect(1,:) = sscanf(tline, '%f %f %f %*s');
tline = fgetl(fID); %get line 3
Axes_Euler(1,:) = sscanf(tline, '%f %f %f %*s');
tline = fgetl(fID); %get line 4
%nGrain = sscanf(tline, '%*s %u'); %number of grains in file

% Initialize Tex_Euler
Tex_Euler = zeros(nIter+1,3);

% Loop over initial texture
tline = fgetl(fID);
Tex_Euler(1,:) = sscanf(tline, '%f %f %f %*f');


%% Now deal with the data in the actual strained state in the first file

% strain
frewind(fID);
tline = fgetl(fID);
strain(2) = sscanf(tline, '%*s %*s %*s %*s %f');

tline = fgetl(fID); %get line 2
Axes_Aspect(2,:) = sscanf(tline, '%f %f %f %*s');
tline = fgetl(fID); %get line 3
Axes_Euler(2,:) = sscanf(tline, '%f %f %f %*s');
tline = fgetl(fID); %get line 4

tline = fgetl(fID);
Tex_Euler(2,:) = sscanf(tline, '%f %f %f %*f');

fclose(fID);

%% Finally, loop over all of the remaining files and populate the matrices

for i = 2:nIter
    % set up the new file from which to read
    fname = [pname filesep 'TEX_PH' num2str(phase_index) '_SEG' num2str(it_start+i-1) '.OUT'];
    fID = fopen(fname);

    % Discard the data from the previous step (first half of file)
%     for j = 1:nGrain+4
%         tline = fgetl(fID);
%     end
    
    % strain
    tline = fgetl(fID);
    strain(i+1) = sscanf(tline, '%*s %*s %*s %*s %f');

    tline = fgetl(fID); %get line 2
    Axes_Aspect(i+1,:) = sscanf(tline, '%f %f %f %*s');
    tline = fgetl(fID); %get line 3
    Axes_Euler(i+1,:) = sscanf(tline, '%f %f %f %*s');
    tline = fgetl(fID); %get line 4, discard

    tline = fgetl(fID);
    Tex_Euler(i+1,:) = sscanf(tline, '%f %f %f %*f');

    fclose(fID);
    
end

