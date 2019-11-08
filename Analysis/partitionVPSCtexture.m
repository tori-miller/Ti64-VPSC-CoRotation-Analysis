% Code to break up (single) texture output file into single texture steps
%Only need to give it file name and number of rows in header - it reads the
%number of grains from the file. 
function [segments] = partitionVPSCtexture(pname,phaseID)

% Input the pathname/file name
%pname = 'Z:\Group Resources\Collaborative Projects\Ti64_deformation\Ti64 - loading along TD to 0.05 for VPSC comparison\Ti64_set3_s2_after5pct\MTRneigh';
fname = [pname '\TEX_PH' num2str(phaseID) '_.OUT']; 

nhead = 4; 

if exist([pname '\TEX_PH' num2str(phaseID) '_SEG1.OUT'],'file')~=0 
    % Check file date
    split_info = dir([pname '\TEX_PH' num2str(phaseID) '_SEG1.OUT']);
    whole_info = dir(fname);    
    if split_info.datenum < whole_info.datenum
        % Open the input file and read the header lines
        fin = fopen(fname); 
        for i=1:nhead
            buffer = fgetl(fin);
        end

        %Extract the number of grains from the file
        ngrain = sscanf(buffer,'%*s %g');
        %Calculate the length of each texture segment
        seglength = nhead + ngrain; 

        %Calculate the number of segments
        nrows = numel(textread(fname,'%1c%*[^\n]'));
        segments = nrows/seglength;


        %Return to start of file in preperation for splitting
        frewind(fin);

        %loop over segments
        for ii = 1:segments
            fname_temp = ['\TEX_PH' num2str(phaseID) '_SEG' num2str(ii) '.OUT'];
            fout = fopen([pname fname_temp],'w');
            %Loop over each line in the segment and write to file
           for j=1:seglength
               buffer = fgets(fin);
               fprintf(fout,'%s',buffer);
           end
        end

        fclose('all');
        
    end
else % If it does not exist yet... 
            % Open the input file and read the header lines
        fin = fopen(fname); 
        for i=1:nhead
            buffer = fgetl(fin);
        end

        %Extract the number of grains from the file
        ngrain = sscanf(buffer,'%*s %g');
        %Calculate the length of each texture segment
        seglength = nhead + ngrain; 

        %Calculate the number of segments
        nrows = numel(textread(fname,'%1c%*[^\n]'));
        segments = nrows/seglength;


        %Return to start of file in preperation for splitting
        frewind(fin);

        %loop over segments
        for ii = 1:segments
            fname_temp = ['\TEX_PH' num2str(phaseID) '_SEG' num2str(ii) '.OUT'];
            fout = fopen([pname fname_temp],'w');
            %Loop over each line in the segment and write to file
           for j=1:seglength
               buffer = fgets(fin);
               fprintf(fout,'%s',buffer);
           end
        end

    fclose('all');
end





end