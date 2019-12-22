
InitializeParameters;

% Make directories if they don't exist
if ~exist([pwd filesep 'Data_7SS' num2str(resolution) '_degrees'], 'dir')
    mkdir([pwd filesep 'Data_7SS' num2str(resolution) '_degrees'])
    sprintf('New Directory Data_%s_degrees created.', num2str(resolution));
else
    %warning('Directory already exists.')
end

datapath = [pwd filesep 'Data_7SS' num2str(resolution) '_degrees'];

%% Iterate through VPSC and manage output
% Write output every 5% strain, up to a total of 100% strain (compression)

w = waitbar(0,sprintf('VPSC Progress: %.0f%%',i/length(r(:))*100));
    % Feel free to disable, there are some bugs with the waitbars.
    % Unimportant. 

% Loop over loading directions
for i = 1:length(r(:))
%use this loop instead if you need to re-run a subset of indicies:
%for i = start_index:end_index

    %Change working directory to folder containing VPSC dependencies
    OriginalFolder = cd([pwd filesep 'VPSC']);
    
    % Write the rotation matrix and and inverse rotation matrix files
    WriteRot(rot(i),pwd,'rotmatrix.txt');
    WriteRot(rot2(i),pwd,'rotmatrixINV.txt');
    
    % Run VPSC
    [status, results] = dos('vpsc_7SS.exe','-echo');
    
    % Handle VPSC Erros
    if status~=0
        status
        fclose all
        error('VPSC failed to run successfully')
    end
    

    
    %% Manage files
    
    mkdir([datapath filesep 'Rot_' num2str(i)])
    
    % texture files
    movefile(fullfile(pwd,'TEX_PH1.OUT'),fullfile(datapath,['Rot_' num2str(i)],['TEX_PH1_.OUT']));
    movefile(fullfile(pwd,'TEX_PH2.OUT'),fullfile(datapath,['Rot_' num2str(i)],['TEX_PH2_.OUT']));
    % rotation file
    movefile(fullfile(pwd,'rotmatrix.txt'),fullfile(datapath,['Rot_' num2str(i)],['rotmatrix.txt']));
    movefile(fullfile(pwd,'rotmatrixINV.txt'),fullfile(datapath,['Rot_' num2str(i)],['rotmatrixINV.txt']));
    % slip activity
    movefile(fullfile(pwd,'ACT_PH1.OUT'),fullfile(datapath,['Rot_' num2str(i)],['ACT_PH1.OUT']));
    movefile(fullfile(pwd,'ACT_PH2.OUT'),fullfile(datapath,['Rot_' num2str(i)],['ACT_PH2.OUT']));
    %str
    movefile(fullfile(pwd,'STR_STR.OUT'),fullfile(datapath,['Rot_' num2str(i)],['STR_STR.OUT']));
    
    %% Change Back to Original Working Directory
    
    waitbar(i/length(r(:)),w,sprintf('Data Parse Progress: %.0f%%',i/length(r(:))*100));
    
    cd(OriginalFolder);
            
end

close(w);