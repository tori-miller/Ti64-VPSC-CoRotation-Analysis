function outpict=lch2rgb(inpict,varargin)
%   LCH2RGB(INPICT, {MODE}, {LIMIT}, {NOGC}, {WP})
%       Convert a LCH image to sRGB. LCH variant may be CIELUV, CIELAB, or SRLAB2
%       
%   INPICT is a single LCH image (of known type)
%   MODE is either 'luv' (default), 'lab', or 'srlab'
%   LIMIT options include:
%       'notruncate' performs no data truncation (default)
%       'truncatergb' limits color points to RGB data ranges when in RGB
%       'truncatelch' limits color points to RGB data ranges when in LCH 
%       'truncatelchcalc' is the same as 'truncatelch', but uses direct calculations instead of a LUT
%           (see maxchroma() documentation for details)
%   NOGC option can be used to disable gamma correction of the output
%       this is primarily intended to be used to speed up the calculations involved
%       in checking whether points are in-gamut.  (about 30% faster)
%   WP optionally allows the selection of the white point
%       'D65' (default) 
%       'D50' uses an adapted (Bradford) sRGB-XYZ matrix
%       D50 method is not compatible with 'truncatelch' option
%
%   This code formed as an interpretation of Pascal Getreuer's COLORSPACE() and other files.
%   Information on SRLAB2 can be found at http://www.magnetkern.de/srlab2.html
%
%   See also: RGB2HSY, HSY2RGB, RGB2HUSL, HUSL2RGB, RGB2LCH, MAXCHROMA, CSVIEW.

% doing chroma limiting while in LCH is the only practical way I can think of to handle OOG points
% when converting back to sRGB.  Using a wider gamut doesn't solve the fact that the projection 
% of a cube isn't rotationally symmetric.  LUV can be bound with simple line intersection calculations
% since the level curves of the RGB gamut are straight lines in LUV.
% The edges, level curves and meridians of the projection in LAB are not straight lines.  
% segregation of faces can't be done by angle alone either.  
% I'm left to offload the bisection task and use a LUT.

for k=1:length(varargin);
    switch lower(varargin{k})
        case 'notruncate'
            truncate='none';
        case 'truncatergb'
            truncate='rgb';
        case 'truncatelch'
            truncate='lch';
        case 'truncatelchcalc'
            truncate='lchcalc';
        case {'lab','luv','srlab'}
            mode=varargin{k};
        case 'nogc'
            nogc=true;
        case 'd65'
            thiswp='d65';
        case 'd50'
            thiswp='d50'; 
        otherwise
            disp(sprintf('LCH2RGB: unknown option %s',varargin{k}))
            return
    end
end

if ~exist('truncate','var')
    truncate='none';
end
if ~exist('mode','var')
    mode='luv';
end
if ~exist('nogc','var')
    nogc=false;
end
if ~exist('thiswp','var')
    thiswp='d65';
end

H=inpict(:,:,3);
C=inpict(:,:,2);
L=inpict(:,:,1);

if strcmpi(truncate,'lch')
    Cnorm=maxchroma(lower(mode(mode~=' ')),'l',L,'h',H);
    C=min(max(C,0),Cnorm);
end
if strcmpi(truncate,'lchcalc')
    Cnorm=maxchroma([lower(mode(mode~=' ')) 'calc'],'l',L,'h',H);
    C=min(max(C,0),Cnorm);
end

% convert to LUV/LAB from LCH
Hrad=H*pi/180;
inpict(:,:,3)=sin(Hrad).*C; % V/B
inpict(:,:,2)=cos(Hrad).*C; % U/A

switch thiswp
    case 'd65'
        WP=[0.950470 1 1.088830];
        
        % sRGB > XYZ (D65)
        Ainv=[3.240454162114103 -1.537138512797715 -0.49853140955601; ...   
            -0.96926603050518 1.876010845446694 0.041556017530349; ...
            0.055643430959114 -0.20402591351675 1.057225188223179];
        
        % Adobe 1998
        %Ainv=[ 2.0413690 -0.5649464 -0.3446944; ...
        %    -0.9692660  1.8760108  0.0415560; ...
        %    0.0134474 -0.1183897  1.0154096];
    case 'd50'
        WP=[0.964220 1 0.825210];
        % sRGB > XYZ (D50)
        Ainv=[3.1338561 -1.6168667 -0.4906146; ...
            -0.9787684  1.9161415  0.0334540; ...
            0.0719453 -0.2289914  1.4052427];
            
        % Wide Gamut RGB
        %Ainv=[1.4628067 -0.1840623 -0.2743606; ...
        %    -0.5217933  1.4472381  0.0677227; ...
        %     0.0349342 -0.0968930  1.2884099];
