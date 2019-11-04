%% Plot Activity across orientations
% First section lets us plot activy projection plots at any single strain 
% step. Next, gifs are generated which run through every strain step. This
% is done for all the slip systems, as well as for basal + prism, the sum
% of all prism and basal system activities. 

%which strain step are we running the single strain step plots?
strainStep = 22;

%plot single strain step graphs
figure
contourf(r,a_prism1(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('prism1')

figure
contourf(r,a_prism3(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('prism3')

figure
contourf(r,a_basal1(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('basal1')

figure
contourf(r,a_basal3(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('basal3')

figure
contourf(r,a_mix2(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('mix')

figure
contourf(r,a_pyr(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('pyr')

figure
contourf(r,basal_prism(strainStep,:))
colorbar
mtexColorMap blue2red
caxis([0,1])
title('Basal + Prism')

% figure
% contourf(r,squeeze(activitySum(22,:,7)))
% title('SUM')

%% Generate gifs for strain evolution

%prism 1
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'prism1Activity_strain.gif';
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Prism 1 Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Prism 1 Progress: %.0f%%',i/21*100) );
end
close(w);

% prism3
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'prism3Activity_strain.gif';
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Prism 3 Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Prism 3 Progress: %.0f%%',i/21*100) );
end
close(w);
% basal1
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'basal1Activity_strain.gif';
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Basal 1 Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Basal 1 Progress: %.0f%%',i/21*100) );
end
close(w);
% basal3
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'basal3Activity_strain.gif';
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Basal 3 Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Basal 3 Progress: %.0f%%',i/21*100) );
end
close(w);
% pyr
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'pyrActivity_strain.gif';
    contourf(r,a_pyr(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Pyramidal Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Pyramidal Progress: %.0f%%',i/21*100) );
end
close(w);
% mix2 
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'mix2Activity_strain.gif';
    contourf(r,a_mix2(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Basal and Prism 2 Mixed Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Basal and Prism 2 Mixed Progress: %.0f%%',i/21*100) );
end
close(w);

%% Sum of all Basal and Prism 
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = 'allBasalPrismActivity_strain.gif';
    contourf(r,basal_prism(i,:))
    colorbar
    mtexColorMap blue2red
    caxis([0,1])
    title(sprintf('Sum of all Basal and Prism Activity at Strain %.0f',i),'visible', 'on');
    set(h, 'visible', 'off');
    drawnow;
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h);
    waitbar(i/21, w, sprintf('Basal and Prism SumProgress: %.0f%%',i/21*100) );
end
close(w);