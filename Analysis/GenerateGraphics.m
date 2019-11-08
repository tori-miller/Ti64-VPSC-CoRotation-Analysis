%% Variables

MaxMisoScale = 40;
thresh = 20;

%% Create New Directories If Necessary

datapath = [pwd filesep 'Data_' num2str(resolution) '_degrees'];

if ~exist([datapath filesep 'Graphics'], 'dir')
    mkdir([datapath filesep 'Graphics'])
    graphpath = [datapath filesep 'Graphics'];
    mkdir([graphpath filesep 'AlphaAlpha'])
    mkdir([graphpath filesep 'AlphaBeta'])
    mkdir([graphpath filesep 'BetaBeta'])
    mkdir([graphpath filesep 'Binning'])
    mkdir([graphpath filesep 'SlipActivity'])
    sprintf('New Directory Graphics created.');
else
    graphpath = [datapath filesep 'Graphics'];
end

%% Prepare Quaternion Variables
%Calculates quaternion of rotation from ori_x0 to orix(i,j)

QuaternionColor;

%% Alpha-Alpha Strain = 1 

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
contourf(r,adiv(:,segments-1))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'AlphaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
contourf(r,adiv(:,segments))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'AlphaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Strain Gif

fn = [graphpath filesep 'AlphaAlpha' filesep];

h = figure;
for j = 1:segments-1
    contourf(r,adiv(:,j))
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap blue2red
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'AlphaMisorientationVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 

    
end
close

%% Alpha-Alpha Quaternion Strain = 1

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
rgb = squeeze(oMa.orientation2color(aMori(:,segments-1)));
plot(r, rgb);
saveas(gcf,[fn 'AlphaQuaternionStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Quaternion Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
rgb = squeeze(oMa.orientation2color(aMori(:,segments)));
plot(r, rgb);
saveas(gcf,[fn 'AlphaQuaternionStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Quaternion Gif

fn = [graphpath filesep 'AlphaAlpha' filesep];

h = figure;
for j = 1:segments-1
    
    rgb = squeeze(oMa.orientation2color(aMori(:,j)));
    plot(r, rgb);
    text(-1.5,-1.5, num2str((j-1)*0.05));
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'AlphaQuaternionVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 

end
close

%% Alpha-Alpha Quaternion Key
fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
plot(oMa)
saveas(gcf,[fn 'AlphaQuaternionKey' '.png'])
close

%% Beta-Beta Strain = 1

fn = [graphpath filesep 'BetaBeta' filesep];

figure
contourf(r,bdiv(:,segments-1))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'BetaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Strain = 1 End Rotation

fn = [graphpath filesep 'BetaBeta' filesep];

figure
contourf(r,bdiv(:,segments))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'BetaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Strain Gif

fn = [graphpath filesep 'BetaBeta' filesep];

h = figure;
for j = 1:segments-1
    contourf(r,bdiv(:,j))
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap blue2red
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'BetaMisorientationVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    
end
close

%% Beta-Beta Quaternion Strain = 1

fn = [graphpath filesep 'BetaBeta' filesep];

figure
rgb = squeeze(oMb.orientation2color(bMori(:,segments-1)));
plot(r, rgb);
saveas(gcf,[fn 'BetaQuaternionStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Quaternion Strain = 1 End Rotation

fn = [graphpath filesep 'BetaBeta' filesep];

figure
rgb = squeeze(oMb.orientation2color(bMori(:,segments)));
plot(r, rgb);
saveas(gcf,[fn 'BetaQuaternionStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Quaternion Gif

fn = [graphpath filesep 'BetaBeta' filesep];

h = figure;
for j = 1:segments-1
    
    rgb = squeeze(oMb.orientation2color(bMori(:,j)));
    plot(r, rgb);
    text(-1.5,-1.5, num2str((j-1)*0.05));
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'BetaQuaternionVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 

end
close

%% Beta-Beta Quaternion Key
fn = [graphpath filesep 'BetaBeta' filesep];

figure
plot(oMb)
saveas(gcf,[fn 'BetaQuaternionKey' '.png'])
close

%% Alpha-Beta Misorientation at Strain = 1

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
contourf(r,mangle(:,segments-1))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'AlphaBetaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Misorientation at Strain = 1 EndRotation

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
contourf(r,mangle(:,segments))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'AlphaBetaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Misorientation Gif

fn = [graphpath filesep 'AlphaBeta' filesep];

h = figure;
for j = 1:segments-1
    contourf(r,mangle(:,j))
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap blue2red
   
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'AlphaBetaMisorientationVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    
end
close

%% Alpha-Beta Persistent Maximum Misorientation Strain = 1

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
contourf(r,maxmangleplot(:,segments-1))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'MaximumPersistentMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Persistent Maximum Misorientation Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
contourf(r,maxmangleplot(:,segments))
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap blue2red
saveas(gcf,[fn 'MaximumPersistentMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Persistent Maximum Misorientation Gif

fn = [graphpath filesep 'AlphaBeta' filesep];

h = figure;
for j = 1:segments-1
    contourf(r,maxmangleplot(:,j))
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap blue2red
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'MaximumPersistentMisorientationVStrain_' num2str(resolution) '_degrees' '.gif'];
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
    end 
    
end
close

%% Slip Activity Plots

plotActivityPole_gif;

%% Binning Plots

conditions123;
