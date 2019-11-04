%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

From Corotationdataprocessing:

%% Data processing

% syntax: countourf(r,value)

% stress-strain data first:
% at yield
% figure
% contourf(r, stress(:,1))
% mtexColorMap white2black
% colorbar
% 
% figure
% contourf(r,stress(:,end))
% mtexColorMap white2black
% colorbar

% figure(1)
% contourf(r,stress(:,1))
% mtexFig = gcm;
% contourf(r,stress(:,end),mtexFig.nextAxis)
% mtexColorMap white2black
% setColorRange('equal')
% mtexColorbar('multiple')
% 

%%
        % calc difference from oringinal angle. 
        adiff = abs(a - 1.79); %0.79 is the value at strain==0

        adiff = adiff * (180/pi);
        
for j = 1:4:segments
    % contour plots   
    figure
    contourf(r,adiff(:,j))
    colorbar
    mtexColorMap white2black

end
% 
%% Data processing: slip mode activity

% initial
figure


for k = 1:length(r(:))
    hold on
    plot(r(k),'MarkerFaceColor',(1/sum([act(k,1,1) act(k,1,2) act(k,1,3)]))*[act(k,1,1) act(k,1,2) act(k,1,3)],'MarkerSize',5);
    
end

%%

% final
figure


for k = 1:length(r(:))
    hold on
    plot(r(k),'complete','MarkerFaceColor',(1/sum([act(k,41,1) act(k,41,2) act(k,41,3)]))*[act(k,41,1) act(k,41,2) act(k,41,3)],'MarkerSize',5);
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

From Final_Corotation_Processing

%% Plot initial orientations

% figure
% plotPDF(ori_a0,h_a)
% 
% figure
% plotPDF(ori_b0,h_b,'MarkerFaceColor','r')

%%

for j = 2:4:segments
    % contour plots   
    figure
    contourf(r,adiv(:,j))
    colorbar
    mtexColorMap cool
    
    figure
    contourf(r,bdiv(:,j))
    colorbar
    mtexColorMap hot
    

end

%% Calculate and plot the deviation from the ideal alpha beta separation. 

        % calc difference from oringinal angle. 
        adiff = abs(a - 0.7900); %0.79 is the value at strain==0

        adiff = adiff * (180/pi);
        
for j = 2:4:segments
    % contour plots   
    figure
    contourf(r,adiff(:,j))
    colorbar
    mtexColorMap white2black

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

From MisorientationProcessing

%% Plot Alpha Difference From Original
figure
contourf(r,adiv(:,22))
colorbar
mtexColorMap blue2red

%% Plot Beta Difference From Original

figure
contourf(r,bdiv(:,22))
colorbar
mtexColorMap blue2red
%% Plot Alpha Misorientation From Original
figure
contourf(r,mangle(:,22))
colorbar
mtexColorMap blue2red

