# Ti VPSC CoRotation Analysis

© Victoria M. Miller and Benjamin A. Begley, 2019.

This repository contains the code necessary to run and analyze Viscoplastic Self-Consistent (VPSC) simulations for alpha-beta Ti alloys in compression. This code was used in the paper "Prediction of relative globularization rates in α + β titanium alloys as a function of initial crystal orientation," by B.A. Begley, S.K. Markham, M.R. Mizak, A.L. Pilchak, and V.M. Miller, published in _Journal of Materials Research_ Vol. 35, Iss. 8, April 2020. Available at: https://doi.org/10.1557/jmr.2020.54


Code is broken into three parts: 
1. Variable declarations (for conventionally modified parameters), found in *InitializeParameters.m*
2. Running the VPSC simulations across orientation space, using *RunVPSC.m*
3. Analyzing and plotting the VPSC output files, using *AnalyzeVPSC.m*
 
*RunVPSC.m* and *AnalyzeVPSC.m* are designed to use the same variable declarations in *InitializeParameters.m*, so do not change any parameters between running VPSC and analyzing/plotting the data. When running VPSC, the raw data will be output to a directory with the name "Data_X_degrees", where *X* is the degree resolution of the data (smaller degree, higher resolution data.) Figures and Gifs of the analyzed data will be exported to "./Data_X_degrees/Graphics/".

This code relies heavily on the MTEX Matlab toolbox for analyzing and modeling crystallographic textures. This code was written and tested in MTEX version 5.2.X and may not function in older versions.

Please note that this code automatically and temporarily adds several of its sub-directories to your Matlab path, which will be removed at the end of your current Matlab session. If this is a feature you wish to remove, that code is found at the end of *InitializeParameters.m*, however, you will have to move several scripts and function files to the working directory, as they will no longer be searchable in the path.

The developers thank Oliver J. Woodford and Yair M. Altman for the development of export_fig, which has been used extensively in this work to create publication quality figures and gifs. We also thank Víctor Martínez-Cagigal for customcolormap and DGM for blendtools, both tools found on the Matlab File Exchange. These excellent tools provided several solutions to problems that might have otherwise gone unsolved. Finally, we thank Ralf Hielscher and his collaborators for the MTEX toolbox, without which this work would have required coding skills well beyond me.

MTEX: https://mtex-toolbox.github.io/index.html
Export_fig: https://github.com/altmany/export_fig
Blendtools: https://www.mathworks.com/matlabcentral/fileexchange/52513-image-blending-functions
Custom Colormap: https://www.mathworks.com/matlabcentral/fileexchange/69470-custom-colormap
