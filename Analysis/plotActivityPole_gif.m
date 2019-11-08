%% Plot Activity across orientations
% First section lets us plot activy projection plots at any single strain 
% step. Next, gifs are generated which run through every strain step. This
% is done for all the slip systems, as well as for basal + prism, the sum
% of all prism and basal system activities. 

%which strain step are we running the single strain step plots?
strainStep = 22;

%plot single strain step graphs
%% Prism 1

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_prism1(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('prism1')

saveas(gcf,[fn 'Prism_1' '.png'])
close

%% Prism 3

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_prism3(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('prism3')

saveas(gcf,[fn 'Prism_3' '.png'])
close

%% Basal 1

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_basal1(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('basal1')

saveas(gcf,[fn 'Basal_1' '.png'])
close

%% Basal 3

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_basal3(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('basal3')

saveas(gcf,[fn 'Basal_3' '.png'])
close

%% Mix

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_mix2(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('mix')

saveas(gcf,[fn 'Mix' '.png'])
close

%% Pyramidal

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,a_pyr(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('pyr')

saveas(gcf,[fn 'Pyramidal' '.png'])
close

%% Basal + Prismatic

fn = [graphpath filesep 'SlipActivity' filesep];

figure
contourf(r,basal_prism(strainStep,:))
colorbar
mtexColorMap black2white
caxis([0,1])
title('Basal + Prism')

saveas(gcf,[fn 'Basal_Prismatic' '.png'])
close

%%
% figure
% contourf(r,squeeze(activitySum(22,:,7)))
% title('SUM')

%% Generate gifs for strain evolution

fn = [graphpath filesep 'SlipActivity' filesep];

%prism 1
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'visible', 'off');
    filename = [fn 'prism1Activity_strain.gif'];
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'prism3Activity_strain.gif'];
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'basal1Activity_strain.gif'];
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'basal3Activity_strain.gif'];
    contourf(r,a_prism1(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'pyrActivity_strain.gif'];
    contourf(r,a_pyr(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'mix2Activity_strain.gif'];
    contourf(r,a_mix2(i,:))
    colorbar
    mtexColorMap black2white
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
    filename = [fn 'allBasalPrismActivity_strain.gif'];
    contourf(r,basal_prism(i,:))
    colorbar
    mtexColorMap black2white
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