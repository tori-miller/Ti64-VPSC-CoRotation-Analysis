%% Make a gif for each slip system representing the change in activity with increasing strain. Make a combined plot first. 
% under construction

%% combined
w = waitbar(0);
for i = 1:21
    h = figure;
    set(h, 'Visible', 'off');
    filename = 'ActivityVsStrain_Combined.gif';
    plot(1:1:dataSet,squeeze(activitySum(i,:,:)));
    title('Combined Activity vs Strain Steps');
    caxis([0 0.5]);
    legend('a_prism1','a_prism3','a_basal1','a_basal3','a_pyr','a_mix2','SUM');
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
    waitbar(i/21, w, sprintf('Progress: %.0f%%',i/21*100) );
end
close(w);
%% by Orientation
% w = waitbar(0);
% for i = 1:dataSet
%     h = figure;
%     set(h, 'Visible', 'off');
%     filename = 'ActivityVsOrientation_Combined.gif';
%     plot(1:1:21,squeeze(activitySum(:,i,:)));
%     title('Combined Activity vs Orientation');
%     caxis([0 0.5]);
%     legend('a_prism1','a_prism3','a_basal1','a_basal3','a_pyr','a_mix2','SUM');
%     drawnow;
%     frame = getframe(h);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     
%     if i==1
%         imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
%     else
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
%     end
%     
%     close(h);
%     waitbar(i/915, w, sprintf('Progress: %.0f%%',i/915*100) );
% end
% close(w);
%% Individual
for i = 1:21
    h = figure;
    filename = 'BasalAlpha1.gif';
    contourf(r,SFBasA1(:,i))
    title('Alpha Basal 1 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'BasalAlpha2.gif';
    contourf(r,SFBasA2(:,i))
    title('Alpha Basal 2 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'BasalAlpha3.gif';
    contourf(r,SFBasA3(:,i))
    title('Alpha Basal 3 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'PrismAlpha1.gif';
    contourf(r,SFPrisA1(:,i))
    title('Alpha Prismatic 1 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'PrismAlpha2.gif';
    contourf(r,SFPrisA2(:,i))
    title('Alpha Prismatic 2 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'PrismAlpha3.gif';
    contourf(r,SFPrisA3(:,i))
    title('Alpha Prismatic 3 Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end

for i = 1:21
    h = figure;
    filename = 'PyramidAlpha.gif';
    contourf(r,SFPyrA(:,i))
    title('Alpha Pyramidal <c+a> Schmid Factor')
    caxis([0 0.5])
    colorbar
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    if i==1
        imwrite(imind,cm,filename,'gif','LoopCount',Inf,'DelayTime',0.25);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.25);
    end
    
    close(h)
end