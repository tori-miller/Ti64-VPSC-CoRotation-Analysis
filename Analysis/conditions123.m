%% Threshold by Condition. Use midpoint to bin high vs low. 
% This is less about thresholds per se and more about binning the angles
% for overlay comparison. The threshold I'm using here is 20 - half the 
% maximum misorientation value. Arbitraty? yes. I figured half way was as
% reasonable as it would get for a first pass high/low binning without data to inform us.
% Distributions of the misorientations may be more useful for more in depth
% attempts. 

%No need to choose only 20, let's do all of them!
%threshold = 20;

% parameterize the strain step for all these plots. All this could be done
% for every strain step and turned into a gif, but in the interest of 
%processing time and targeting the data we want this is better. 
strainStep = 22; 

%% Define a few custom color maps

white2red = customcolormap([0 0.5 1], {'#ff0000', '#ffffff', '#ffffff'});

white2ltgrey = customcolormap([0 0.5 1], {'#d3d3d3','#ffffff', '#ffffff'});

white2dkgrey = customcolormap([0 0.5 1], {'#696969', '#ffffff', '#ffffff'});

%% Define high region of all three misorientation matrices - adiv, bdiv, and mangle. Then bin according to conditions 1,2, and 3
% A lot goes on in this loop, but its better than 4 individual loops doing
% the same thing. These first define a new matrix where any angle less than
% 20 is made 0. Then, using the logical form of that matrix we sort each 
% orientation into a condition based on the relationship between angles of 
% alpha, beta, and mangle.
% Using true data values for the high part allows us to get
% both intensity and regional meaning out of overlaying these plots.


%% Plot the individual contours for adivHigh, bdivHigh, and mangleHigh
% I use white2red which I made up. It is white until the midpoint at 20 which makes a cool heat map
% effect which will also be convenient for overlay work. Any colormap could be used. 
% plot adivHigh
% figure
% contourf(r,adivHigh, 'linestyle', 'none');
% caxis([0,40])
% colorbar
% colormap(white2red)
% % plot bdivHigh
% figure
% contourf(r,bdivHigh, 'linestyle', 'none')
% caxis([0,40])
% colorbar
% colormap(white2red)
% % plot mangleHigh
% figure
% contourf(r,mangleHigh, 'linestyle', 'none');
% caxis([0,40])
% colorbar
% colormap(white2red)

%% Now, lets plot conditions.

fn = [graphpath filesep 'Binning' filesep];

for threshold = 5:5:40
    
    %initialize matrices
    adivHighLogic = adiv(:,strainStep)>threshold;
    bdivHighLogic = bdiv(:,strainStep)>threshold;
    mangleHighLogic = mangle(:,strainStep)>threshold;
    adivHigh = zeros(1,dataSet);
    bdivHigh = zeros(1,dataSet);
    mangleHigh = zeros(1,dataSet);
    cond1 = zeros(1,dataSet);
    cond2 = zeros(1,dataSet);
    cond3 = zeros(1,dataSet);
    
    for j = 1:1:dataSet
        % alpha self-rotation
        if adivHighLogic(j)
            adivHigh(j) = adiv(j,strainStep);
        else
            adivHigh(j) = 0;
        end
        % beta self-rotation
        if bdivHighLogic(j)
            bdivHigh(j) = bdiv(j,strainStep);
        else
            bdivHigh(j) = 0;
        end
        % alpha-beta corotation
        if mangleHighLogic(j)
            mangleHigh(j) = mangle(j,strainStep);
        else
            mangleHigh(j) = 0;
        end
    
        %bin into conditions 1, 2, or 3. The values will make a contour plot
        %possible later. 
        if mangleHighLogic(j) % at present no differentiation for beta&&mangle or alpha&&mangle or all three
            cond1(j) = 1; 
        elseif adivHighLogic(j) && bdivHighLogic(j) % if both rotated a lot but misorentation is low
            cond2(j) = 2;
        else % if neither rotated much, and misorientation is low
            cond3(j) = 3;
        end
    end
    
    % condition 1
    figure
    contourf(r,cond1, 'linestyle', 'none');
    caxis([.999,1])% weird numbers because filled contours dont like having a single level
    %colorbar
    colormap(white2red)
    export_fig([fn 'Condition1_Threshold_' num2str(threshold)], '-tiff', '-m4', '-rgb')
    close
    
    % condition 2
    figure
    contourf(r,cond2, 'linestyle', 'none');
    caxis([1.999,2])% weird numbers because filled contours dont like having a single level
    %colorbar
    colormap(white2ltgrey)
    export_fig([fn 'Condition2_Threshold_' num2str(threshold)], '-tiff', '-m4', '-rgb')
    close
    
    % condition3
    figure
    contourf(r,cond3, 'linestyle', 'none');
    caxis([2.999,3]) % weird numbers because filled contours dont like having a single level
    %colorbar
    colormap(white2dkgrey)
    export_fig([fn 'Condition3_Threshold_' num2str(threshold)], '-tiff', '-m4', '-rgb')
    close
    
end

%% Create Binning GIF

fn = [graphpath filesep 'Binning' filesep];

if exist([fn 'BinningThreshold' '.tif'], 'file')==2
  delete([fn 'BinningThreshold' '.tif']);
end

for i = 5:5:40

con1 = imread([fn 'Condition1_Threshold_' num2str(i) '.tif']);
con2 = imread([fn 'Condition2_Threshold_' num2str(i) '.tif']);
con3 = imread([fn 'Condition3_Threshold_' num2str(i) '.tif']);

con12 = imblend(con1, con2, 1, 'multiply');
con123 = imblend(con12, con3, 1, 'multiply');

if numel(size(con123))<3
    con123 = cat(3, con123, con123, con123);
end

imshow(con123);

export_fig([fn 'Condition123_Threshold_' num2str(i)], '-tiff', '-native')

text(50,1800, [num2str(i) ' degrees']);
export_fig([fn 'BinningThreshold'], '-tiff', '-native', '-append');
close
end

infile = [fn 'BinningThreshold' '.tif'];
outfile = [fn 'BinningThreshold' '.gif'];
im2gif( infile, outfile, '-delay', 0.5);
