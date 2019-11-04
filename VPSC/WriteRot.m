%% Function to write a new rigid rotation file
% Rigid rotation file will be fed to VPSC. 

function [status] = WriteRot(rotation,path,fname)



MatrixOut = matrix(rotation);

fileID = fopen(fullfile(path,fname),'w');

fprintf(fileID,'Rotation Matrix \r\n');
fprintf(fileID, '%f     %f     %f \r\n',MatrixOut);

status = fclose(fileID);

end
