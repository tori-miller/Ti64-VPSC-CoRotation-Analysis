function outpict=rgb2lch(rgb,varargin)
%   RGB2LCH(INPICT, {MODE}, {LIMIT}, {NOGC}, {WP})
%       Convert an sRGB image to the cylindrical mappings of CIELUV, CIELAB, or SRLAB2
%       
%   INPICT is a single RGB image 
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
%   See also: RGB2HSY, HSY2RGB, RGB2HUSL, HUSL2RGB, LCH2RGB, MAXCHROMA, CSVIEW.

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
            disp(sprintf('RGB2LCH: unknown option %s',varargin{k}))
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

rgb=imcast(rgb,'double');
R=rgb(:,:,1);
G=rgb(:,:,2);
B=rgb(:,:,3);

if ~nogc
    R=invgammac(R);
    G=invgammac(G);
    B=invgammac(B);
end

if strcmpi(truncate,'rgb')
    R=min(max(R,0),1);
    G=min(max(G,0),1);
    B=min(max(B,0),1);
end

switch thiswp
    case 'd65'
        % sRGB > XYZ (D65)
        A=[0.412456439089691 0.357576077643907 0.180437483266397; ...
            0.212672851405621 0.715152155287816 0.072174993306558; ...
            0.019333895582328 0.119192025881300 0.950304078536368];
        WP=[0.950470 1 1.088830];
    case 'd50'
        % sRGB > XYZ (D50)
        A=[0.4360747  0.3850649  0.1430804; ...
            0.2225045  0.7168786  0.0606169; ...
            0.0139322  0.0971045  0.7141733];
        WP=[0.964220 1 0.825210];
end
%WP=sum(A,2)';

% RGB to CIEXYZ
X=R*A(1,1)+G*A(1,2)+B*A(1,3);
Y=R*A(2,1)+G*A(2,2)+B*A(2,3);
Z=R*A(3,1)+G*A(3,2)+B*A(3,3);

if strcmpi(mode,'luv')
    % CIEXYZ to CIELUV
    refd=dot([1 15 3],WP);
    refU=4*WP(1)/refd;
    refV=9*WP(2)/refd;

    D=X + 15*Y + 3*Z;
    mk=(D==0);
    U=4*X./(D+mk);
    V=9*Y./(D+mk);

    L=116*f(Y)-16;
    U=13*L.*(U-refU);
    V=13*L.*(V-refV);
    
    outpict=cat(3,L,U,V);
    
elseif strcmpi(mode,'lab')
    % CIEXYZ to CIELAB    
    X=X/WP(1);
    Z=Z/WP(3);
    
    fX=f(X);
    fY=f(Y);
    fZ=f(Z);
    
    L=116*fY-16;
    A=500*(fX-fY);
    B=200*(fY-fZ);

    outpict=cat(3,L,A,B);
elseif strcmpi(mode,'srlab')
    % CIEXYZ to SRLAB2
    Mcat02=[0.7328, 0.4296, -0.1624;
            -0.7036, 1.6975, 0.0061; 
            0.0030, 0.0136, 0.9834];

    Mhpe=[0.38971 0.68898 -0.07868;
            -0.22981 1.18340 0.04641; 
            0 0 1];
    
    % equivalent to first coefficient matrix in ref implementation's RGB>SRLAB function 
    % (after extracting XYZ conversion matrix)
    Msr=Mhpe*(Mcat02\diag(Mcat02*(1./WP'))*Mcat02);
    
    % equivalent to second coefficient matrix in ref implementation's RGB>SRLAB function
    Msr2=[0 100 0; 500/1.16 -500/1.16 0; 0 200/1.16 -200/1.16]/Mhpe;

    % XYZ to X'Y'Z'
    Xp=X*Msr(1,1)+Y*Msr(1,2)+Z*Msr(1,3);
    Yp=X*Msr(2,1)+Y*Msr(2,2)+Z*Msr(2,3);
    Zp=X*Msr(3,1)+Y*Msr(3,2)+Z*Msr(3,3);
    
    fX=f(Xp);
    fY=f(Yp);
    fZ=f(Zp);
    
    L=fX*Msr2(1,1)+fY*Msr2(1,2)+fZ*Msr2(1,3);
    A=fX*Msr2(2,1)+fY*Msr2(2,2)+fZ*Msr2(2,3);
    B=fX*Msr2(3,1)+fY*Msr2(3,2)+fZ*Msr2(3,3);
    
    outpict=cat(3,L,A,B);
end

% convert to polar LCHuv/LCHab
Hrad=mod(atan2(outpict(:,:,3),outpict(:,:,2)),2*pi);
H=Hrad*180/pi;
C=sqrt(outpict(:,:,2).^2 + outpict(:,:,3).^2);

if strcmpi(truncate,'lch')
    Cnorm=maxchroma(lower(mode(mode~=' ')),'l',L,'h',H);
    C=min(max(C,0),Cnorm);
end
if strcmpi(truncate,'lchcalc')
    Cnorm=maxchroma([lower(mode(mode~=' ')) 'calc'],'l',L,'h',H);
    C=min(max(C,0),Cnorm);
end

outpict(:,:,2)=C;
outpict(:,:,3)=H;

end

% for phi=12.9232102, K0=0.0392857, half-functions are slope and value-continuous at intersection (tangent)
% for phi=12.92, K0=0.0404483, half-functions are only value-continuous (but this is per sRGB standard)
function out=invgammac(channel)
    out=zeros(size(channel));
    mk=(channel<=0.0404482362771076);
    out(mk)=channel(mk)/12.92;
    out(~mk)=real(((channel(~mk)+0.055)/1.055).^2.4);
end

function fY=f(Y)
    ep=216/24389;
    kp=24389/27;
    my=(Y<ep);
    fY=real(Y.^(1/3));
    fY(my)=(kp*Y(my)+16)/116;
end