end

if strcmpi(mode,'luv')
    % CIELUV to CIEXYZ
    refd=dot([1 15 3],WP);
    refU=4*WP(1)/refd;
    refV=9*WP(2)/refd;
    
    U=inpict(:,:,2);
    V=inpict(:,:,3);
    
    fY=(L+16)/116;
    Y=invf(fY);
    
    mk=(L==0);
    U=U./(13*L + 1E-6*mk) + refU;
    V=V./(13*L + 1E-6*mk) + refV;
    
    X=-(9*Y.*U)./((U-4).*V - U.*V);
    Z=(9*Y - (15*V.*Y) - (V.*X))./(3*V);
    
elseif strcmpi(mode,'lab')
    % CIELAB to CIEXYZ   
    A=inpict(:,:,2);
    B=inpict(:,:,3);
    
    fY=(L+16)/116;
    fX=fY+A/500;
    fZ=fY-B/200;
    
    X=invf(fX);
    Y=invf(fY);
    Z=invf(fZ);
    
    X=X*WP(1);
    Z=Z*WP(3);
elseif strcmpi(mode,'srlab')
    % SRLAB2 to CIEXYZ
    L=inpict(:,:,1);
    A=inpict(:,:,2);
    B=inpict(:,:,3);
    
    Mcat02=[0.7328, 0.4296, -0.1624;
            -0.7036, 1.6975, 0.0061; 
            0.0030, 0.0136, 0.9834];

    Mhpe=[0.38971 0.68898 -0.07868;
            -0.22981 1.18340 0.04641; 
            0 0 1];
    
    % equivalent to first coefficient matrix in ref implementation's SRLAB>RGB function    
        Msr2p=Mhpe/[0 100 0; 500/1.16 -500/1.16 0; 0 200/1.16 -200/1.16];
    
    % equivalent to second coefficient matrix in ref implementation's SRLAB>RGB function 
    % (after extracting XYZ conversion matrix)
        Msrp=inv(Mhpe*(Mcat02\diag(Mcat02*(1./WP'))*Mcat02));
        
    fX=L*Msr2p(1,1)+A*Msr2p(1,2)+B*Msr2p(1,3);
    fY=L*Msr2p(2,1)+A*Msr2p(2,2)+B*Msr2p(2,3);
    fZ=L*Msr2p(3,1)+A*Msr2p(3,2)+B*Msr2p(3,3);
    
    Xp=invf(fX);
    Yp=invf(fY);
    Zp=invf(fZ);
    
    X=Xp*Msrp(1,1)+Yp*Msrp(1,2)+Zp*Msrp(1,3);
    Y=Xp*Msrp(2,1)+Yp*Msrp(2,2)+Zp*Msrp(2,3);
    Z=Xp*Msrp(3,1)+Yp*Msrp(3,2)+Zp*Msrp(3,3);
    
end

% CIEXYZ to RGB
R=X*Ainv(1,1)+Y*Ainv(1,2)+Z*Ainv(1,3);
G=X*Ainv(2,1)+Y*Ainv(2,2)+Z*Ainv(2,3);
B=X*Ainv(3,1)+Y*Ainv(3,2)+Z*Ainv(3,3);

if ~nogc
    R=gammac(R);
    G=gammac(G);
    B=gammac(B);
end

% truncate rgb even if truncating lch
% this cleans up oog points in LAB/SRLAB undercuts
if ~strcmpi(truncate,'none')
    R=min(max(R,0),1);
    G=min(max(G,0),1);
    B=min(max(B,0),1);
end

outpict=cat(3,R,G,B);

end

function out=gammac(channel)
    out=zeros(size(channel));
    mk=(channel<=0.0031306684425005883);
    out(mk)=12.92*channel(mk);
    out(~mk)=real(1.055*channel(~mk).^0.416666666666666667-0.055);
end

function Y=invf(fY)
    ep=216/24389;
    kp=24389/27;
    Y=fY.^3;
    my=(Y<ep);
    Y(my)=(116*fY(my)-16)/kp;
end

