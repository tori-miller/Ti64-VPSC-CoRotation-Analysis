function  outpict=imblend(FG,BG,opacity,blendmode,varargin)
%   IMBLEND(FG, BG, OPACITY, BLENDMODE,{AMOUNT},{COMPMODE},{CAMOUNT},{OPTIONS})
%       Blend images or imagesets as one would blend layers in GIMP or Photoshop. 
%
%   FG, BG are image arrays of same H,V dimension
%       Mismatches of dimensions 1:2 are not supported. Use IMSTACKER, IMRESIZE,  
%           IMCROP, or PADARRAY to enforce desired colocation of layer content.
%       Mismatches of dimension 3 are handled by array expansion.  
%           1 or 3 channel images are assumed to be monochrome or RGB, respectively
%           2 or 4 channel images are assumed to have an added alpha channel
%           blending a RGB image and a monochrome image results in an RGB image
%           blending a I/RGB image with a IA/RGBA image results in an image with alpha
%       Mismatches of dimension 4 are handled by array expansion.
%           both can be single images or 4-D imagesets of equal length
%           can also blend a single image with a 4-D imageset
%   OPACITY is a scalar from 0 to 1
%       defines mixing of blended result and original BG
%   BLENDMODE is a string assignment (see list & notes) 
%       this parameter is insensitive to case and spacing
%       see included contour plots for insight into relationships and scaling behaviors
%   AMOUNT is a numeric parameter (optional, default 1)
%       used to internally scale the influence of blend calculations
%       modes which accept this argument are marked with effective range
%   COMPMODE optionally specifies the compositing or alpha blending used for images. (see list)
%       default behavior replicates legacy GIMP behavior
%   CAMOUNT is a thresholding parameter used by some compositing modes (optional, default 1)
%
%   OPTIONS may include the following keys:
%   The user may optionally specify the standard used for luma or YPbPr calculations.
%       This only affects modes which perform Y or YPbPr conversion within the scope of IMBLEND.
%       'rec601' (default) or 'rec709' are valid keys.
%   For niche application, a polar color model can be selected with the 'hsy' or 'ypbpr' keys.
%       Both modes enforce gamut extents via chroma normalization (hsy) or truncation (ypbpr).
%   Specifying 'quiet' will suppress non-terminal warnings
%   Specifying 'verbose' will dump extra information relevant for some modes
%       
%   ============================= BLEND MODES =============================
%   Opacity & Composition
%       normal			(compositing only)
%
%   Light & Contrast
%       soft light      (legacy GIMP & GEGL)
%       soft light ps   (Photoshop)
%       soft light svg  (SVG 1.2)
%       soft light eb   (EffectBank/illusions.hu)
%       soft light eb2  (EffectBank/illusions.hu)                    amount:[0 to +inf)
%       overlay         (combined multiply & screen)                 amount:[0 to +inf)
%       hard light      (transpose of overlay)                       amount:[0 to +inf)
%       linear light    (combined lineardodge & linearburn)          amount:[0 1]
%       vivid light     (combined colordodge & colorburn)            amount:[0 to +inf)
%       easy light      (combined easydodge & easyburn)              amount:[0 to +inf)
%       flat light      (combined softdodge & softburn)              amount:[0 to +inf)
%       soft flat light                                              amount:[0 to +inf)
%       pin light       (combined lighten & darken)                  amount:[0 1]
%       super light     (adjust from linear to pin light)            amount:[1 to +inf)
%       scale add       (add bg to fg deviation from mean)           amount:(-inf to +inf)
%       scale mult      (scale bg by mean-normalized fg)             amount:[0 to +inf)
%       contrast        (adjust bg contrast by mean-normalized fg)   amount:[0 to +inf)
%
%   Dodge & Burn
%       color dodge     (similar to GIMP dodge)                      amount:[0 1]
%       color burn      (similar to GIMP burn)                       amount:[0 1]
%       linear dodge                                                 amount:[0 1]
%       linear burn                                                  amount:[0 1]
%       soft dodge                                                   amount:[0 to +inf)
%       soft burn       (transpose of soft dodge)                    amount:[0 to +inf)
%       easy dodge      (improved detail retention)                  amount:[0 to +inf)
%       easy burn                                                    amount:[0 to +inf)
%
%   Niche Complements from EffectBank
%       light           
%       shadow          (complement of 'light')
%       bright          (like a softer easydodge)
%       dark            (complement of 'bright')
%       lighteneb       (like a strong softdodge)
%       darkeneb        (complement of 'lighteneb')
%
%   Quadratics & Complements
%       glow            (similar to dodge)                           amount:(-inf to +inf)
%       heat            (similar to burn)                            amount:(-inf to +inf)
%       reflect         (glow transpose)                             amount:(-inf to +inf)
%       freeze          (heat transpose)                             amount:(-inf to +inf)
%       helow           (similar to softlight)                       amount:(-inf to +inf)
%       gleat           (similar to vividlight)                      amount:(-inf to +inf)
%       frect           (helow transpose)                            amount:(-inf to +inf)
%       reeze           (gleat transpose)                            amount:(-inf to +inf)
%
%   Relational
%       lighten RGB     (lighten only (RGB))                         amount:[1 100]
%       darken RGB      (darken only (RGB))                          amount:[1 100]
%       lighten Y       (lighten only (test luma only))              amount:[1 100]
%       darken Y        (darken only (test luma only))               amount:[1 100]
%       saturate        (only increase saturation)                   amount:[0 to +inf)
%       desaturate      (only decrease saturation)                   amount:[0 to +inf)
%       near {layer}	(apply only similar colors)                  amount:[0 1]
%       far {layer}     (transpose of 'near')                        amount:[0 1]
%       replace color   (replace specified regions of BG)            amount:[0 1]
%       exclude color   (transpose of 'replacecolor')                amount:[0 1]
%   
%   Mathematic
%       multiply
%       screen
%       divide
%       addition
%       subtraction
%       bleach          (inverse of addition)
%       stain           (transpose of bleach)
%       difference
%       equivalence     (inverse of difference)
%       negation                                                     amount:[0 1]
%       extremity       (inverse of negation)                        amount:[0 1]
%       exclusion       (continuized XOR)
%       hard mix        (similar to posterization)                   amount:[0 2]
%       interpolate     (cosine interpolation)
%       hard int        (quantized cosine interpolation)             amount:[1 to +inf)
%       average         (arithmetic mean, linear interpolation)
%       geometric       (geometric mean)
%       harmonic        (harmonic mean)
%       pnorm           (p-norm for p=amount)                        amount:[0 to +inf)
%       sqrtdiff
%       compsqrtdiff
%       arctan
%       curves          (apply contrast map)                         amount:(-inf to +inf)
%       gammalight      (apply gamma correction map)                 amount:[0 to +inf)
%       gammadark       (apply inverse gamma correction)             amount:[0 to +inf)
%       grain extract
%       grain merge
%
%   Mesh Effects
%       mesh            (apply arbitrary transfer function)          amount:[0 1]
%       hard mesh       (apply arbitrary transfer function)          amount:[0 1]
%       bomb            (random transfer function)                   amount:[1 to +inf)
%       bomb locked     (channel-locked bomb)                        amount:[1 to +inf)
%       hard bomb       (think bomb + hardmix)                       amount:[1 to +inf)
%
%   Component
%       hue             (H in CIELCHab)
%       saturation      (C in CIELCHab)
%       color           (HS in HSL, preserve Y)
%       color lchab     (CH in CIELCHab)
%       color lchsr     (CH in SRLAB2 LCH)
%       color hsl       (HS in HSL)
%       color hsyp      (HS in HSYp)
%       value           (max(R,G,B))
%       luma            (Rec601 or {Rec709})
%       lightness       (mean(min(R,G,B),max(R,G,B))
%       intensity       (mean(R,G,B))
%       transfer inchan>outchan   (directly transfer any channel to another)
%       permute inchan>H     (rotate hue)                            amount:(-inf to +inf)
%       permute inchan>HS    (rotate hue and blend chroma)           amount:(-inf to +inf)
%
%   NOTES:
%       The 'lighten Y', 'darken Y', and some other component modes expect RGB input 
%       and will force expansion if fed single-channel images.
%
%       SYNONYMOUS MODES:
%       'equivalence' is referred to as 'phoenix' in several sources.
%       'average' is referred to as 'allanon' in Krita and EffectBank
%       'harmonic' is referred to as 'parallel' in Krita
%       'linearburn' is referred to as 'inverse subtract' in Krita
%       'sqrtdiff' is referred to as 'additive subtractive' in Krita
%       'softlight' is referred to as 'pegtop light' by ImageMagick
%       Either name may be used.
%       
%       SOFT LIGHT:
%       The assumed goal of these modes is to behave as a gamma adjustment function symmetric about FG=0.5. 
%       Roughly speaking, these are listed from fastest to most mathematically correct.
%       'softlight' is equivalent to ImageMagick, GIMP, and GEGL code.  Also known as 'pegtop light'.
%             This mode has gradient continuity, but poor symmetry.
%       'softlightps' is equivalent to all formulae found attributed to Photoshop (afaik). 
%       'softlightsvg' follows SVG 1.2 spec, and is nearly identical to 'softlightps'.
%             These modes have notable gradient discontinuity, but better symmetry.
%       'softlighteb' uses the faster of the two methods posed for EffectBank by illusions.hu
%             This mode has gradient continuity and only slight asymmetry, but it's ~2x as fast as 'eb2'.
%       'softlighteb2' is a parametric extension of the more accurate method posed for EffectBank
%             This mode has gradient continuity and symmetry for all parameter values.
%       See contour plot pdf for exploration of symmetry, relative speed, and gradient discontinuity.
%       See also: https://mail.gnome.org/archives/gimp-developer-list/2012-July/msg00201.html
%
%       OVERLAY & HARDLIGHT MODES:
%       For AMOUNT=1, these behave as per standard formulae. Otherwise, an alternative is used.
%       These are custom mesh modes which approximate iterated application of the named blend
%       in a fashion which is continuously scalable so as to simulate fractional iterates.
%       Consider the following examples using 'overlay'
%           For AMOUNT=0.7, results approximate a softlight blend
%           For AMOUNT=1, results are identical to standard methods
%           For AMOUNT=2, results approximate IMBLEND(FG,IMBLEND(FG,BG,1,'overlay'),1,'overlay')
%
%       COMBINED DODGE/BURN MODES:
%       'linear light', 'vivid light' and 'easy light' can be thought of as bidirectional variants of 
%       'linear', 'color', and 'easy' dodge/burn modes.  The primary differences to keep in mind is that 
%       the neutral color is FG=0.5, and dR/dFG is correspondingly doubled.
%
%       FLAT LIGHT:
%       This is a piecewise combination of 'softdodge' & 'softburn'.  The effect is flat and somewhat
%       opaque, tending to superimpose FG extrema.  The result is a middle ground between the behaviors 
%       and utility of 'vividlight' and 'pinlight'.  
%
%       SOFT FLAT LIGHT:
%       While otherwise very similar to 'flatlight', this trig-based variant trades the strictly neutral 
%       response at FG=0.5 for a more subtle response along the FG=BG diagonal.  See contour plots.
%
%       PIN LIGHT:
%       This mode combines lighten-only and darken-only thresholding to allow incorporation of FG
%       extrema into the BG image.  As AMOUNT is decreased, the thresholding becomes more exclusive.
%
%       SUPER LIGHT:
%       Piecewise union of functions whose level curves are superelliptic.  Allows transition between
%       behaviors of other blend modes. Useful in place of 'pin light' if a soft threshold is desired.
%           For AMOUNT=1, behavior matches 'linear light'
%           For AMOUNT=2, behavior is similar to 'hard light'
%           For AMOUNT>>2, behavior approaches 'pin light'
%
%       MEAN-CENTERED CONTRAST MODES:
%       The modes 'scale add', 'scale mult', and 'contrast' are intended for uses similar to those of GIMP's
%       'grain merge' mode.  In normal operation, the FG content is treated as a mean-centered gain map for
%       the blend effect in question.  As an alternative to mean-centering, the center color may be specified
%       via AMOUNT in the form of [k cc], where k is the scaling factor and cc is the center color, which may
%       be either 1 or 3 elements;  i.e. [1 0.5] is equivalent to [1 0.5 0.5 0.5].  In this fashion, 'scale add'
%       and 'scale mult' effect adjustable additive and multiplicative gain mapping.  'contrast' acts as a 
%       levels tool, shifting the BG input white point or black point depending on FG value. This mode is
%       similar to a subtle application of 'vivid light', with its breakpoints controlled by the center color.
%       When cc=0 or 1, 'contrast' becomes equivalent to 'color dodge' or 'color burn'.  
%
%       CURVES:
%       This mode allows direct manipulation of BG contrast in a fashion similar to that of a curves tool.
%       This mode can take up to three parameters via AMOUNT.  A full specification is of the form [k os gp],
%       where k is a scaling factor, os is an offset (default 0), and gp is the input grey value (default 0.5).
%       The amount of curvature is modulated following C=(k*FG + os), and the midpoint of the curve is shifted 
%       by gp.  Setting k=0 allows scalar manipulation of contrast without the necessity for a solid FG fill.
%           When C>1, BG contrast is increased
%           When 0<C<1, BG contrast is decreased.
%           When C=0, BG = 0.5.
%           When C<0, BG is inverted, with contrast following abs(C)
%       With that in mind, AMOUNT=[0 1 0.5] is the null condition, and results in no change to the BG
%    
%       SOFT DODGE & BURN:
%       Jens Gruschel's original formulae are a combination of 'colordodge' and inverse 'colorburn';  
%       the pair are simple transposes, unlike the other dodge/burn modes.  When parameterized, 
%       their relationship follows imblend(FG,BG,1,'softdodge',k) = imblend(BG,FG,'softburn',1/k).  
%       In other words, either can function as dodge or burn depending on intended layer order.  
%       For AMOUNT>1, BG content remains dominant; for AMOUNT<1, FG content dominates.  
%       See contour plots for insight.  These modes have no neutral FG color.
%
%       EASY DODGE & BURN:
%       These are modified power functions allowing scalable dodge/burn functionality without destroying
%       highlight and shadow details.  As traditional methods are constant-valued for 50% of their
%       domain, they tend to exhibit a thresholding behavior.  While 'easydodge' and Gruschel's 'softdodge'
%       can both darken and lighten, 'easydodge' is more asymmetric and has only subtle darkening effect.
%       Unlike 'color' or 'linear' dodge & burn, the neutral FG color for the 'easy' modes is not black/white, 
%       but 1/6 and 5/6 (for AMOUNT=1). Results from 'easydodge' tend to be soft and less-oversaturated,  
%       as if a compromise between 'colordodge' and 'screen'.  These are good all-around tools for dodge/burn  
%       tasks where extra contrast stretching is desired.
%
%       QUADRATIC MODES:
%       'glow' and 'heat' are higher-ordered variants of 'colordodge' and 'colorburn'. Compared to the  
%       latter, they have subdued effect for default AMOUNT, though they are largely constant-valued 
%       and exhibit the same thresholding behavior.  While both color and linear dodge/burn are unidirectional, 
%       these modes can both lighten and darken an image. The complementary modes 'gleat' and 'helow' are 
%       symmetric modes derived from the prior.  'gleat' behaves similar to 'vividlight', whereas 'helow' 
%       is similar to 'overlay' but with the midtone contrast response inverted (see contour plots).
%       'helow' and its transpose do not exhibit thresholding.
%
%       LIGHTEN & DARKEN: 
%       The RGB modes are simple max/min relationals, much like GIMP's 'lighten only' and 'darken only'.
%       The hard edge of these RGB modes can be tempered by specifying a range of smooth transition.  
%       For AMOUNT=1, the operation is simple relational. Otherwise, AMOUNT specifies the width of the 
%       transition region about the unit square diagonal (in percent).  When AMOUNT=100, no unaltered FG
%       or BG content remains; a value of 10% or so helps reduce the appearance of transition edges.
%
%       'lighteny' and 'darkeny' are similar to Photoshop's 'lighter color' and 'darker color' modes. 
%       Here, the FG/BG pixel luma is evaluated and the pixels replaced as a whole instead of evaluating 
%       each channel. This results in a binary masking behavior when AMOUNT=1. Otherwise, the transition
%       between FG and BG is a linearized opacity blend.  This is a tentative measure to reduce perceived
%       brightness inversions or banding which otherwise occur in the blended region.
%
%       DISTANCE MODES:
%       The modes 'near' and 'far' locate regions in which FG and BG colors are within or beyond a weighted
%       euclidean distance.  Both modes accept an optional argument {layer} which may be 'fg' or 'bg'.
%           'near fg' will return only the FG content in the match region
%           'near bg' will return only the BG content in the match region
%           'near' merges matching FG content into BG
%       For RGB inputs, distance calculation is performed in YPbPr, with extra weighting on luma.
%       For distance specified by AMOUNT>=1, all colors are considered 'near'.
%
%       REPLACE & EXCLUDE COLOR:
%       These incorporate simple masking behavior which allows the user to handle composition with
%       solid-color image matting.  For example, if AMOUNT=[0 0 0], 'replacecolor' copies FG data  
%       to all black BG regions; 'excludecolor' copies all non-black FG content to the BG.  
%       If AMOUNT is a scalar, it will be expanded as necessary. Masking has a tolerance of 1%
%
%       SATURATE & DESATURATE:
%       Unlike the component mode 'saturation', these are thresholding modes operating on chroma 
%       in LCHab, much like 'lightenrgb' or 'lighteny' operates on rgb channels and luma. In these
%       modes, AMOUNT modulates foreground chroma.
%
%       KRITA & EFFECTBANK/ILLUSIONS.HU MODES:
%       'light' and 'shadow' are strong dodge/burn-like modes
%       'bright' and 'dark' are soft, partially inverting dodge/burn-like modes
%       'lighteneb' and 'darkeneb' are similar to a strong, transposed softdodge/burn
%       'gammalight' and 'gammadark' allow gamma adjustment with AMOUNTxFG as a gamma map.
%       'bleach' and 'stain' are the inverse of 'lineardodge' (addition), and 'linearburn'
%       'sqrtdiff', aka 'additivesubtract' is the difference of square roots
%       'harmonic', aka 'parallel' is the harmonic mean; roughly equivalent to 'geometric'
%       'arctan' is similar to 'softdodge' with an inverted FG
%
%       MESH MODES:
%       These modes accept AMOUNT in the form of a 2x2 or larger matrix whose elements represent
%       output intensity for input intensities from 0 to 1 (consider BG as horizontal axis, etc)
%       e.g [0 0.5; 0.5 1] is equivalent to 'average'; [0 0; 1 1] is the same as 'normal'
%       Compare to the included contour plots; amount(1,1) is at the origin of BG and FG axes.
%       Values are assumed to be evenly spaced and are subject to interpolation (bilinear for 'mesh' 
%       and nearest-neighbor for 'hardmesh'). If AMOUNT is not set explicitly to a valid matrix, 
%       a warning will be dumped and a default used.
%
%       RANDOMIZED MODES:
%       These are all mesh modes based on a random transfer function matrix of user-defined size.
%       For scalar AMOUNT, the tf matrix is of size (AMOUNT+1)x(AMOUNT+1).
%       When AMOUNT is a 2-element vector, the tf matrix is (AMOUNT(1)+1)x(AMOUNT(2)+1).
%       The 'bomb' mode applies a random piecewise-linear mesh blend
%       The 'bomblocked' mode is the same as 'bomb', but without channel-independence
%       The 'hardbomb' mode applies a random piecewise-constant mesh blend
%       Using the 'verbose' key with these modes will display the transformation matrix as a command string.
%       These can then be used with the mesh modes to reproduce a particular random blend. 
%		
%       COLOR MODES: 
%       'color' is a variant of the HSL method with an attempt to enforce luma preservation (fast)
%       'color hsyp' attempts to provide best uniformity, at the cost of maximum chroma range.
%       'color hsl' matches the legacy 'color' blend mode in GIMP
%        Based only on experiment, LCHab method best approximates Photoshop behavior.
%
%       The 'hue' & 'saturation' modes are derived from LCHab instead of HSL as in GIMP.
%       If H or S modes are desired in HuSL, HSY, HSI or HSV, use 'transfer' instead.
%
%       TRANSFER MODES:
%       mode accepts channel strings based on RGBA, HuSLuv, HSY, HSYp, HSI, HSL, HSV, or CIELCHab models
%           'y', 'r', 'g', 'b', 'a'
%           'h_husl', 's_husl', 'l_husl'
%           'h_hsy', 's_hsy', 'y_hsy'
%           'h_hsyp', 's_hsyp', 'y_hsyp'
%           'h_hsi', 's_hsi', 'i_hsi'
%           'h_hsl', 's_hsl', 'l_hsl'
%           'h_hsv', 's_hsv', 'v_hsv'
%           'l_lch', 'c_lch', 'h_lch'
%       non-rgb symmetric channel transfers (e.g. V>V or Y>Y) are easier applied otherwise
%           (e.g. 'value' or 'luma' blend modes)
%  
%       PERMUTATION MODES:
%       modes can accept input channel strings 'h', 's', 'y', 'dh', 'ds', 'dy'
%       permutations actually occur on H and S in the HuSLuv model
%       color permutations (inchan>HS) combine hue rotation and chroma blending
%       chroma blending is maximized when abs(amount)==1
%
%   ============================= COMPOSITION MODES =============================
%   Porter-Duff 
%       src over                                                     camount:[0 to +inf)
%       src atop                                                     camount:[0 to +inf)
%       src in                                                       camount:[0 to +inf)
%       src out                                                      camount:[0 to +inf)
%       dst over                                                     camount:[0 to +inf)
%       dst atop                                                     camount:[0 to +inf)
%       dst in                                                       camount:[0 to +inf)
%       dst out                                                      camount:[0 to +inf)
%       xor                                                          camount:[0 to +inf)
%
%   Other
%       gimp                (default)
%       translucent     
%       dissolve {type}     (alpha dithering)                        camount:[0 1]
%       lindissolve {type}  (preserve linear alpha)                  camount:[0 1]
%   
%   NOTES:
%       Some of these modes (e.g. 'dst in', 'xor') don't really make much sense to use with
%       any blend mode other than 'normal'.  You're not restricted from doing it, though.
%       
%       'gimp' specifies the legacy approach used by GIMP prior to GEGL (default)
%       This is similar to SRC-OVER composition for 'normal' and a modified SRC-ATOP 
%       composition for other blends
%
%       The SVG 1.2 spec and GEGL follow a Porter-Duff SRC-OVER composition for all blends
%
%       PORTER-DUFF MODES:
%       If using these modes where hard-edged masking behavior is desired, specifying a nonunity CAMOUNT 
%       will invoke a thresholding operation on the FG alpha channel.  
%           CAMOUNT>1 sets all alpha <1 to 0
%           CAMOUNT in the interval (0,1) thresholds alpha at the specified value
%           CAMOUNT=0 will set all nonzero alpha to 1
%       Unlike other modes, using these on I/RGB inputs may force IA/RGBA output depending on the mode
%       and the value of specified OPACITY.  These are generally not useful cases.
%
%       TRANSLUCENT MODE:
%       This mode is based on an article by Søren Sandmann Pedersen, and uses a transmission-reflection
%       model to emulate the effect of a translucent material. Calculations are performed in linear RGB.
%       http://ssp.impulsetrain.com/translucency.html
%
%       DISSOLVE MODES:   
%       These modes are essentially SRC-OVER composition after FG alpha is converted to a dithered
%       binary mask using one of the following methods:
%           'dissolve' applies a white noise thresholding dither (GIMP behavior)
%           'dissolve ord' applies a 64-level ordered dither
%           'dissolve zf' applies a Zhou-Fang variable-coefficient E-D dither (best)
%       When using these modes, final mixdown opacity is linearly scaled with OPACITY as usual.
%       The masking density is controlled via CAMOUNT. The combination of dithering and linear opacity
%       makes the creation of texture or grain overlays very simple.
%
%       The 'lindissolve' modes offer the same methods, but the dithering is performed only on a uniform 
%       mask.  This leaves linear FG alpha intact, allowing for a different range of control. i.e.:
%           In 'dissolve', opacity is scalar (OPACITY) and density is a map (alpha*CAMOUNT)
%           In 'lindissolve', opacity is a map (alpha*OPACITY) and density is scalar (CAMOUNT)
%       When no FG alpha channel is present, 'dissolve' and 'lindissolve' are identical.
%
%   =====================================================================
%   EXAMPLES:
%      Do a simple multiply blend as would GIMP:
%          R=imblend(FG,BG,1,'multiply');
%
%      Specify SRC-OVER composition and use CAMOUNT for alpha thresholding:
%          R=imblend(FG,BG,1,'multiply','srcover',0.5);          
%
%   CLASS SUPPORT:
%       Accepts 'double','single','uint8','uint16','int16', and 'logical'
%       Return type is inherited from BG
%
%   See also: REPLACEPIXELS, IMCOMPOSE

%   REFERENCES:
%       https://www.ffmpeg.org/doxygen/2.4/vf__blend_8c_source.html
%       http://dunnbypaul.net/blends/
%       http://www.pegtop.net/delphi/articles/blendmodes/
%       http://www.venture-ware.com/kevin/coding/lets-learn-math-photoshop-blend-modes/
%       http://www.deepskycolors.com/archive/2010/04/21/formulas-for-Photoshop-blending-modes.html
%       http://www.kineticsystem.org/?q=node/13
%       http://www.simplefilter.de/en/basics/mixmods.html
%       http://en.wikipedia.org/wiki/Blend_modes
%       http://en.wikipedia.org/wiki/YUV
%       https://en.wikipedia.org/wiki/Alpha_compositing
%       http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/PDF32000_2008.pdf
%       https://dev.w3.org/SVG/modules/compositing/master/
%       https://www.w3.org/TR/SVG11/filters.html#feBlendElement
%       http://ssp.impulsetrain.com/porterduff.html
%       http://ssp.impulsetrain.com/translucency.html
%       GIMP 2.4 & 2.8.10 source
%       Krita 3.1.4 source
%       http://illusions.hu/effectwiki/doku.php?id=list_of_blendings (DEAD LINK)
%       https://mail.gnome.org/archives/gimp-developer-list/2012-July/msg00201.html
%       https://yahvuu.files.wordpress.com/2009/09/table-contrast-2100b.png
%       https://yahvuu.wordpress.com/2009/09/27/blendmodes1/

compkeys={'gimp','translucent','srcover','srcatop','srcin','srcout','dstover','dstatop','dstin', ...
	'dstout','xor','dissolve','dissolvezf','dissolveord','lindissolve','lindissolvezf','lindissolveord'};

amount=1;
camount=1;
compositionmode='gimp';
rec='rec601';
quiet=0;
verbose=0;
colormodel='rgb';
wclass='double'; % this isn't documented

compkeyset=0;
for k=1:1:length(varargin);
    if isnumeric(varargin{k})
		if compkeyset==1;
			camount=varargin{k}; 
		else
			amount=varargin{k};
		end
    elseif ischar(varargin{k})
		key=lower(varargin{k});
		key=key(key~=' ');
		switch key
			case compkeys
				compositionmode=key;
				compkeyset=1;
			case {'rec601','rec709'}
				rec=key;
			case 'quiet'
				quiet=1;
			case 'verbose'
				verbose=1;
			case 'ypbpr'
				colormodel='ypbpr';
			case 'hsy'
				colormodel='hsy';
			case 'double'
				wclass='double';
			case 'single'
				wclass='single';
			otherwise
				if ~quiet % only suppressed if quiet key comes first!
					fprintf('IMBLEND: Ignoring unknown key ''%s''\n',key)
				end 
		end
    end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check and modify datatypes %%%%%%%%%%%%%%%%%%%%%%%%%
% output type is inherited from BG
try
	FG=imcast(FG,wclass);
catch b
	error('IMBLEND: unsupported class for FG')
end

try
	[BG inclassBG]=imcast(BG,wclass);
catch b
	error('IMBLEND: unsupported class for BG')
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check and modify dimensions %%%%%%%%%%%%%%%%%%%%%%%%%
% check if height & width match
sFG=size(FG);
sBG=size(BG);  
if any(sFG(1:2)~=sBG(1:2)) 
    error('IMBLEND: images of mismatched dimension')
end

% check frame count and expand as necessary
if length(sFG)~=4 && length(sBG)~=4 % two single images
    images=1;
else
    if length(sFG)~=4 % single FG, multiple BG
        FG=repmat(FG,[1 1 1 sBG(4)]);
    elseif length(sBG)~=4 % multiple FG, single BG
        BG=repmat(BG,[1 1 1 sFG(4)]); sBG=size(BG);
    elseif sFG(4)~=sBG(4) % two unequal imagesets
        error('IMBLEND: imagesets of unequal length')
    end
    images=sBG(4);
end

% expand along dimension 3 where necessary

% some blend modes expect RGB input; force expansion to avoid error bombing users
% yes, ~isempty(find(strcmp())) is about 50x faster than ismember() in R2009b!
modestring=lower(blendmode(blendmode~=' '));
if ~isempty(find(strcmp(modestring,{'value','lightness','intensity','hue','saturation','luma','lighteny', ...
        'darkeny','color','colorlchab','colorlchsr','colorhsl','colorhsyp','saturate','desaturate'}),1)) ...
            || ~isempty(strmatch('transfer',modestring)) ...
            || ~isempty(strmatch('permute',modestring))  || ~strcmp(colormodel,'rgb')
    mustRGB=true;
else
    mustRGB=false;
end

s3FG=size(FG,3); % image size
s3BG=size(BG,3);
ccFG=s3FG; % number of color channels
ccBG=s3BG;
FGhasalpha=0; % alpha flag
BGhasalpha=0;
% determine number of color channels, alpha presence, and split alpha from color
if any(ccFG==[2 4])
    FGhasalpha=1;
    ccFG=2*floor((ccFG+1)/2)-1;
    FGA=FG(:,:,ccFG+1,:);
    FG=FG(:,:,1:ccFG,:);
end
if any(ccBG==[2 4])
    BGhasalpha=1;
    ccBG=2*floor((ccBG+1)/2)-1;
    BGA=BG(:,:,ccBG+1,:);
    BG=BG(:,:,1:ccBG,:);
end

% at this point, both FG and BG can only be 1 or 3 channel images with or without seperate alpha
if ccFG<ccBG
    FG=repmat(FG,[1 1 3 1]);
elseif ccFG>ccBG
    BG=repmat(BG,[1 1 3 1]);
elseif mustRGB && all([ccFG==1 ccBG==1])
    FG=repmat(FG,[1 1 3 1]);
    BG=repmat(BG,[1 1 3 1]);
end

% add a solid alpha channel where missing
if FGhasalpha==0 && BGhasalpha==1
    sFG=size(FG);
    FGA=ones([sFG(1:2) 1 size(FG,4)]);
elseif FGhasalpha==1 && BGhasalpha==0
    sBG=size(BG);
    BGA=ones([sBG(1:2) 1 size(BG,4)]);
end


% perform blend operations per frame %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these composition modes are not dependent on the results of any blend
% i.e. the [both] term is either 0 or BG, so just shunt straight to composition
noblendcompmodes={'srcout','dstover','dstatop','dstin','dstout','xor'};

if strcmp(modestring,'normal') || ~isempty(find(strcmp(compositionmode,noblendcompmodes),1))
    outpict=FG;
else
	 
	if isempty(find(strcmp(modestring,{'mesh','hardmesh','replacecolor','excludecolor','curves','scaleadd', ...
			'scalemult','contrast','bomb','bomblocked','hardbomb'}),1)) && numel(amount)~=1 
		if ~quiet
			fprintf('IMBLEND: AMOUNT parameter must be scalar for ''%s'' mode.  Defaulting to 1\n',modestring)
		end
		amount=1;
	end
	
	if images~=1
		outpict=zeros(size(BG)); 
	end
		
    for f=1:images
		if images==1
			I=BG;
			M=FG;
		else
			I=BG(:,:,:,f);
			M=FG(:,:,:,f);
		end
		
		switch colormodel
			case 'ypbpr'
				A=gettfm('ypbpr');
				My=sum(bsxfun(@times,M,A(1,:,:)),3);
				Mpb=sum(bsxfun(@times,M,A(2,:,:)),3);
				Mpr=sum(bsxfun(@times,M,A(3,:,:)),3);
				Iy=sum(bsxfun(@times,I,A(1,:,:)),3);
				Ipb=sum(bsxfun(@times,I,A(2,:,:)),3);
				Ipr=sum(bsxfun(@times,I,A(3,:,:)),3);
				
				% convert to lch
				M(:,:,1)=My;				
				M(:,:,2)=sqrt(Mpr.^2+Mpb.^2);
				M(:,:,3)=mod(atan2(Mpr,Mpb),2*pi)/(2*pi);
				I(:,:,1)=Iy;
				I(:,:,2)=sqrt(Ipr.^2+Ipb.^2);
				I(:,:,3)=mod(atan2(Ipr,Ipb),2*pi)/(2*pi);
			case 'hsy'
				M=rgb2hsy(M,'normal');
				I=rgb2hsy(I,'normal');
				M(:,:,1)=M(:,:,1)/360;
				I(:,:,1)=I(:,:,1)/360;
								
		end

        switch modestring
			
			case 'overlay'
				% for amount==1, this is a standard 'overlay' mode
				% otherwise, it's a brute-force attempt to approximate an iterative 'overlay' 
				% it's probably still faster than the horrible giant polynomial alternative
				% results for amt=1 equal standard 'overlay'
				% results for amt=2 approximate twice-recursed 'overlay', and so on ...
				amount=max(amount,0);
				if amount==1;
					hi=I>0.5; 
					R=(1-2*(1-I).*(1-M)).*hi + (2*M.*I).*~hi;
				else
					if amount<1
						mesh=(1-amount)*fetchLUT(0) + amount*fetchLUT(1);
					elseif amount==1
						mesh=fetchLUT(1);
					elseif amount>1 && amount<2
						mesh=(2-amount)*fetchLUT(1) + (amount-1)*fetchLUT(2);
					elseif amount==2
						mesh=fetchLUT(2);
					elseif amount==3
						mesh=fetchLUT(3);	
					elseif amount==4
						mesh=fetchLUT(4);	
					elseif amount>2 && amount<3
						mesh=(3-amount)*fetchLUT(2) + (amount-2)*fetchLUT(3);
					elseif amount>3
						mesh=(4-amount)*fetchLUT(3) + (amount-3)*fetchLUT(4);
					end

					[bg fg]=meshgrid(0:1/(size(mesh,2)-1):1,0:1/(size(mesh,1)-1):1);
					R=zeros(size(I));
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,mesh,I(:,:,c),M(:,:,c),'bilinear');
					end
				end
				
			case 'hardlight'
				% this is the transpose of 'overlay' and follows the same concept
				amount=max(amount,0);
				if amount==1;
					hi=M>0.5; 
					R=(1-2*(1-M).*(1-I)).*hi + (2*I.*M).*~hi;
				else
					if amount<1
						mesh=(1-amount)*fetchLUT(0) + amount*fetchLUT(1);
					elseif amount>1 && amount<2
						mesh=(2-amount)*fetchLUT(1) + (amount-1)*fetchLUT(2);
					elseif amount==2
						mesh=fetchLUT(2);
					elseif amount==3
						mesh=fetchLUT(3);	
					elseif amount==4
						mesh=fetchLUT(4);	
					elseif amount>2 && amount<3
						mesh=(3-amount)*fetchLUT(2) + (amount-2)*fetchLUT(3);
					elseif amount>3
						mesh=(4-amount)*fetchLUT(3) + (amount-3)*fetchLUT(4);
					end

					[bg fg]=meshgrid(0:1/(size(mesh,2)-1):1,0:1/(size(mesh,1)-1):1);
					R=zeros(size(I));
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,mesh,M(:,:,c),I(:,:,c),'bilinear');
					end
				end
				
            case {'softlight','pegtoplight'}
                % algebraically identical to GIMP for both legacy and GEGL methods
				% this is the same as ImageMagick's 'pegtop light' variant
                % same as legacy GIMP 'overlay' due to bug
                R=I.^2 + 2*M.*I.*(1-I);              
                
            case 'softlightsvg'
                % https://dev.w3.org/SVG/modules/compositing/master/
                m1=M<=0.50;
                m2=I<=0.25;
                m3=~m1 & m2;
                m4=~m1 & ~m2;
				
				R=(I - (1-2*M).*I.*(1-I)).*m1 ...
					+ (I + (2*M-1).*(4*I.*(4*I + 1).*(I-1) + 7*I)).*m3 ...
					+ (I + (2*M-1).*(I.^0.5 - I)).*m4;
								
			case 'softlightps' % krita's version of ps softlight; equiv to formulae for ps afaict
				I=max(I,0);
				hi=M>0.5; 
				R=(I+(2*M-1).*(sqrt(I)-I)).*hi ...
					+ (I-(1-2*M).*I.*(1-I)).*~hi;
				
			case {'softlighthu','softlighteb'}
				I=max(I,0);
				% i'm not sure which version was originally given at illusions.hu. the domain was parked
				% these test equivalent to within 3LSB (uint8)

				% https://yahvuu.files.wordpress.com/2009/09/table-contrast-2100b.png
				% this version is ~2x faster; gradient angle is only weakly dependent on FG
				% still has continuity advantage over PS/SVG methods; still has better symmetry than pegtop method
				R=I.^(M.^2 - 2.5*M + 2);  
				
			case 'softlighteb2'
				% https://en.wikipedia.org/wiki/Blend_modes#Soft_Light
				% this is probably the most correct version; gradient angle is independent of FG
				% this version (and the parametric variant) act strictly as gamma adjustment functions symmetric about FG=0.5
				amount=0.5*max(amount,0)+0.5;
				I=max(I,0);
				% R=I.^(2.^(1-2*M)); % formula from reference
				R=I.^((amount*2).^(amount*(1-2*M))); % my own parametric version				
				
			case 'flatlight' 
				% this is a thing made from parametric softdodge & softburn
				amount=max(amount,0);
                hi=M>=I;
				pm1=((M+I*amount)<1);
				pm2=((M*amount+I)<1);
				
                pmu1=pm1 & hi;
				pmd1=~pm1 & hi;
				pmu2=pm2 & ~hi;
				pmd2=~pm2 & ~hi;
				
				R=(0.5*amount*I./(eps+1-M)).*pmu1 ...
					+ (1-0.5*(1-M)./(eps+I*amount)).*pmd1 ...
					+ (0.5*amount*M./(eps+1-I)).*pmu2 ...
					+ (1-0.5*(1-I)./(eps+M*amount)).*pmd2;
								
			case 'softflatlight' 
				% this is similar to 'flatlight'
				% trades neutral response at FG=0.5 for softer curve along FG=BG diagonal
				hi=M<=I;
				R=((2*atan(M./(1-I))/pi).*hi + (1-2*atan((1-M)./I)/pi).*(1-hi)).^(1/amount);
											
			case 'linearlight'
				% this is essentially a combination of 'lineardodge' and 'linearburn'
				amount=min(max(amount,0),1);
				R=M*(amount+1)+I*amount-amount;
				
			case 'vividlight'
				% this is useful if a combined version of 'color dodge/burn' are desired
				% this parametric method is actually faster than standard method
				amount=max(amount,0);
                R=zeros(size(I));
				for c=1:1:size(M,3);
                    lo=-min(M(:,:,c)-0.5,0)*amount*2;
                    hi=1-max(M(:,:,c)-0.5,0)*amount*2;
                    R(:,:,c)=(I(:,:,c)-lo)./max(hi-lo,0);
				end			
						
			case 'easylight'
				% this is a kludged combination of easydodge/easyburn for sake of completeness
				% loses a lot of utility for non-default parameter values
				% neutral is 1-(5/6)*amount
				amount=1/(eps+max(0,amount));
				I=min(max(I,0),1);
				hi=M>(1-0.5/amount);
				R=I.^((1-M)*2*amount).*hi + (1-(1-I).^(M*(1/(amount-0.5))*amount)).*(1-hi);
			
            case 'pinlight'	% highlights are lighten-only, shadows are darken-only
				amount=min(max(amount,0),1);
				roiw=amount/2;				
				hi=M>0.5;
				R=(max(I,(1/roiw)*(M-(1-roiw)))).*hi ...
					+ (min(I,(1/roiw)*M)).*~hi;
				
			case 'superlight' % use piecewise-pnorm to create a superelliptic contrast mode
				amount=max(1,amount);
				if amount==1;
					R=2*M+I-1;
				else				
					lo=M<0.5;
					R=(1-((1-I).^amount + (1-2*M).^amount).^(1/amount)).*lo ...
						+ ((I.^amount + (2*M-1).^amount).^(1/amount)).*~lo;
				end
				
			% my own variation; slope varies with amount
			case 'hardmix' 
                amount=max(min(amount,2),0);
				if amount>=1
					R=M*(2-amount)+I*amount;
				else
					R=M*amount+I*(2-amount);
				end
                m=R>amount;
                R(m)=1;
                R(~m)=0;
				
 			case 'hardint'
                R=round(0.5*amount*(2-cos(M*pi)-cos(I*pi)))/(2*amount);
				
			
            % DODGES/BURNS    
            case'colordodge'
                amount=max(min(amount,1),0);
                R=I./(1-M*amount);

            case 'colorburn'
                amount=max(min(amount,1),0);
                R=1-(1-I)./(M*amount+(1-amount));
				
			% neutral is 1-(5/6)*amount
			case 'easydodge'
				amount=1/(eps+max(0,amount));
				I=max(I,0);
				R=I.^((1-M)*1.2*amount);
				
			% neutral is (5/6)*amount
			case 'easyburn'
				amount=1/(eps+max(0,amount));
				I=min(I,1);
				R=1-(1-I).^(M*1.2*amount);

            case 'lineardodge' % addition
                amount=max(min(amount,1),0);
                R=M*amount+I;

            case {'linearburn','inversesubtract'}
                amount=max(min(amount,1),0);
                R=M*amount+I-1*amount;
				
			case 'softdodge'
				amount=max(0,amount);
                pm=(M+I*amount)<1;
				R=(0.5*amount*I./(eps+1-M)).*pm ...
					+ (1-0.5*(1-M)./(I*amount+eps)).*~pm;
				
			case 'softburn'
				amount=max(0,amount);
                pm=(M/amount+I)<1;
				R=(0.5*M./((eps+1-I)*amount)).*pm ...
					+ (1-0.5*amount*(1-I)./(M+eps)).*~pm;
								
					
            % SIMPLE MATH OPS    
			case 'lightenrgb'
				% use a fillet to effect a smooth transition from FG to BG
				% it might seem like an opacity blend would make more sense
				% but it causes dark banding, where this method causes minor lightening
				if amount==1;
					R=max(I,M);
				else
					amount=amount*0.01;
					amount=min(max(0.01,amount),1);
					
					mlo=M<(I-amount);
					mhi=M>(I+amount);
					mid=~mhi & ~mlo;
					OS=min(I,M)-0.5*(amount*1.414*sin(pi/4 - asin(abs(I-M)/(amount*1.414))));
					
					R=I.*mlo ...
						+ M.*mhi ...
						+ (sqrt((M-OS).^2 + (I-OS).^2)+OS).*mid;
				end

            case 'darkenrgb'
				if amount==1;
					R=min(I,M);
				else
					amount=amount*0.01;
					amount=min(max(0.01,amount),1);
					
					mlo=M<(I-amount);
					mhi=M>(I+amount);
					mid=~mhi & ~mlo;
					OS=min(1-I,1-M)-0.5*(amount*1.414*sin(pi/4 - asin(abs(M-I)/(amount*1.414))));
					
					R=1-((1-M).*mlo ...
						+ (1-I).*mhi ...
						+ (sqrt((1-M-OS).^2 + (1-I-OS).^2)+OS).*mid);		
				end

			case 'lighteny'
				% soft mode does a faux-linear opacity blend
				% as a compromise to avoid inversions or dark banding
				factors=gettfm('luma');
                My=sum(bsxfun(@times,M,factors),3);
                Iy=sum(bsxfun(@times,I,factors),3);
				if amount==1;
					mask=My>Iy;
					R=bsxfun(@times,M,mask) + bsxfun(@times,I,1-mask);
				else
					I=max(I,0);
					M=max(M,0);
					amount=amount*0.01;
					amount=min(max(0.01,amount),1);
					mask=((1-Iy)+My-(1-amount))/(2*amount);
					mask=max(min(mask,1),0);
					
					p=2.4;
					R=(bsxfun(@times,M.^(p),mask) + bsxfun(@times,I.^(p),1-mask)).^(1/p);
				end
				
			case 'darkeny'
				factors=gettfm('luma');
                My=sum(bsxfun(@times,M,factors),3);
                Iy=sum(bsxfun(@times,I,factors),3);
				if amount==1;
					mask=My>Iy;
					R=bsxfun(@times,M,1-mask) + bsxfun(@times,I,mask);
				else
					I=max(I,0);
					M=max(M,0);
					amount=amount*0.01;
					amount=min(max(0.01,amount),1);
					mask=((1-Iy)+My-(1-amount))/(2*amount);
					mask=max(min(mask,1),0);
					
					p=2.4;
					R=(bsxfun(@times,M.^(1/p),1-mask) + bsxfun(@times,I.^(1/p),mask)).^(p);
				end

				
			% distance modes should probably also change alpha when in fg/bg mode
			% luma is weighted more to keep appearance good
			case {'near','nearbg','nearfg'}
				if size(M,3)==3
					A=gettfm('ypbpr');
					My=sum(bsxfun(@times,M,A(1,:,:)),3);
					Mpb=sum(bsxfun(@times,M,A(2,:,:)),3);
					Mpr=sum(bsxfun(@times,M,A(3,:,:)),3);
					Iy=sum(bsxfun(@times,I,A(1,:,:)),3);
					Ipb=sum(bsxfun(@times,I,A(2,:,:)),3);
					Ipr=sum(bsxfun(@times,I,A(3,:,:)),3);
					D=sqrt(25*(My-Iy).^2 + (Mpb-Ipb).^2 + (Mpr-Ipr).^2)<=(amount*5*1.27);
				else
					D=abs(M-I)<=amount;
				end
				if strcmp(modestring,'nearfg')
					R=zeros(size(M));
					R=bsxfun(@times,R,1-D) + bsxfun(@times,M,D);
				elseif strcmp(modestring,'nearbg')
					R=zeros(size(M));
					R=bsxfun(@times,R,1-D) + bsxfun(@times,I,D);
				else
					R=bsxfun(@times,I,1-D) + bsxfun(@times,M,D);
				end
				
			case 'far'
				if size(M,3)==3
					A=gettfm('ypbpr');
					My=sum(bsxfun(@times,M,A(1,:,:)),3);
					Mpb=sum(bsxfun(@times,M,A(2,:,:)),3);
					Mpr=sum(bsxfun(@times,M,A(3,:,:)),3);
					Iy=sum(bsxfun(@times,I,A(1,:,:)),3);
					Ipb=sum(bsxfun(@times,I,A(2,:,:)),3);
					Ipr=sum(bsxfun(@times,I,A(3,:,:)),3);
					D=sqrt(25*(My-Iy).^2 + (Mpb-Ipb).^2 + (Mpr-Ipr).^2)>(amount*5*1.27);
				else
					D=abs(M-I)>amount;
				end
				if strcmp(modestring,'farfg')
					R=zeros(size(M));
					R=bsxfun(@times,R,1-D) + bsxfun(@times,M,D);
				elseif strcmp(modestring,'farbg')
					R=zeros(size(M));
					R=bsxfun(@times,R,1-D) + bsxfun(@times,I,D);
				else
					R=bsxfun(@times,I,1-D) + bsxfun(@times,M,D);
				end
				
			% replace BG == color areas with FG
			case 'replacecolor'
				if numel(amount)==1
					amount=[1 1 1]*max(min(amount,1),0);
				end
				mhi=all(bsxfun(@le,I,reshape(amount+0.01,[1 1 3])),3);
				mlo=all(bsxfun(@ge,I,reshape(amount-0.01,[1 1 3])),3);
				m=mhi & mlo;
				R=bsxfun(@times,I,1-m) + bsxfun(@times,M,m);

			% apply only FG content == color
			% same as replacecolor transposed
			case 'excludecolor'
				if numel(amount)==1
					amount=[1 1 1]*max(min(amount,1),0);
				end
				mhi=all(bsxfun(@le,M,reshape(amount+0.01,[1 1 3])),3);
				mlo=all(bsxfun(@ge,M,reshape(amount-0.01,[1 1 3])),3);
				m=~(mhi & mlo);
				R=bsxfun(@times,I,1-m) + bsxfun(@times,M,m);
				
            case 'multiply'
                R=M.*I;
				
			case 'screen'
                R=1-((1-M).*(1-I));

            case {'division','divide'}
                R=I./(M+eps);
				
            case {'addition','add'} % same as lineardodge
                R=M+I;

            case {'subtraction','subtract'}
                R=I-M;

            case 'difference'
                R=abs(M-I);
                			
			case {'equivalence','phoenix'}
				R=1 - abs(I-M);

            case 'exclusion'
                R=M+I-2*M.*I;

            case 'negation'
                R=1-abs(amount-M-I);
				
			case 'extremity' % inverse of negation
                R=abs(amount-M-I);

            case 'grainextract'
                R=I-M+0.5;

            case 'grainmerge'
                R=I+M-0.5;

            case 'interpolate'
                R=0.25-cos(M*pi)/4 + 0.25-cos(I*pi)/4;

            case {'average','allanon'}
                R=(M+I)/2;
				
			case 'pnorm' % default is sum, generally p-norm for p=(amount)
				amount=max(0,amount);
				if amount~=1
					I=max(I,0);
					M=max(M,0);
				end
				R=(M.^(amount) + I.^(amount)).^(1/(amount));	
				
			case 'geometric' % geometric mean
				R=sqrt(max(M,0).*max(I,0));
				
			case 'mesh' % apply a user-supplied transfer function
				amount=max(0,min(1,amount));
				meshh=size(amount,1);
				meshw=size(amount,2);
				if meshh==1 || meshw==1
					if ~quiet
						disp('IMBLEND: AMOUNT parameter must be at least 2x2 for mesh mode.  Default is eye(4)');
					end
					amount=eye(4);
					meshh=size(amount,1);
					meshw=size(amount,2);
				end
				% amount=flipud(amount); % flip this if you can't stand the array orientation convention
				[bg fg]=meshgrid(0:1/(meshw-1):1,0:1/(meshh-1):1);
				R=zeros(size(I));
				if size(I,3)==3 && size(amount,3)==3
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,amount(:,:,c),I(:,:,c),M(:,:,c),'bilinear');
					end
				else
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,amount(:,:,1),I(:,:,c),M(:,:,c),'bilinear');
					end
				end
				
			case 'hardmesh' % apply a user-supplied transfer function
				amount=max(0,min(1,amount));
				meshh=size(amount,1);
				meshw=size(amount,2);
				if meshh==1 || meshw==1
					if ~quiet
						disp('IMBLEND: AMOUNT parameter must be at least 2x2 for mesh mode.  Default is eye(4)');
					end
					amount=eye(4);
					meshh=size(amount,1);
					meshw=size(amount,2);
				end
				% amount=flipud(amount); % flip this if you can't stand the array orientation convention
				[bg fg]=meshgrid(0:1/(meshw-1):1,0:1/(meshh-1):1);
				R=zeros(size(I));
				if size(I,3)==3 && size(amount,3)==3
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,amount(:,:,c),I(:,:,c),M(:,:,c),'nearest');
					end
				else
					for c=1:size(I,3)
						R(:,:,c)=interp2(bg,fg,amount(:,:,1),I(:,:,c),M(:,:,c),'nearest');
					end
				end
				
			case 'bomb' % apply a random transfer function (independent channels)
				amount=max(1,round(amount));
				if numel(amount)==1
					cf=0:1/amount:1;
					cb=cf;
				elseif numel(amount)==2
					cf=0:1/amount(1):1;
					cb=0:1/amount(2):1;
				else
					if ~quiet
						disp('IMBLEND: AMOUNT parameter must be scalar or a 2-element vector for bomb modes.  Using amount(1) only.');
					end
				end
				[bg fg]=meshgrid(cb,cf);
				tf=imadjustFB(rand([size(bg) size(I,3)]));
				R=zeros(size(I));
				for c=1:size(I,3)
					R(:,:,c)=interp2(bg,fg,tf(:,:,c),I(:,:,c),M(:,:,c),'bilinear');
				end
				if verbose 
					tfstring='cat(3,';
					for c=1:size(tf,3)
						tfstring=[tfstring mat2str(tf(:,:,c),5)];
						if c~=3; tfstring=[tfstring ',']; end
					end
					tfstring=[tfstring ');'];
					disp(['TF for ''bomb'' op:  ' tfstring])
				end
				
			case 'bomblocked' % apply a random transfer function (locked channels)
				amount=max(1,round(amount));
				if numel(amount)==1
					cf=0:1/amount:1;
					cb=cf;
				elseif numel(amount)==2
					cf=0:1/amount(1):1;
					cb=0:1/amount(2):1;
				else
					if ~quiet
						disp('IMBLEND: AMOUNT parameter must be scalar or a 2-element vector for bomb modes.  Using amount(1) only.');
					end
				end
				[bg fg]=meshgrid(cb,cf);
				R=zeros(size(I));
				tf=imadjustFB(rand(size(bg)));
				for c=1:size(I,3)
					R(:,:,c)=interp2(bg,fg,tf,I(:,:,c),M(:,:,c),'bilinear');
				end
				if verbose 
					disp(['TF for ''bomblocked'' op:  ' mat2str(tf,5)])
				end				
				
			case 'hardbomb'
				amount=max(1,round(amount));
				if numel(amount)==1
					cf=0:1/amount:1;
					cb=cf;
				elseif numel(amount)==2
					cf=0:1/amount(1):1;
					cb=0:1/amount(2):1;
				else
					if ~quiet
						disp('IMBLEND: AMOUNT parameter must be scalar or a 2-element vector for bomb modes.  Using amount(1) only.');
					end
				end
				[bg fg]=meshgrid(cb,cf);
				tf=imadjustFB(rand([size(bg) size(I,3)]));
				R=zeros(size(I));
				for c=1:size(I,3)
					R(:,:,c)=interp2(bg,fg,tf(:,:,c),I(:,:,c),M(:,:,c),'nearest');
				end
				if verbose 
					tfstring='cat(3,';
					for c=1:size(tf,3)
						tfstring=[tfstring mat2str(tf(:,:,c),5)];
						if c~=3; tfstring=[tfstring ',']; end
					end
					tfstring=[tfstring ');'];
					disp(['TF for ''hardbomb'' op:  ' tfstring])
				end

            case 'hue' % bounded LCHab operation
                Mlch=rgb2lch(M,'lab');
                Rlch=rgb2lch(I,'lab');
                Rlch(:,:,3)=Mlch(:,:,3);
                R=lch2rgb(Rlch,'lab','truncatelch');

            case 'saturation' % bounded LCHab operation
                Mlch=rgb2lch(M,'lab');
                Rlch=rgb2lch(I,'lab');
                Rlch(:,:,2)=Mlch(:,:,2);
                R=lch2rgb(Rlch,'lab','truncatelch');
				
			% these are thresholding methods
			case 'saturate'
				amount=max(amount,0);
				Mlch=rgb2lch(M,'lab');
                Rlch=rgb2lch(I,'lab');
				Rlch(:,:,2)=max(Rlch(:,:,2),Mlch(:,:,2)*amount);
                R=lch2rgb(Rlch,'lab','truncatelch');
				
			case 'desaturate'
				amount=max(amount,0);
				Mlch=rgb2lch(M,'lab');
                Rlch=rgb2lch(I,'lab');
                Rlch(:,:,2)=min(Rlch(:,:,2),Mlch(:,:,2)*amount);
                R=lch2rgb(Rlch,'lab','truncatelch');
				
            % COLOR BLEND MODES
            % COLOR_HSL matches legacy GIMP mode
            % COLOR_HSY uses a chroma-normalized variant of YPbPr

            case 'color' % swap H & S in HSL; preserve initial Y
				A=gettfm('ypbpr');
				Ai=gettfm('ypbpr_inv');
				
                Y=sum(bsxfun(@times,I,A(1,:,:)),3);
				Mhsl=rgb2hsl(M);
				Rhsl=rgb2hsl(I);
				Rhsl(:,:,1:2)=Mhsl(:,:,1:2);
				R=hsl2rgb(Rhsl);
				
				Rpb=sum(bsxfun(@times,R,A(2,:,:)),3);
				Rpr=sum(bsxfun(@times,R,A(3,:,:)),3);
				Rypp=cat(3,Y,Rpb,Rpr);
				
				R(:,:,1)=sum(bsxfun(@times,Rypp,Ai(1,:,:)),3);
				R(:,:,2)=sum(bsxfun(@times,Rypp,Ai(2,:,:)),3);
				R(:,:,3)=sum(bsxfun(@times,Rypp,Ai(3,:,:)),3);

            case 'colorhsyp' % swap H & S in HSYp
                Mhsy=rgb2hsy(M,'pastel');
                Rhsy=rgb2hsy(I,'pastel');
                Rhsy(:,:,1:2)=Mhsy(:,:,1:2);
                R=hsy2rgb(Rhsy,'pastel');

            case 'colorlchab' % bounded LCHab operation
                Mlch=rgb2lch(M,'lab');
                Rlch=rgb2lch(I,'lab');
                Rlch(:,:,2:3)=Mlch(:,:,2:3);
                R=lch2rgb(Rlch,'lab','truncatelch');

            case 'colorlchsr' % bounded SRLAB2 operation
                Mlch=rgb2lch(M,'srlab');
                Rlch=rgb2lch(I,'srlab');
                Rlch(:,:,2:3)=Mlch(:,:,2:3);
                R=lch2rgb(Rlch,'srlab','truncatelch');

            case 'colorhsl' % swap H & S in HSL
				Mhsl=rgb2hsl(M);
				Rhsl=rgb2hsl(I);
				Rhsl(:,:,1:2)=Mhsl(:,:,1:2);
				R=hsl2rgb(Rhsl);


            % V=max([R G B])
            % L=mean(max([R G B]),min([R G B]))
            % I=mean([R G B])
            % Y=[0.299 0.587 0.114]*[R G B]' or whatever R709 is

            case 'value'
                Mhsv=rgb2hsv(M);
                Rhsv=rgb2hsv(I);
                Rhsv(:,:,3)=Mhsv(:,:,3);
                R=hsv2rgb(Rhsv); 

            case {'luma', 'luma1', 'luma2'} % swaps fg bg luma
				A=gettfm('ypbpr');
				Ai=gettfm('ypbpr_inv');
				
                My=sum(bsxfun(@times,M,A(1,:,:)),3);
				Ipb=sum(bsxfun(@times,I,A(2,:,:)),3);
				Ipr=sum(bsxfun(@times,I,A(3,:,:)),3);
				Rypp=cat(3,My,Ipb,Ipr);
				
				R=zeros(size(M));
				R(:,:,1)=sum(bsxfun(@times,Rypp,Ai(1,:,:)),3);
				R(:,:,2)=sum(bsxfun(@times,Rypp,Ai(2,:,:)),3);
				R(:,:,3)=sum(bsxfun(@times,Rypp,Ai(3,:,:)),3);
				
            case 'lightness' % swaps fg bg lightness
				Mhsl=rgb2hsl(M);
				Rhsl=rgb2hsl(I);
				Rhsl(:,:,3)=Mhsl(:,:,3);
				R=hsl2rgb(Rhsl);

            case 'intensity' % swaps fg bg intensity 
                Mhsi=rgb2hsi(M);
                Rhsi=rgb2hsi(I);
                Rhsi(:,:,3)=Mhsi(:,:,3);
                R=hsi2rgb(Rhsi);

            % SCALE ADD treats FG as an additive gain map with a null point at its mean
            case 'scaleadd'
				% RGB independent limits
                %Mstretch=imadjustFB(M,stretchlimFB(M));
				% RGB average limits
				Mstretch=imadjustFB(M,mean(stretchlimFB(M,0.001),2)',[0; 1],1);
                sf=amount(1);
				if numel(amount)>1
					centercolor=amount(2:end);
					if size(M,3)>numel(centercolor)
						centercolor=repmat(centercolor(1),[1 size(M,3)]);
					end
				else
					centercolor=mean(mean(Mstretch,1),2);
				end
                R=zeros(size(I));
                for c=1:1:size(M,3);
                    R(:,:,c)=I(:,:,c)+(Mstretch(:,:,c)-centercolor(c))*sf;
                end

            % SCALE MULT treats FG as a gain map with a null point at its mean
            case 'scalemult'
				% RGB independent limits
                %Mstretch=imadjustFB(M,stretchlimFB(M));				
				% RGB average limits
				Mstretch=imadjustFB(M,mean(stretchlimFB(M,0.001),2)',[0; 1],1);
				amount=max(amount,0);
				sf=amount(1);
				if numel(amount)>1
					centercolor=amount(2:end);
					if size(M,3)>numel(centercolor)
						centercolor=repmat(centercolor(1),[1 size(M,3)]);
					end
				else
					centercolor=mean(mean(Mstretch,1),2);
				end
                R=zeros(size(I));
                for c=1:1:size(M,3);
                    R(:,:,c)=I(:,:,c).*(Mstretch(:,:,c)./(centercolor(c)+eps))*sf;
                end

            % CONTRAST uses a stretched copy of FG to map [IN_LO and IN_HI] for stretching BG contrast
            %   treats FG as a gain map with a null point at its mean
            case 'contrast'
				% RGB independent limits
                %Mstretch=imadjustFB(M,stretchlimFB(M));
				% RGB average limits
				Mstretch=imadjustFB(M,mean(stretchlimFB(M,0.001),2)',[0; 1],1);
				amount=max(amount,0);
				sf=amount(1);
				if numel(amount)>1
					centercolor=amount(2:end);
					if size(M,3)>numel(centercolor)
						centercolor=repmat(centercolor(1),[1 size(M,3)]);
					end
				else
					centercolor=mean(mean(Mstretch,1),2);
				end
                R=zeros(size(I));
				for c=1:1:size(M,3);
                    lo=-min(Mstretch(:,:,c)-centercolor(c),0)*sf;
                    hi=1-max(Mstretch(:,:,c)-centercolor(c),0)*sf;
                    R(:,:,c)=(I(:,:,c)-lo)./max(hi-lo,0);
				end
				
			% this implements direct contrast mapping
			case 'curves'
				I=min(max(I,0),1);
				ko=amount(1);
				switch numel(amount)
					case 1
						os=0; c=0.5;
					case 2
						os=amount(2); c=0.5;
					otherwise
						os=amount(2); c=max(min(amount(3),1),0);
				end
				
				k=ko*M+os;
				mk=abs(ko+os)<1;
				mc=c<0.5;
				if ~xor(mk,mc)
					pp=k; kk=k*c/(1-c);
				else
					kk=k; pp=(1-c)*k/c;
				end

				hi=I>c;
				R=(1-0.5*((1-I)*(1/(1-c))).^pp).*hi ...
					+ (0.5*((1/c)*I).^kk).*~hi;
				
				
            % quadratic modes
            % i guess they aren't really quadratic when you change 'amount'
            % quadratic modes are semi-complementary when parameterized
            % reflect(amount)=1-heat(-(amount+1))
            % freeze(amount)=1-glow(-(amount+1))
            % frect(amount)=1-gleat(-(amount+1))
            % reeze(amount)=1-helow(-(amount+1))
            case 'reflect'
				I=I*0.995;
				if amount==1 % faster for trivial case
                    R=min(1,(M.^2./(1-I+eps)));
				else
					M=max(M,0);
					I=min(I,1);
                    R=min(1,(M.^(amount+1)./(1-I+eps).^(amount)));
				end

            case 'glow'
				M=M*0.995;
				if amount==1 % faster for trivial case
                    R=min(1,(I.^2./(1-M+eps)));
				else
					M=min(M,1);
					I=max(I,0);
                    R=min(1,(I.^(amount+1)./(1-M+eps).^amount));
				end

            case 'freeze'
				I=0.005+I*0.995;
                if amount==1 % faster for trivial case
                    R=1-min(1,((1-M).*(1-M)./I+eps));
				else
					I=max(I,0);
                    R=1-min(1,((1-M).^(amount+1)./(I+eps).^amount));
                end

            case 'heat'
				M=0.005+M*0.995;
                if amount==1 % faster for trivial case
                    R=1-min(1,((1-I).*(1-I)./M+eps));
				else
					M=max(M,0);
                    R=1-min(1,((1-I).^(amount+1)./(M+eps).^amount));
                end
                
            % complementary quadratic modes
            case 'frect' % same as 'helow' with layers swapped
                hi=M>=1-I;
                I=min(1,I+0.0001);
                if amount==1
					R=(1-min(1,((1-M).*(1-M)./I))).*hi ...
						+ (min(1,(M.^2./(1-I)))).*~hi;
				else
					M=max(M,0);
					R=(1-min(1,((1-M).^(amount+1)./I.^amount))).*hi ...
						+ (min(1,(M.^(amount+1)./(1-I).^(amount)))).*~hi;
                end
                
            case 'reeze' % same as 'gleat' with layers swapped
                hi=M>=1-I;
				I=0.005+I*0.99;
                if amount==1
					R=(min(1,(M.^2./(1-I)))).*hi ...
						+ (1-min(1,((1-M).*(1-M)./I))).*~hi;
				else
					I=max(min(I,1),0);
					M=max(min(M,1),0);
                 	R=(min(1,(M.^(amount+1)./(1-I).^(amount)))).*hi ...
						+ (1-min(1,((1-M).^(amount+1)./I.^amount))).*~hi;
                end
                
            case 'gleat' % compare to 'vividlight'
                hi=M>1-I;
				M=0.005+M*0.99;
                if amount==1
					R=(min(1,(I.*I./(1-M)))).*hi ...
						+ (1-min(1,((1-I).*(1-I)./M))).*~hi;
				else
					I=max(min(I,1),0);
					M=max(min(M,1),0);
					R=(min(1,(I.^(amount+1)./(1-M).^amount))).*hi ...
						+ (1-min(1,((1-I).^(amount+1)./M.^amount))).*~hi;
                end
                
            case 'helow' % compare to 'overlay' and 'softlight' for amt=0.4-0.6
                hi=M>1-I;
				M=min(1,M+0.0001);
				if amount==1
					R=(1-min(1,((1-I).*(1-I)./M))).*hi ...
						+ (min(1,(I.*I./(1-M)))).*~hi;
				else
					I=max(I,0);
					R=(1-min(1,((1-I).^(amount+1)./M.^amount))).*hi ...
						+ (min(1,(I.^(amount+1)./(1-M).^amount))).*~hi;
				end
				
				
			% MATH OPS FROM KRITA
			% allanon = average
			% equivalence = phoenix	
			% inversesubtract = linearburn
			% greater = alpha thresholding
			case 'gammalight'
				amount=max(eps,amount);
				R=max(I,0).^(amount*M);
				
			case 'gammadark'
				amount=max(eps,amount);
				R=max(I,0).^(1./(amount*M));
			
			% 'parallel' is actually the harmonic mean instead.  good job, krita.
			case {'harmonic','parallel'} % practically equivalent to geometric
				R=2./(1./I+1./M);
				
			case {'sqrtdiff','additivesubtractive'}
				R=abs(sqrt(I)-sqrt(M));
				
			case 'compsqrtdiff'
				R=1-abs(sqrt(1-I)-sqrt(1-M));
				
			case 'arctan'
				R=2*atan(I./M)./pi;
				
			% Unverified modes attributed to EffectBank/illusions.hu
			case 'light'
				M=max(M,0);
				R=I.*(1-M)+sqrt(M);
			case 'shadow'
				M=min(M,1);
				R=(1-((1-I).*M+sqrt(1-M)));	
				
			case 'bright' 
 				lo=M<0.5;
				R=(1-(1-M).*M-(1-I).*(1-M)).*lo ...
						+ (M-(1-I).*(1-M)+(1-M).^2).*~lo;
					
			case 'dark'
				lo=M<0.5;
				R=(M.*(1-M)+M.*I).*lo ...
						+ (M.*I+M-M.^2).*~lo;
			
			case 'lighteneb' 
				R=1-log2(1+(1-I)./(8*M));
			case 'darkeneb'
				R=log2(1+I./(8*(1-M))); 
				
			case 'bleach' % these are inverted linear dodge/burn 
				R=(1-I)+(1-M)-1;
			case 'stain' 
				R=2-I-M;
			
												
            otherwise
                % PARAMETRIC COMPONENT MODES
                if numel(modestring)>=11 && strcmp(modestring(1:8),'transfer')
                    % CHANNEL TRANSFER
                    com=modestring(9:end);
                    com=com(com~='_');
                    [inchan outchan]=strtok(com,'>');
                    outchan=outchan(outchan~='>');
                    R=I;

                    switch inchan
                        case 'r'
                            pass=M(:,:,1);
                        case 'g'
                            pass=M(:,:,2);
                        case 'b'
                            pass=M(:,:,3); 
						case 'a'
							if any([FGhasalpha BGhasalpha]==1)
								pass=FGA(:,:,:,f);
							else
								error('IMBLEND: inputs have no alpha to transfer')
							end
                        case 'hhsl'
							Mhsl=rgb2hsl(M);
                            pass=Mhsl(:,:,1)/360;
                        case 'shsl'
                            Mhsl=rgb2hsl(M);
                            pass=Mhsl(:,:,2);
                        case 'lhsl'
                            Mhsl=rgb2hsl(M);
                            pass=Mhsl(:,:,3);
                        case 'hhsi'
                            Mhsi=rgb2hsi(M);
                            pass=Mhsi(:,:,1)/360;
                        case 'shsi'
                            Mhsi=rgb2hsi(M);
                            pass=Mhsi(:,:,2);
                        case {'ihsi','i'}
                            Mhsi=rgb2hsi(M);
                            pass=Mhsi(:,:,3);                        
                        case 'hhsv'
                            Mhsv=rgb2hsv(M);
                            pass=Mhsv(:,:,1);
                        case 'shsv'
                            Mhsv=rgb2hsv(M);
                            pass=Mhsv(:,:,2);
                        case {'vhsv','v'}
                            Mhsv=rgb2hsv(M);
                            pass=Mhsv(:,:,3);
                        case {'llch','l'}
                            Mlch=rgb2lch(M,'lab');
                            pass=Mlch(:,:,1)/100;
                        case {'clch','c'}
                            Mlch=rgb2lch(M,'lab');
                            pass=Mlch(:,:,2)/134.2;
                        case 'hlch'
                            Mlch=rgb2lch(M,'lab');
                            pass=Mlch(:,:,3)/360;
                        case 'hhusl'
                            Mhusl=rgb2husl(M);
                            pass=Mhusl(:,:,1)/360;
                        case 'shusl'
                            Mhusl=rgb2husl(M);
                            pass=Mhusl(:,:,2)/100;
                        case 'lhusl'
                            Mhusl=rgb2husl(M);
                            pass=Mhusl(:,:,3)/100;
                        case {'y','yhsy','yhsyp'}
							factors=gettfm('luma');
                            pass=sum(bsxfun(@times,M,factors),3);
                        case {'hhsy','hhsyp'}
                            Mhsy=rgb2hsy(M);
                            pass=Mhsy(:,:,1)/360;
                        case 'shsy'
                            Mhsy=rgb2hsy(M);
                            pass=Mhsy(:,:,2);
                        case 'shsyp'
                            Mhsy=rgb2hsy(M,'pastel');
                            pass=Mhsy(:,:,2);
                        otherwise
                            error('IMBLEND: unknown INCHAN parameter ''%s'' for TRANSFER mode',inchan);
                    end  

                    switch outchan
                        case 'r'
                            R(:,:,1)=pass;
                        case 'g'
                            R(:,:,2)=pass;
                        case 'b'
                            R(:,:,3)=pass; 
						case 'a'
							FGA(:,:,:,f)=pass;
                        case 'hhsl'
							Rhsl=rgb2hsl(R);
                            Rhsl(:,:,1)=pass*360;
                            R=hsl2rgb(Rhsl);
                        case 'shsl'
							Rhsl=rgb2hsl(R);
                            Rhsl(:,:,2)=pass;
                            R=hsl2rgb(Rhsl);
                        case 'lhsl'
							Rhsl=rgb2hsl(R);
                            Rhsl(:,:,3)=pass;
                            R=hsl2rgb(Rhsl);
                        case 'hhsi'
                            Rhsi=rgb2hsi(R);
                            Rhsi(:,:,1)=pass*360;
                            R=hsi2rgb(Rhsi);
                        case 'shsi'
                            Rhsi=rgb2hsi(R);
                            Rhsi(:,:,2)=pass;
                            R=hsi2rgb(Rhsi);
                        case {'ihsi','i'}
                            Rhsi=rgb2hsi(R);
                            Rhsi(:,:,3)=pass;
                            R=hsi2rgb(Rhsi);
                        case 'hhsv'
                            Rhsv=rgb2hsv(R);
                            Rhsv(:,:,1)=pass;
                            R=hsv2rgb(Rhsv);
                        case 'shsv'
                            Rhsv=rgb2hsv(R);
                            Rhsv(:,:,2)=pass;
                            R=hsv2rgb(Rhsv);
                        case {'vhsv','v'}
                            Rhsv=rgb2hsv(R);
                            Rhsv(:,:,3)=pass;
                            R=hsv2rgb(Rhsv);
                        case {'llch','l'}
                            Rlch=rgb2lch(R,'lab');
                            Rlch(:,:,1)=pass*100;
                            R=lch2rgb(Rlch,'lab','truncatelch');
                        case {'clch','c'}
                            Rlch=rgb2lch(R,'lab');
                            Rlch(:,:,2)=pass*134.2;
                            R=lch2rgb(Rlch,'lab','truncatelch');
                        case 'hlch'
                            Rlch=rgb2lch(R,'lab');
                            Rlch(:,:,3)=pass*360;
                            R=lch2rgb(Rlch,'lab','truncatelch');
                        case 'hhusl'
                            Rhusl=rgb2husl(R);
                            Rhusl(:,:,1)=pass*360;
                            R=husl2rgb(Rhusl);
                        case 'shusl'
                            Rhusl=rgb2husl(R);
                            Rhusl(:,:,2)=pass*100;
                            R=husl2rgb(Rhusl);
                        case 'lhusl'
                            Rhusl=rgb2husl(R);
                            Rhusl(:,:,3)=pass*100;
                            R=husl2rgb(Rhusl);
                        case {'y','yhsy','yhsyp'}
                            Rhsy=rgb2hsy(R);
                            Rhsy(:,:,3)=pass;
                            R=hsy2rgb(Rhsy);
                        case {'hhsy','hhsyp'}
                            Rhsy=rgb2hsy(R);
                            Rhsy(:,:,1)=pass*360;
                            R=hsy2rgb(Rhsy);   
                        case 'shsy'
                            Rhsy=rgb2hsy(R);
                            Rhsy(:,:,2)=pass;
                            R=hsy2rgb(Rhsy); 
                        case 'shsyp'
                            Rhsy=rgb2hsy(R,'pastel');
                            Rhsy(:,:,2)=pass;
                            R=hsy2rgb(Rhsy,'pastel'); 
                        otherwise
                            error('IMBLEND: unknown OUTCHAN parameter ''%s'' for TRANSFER mode',outchan);
                    end 

                elseif numel(modestring)>=10 && strcmp(modestring(1:7),'permute')
                    % HUE/COLOR PERMUTATION
                    com=modestring(8:end);
                    [inchan outchan]=strtok(com,'>');
                    outchan=outchan(outchan~='>');

                    Rhusl=rgb2husl(I);
                    Rhusl(:,:,1)=Rhusl(:,:,1)/360;
                    Rhusl(:,:,2)=Rhusl(:,:,2)/100;
                    Rhusl(:,:,3)=Rhusl(:,:,3)/100;

                    switch inchan
                        case 'h'
                            Mhusl=rgb2husl(M);
                            pass=Mhusl(:,:,1)/360;
                        case 'dh'
                            Mhusl=rgb2husl(M);
                            pass=Rhusl(:,:,1)-Mhusl(:,:,1)/360;
                        case 's'
                            Mhusl=rgb2husl(M);
                            pass=Mhusl(:,:,2)/100;
                        case 'ds'
                            Mhusl=rgb2husl(M);
                            pass=Rhusl(:,:,2)-Mhusl(:,:,2)/100;
                        case 'y'
							factors=gettfm('luma');
                            pass=sum(bsxfun(@times,M,factors),3);
                        case 'dy'
                            factors=gettfm('luma');
                            Ym=sum(bsxfun(@times,M,factors),3);
                            Yi=sum(bsxfun(@times,I,factors),3);
                            pass=Yi-Ym;
                        otherwise
                            error('IMBLEND: unknown INCHAN parameter ''%s'' for PERMUTE mode',inchan);
                    end  

                    switch outchan
                        case 'h'
                            Rhusl(:,:,1)=mod(Rhusl(:,:,1)+pass*amount,1)*360;
                            Rhusl(:,:,2)=Rhusl(:,:,2)*100;
                            Rhusl(:,:,3)=Rhusl(:,:,3)*100;
                            R=husl2rgb(Rhusl);
                        case 'hs'
                            if any(inchan=='y')
                                Mhusl=rgb2husl(M);
                                Mhusl(:,:,1)=Mhusl(:,:,1)/360;
                                Mhusl(:,:,2)=Mhusl(:,:,2)/100;
                            end
                            amt=max(min(abs(amount),1),0); % needed since S-blending has limited range
                            Rhusl(:,:,1)=mod(Rhusl(:,:,1)+pass*amount,1)*360;
                            Rhusl(:,:,2)=amt*Mhusl(:,:,2)+(1-amt)*Rhusl(:,:,2);
                            Rhusl(:,:,2)=Rhusl(:,:,2)*100;
                            Rhusl(:,:,3)=Rhusl(:,:,3)*100;
                            R=husl2rgb(Rhusl);
                        otherwise
                            error('IMBLEND: unknown OUTCHAN parameter ''%s'' for PERMUTE mode',outchan);
                    end 

                else
                    error('IMBLEND: unknown blend mode ''%s''',modestring);
                end

		end

		switch colormodel
			case 'ypbpr'
				Ai=gettfm('ypbpr_inv');
				
				Y=R(:,:,1);
				C=R(:,:,2);
				H=R(:,:,3)*2*pi; % rescale H
				
				% clamp at max chroma
				Cnorm=maxchroma('ypp','luma',Y,'hue',H);
				C=min(C,Cnorm);

				Rw(:,:,1)=Y;
				Rw(:,:,2)=C.*cos(H); % B
				Rw(:,:,3)=C.*sin(H); % R
				
				R(:,:,1)=sum(bsxfun(@times,Rw,Ai(1,:,:)),3);
				R(:,:,2)=sum(bsxfun(@times,Rw,Ai(2,:,:)),3);
				R(:,:,3)=sum(bsxfun(@times,Rw,Ai(3,:,:)),3);
			case 'hsy'
				R(:,:,1)=R(:,:,1)*360;
				R=hsy2rgb(R,'normal');
		end
		
        
		if images==1
			outpict=R;
		else
			outpict(:,:,:,f)=R;
		end
    end
end
outpict=max(min(outpict,1),0);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handle alpha compositing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmp(compositionmode,'gimp')
	if all([FGhasalpha BGhasalpha]==1)
		if ~isempty(find(strcmp(compositionmode,{'srcover','srcatop','srcin','srcout','dstover', ...
			'dstatop','dstin','dstout','xor'}),1))
			% stretch alpha if desired
			if camount>1 
				FGA=FGA==1;
			elseif camount==0
				FGA=FGA~=0;
			elseif camount<1 
				FGA=FGA>=camount;
			end
		end
	else
		% there's not much point in using these modes this way, but just in case ...
		% some composite-only modes will generate nonopaque output when both inputs are opaque
		if (~isempty(find(strcmp(compositionmode,{'srcin','dstatop','dstin'}),1)) && opacity~=1) ...
			|| (~isempty(find(strcmp(compositionmode,{'dstout','xor'}),1)) && opacity~=0) ...
			|| strcmp(compositionmode,'srcout')
			% expand and force alpha mode
			if ~quiet
				disp('IMBLEND: using this mode and opacity with I/RGB inputs will produce IA/RGBA output')
			end
			FGhasalpha=1;
			sFG=size(FG);
			FGA=ones([sFG(1:2) 1 size(FG,4)]);
			BGA=FGA;
		end		
	end
end

if any([FGhasalpha BGhasalpha]==1)
	switch compositionmode
		case 'gimp'
			% this is configured to match legacy (ver<=2.8) GIMP behavior
			% don't ask me to justify the propriety of these methods
			% this was based on paint-funcs.c and gimp-composite-generic.c
			% and tweaked to match observed output
			if strcmp(blendmode,'normal')
				FGA=FGA*opacity;
				outA=BGA+(1-BGA).*FGA; % FGA when BGA=0; 0 when both=0
				ratio=FGA./(outA+eps);
				outpict=bsxfun(@times,outpict,ratio) + bsxfun(@times,BG,(1-ratio));
				% when outA=0, gimp sets outRGB=0
				% otherwise, this retains BG
				outpict(outA==0)=0;
				outpict=cat(3,outpict,outA);
			else
				FGA=min(FGA,BGA);  % << why this?
				FGA=FGA*opacity;
				outA=BGA+(1-BGA).*FGA;
				ratio=FGA./(outA+eps);
				outpict=bsxfun(@times,outpict,ratio) + bsxfun(@times,BG,(1-ratio));
				% when BGA=0, gimp sets outRGB=0
				% otherwise this retains BG  
				outpict(BGA==0)=0;
				outpict=cat(3,outpict,BGA);
			end

		% Porter-Duff compositing
		% SVG 1.2 blend modes are essentially SRC-OVER, with the Ab term (i.e. Sa.*Da)
		% buried algebraically in the blend math.  e.g.
		%  MULTIPLY: Dca' = Sca × Dca + Sca × (1 - Da) + Dca × (1 - Sa)
		%                 = (Sc.*Dc).*Ab + Sc.*As + Dc.*Ad
		% if we're not using premultiplied alpha then we can just do that here for now
		% some modes can't be optimized, but this simplifies GIMP mode compatibility
		case 'srcover'
			if strcmp(blendmode,'normal')
				FGA=FGA*opacity;
				As=FGA;
				Ad=BGA.*(1-FGA);
				outpict=bsxfun(@times,As,FG) ...
					+ bsxfun(@times,Ad,BG);
				outA=As+Ad;
			else
				FGA=FGA*opacity;
				As=FGA.*(1-BGA);
				Ad=BGA.*(1-FGA);
				Ab=FGA.*BGA;
				outpict=bsxfun(@times,As,FG) ...
					+ bsxfun(@times,Ad,BG) ...
					+ bsxfun(@times,Ab,outpict);
				outA=As+Ad+Ab;
			end

		case 'srcatop'
			FGA=FGA*opacity;
			Ad=BGA.*(1-FGA);
			Ab=FGA.*BGA;
			outpict=bsxfun(@times,Ad,BG) ...
				+ bsxfun(@times,Ab,outpict);
			outA=BGA;

		case 'srcin'
			FGA=FGA*opacity;
			Ab=FGA.*BGA;
			outpict=bsxfun(@times,Ab,outpict);
			outA=Ab;

		case 'srcout'
			FGA=FGA*opacity;
			As=FGA.*(1-BGA);
			outpict=bsxfun(@times,As,FG);
			outA=As;

		case 'dstover'
			FGA=FGA*opacity;
			As=FGA.*(1-BGA);
			Ad=BGA;
			outpict=bsxfun(@times,As,FG) ...
				+ bsxfun(@times,Ad,BG);
			outA=As+Ad;

		case 'dstatop'
			FGA=FGA*opacity;
			As=FGA.*(1-BGA);
			Ab=FGA.*BGA;
			outpict=bsxfun(@times,As,FG) ...
				+ bsxfun(@times,Ab,BG);
			outA=FGA;

		case 'dstin'
			FGA=FGA*opacity;
			Ab=FGA.*BGA;
			outpict=bsxfun(@times,Ab,BG);
			outA=Ab;

		case 'dstout'
			FGA=FGA*opacity;
			Ad=BGA.*(1-FGA);
			outpict=bsxfun(@times,Ad,BG);
			outA=Ad;

		case 'xor'
			FGA=FGA*opacity;
			As=FGA.*(1-BGA);
			Ad=BGA.*(1-FGA);
			outpict=bsxfun(@times,As,FG) ...
				+ bsxfun(@times,Ad,BG);
			outA=As+Ad;	
				
		case 'translucent'
			% http://ssp.impulsetrain.com/translucency.html
			FGA=FGA*opacity;
			outpict=invgammac(outpict);
			BG=invgammac(BG);
			FGp=bsxfun(@times,FGA,outpict);
			BGp=bsxfun(@times,BGA,BG);
			outpict=FGp + bsxfun(@times,(1-FGA).^2,BGp) ./ (1-(FGp.*BGp)+eps);
			outpict=gammac(outpict);
			outA=FGA + ((1-FGA).^2.*BGA)./(1-FGA.*BGA+eps);
			
		case {'dissolve','dissolvezf','dissolveord','lindissolve','lindissolvezf','lindissolveord'}
			switch compositionmode
				case 'dissolve'
					FGA=(rand(size(FGA))+eps<=FGA*camount)*opacity;
					
				case 'dissolvezf'
					for f=1:images
						FGA(:,:,:,f)=zfdither(FGA(:,:,:,f)*camount)*opacity;
					end
					
				case 'dissolveord'
					for f=1:images
						FGA(:,:,:,f)=orddither(FGA(:,:,:,f)*camount)*opacity;
					end
					
				case 'lindissolve'
					FGA=(rand(size(FGA))+eps<=camount).*FGA*opacity;
					
				case 'lindissolvezf'
					for f=1:images
						FGA(:,:,:,f)=zfdither(ones(sFG(1:2))*camount).*FGA(:,:,:,f)*opacity;
					end
					
				case 'lindissolveord'
					for f=1:images
						FGA(:,:,:,f)=orddither(ones(sFG(1:2))*camount).*FGA(:,:,:,f)*opacity;
					end
			end
			
			As=FGA.*(1-BGA);
			Ad=BGA.*(1-FGA);
			Ab=FGA.*BGA;
			outpict=bsxfun(@times,As,FG) ...
				+ bsxfun(@times,Ad,BG) ...
				+ bsxfun(@times,Ab,outpict);
			outA=As+Ad+Ab;
			
		otherwise 
			% this shouldn't ever execute since keys are matched
			error('IMBLEND: unknown composition mode ''%s''',compositionmode);
			
	end
		
	if ~strcmp(compositionmode,'gimp')
		outpict=bsxfun(@rdivide,outpict,outA+eps);
		outpict=cat(3,outpict,outA);
	end
	
else
	
	switch compositionmode
		% if no alpha is present, do regular opacity mixdown 
		% when Sa,Da==1, both GIMP and SRC-OVER methods collapse to this
		case {'gimp','srcover','srcatop'}
			if opacity~=1 % don't waste time if opaque
				outpict=opacity*outpict + BG*(1-opacity);
			end
			
		% VALID FOR 'srcin' ONLY WHEN OPACITY==1
		case 'srcin'
			% outpict=outpict; NOP

		% VALID FOR 'dstout' and 'xor' ONLY WHEN OPACITY==0
		% VALID FOR 'dstin' and 'dstatop' ONLY WHEN OPACITY==1
		case {'dstout','dstin','dstatop','xor','dstover'}
			outpict=BG;

		case 'translucent'
			if opacity~=1
				outpict=invgammac(outpict);
				BG=invgammac(BG);
				FGp=opacity*outpict;
				outpict=FGp + (1-opacity)^2*BG ./ (1-(FGp.*BG)+eps);
				outpict=gammac(outpict);
			end
			
		case {'dissolve','lindissolve'}
			if opacity~=1 || camount~=1
				m=(rand(size(outpict(:,:,1)))+eps<=camount)*opacity;
				outpict=bsxfun(@times,BG,1-m) + bsxfun(@times,outpict,m);
			end
		
		case {'dissolvezf','lindissolvezf'}
			if opacity~=1 || camount~=1
				m=zfdither(ones(size(outpict(:,:,1)))*camount)*opacity;
				outpict=bsxfun(@times,BG,1-m) + bsxfun(@times,outpict,m);
			end
			
		case {'dissolveord','lindissolveord'}
			if opacity~=1 || camount~=1
				m=orddither(ones(size(outpict(:,:,1)))*camount)*opacity;
				outpict=bsxfun(@times,BG,1-m) + bsxfun(@times,outpict,m);
			end
					
		otherwise 
			% this shouldn't ever execute since keys are matched
			error('IMBLEND: unknown composition mode ''%s''',compositionmode);
	end
end

% handle output typecast %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outpict=imcast(outpict,inclassBG);


% returns a transformation matrix oriented along dim3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat=gettfm(transformation)
	switch rec
		case 'rec601'
			switch transformation
				case 'luma'
					mat=[0.299 0.587 0.114];
					
				case 'ypbpr'
					mat=[0.299,0.587,0.114;-0.1687367,-0.331264,0.5;0.5,-0.418688,-0.081312];
					
				case 'ypbpr_inv'
					mat=[1,0,1.402; 1,-0.3441,-0.7141; 1,1.772,0];
			end
		case 'rec709'
			switch transformation
				case 'luma'
					mat=[0.213 0.715 0.072];

				case 'ypbpr'
					mat=[0.213 0.715 0.072; -0.115 -0.385 0.500; 0.500 -0.454 -0.046];
					
				case 'ypbpr_inv'
					mat=[1 0 1.575; 1 -0.187 -0.468; 1 1.856 0];
			end
	end
	mat=permute(mat,[1 3 2]);
end

end

% return a LUT for custom mesh modes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function thisLUT=fetchLUT(whichlut)
	switch whichlut
		case 1 % overlay 1x
			thisLUT=[0,0,0,0,0,0,0,0,0,0,0.0526315789473686,0.157894736842105,0.263157894736842,0.368421052631579,0.473684210526316,0.578947368421053,0.684210526315789,0.789473684210526,0.894736842105263,1;0,0.00554016620498615,0.0110803324099723,0.0166204986149584,0.0221606648199446,0.0277008310249307,0.0332409972299169,0.0387811634349030,0.0443213296398892,0.0498614958448753,0.102493074792244,0.202216066481994,0.301939058171745,0.401662049861496,0.501385041551247,0.601108033240997,0.700831024930748,0.800554016620499,0.900277008310249,1;0,0.0110803324099723,0.0221606648199446,0.0332409972299169,0.0443213296398892,0.0554016620498615,0.0664819944598338,0.0775623268698061,0.0886426592797784,0.0997229916897507,0.152354570637119,0.246537396121884,0.340720221606648,0.434903047091413,0.529085872576177,0.623268698060942,0.717451523545706,0.811634349030471,0.905817174515236,1;0,0.0166204986149584,0.0332409972299169,0.0498614958448753,0.0664819944598338,0.0831024930747922,0.0997229916897507,0.116343490304709,0.132963988919668,0.149584487534626,0.202216066481995,0.290858725761773,0.379501385041551,0.468144044321330,0.556786703601108,0.645429362880887,0.734072022160665,0.822714681440443,0.911357340720222,1;0,0.0221606648199446,0.0443213296398892,0.0664819944598338,0.0886426592797784,0.110803324099723,0.132963988919668,0.155124653739612,0.177285318559557,0.199445983379501,0.252077562326870,0.335180055401662,0.418282548476454,0.501385041551247,0.584487534626039,0.667590027700831,0.750692520775623,0.833795013850416,0.916897506925208,1;0,0.0277008310249307,0.0554016620498615,0.0831024930747922,0.110803324099723,0.138504155124654,0.166204986149584,0.193905817174515,0.221606648199446,0.249307479224377,0.301939058171745,0.379501385041551,0.457063711911357,0.534626038781163,0.612188365650970,0.689750692520776,0.767313019390582,0.844875346260388,0.922437673130194,1;0,0.0332409972299169,0.0664819944598338,0.0997229916897507,0.132963988919668,0.166204986149584,0.199445983379501,0.232686980609418,0.265927977839335,0.299168975069252,0.351800554016621,0.423822714681441,0.495844875346260,0.567867036011080,0.639889196675900,0.711911357340720,0.783933518005540,0.855955678670360,0.927977839335180,1;0,0.0387811634349030,0.0775623268698061,0.116343490304709,0.155124653739612,0.193905817174515,0.232686980609418,0.271468144044321,0.310249307479224,0.349030470914127,0.401662049861496,0.468144044321330,0.534626038781163,0.601108033240997,0.667590027700831,0.734072022160665,0.800554016620499,0.867036011080333,0.933518005540166,1;0,0.0443213296398892,0.0886426592797784,0.132963988919668,0.177285318559557,0.221606648199446,0.265927977839335,0.310249307479224,0.354570637119114,0.398891966759003,0.451523545706371,0.512465373961219,0.573407202216066,0.634349030470914,0.695290858725762,0.756232686980609,0.817174515235457,0.878116343490305,0.939058171745152,1;0,0.0498614958448753,0.0997229916897507,0.149584487534626,0.199445983379501,0.249307479224377,0.299168975069252,0.349030470914127,0.398891966759003,0.448753462603878,0.501385041551247,0.556786703601108,0.612188365650970,0.667590027700831,0.722991689750693,0.778393351800554,0.833795013850415,0.889196675900277,0.944598337950139,1;0,0.0554016620498615,0.110803324099723,0.166204986149585,0.221606648199446,0.277008310249308,0.332409972299169,0.387811634349031,0.443213296398892,0.498614958448754,0.551246537396122,0.601108033240997,0.650969529085873,0.700831024930748,0.750692520775623,0.800554016620499,0.850415512465374,0.900277008310249,0.950138504155125,1;0,0.0609418282548476,0.121883656509695,0.182825484764543,0.243767313019391,0.304709141274238,0.365650969529086,0.426592797783934,0.487534626038781,0.548476454293629,0.601108033240997,0.645429362880887,0.689750692520776,0.734072022160665,0.778393351800554,0.822714681440443,0.867036011080332,0.911357340720222,0.955678670360111,1;0,0.0664819944598338,0.132963988919668,0.199445983379501,0.265927977839335,0.332409972299169,0.398891966759003,0.465373961218837,0.531855955678670,0.598337950138504,0.650969529085873,0.689750692520776,0.728531855955679,0.767313019390582,0.806094182825485,0.844875346260388,0.883656509695291,0.922437673130194,0.961218836565097,1;0,0.0720221606648199,0.144044321329640,0.216066481994460,0.288088642659280,0.360110803324100,0.432132963988920,0.504155124653740,0.576177285318560,0.648199445983380,0.700831024930748,0.734072022160665,0.767313019390582,0.800554016620499,0.833795013850416,0.867036011080333,0.900277008310249,0.933518005540166,0.966759002770083,1;0,0.0775623268698061,0.155124653739612,0.232686980609418,0.310249307479224,0.387811634349031,0.465373961218837,0.542936288088643,0.620498614958449,0.698060941828255,0.750692520775623,0.778393351800554,0.806094182825485,0.833795013850416,0.861495844875346,0.889196675900277,0.916897506925208,0.944598337950139,0.972299168975069,1;0,0.0831024930747922,0.166204986149584,0.249307479224377,0.332409972299169,0.415512465373961,0.498614958448753,0.581717451523546,0.664819944598338,0.747922437673130,0.800554016620499,0.822714681440443,0.844875346260388,0.867036011080333,0.889196675900277,0.911357340720222,0.933518005540166,0.955678670360111,0.977839335180055,1;0,0.0886426592797784,0.177285318559557,0.265927977839335,0.354570637119114,0.443213296398892,0.531855955678670,0.620498614958449,0.709141274238227,0.797783933518006,0.850415512465374,0.867036011080332,0.883656509695291,0.900277008310249,0.916897506925208,0.933518005540166,0.950138504155125,0.966759002770083,0.983379501385042,1;0,0.0941828254847645,0.188365650969529,0.282548476454294,0.376731301939058,0.470914127423823,0.565096952908587,0.659279778393352,0.753462603878116,0.847645429362881,0.900277008310249,0.911357340720222,0.922437673130194,0.933518005540166,0.944598337950139,0.955678670360111,0.966759002770083,0.977839335180055,0.988919667590028,1;0,0.0997229916897507,0.199445983379501,0.299168975069252,0.398891966759003,0.498614958448754,0.598337950138504,0.698060941828255,0.797783933518006,0.897506925207756,0.950138504155125,0.955678670360111,0.961218836565097,0.966759002770083,0.972299168975069,0.977839335180055,0.983379501385042,0.988919667590028,0.994459833795014,1;0,0.105263157894737,0.210526315789474,0.315789473684211,0.421052631578947,0.526315789473684,0.631578947368421,0.736842105263158,0.842105263157895,0.947368421052632,1,1,1,1,1,1,1,1,1,1;];
		case 2 % overlay 2x
			thisLUT=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.157894736842105,0.368421052631579,0.578947368421053,0.789473684210527,1;0,0.000583175389998542,0.00116635077999708,0.00174952616999563,0.00233270155999417,0.00291587694999271,0.00349905233999125,0.00408222772998979,0.00466540311998834,0.00524857850998688,0.0107887447149730,0.0212859017349468,0.0317830587549205,0.0422802157748943,0.0552558682023619,0.244204694561890,0.433153520921417,0.622102347280945,0.811051173640473,1;0,0.00233270155999417,0.00466540311998834,0.00699810467998250,0.00933080623997667,0.0116635077999708,0.0139962093599650,0.0163289109199592,0.0186616124799533,0.0209943140399475,0.0320746464499198,0.0519026097098703,0.0717305729698207,0.0915585362297711,0.157311561452107,0.325849249161685,0.494386936871264,0.662924624580843,0.831462312290422,1;0,0.00524857850998688,0.0104971570199738,0.0157457355299606,0.0209943140399475,0.0262428925499344,0.0314914710599213,0.0367400495699081,0.0419886280798950,0.0472372065898819,0.0638577052048404,0.0918501239247704,0.119842542644700,0.147834961364630,0.253535500801866,0.402828400641493,0.552121300481120,0.701414200320747,0.850707100160373,1;0,0.00933080623997667,0.0186616124799533,0.0279924187199300,0.0373232249599067,0.0466540311998834,0.0559848374398600,0.0653156436798367,0.0746464499198134,0.0839772561597900,0.106137920979735,0.141128444379647,0.176118967779560,0.212713223501968,0.343927686251640,0.475142149001312,0.606356611750984,0.737571074500656,0.868785537250328,1;0,0.0145793847499635,0.0291587694999271,0.0437381542498907,0.0583175389998542,0.0728969237498177,0.0874763084997813,0.102055693249745,0.116635077999708,0.131214462749672,0.158915293774603,0.199737571074501,0.240559848374399,0.314185741361715,0.428488117801429,0.542790494241143,0.657092870680857,0.771395247120571,0.885697623560286,1;0,0.0209943140399475,0.0419886280798950,0.0629829421198425,0.0839772561597900,0.104971570199738,0.125965884239685,0.146960198279633,0.167954512319580,0.188948826359528,0.222189823589445,0.267677504009331,0.313165184429217,0.408660154541478,0.507216795451232,0.605773436360986,0.704330077270739,0.802886718180493,0.901443359090246,1;0,0.0285755941099286,0.0571511882198571,0.0857267823297857,0.114302376439714,0.142877970549643,0.171453564659571,0.200029158769500,0.228604752879428,0.257180346989357,0.295961510424260,0.344948243184138,0.412159206881470,0.496136463041260,0.580113719201050,0.664090975360840,0.748068231520630,0.832045487680420,0.916022743840210,1;0,0.0373232249599067,0.0746464499198134,0.111969674879720,0.149292899839627,0.186616124799533,0.223939349759440,0.261262574719347,0.298585799679253,0.335909024639160,0.380230354279049,0.435486222481411,0.506050444671235,0.576614666861058,0.647178889050882,0.717743111240706,0.788307333430529,0.858871555620353,0.929435777810177,1;0,0.0472372065898819,0.0944744131797638,0.141711619769646,0.188948826359528,0.236186032949410,0.283423239539291,0.330660446129173,0.377897652719055,0.425134859308937,0.475142149001312,0.533459688001166,0.591777227001020,0.650094766000875,0.708412305000729,0.766729844000583,0.825047383000437,0.883364922000292,0.941682461000146,1;0,0.0583175389998542,0.116635077999708,0.174952616999563,0.233270155999417,0.291587694999271,0.349905233999125,0.408222772998980,0.466540311998834,0.524857850998688,0.574865140691063,0.622102347280945,0.669339553870827,0.716576760460709,0.763813967050591,0.811051173640472,0.858288380230354,0.905525586820236,0.952762793410118,1;0,0.0705642221898236,0.141128444379647,0.211692666569471,0.282256888759294,0.352821110949118,0.423385333138942,0.493949555328765,0.564513777518589,0.619769645720951,0.664090975360840,0.701414200320747,0.738737425280653,0.776060650240560,0.813383875200467,0.850707100160373,0.888030325120280,0.925353550080187,0.962676775040093,1;0,0.0839772561597900,0.167954512319580,0.251931768479370,0.335909024639160,0.419886280798950,0.503863536958740,0.587840793118530,0.655051756815862,0.704038489575740,0.742819653010643,0.771395247120572,0.799970841230500,0.828546435340429,0.857122029450357,0.885697623560286,0.914273217670214,0.942848811780143,0.971424405890072,1;0,0.0985566409097536,0.197113281819507,0.295669922729261,0.394226563639014,0.492783204548768,0.591339845458522,0.686834815570783,0.732322495990669,0.777810176410556,0.811051173640472,0.832045487680420,0.853039801720367,0.874034115760315,0.895028429800262,0.916022743840210,0.937017057880157,0.958011371920105,0.979005685960053,1;0,0.114302376439714,0.228604752879429,0.342907129319143,0.457209505758857,0.571511882198571,0.685814258638286,0.759440151625602,0.800262428925499,0.841084706225397,0.868785537250328,0.883364922000292,0.897944306750255,0.912523691500219,0.927103076250182,0.941682461000146,0.956261845750109,0.970841230500073,0.985420615250036,1;0,0.131214462749672,0.262428925499344,0.393643388249016,0.524857850998688,0.656072313748360,0.787286776498032,0.823881032220440,0.858871555620353,0.893862079020265,0.916022743840210,0.925353550080187,0.934684356320163,0.944015162560140,0.953345968800117,0.962676775040093,0.972007581280070,0.981338387520047,0.990669193760023,1;0,0.149292899839627,0.298585799679253,0.447878699518880,0.597171599358507,0.746464499198134,0.852165038635370,0.880157457355300,0.908149876075230,0.936142294795160,0.952762793410118,0.958011371920105,0.963259950430092,0.968508528940079,0.973757107450066,0.979005685960052,0.984254264470039,0.989502842980026,0.994751421490013,1;0,0.168537687709579,0.337075375419157,0.505613063128736,0.674150750838315,0.842688438547893,0.908441463770229,0.928269427030179,0.948097390290130,0.967925353550080,0.979005685960053,0.981338387520047,0.983671089080041,0.986003790640035,0.988336492200029,0.990669193760023,0.993001895320018,0.995334596880012,0.997667298440006,1;0,0.188948826359528,0.377897652719055,0.566846479078583,0.755795305438111,0.944744131797638,0.957719784225106,0.968216941245080,0.978714098265053,0.989211255285027,0.994751421490013,0.995334596880012,0.995917772270010,0.996500947660009,0.997084123050007,0.997667298440006,0.998250473830004,0.998833649220003,0.999416824610002,1;0,0.210526315789474,0.421052631578947,0.631578947368421,0.842105263157895,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
		case 0 % overlay 0x (BG only)
			thisLUT=repmat(0:1/19:1,[20 1]);
		case 3
			thisLUT=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.157894736842105,0.578947368421053,1;0,6.13868831577413e-05,0.000122773766315483,0.000184160649473224,0.000245547532630965,0.000306934415788706,0.000368321298946448,0.000429708182104189,0.000491095065261930,0.000552481948419671,0.00113565733841821,0.00224062123525756,0.00334558513209690,0.00445054902893624,0.00581640717919599,0.0257057573223042,0.0455951074654123,0.283983394848106,0.641991697424053,1;0,0.000491095065261930,0.000982190130523860,0.00147328519578579,0.00196438026104772,0.00245547532630965,0.00294657039157158,0.00343766545683351,0.00392876052209544,0.00441985558735737,0.00675255714735154,0.0109268652020779,0.0151011732568044,0.0192754813115308,0.0331182234636014,0.0685998419287759,0.104081460393950,0.396812486092034,0.698406243046018,1;0,0.00165744584525901,0.00331489169051803,0.00497233753577704,0.00662978338103606,0.00828722922629507,0.00994467507155408,0.0116021209168131,0.0132595667620721,0.0149170126073311,0.0201655911173180,0.0290053022920328,0.0378450134667475,0.0466847246414622,0.0800638423584841,0.127208968623629,0.245677979757675,0.497118653171784,0.748559326585892,1;0,0.00392876052209544,0.00785752104419088,0.0117862815662863,0.0157150420883818,0.0196438026104772,0.0235725631325726,0.0275013236546681,0.0314300841767635,0.0353588446988590,0.0446896509388357,0.0594225028966935,0.0741553548545514,0.0895634625271446,0.144811657369112,0.200059852211079,0.378457808027869,0.585638538685246,0.792819269342624,1;0,0.00767336039471766,0.0153467207894353,0.0230200811841530,0.0306934415788706,0.0383668019735883,0.0460401623683059,0.0537135227630236,0.0613868831577413,0.0690602435524589,0.0836396283024225,0.105125037407632,0.126610446512841,0.165360916506166,0.225520062000752,0.326217570460632,0.494663177845474,0.663108785230316,0.831554392615158,1;0,0.0132595667620721,0.0265191335241442,0.0397787002862163,0.0530382670482884,0.0662978338103606,0.0795574005724327,0.0928169673345048,0.106076534096577,0.119336100858649,0.140330414898597,0.169059476216419,0.197788537534242,0.258101150236723,0.325665088512212,0.460532070809770,0.595399053107327,0.730266035404885,0.865133017702442,1;0,0.0210557009231053,0.0421114018462105,0.0631671027693158,0.0842228036924210,0.105278504615526,0.126334205538632,0.147389906461737,0.168445607384842,0.189501308307947,0.218076902417876,0.254172389714628,0.303696257702136,0.365574235925139,0.469617329517116,0.575693863613693,0.681770397710269,0.787846931806846,0.893923465903423,1;0,0.0314300841767635,0.0628601683535271,0.0942902525302906,0.125720336707054,0.157150420883818,0.188580505060581,0.220010589237345,0.251440673414108,0.282870757590872,0.320193982550778,0.366725239984346,0.428058409619325,0.509764351102278,0.591470292585232,0.673176234068185,0.754882175551139,0.836588117034093,0.918294058517047,1;0,0.0447510378219934,0.0895020756439868,0.134253113465980,0.179004151287974,0.223755189109967,0.268506226931960,0.313257264753954,0.358008302575947,0.402759340397940,0.450134667474927,0.508904934738070,0.570291817895811,0.631678701053552,0.693065584211294,0.754452467369035,0.815839350526776,0.877226233684517,0.938613116842259,1;0,0.0613868831577413,0.122773766315483,0.184160649473224,0.245547532630965,0.306934415788707,0.368321298946448,0.429708182104189,0.491095065261930,0.549865332525073,0.597240659602060,0.641991697424053,0.686742735246046,0.731493773068040,0.776244810890033,0.820995848712027,0.865746886534020,0.910497924356013,0.955248962178007,1;0,0.0817059414829536,0.163411882965907,0.245117824448861,0.326823765931815,0.408529707414768,0.490235648897722,0.571941590380675,0.633274760015654,0.679806017449222,0.717129242409128,0.748559326585892,0.779989410762655,0.811419494939419,0.842849579116182,0.874279663292946,0.905709747469709,0.937139831646473,0.968569915823237,1;0,0.106076534096577,0.212153068193154,0.318229602289731,0.424306136386308,0.530382670482885,0.634425764074861,0.696303742297864,0.745827610285372,0.781923097582124,0.810498691692053,0.831554392615158,0.852610093538263,0.873665794461368,0.894721495384474,0.915777196307579,0.936832897230684,0.957888598153790,0.978944299076895,1;0,0.134866982297558,0.269733964595115,0.404600946892673,0.539467929190230,0.674334911487788,0.741898849763277,0.802211462465758,0.830940523783581,0.859669585101404,0.880663899141351,0.893923465903423,0.907183032665495,0.920442599427567,0.933702166189639,0.946961732951712,0.960221299713784,0.973480866475856,0.986740433237928,1;0,0.168445607384842,0.336891214769684,0.505336822154526,0.673782429539368,0.774479937999248,0.834639083493835,0.873389553487159,0.894874962592368,0.916360371697578,0.930939756447541,0.938613116842259,0.946286477236977,0.953959837631694,0.961633198026412,0.969306558421129,0.976979918815847,0.984653279210565,0.992326639605282,1;0,0.207180730657377,0.414361461314754,0.621542191972130,0.799940147788921,0.855188342630888,0.910436537472856,0.925844645145449,0.940577497103306,0.955310349061164,0.964641155301141,0.968569915823237,0.972498676345332,0.976427436867427,0.980356197389523,0.984284957911618,0.988213718433714,0.992142478955809,0.996071239477905,1;0,0.251440673414108,0.502881346828216,0.754322020242325,0.872791031376371,0.919936157641516,0.953315275358538,0.962154986533253,0.970994697707967,0.979834408882682,0.985082987392669,0.986740433237928,0.988397879083187,0.990055324928446,0.991712770773705,0.993370216618964,0.995027662464223,0.996685108309482,0.998342554154741,1;0,0.301593756953983,0.603187513907966,0.895918539606050,0.931400158071224,0.966881776536399,0.980724518688469,0.984898826743196,0.989073134797922,0.993247442852648,0.995580144412643,0.996071239477905,0.996562334543167,0.997053429608429,0.997544524673690,0.998035619738952,0.998526714804214,0.999017809869476,0.999508904934738,1;0,0.358008302575947,0.716016605151894,0.954404892534588,0.974294242677696,0.994183592820804,0.995549450971064,0.996654414867903,0.997759378764742,0.998864342661582,0.999447518051580,0.999508904934738,0.999570291817896,0.999631678701054,0.999693065584211,0.999754452467369,0.999815839350527,0.999877226233685,0.999938613116842,1;0,0.421052631578947,0.842105263157895,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
		case 4 % overlay 4x
			thisLUT=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.157894736842106,1;0,6.46177717449908e-06,1.29235543489982e-05,1.93853315234972e-05,2.58471086979963e-05,3.23088858724954e-05,3.87706630469945e-05,4.52324402214936e-05,5.16942173959926e-05,5.81559945704917e-05,0.000119542877728233,0.000235854866869216,0.000352166856010200,0.000468478845151183,0.000612253387283789,0.00270586919182149,0.00479948499635919,0.0298929889313796,0.321668479329785,1;0,0.000103388434791985,0.000206776869583971,0.000310165304375956,0.000413553739167941,0.000516942173959926,0.000620330608751912,0.000723719043543897,0.000827107478335882,0.000930495913127867,0.00142159097838980,0.00230039267412167,0.00317919436985355,0.00405799606558542,0.00697225757128451,0.0144420719850054,0.0219118863987264,0.0835394707562177,0.460305908608663,1;0,0.000523403951134425,0.00104680790226885,0.00157021185340328,0.00209361580453770,0.00261701975567213,0.00314042370680655,0.00366382765794098,0.00418723160907540,0.00471063556020983,0.00636808140546885,0.00915956914485245,0.0119510568842360,0.0147425446236197,0.0252833186395213,0.0401712532495672,0.0775825199234763,0.156984837843721,0.576520971092029,1;0,0.00165421495667176,0.00330842991334353,0.00496264487001529,0.00661685982668706,0.00827107478335882,0.00992528974003059,0.0115795046967024,0.0132337196533741,0.0148879346100459,0.0188166951321413,0.0250200012196604,0.0312233073071795,0.0377109315903766,0.0609733294185733,0.0842357272467700,0.159350656011734,0.345745061081968,0.672872530540985,1;0,0.00403861073406193,0.00807722146812385,0.0121158322021858,0.0161544429362477,0.0201930536703096,0.0242316644043715,0.0282702751384335,0.0323088858724954,0.0363474966065573,0.0440208570012750,0.0553289670566484,0.0666370771120217,0.0870320613190345,0.118694769474080,0.171693458137175,0.260349040971302,0.503528736128886,0.751764368064444,1;0,0.00837446321815081,0.0167489264363016,0.0251233896544524,0.0334978528726032,0.0418723160907540,0.0502467793089048,0.0586212425270557,0.0669957057452065,0.0753701689633573,0.0886297357254294,0.106774406031423,0.124919076337416,0.163011252781088,0.205683213797187,0.290862360511434,0.446335546357395,0.630890364238264,0.815445182119132,1;0,0.0155147269959723,0.0310294539919446,0.0465441809879169,0.0620589079838892,0.0775736349798615,0.0930883619758337,0.108603088971806,0.124117815967778,0.139632542963751,0.160688243886856,0.187284918737094,0.223776189885784,0.269370489629050,0.346033821749454,0.464034354038349,0.598025765528761,0.732017177019174,0.866008588509587,1;0,0.0264674393067482,0.0529348786134965,0.0794023179202447,0.105869757226993,0.132337196533741,0.158804635840489,0.185272075147238,0.211739514453986,0.238206953760734,0.269637037937498,0.308821254723660,0.360470239679431,0.432358722328953,0.526965601940795,0.621572481552636,0.716179361164477,0.810786240776318,0.905393120388159,1;0,0.0423957200418885,0.0847914400837769,0.127187160125665,0.169582880167554,0.211978600209442,0.254374320251331,0.296770040293219,0.339165760335108,0.381561480376996,0.426443369186773,0.483057826040073,0.547675597785064,0.612293369530055,0.676911141275046,0.741528913020037,0.806146684765027,0.870764456510018,0.935382228255009,1;0,0.0646177717449909,0.129235543489982,0.193853315234973,0.258471086979963,0.323088858724954,0.387706630469945,0.452324402214936,0.516942173959927,0.573556630813227,0.618438519623004,0.660834239664892,0.703229959706781,0.745625679748670,0.788021399790558,0.830417119832446,0.872812839874335,0.915208559916223,0.957604279958112,1;0,0.0946068796118411,0.189213759223682,0.283820638835523,0.378427518447364,0.473034398059205,0.567641277671046,0.639529760320569,0.691178745276340,0.730362962062502,0.761793046239266,0.788260485546014,0.814727924852762,0.841195364159511,0.867662803466259,0.894130242773007,0.920597682079755,0.947065121386504,0.973532560693252,1;0,0.133991411490413,0.267982822980826,0.401974234471239,0.535965645961652,0.653966178250546,0.730629510370950,0.776223810114216,0.812715081262906,0.839311756113144,0.860367457036249,0.875882184032222,0.891396911028194,0.906911638024166,0.922426365020139,0.937941092016111,0.953455819012083,0.968970546008055,0.984485273004028,1;0,0.184554817880868,0.369109635761737,0.553664453642605,0.709137639488567,0.794316786202813,0.836988747218912,0.875080923662584,0.893225593968577,0.911370264274571,0.924629831036643,0.933004294254794,0.941378757472944,0.949753220691095,0.958127683909246,0.966502147127397,0.974876610345548,0.983251073563698,0.991625536781849,1;0,0.248235631935557,0.496471263871114,0.739650959028698,0.828306541862826,0.881305230525920,0.912967938680966,0.933362922887978,0.944671032943352,0.955979142998725,0.963652503393443,0.967691114127505,0.971729724861567,0.975768335595629,0.979806946329691,0.983845557063752,0.987884167797814,0.991922778531876,0.995961389265938,1;0,0.327127469459016,0.654254938918032,0.840649343988265,0.915764272753230,0.939026670581427,0.962289068409623,0.968776692692820,0.974979998780340,0.981183304867859,0.985112065389954,0.986766280346626,0.988420495303298,0.990074710259969,0.991728925216641,0.993383140173313,0.995037355129985,0.996691570086656,0.998345785043328,1;0,0.423479028907972,0.843015162156279,0.922417480076524,0.959828746750433,0.974716681360479,0.985257455376380,0.988048943115764,0.990840430855148,0.993631918594531,0.995289364439790,0.995812768390925,0.996336172342059,0.996859576293193,0.997382980244328,0.997906384195462,0.998429788146597,0.998953192097731,0.999476596048866,1;0,0.539694091391338,0.916460529243782,0.978088113601274,0.985557928014995,0.993027742428716,0.995942003934415,0.996820805630146,0.997699607325878,0.998578409021610,0.999069504086872,0.999172892521664,0.999276280956456,0.999379669391248,0.999483057826040,0.999586446260832,0.999689834695624,0.999793223130416,0.999896611565208,1;0,0.678331520670216,0.970107011068621,0.995200515003641,0.997294130808179,0.999387746612716,0.999531521154849,0.999647833143990,0.999764145133131,0.999880457122272,0.999941844005430,0.999948305782604,0.999954767559779,0.999961229336953,0.999967691114128,0.999974152891302,0.999980614668477,0.999987076445651,0.999993538222826,1;0,0.842105263157895,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
	end
end

% gamma correction functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=invgammac(channel)
    out=zeros(size(channel));
    mk=(channel<=0.0404482362771076);
    out(mk)=channel(mk)/12.92;
    out(~mk)=real(((channel(~mk)+0.055)/1.055).^2.4);
end

function out=gammac(channel)
    out=zeros(size(channel));
    mk=(channel<=0.0031306684425005883);
    out(mk)=12.92*channel(mk);
    out(~mk)=real(1.055*channel(~mk).^0.416666666666666667-0.055);
end

% bark bark bark