%% Calculates quaternion of rotation from ori_x0 to orix(i,j)

clear i;
w = waitbar(0,sprintf('Calculating Quaternion Misorientation: %.0f%%',i/length(r(:))*100));

for i = 1:length(r(:))
    for j = 1:segments
        
        if j == segments
            aMori(i,j) = inv(ori_a0) * oria(i,j);
            bMori(i,j) = inv(ori_b0) * orib(i,j);
        else
            aMori(i,j) = inv(ori_a0) * (rot(i)*oria(i,j));
            bMori(i,j) = inv(ori_b0) * (rot(i)*orib(i,j));
        end
    end
    
    waitbar(i/length(r(:)),w,sprintf('Calculating Quaternion Misorientation: %.0f%%',i/length(r(:))*100));
    
end

close(w);

%%

% Color Key for Quaternion Figure
oMa = PatalaColorKey(aMori);
oMb = PatalaColorKey(bMori);


% Color Key for Axis Only Figure

    %fix the symmetry
    aMori.CS = aMori.CS.Laue;

oMa_ao = ipfHSVKey(aMori);
oMb_ao = ipfHSVKey(bMori);

% figure
% plot(oMa_ao)
% figure
% plot(oMb_ao)
