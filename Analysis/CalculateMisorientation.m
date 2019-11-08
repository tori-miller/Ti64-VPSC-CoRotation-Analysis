%% Calculate angles between original and final orientations for each phase

clear i;
w = waitbar(0,sprintf('Calculating Individual Misorientation: %.0f%%',i/length(r(:))*100));

for i = 1:length(r(:))
    for j = 1:segments
        
        if j == segments
            adiv(i,j) = angle(oria(i,j),ori_a0) * (180/pi);
            bdiv(i,j) = angle(orib(i,j),ori_b0) * (180/pi);

        else
            % Note that this is rot NOT ROT2 because of a difference in
            % convention between VPSC and MTEX on active vs passive
            % rotations. 
            adiv(i,j) = angle( (rot(i)*oria(i,j)),ori_a0) * (180/pi); 
            bdiv(i,j) = angle((rot(i)*orib(i,j)),ori_b0) * (180/pi);
        end

        % This one I could correct, but it 100% does not matter. 
        a(i,j) = angle(oria(i,j),orib(i,j));
        
    end
    
    waitbar(i/length(r(:)),w,sprintf('Calculating Individual Misorientation: %.0f%%',i/length(r(:))*100));
    
end

close(w);

%% Calculates misorientation between final phase orientations, then calculates angle

clear i;
w = waitbar(0,sprintf('Calculating Total Misorientation: %.0f%%',i/length(r(:))*100));

mori_0 = inv(ori_a0) * ori_b0;

for i = 1:length(r(:))
    for j = 1:segments
        if j == segments
            mori(i,j) = inv(oria(i,j)) * orib(i,j);
            mangle(i,j) = angle(mori(i,j), mori_0) ./ degree;
        else
            mori(i,j) = inv(rot(i)*oria(i,j)) * (rot(i)*orib(i,j));
            mangle(i,j) = angle(mori(i,j), mori_0) ./ degree;
        end
    end
    
    waitbar(i/length(r(:)),w,sprintf('Calculating Total Misorientation: %.0f%%',i/length(r(:))*100));
    
end

close(w);

%% Prepare Persistent Maximum Misorientation Variables

clear i;
w = waitbar(0,sprintf('Calculating Maximum Misorientation: %.0f%%',i/length(r(:))*100));

for i = 1:length(r)
    [M, I] = max(mangle(i,:));
    maxmangle(i,1)= M;
    maxmangle(i,2)= I;
end

for i = 1:length(r)
    for j = 1:segments
        if (maxmangle(i,1) > mangle(i,j) & maxmangle(i,2) < j)
            maxmangleplot(i,j) = maxmangle(i,1);
        else
            maxmangleplot(i,j) = mangle(i,j);
        end
    end
    
    waitbar(i/length(r(:)),w,sprintf('Calculating Maximum Misorientation: %.0f%%',i/length(r(:))*100));
    
end

close(w);
