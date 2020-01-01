%% Variables

MaxMisoScale = 40;
thresh = 20;

%% Create New Directories If Necessary

datapath = [pwd filesep 'Data_7SS' num2str(resolution) '_degrees'];

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



figure;
%contourf(r,adiv(:,segments-1))
plot(r, adiv(:, segments-1),'smooth')
% hold
% h=plot(r, adiv(:, segments-1),'contour',0:20:20,'linewidth',2,'linecolor','k')
% hold off
% clabel(h.ContourMatrix,h,20,'FontSize',15)
setColorRange([0 MaxMisoScale])
colorbar
colormap(white2blue)
saveas(gcf,[fn 'AlphaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
%contour(r,adiv(:,segments))
plot(r, adiv(:, segments),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
colormap(white2blue)
saveas(gcf,[fn 'AlphaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Strain Gif

fn = [graphpath filesep 'AlphaAlpha' filesep];

h = figure;
for j = 1:segments-1
    %contour(r,adiv(:,j))
    plot(r, adiv(:, j),'smooth')
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    colormap(white2blue)
    
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

figure
rgb = squeeze(oMa_ao.Miller2Color(aMori(:,segments-1).axis));
plot(r, rgb);
saveas(gcf,[fn 'AlphaAxisOnlyStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Alpha Quaternion Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaAlpha' filesep];

figure
rgb = squeeze(oMa.orientation2color(aMori(:,segments)));
plot(r, rgb);
saveas(gcf,[fn 'AlphaQuaternionStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

figure
rgb = squeeze(oMa_ao.Miller2Color(aMori(:,segments).axis));
plot(r, rgb);
saveas(gcf,[fn 'AlphaAxisOnlyStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
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

h = figure;
for j = 1:segments-1
    
    rgb = squeeze(oMa_ao.Miller2Color(aMori(:,j).axis));
    plot(r, rgb);
    text(-1.5,-1.5, num2str((j-1)*0.05));
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'AlphaAxisOnlyVStrain_' num2str(resolution) '_degrees' '.gif'];
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

figure
plot(oMa_ao)
saveas(gcf,[fn 'AlphaAxisOnlyKey' '.png'])
close

%% Beta-Beta Strain = 1

fn = [graphpath filesep 'BetaBeta' filesep];

figure
%contour(r,bdiv(:,segments-1))
plot(r, bdiv(:, segments-1),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
colormap(white2red)
saveas(gcf,[fn 'BetaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Strain = 1 End Rotation

fn = [graphpath filesep 'BetaBeta' filesep];

figure
%contour(r,bdiv(:,segments))
plot(r, bdiv(:, segments),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
colormap(white2red)
saveas(gcf,[fn 'BetaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Strain Gif

fn = [graphpath filesep 'BetaBeta' filesep];

h = figure;
for j = 1:segments-1
    %contour(r,bdiv(:,j))
    plot(r, bdiv(:, j),'smooth')
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    colormap(white2red)
    
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

figure
rgb = squeeze(oMb_ao.Miller2Color(bMori(:,segments-1).axis));
plot(r, rgb);
saveas(gcf,[fn 'BetaAxisOnlyStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Beta-Beta Quaternion Strain = 1 End Rotation

fn = [graphpath filesep 'BetaBeta' filesep];

figure
rgb = squeeze(oMb.orientation2color(bMori(:,segments)));
plot(r, rgb);
saveas(gcf,[fn 'BetaQuaternionStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

figure
rgb = squeeze(oMb_ao.Miller2Color(bMori(:,segments).axis));
plot(r, rgb);
saveas(gcf,[fn 'BetaAxisOnlyStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
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

h = figure;
for j = 1:segments-1
    
    rgb = squeeze(oMb_ao.Miller2Color(bMori(:,j).axis));
    plot(r, rgb);
    text(-1.5,-1.5, num2str((j-1)*0.05));
    
    % Capture the plot as an image 
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    % Write to the GIF File 
    if j == 1 
          filename = [fn 'BetaAxisOnlyVStrain_' num2str(resolution) '_degrees' '.gif'];
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

figure
plot(oMb_ao)
saveas(gcf,[fn 'BetaQuaternionKey' '.png'])
close

%% Alpha-Beta Misorientation at Strain = 1

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
%contourf(r,mangle(:,segments-1))
plot(r, mangle(:, segments-1),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap parula
saveas(gcf,[fn 'AlphaBetaMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Misorientation at Strain = 1 EndRotation

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
%contourf(r,mangle(:,segments))
plot(r, mangle(:, segments),'smooth')
hold
h=plot(r, mangle(:, segments-1),'contour',0:20:20,'linewidth',2,'linecolor','k')
hold off
% clabel(h.ContourMatrix,h,20,'FontSize',25)
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap parula
saveas(gcf,[fn 'AlphaBetaMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Misorientation Gif

fn = [graphpath filesep 'AlphaBeta' filesep];

h = figure;
for j = 1:segments-1
    %contourf(r,mangle(:,j))
    plot(r, mangle(:, j),'smooth')
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap parula
   
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
%contourf(r,maxmangleplot(:,segments-1))
plot(r, maxmangleplot(:, segments-1),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap parula
saveas(gcf,[fn 'MaximumPersistentMisorientationStrain1_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Persistent Maximum Misorientation Strain = 1 End Rotation

fn = [graphpath filesep 'AlphaBeta' filesep];

figure
%contourf(r,maxmangleplot(:,segments))
plot(r, maxmangleplot(:, segments),'smooth')
setColorRange([0 MaxMisoScale])
colorbar
mtexColorMap parula
saveas(gcf,[fn 'MaximumPersistentMisorientationStrain1_EndRotation_' num2str(resolution) '_degrees' '.png'])
close

%% Alpha-Beta Persistent Maximum Misorientation Gif

fn = [graphpath filesep 'AlphaBeta' filesep];

h = figure;
for j = 1:segments-1
    %contourf(r,maxmangleplot(:,j))
    plot(r, maxmangleplot(:, j),'smooth')
    text(-1.5,-1.5, num2str((j-1)*0.05));
    setColorRange([0 MaxMisoScale])
    colorbar
    mtexColorMap parula
    
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
