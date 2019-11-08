%% Data import

%loop over each loading direction (VPSC run folder)
clear i;
w = waitbar(0,sprintf('Partitioning VPSC Texture Files: %.0f%%',i/length(r(:))*100));


for i = 1:length(r(:))
%for i = start_index:end_index
    
    pname = [pwd filesep 'Data_' num2str(resolution) '_degrees' filesep 'Rot_' num2str(i)];
    
    partitionVPSCtexture(pname, 1);
    partitionVPSCtexture(pname, 2);
    
    %read deformation mode activity 
    %Syntax: slip_act(loading direction, segments, modes)
    %act(i,:,:) = importACT_TiAni(pname, 1);
    
    % read deformation mode activity for each strain step, add to matrix
    [activity_t,a_prism1_t,a_mix2_t,a_prism3_t,a_basal1_t,a_basal3_t,a_pyr_t] = importACT_TiAni(pname,1);
    a_prism1(:,i) = a_prism1_t;
    a_prism3(:,i) = a_prism3_t;
    a_basal1(:,i) = a_basal1_t;
    a_basal3(:,i) = a_basal3_t;
    a_mix2(:,i) = a_mix2_t;
    a_pyr(:,i) = a_pyr_t;
    
    [strain,stress(i,:)] = importSTR(pname);
    
    waitbar(i/length(r(:)),w,sprintf('Partitioning VPSC Texture Files: %.0f%%',i/length(r(:))*100));
       
end

close(w);

%% Data processing: divergence from angle

clear i;
w = waitbar(0,sprintf('Reading Euler Angles: %.0f%%',i/length(r(:))*100));

%for i = 1:2
for i = 1:length(r(:))
    for j = 1:segments

        fname_a = [pwd filesep 'Data_' num2str(resolution) '_degrees' filesep 'Rot_' num2str(i) filesep 'TEX_PH1_SEG' num2str(j) '.OUT'];
        fname_b = [pwd filesep 'Data_' num2str(resolution) '_degrees' filesep 'Rot_' num2str(i) filesep 'TEX_PH2_SEG' num2str(j) '.OUT'];

        % This section was the old way to find the orientation. Disregard. 
                % calc ODF for each phase
                %odf_a = loadODF(fname_a,CSa,SS,'density','kernel',psi,'resolution',5*degree,'interface','VPSC');
                %odf_b = loadODF(fname_b,CSb,SS,'density','kernel',psi,'resolution',5*degree,'interface','VPSC');

                % find max peak in each
                %[ma,oria(i,j)] = max(odf_a);
                %[mb,orib(i,j)] = max(odf_b);
                
        % Read the first orientation in each file
        fID = fopen(fname_a);
        % skip the header (first 4 lines)
        tline = fgetl(fID);
        tline = fgetl(fID);
        tline = fgetl(fID);
        tline = fgetl(fID);
        
        tline = fgetl(fID);
        temp = sscanf(tline, '%f %f %f %*f');
        oria(i,j) = orientation('Euler',temp(1)*degree,temp(2)*degree,temp(3)*degree,CSa,SS);
        fclose(fID);
        
        fID = fopen(fname_b);
        tline = fgetl(fID);
        tline = fgetl(fID);
        tline = fgetl(fID);
        tline = fgetl(fID);
        
        tline = fgetl(fID);
        temp = sscanf(tline, '%f %f %f %*f');
        orib(i,j) = orientation('Euler',temp(1)*degree,temp(2)*degree,temp(3)*degree,CSb,SS);
        fclose(fID);

        % find angle between max peaks
        a(i,j) = angle(oria(i,j),orib(i,j));
        
    end
    
    waitbar(i/length(r(:)),w,sprintf('Reading Euler Angles: %.0f%%',i/length(r(:))*100));
    
end

close(w);
