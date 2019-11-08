function outpict=hsy2rgb(inpict,mode)
%   HSY2RGB(INPICT, {MODE})
%       Extract an rgb image from a normalized polar adaptation of YPbPr
%       This is offered as an unconventional alternative to HuSL or
%       LCH for general image editing without causing large perceived
%       brightness distortions when changing hue/saturation
%
%       This actually uses YPbPr just for numeric convenience
%       Chroma is normalized and clamped in this method.
%
%       Normalization forces color points to stay within the RGB cube.
%       This prevents clipping when rotating H for points with high S.
%       Furthermore, it mimics HuSL behavior in that S is bounded.
%       One could debate whether this is desired behavior.
%
%       HSYp variant is normalized and bounded to the maximum biconic subset of the projected RGB space.  
%       This means HSYp avoids distortion of the chroma space when normalizing, preserving the uniformity 
%       of the parent space. Unfortunately, this also means it can only render colors near the neutral axis (pastels). 
%
%       HSYn variant is still normalized WRT the maximal rotationally-symmetric subset as in HSYp
%       but specified chroma is bound only by the extent of the projected RGB space.  In this mode, 
%       100% S still refers to the extent of HSYp, but color points can be specified with S>100%, 
%       so long as they stay within the RGB cube. This allows uniform access to the entire projected RGB space, 
%       unlike HSYp; it also allows for data truncation to occur before conversion, unlike YPbPr methods.
%
%       HSYp and HSYn are mostly useful for relative specification of uniform colors.
%
%   MODE specifies the normalization and bounding behavior.  
%       'normal' normalizes to the extent of the projected RGB space (HSY) (default)
%       'pastel' normalizes to the maximal biconic subset of the projected RGB space (HSYp)
%       'native' normalizes as in 'pastel' mode, but bounds as in 'normal' mode (HSYn)
%
%   INPICT is of type double, in the range:
%       H \in [0 360)
%       S \in [0 1]
%       Y \in [0 1]
%   
%   Output is of type double, in the range [0 1]
%
%   See also: RGB2HSY, RGB2HUSL, HUSL2RGB, RGB2LCH, LCH2RGB, MAXCHROMA, CSVIEW.

% Since this method uses a LUT to normalize S, this dimension is quantized.
% if some smaller step size is desired, modify 'st'


if ~exist('mode','var')
    mode='normal';
end

st=255; % <<< change this to alter LUT size
A=[0.299,0.587,0.114;-0.1687367,-0.331264,0.5;0.5,-0.418688,-0.081312];
Axyz=circshift(A,-1);
Ai=permute(inv(A),[1 3 2]);
    
% calculate maximal boundary
if any(strcmpi(mode,{'normal','native'}))
    % color angles
    bl=mod(atan2(A(3,3),A(2,3)),2*pi);
    mg=mod(atan2(A(3,3)+A(3,1),A(2,3)+A(2,1)),2*pi);
    rd=mod(atan2(A(3,1),A(2,1)),2*pi);
    yl=mod(atan2(A(3,1)+A(3,2),A(2,1)+A(2,2)),2*pi);
    gr=mod(atan2(A(3,2),A(2,2)),2*pi);
    cy=mod(atan2(A(3,2)+A(3,3),A(2,2)+A(2,3)),2*pi);
    % black point is at [0 0 0]
    % white point is at [0 0 1]

    % magenta, yellow, cyan corner vectors
    vmg=Axyz(:,1)+Axyz(:,3)-[0 0 1]';
    vyl=Axyz(:,1)+Axyz(:,2)-[0 0 1]';
    vcy=Axyz(:,2)+Axyz(:,3)-[0 0 1]';

    % normals for lower, upper planes
    nr0=cross(Axyz(:,2),Axyz(:,3));
    nb0=cross(Axyz(:,1),Axyz(:,2));
    ng0=cross(Axyz(:,3),Axyz(:,1));
    nr1=cross(vmg,vyl);
    ng1=cross(vyl,vcy);
    nb1=cross(vcy,vmg);

    % find maximal boundaries for S(H,Y)
    y=0:1/st:1; h=0:(2*pi)/st:(2*pi);
    [Y H]=meshgrid(y,h);
    a=cos(H);
    b=sin(H);
    kt=zeros(size(H)); kb=kt;
    % bottom planes G=0, B=0, R=0
    mask=H>=bl | H<rd;
    kb(mask)=-ng0(3)*Y(mask)./(ng0(1)*a(mask) + ng0(2)*b(mask));
    mask=H>=rd & H<gr;
    kb(mask)=-nb0(3)*Y(mask)./(nb0(1)*a(mask) + nb0(2)*b(mask));
    mask=H>=gr & H<bl;
    kb(mask)=-nr0(3)*Y(mask)./(nr0(1)*a(mask) + nr0(2)*b(mask));
    % top planes R=1, G=1, B=1
    mask=H>=mg & H<yl;
    kt(mask)=(nr1(3)-nr1(3)*Y(mask))./(nr1(1)*a(mask) + nr1(2)*b(mask));
    mask=H>=yl & H<cy;
    kt(mask)=(ng1(3)-ng1(3)*Y(mask))./(ng1(1)*a(mask) + ng1(2)*b(mask));
    mask=H>=cy | H<mg;
    kt(mask)=(nb1(3)-nb1(3)*Y(mask))./(nb1(1)*a(mask) + nb1(2)*b(mask));

    % find limiting radius from min parameter value
    k=min(kt,kb);
    Cmax=sqrt((a.*k).^2 + (b.*k).^2);
end

% calculate biconic boundary
if any(strcmpi(mode,{'pastel','native'}))
    rd=mod(atan2(A(3,1),A(2,1)),2*pi);
    Ybreak=0.50195313;
    Cbreak=0.28211668;
    Y=0:1/st:1;
    Cpastel=zeros(size(Y));
    
    mk=Y<Ybreak;
    Cpastel(mk)=Cbreak/Ybreak*Y(mk);
    Cpastel(~mk)=Cbreak-Cbreak/(1-Ybreak)*(Y(~mk)-Ybreak);
end

H=mod(inpict(:,:,1),360)*pi/180;
S=max(inpict(:,:,2),0);
Y=max(min(inpict(:,:,3),1),0);
C=zeros(size(S));

% align H with PbPr plane
% instead of cube corner
H=mod(H+rd,2*pi); 

% clamp and denormalize S
if strcmpi(mode,'normal')
    Hp=round(H/(2*pi)*st)+1;
    Yp=round(Y*st)+1;
	
	Hp(isnan(Hp))=1;
	cm=Cmax(sub2ind([1 1]*st+1,Hp,Yp)); % explodes here if hue is NaN
	
    S=min(S,1);
    mask=(cm<1/512);
    C(~mask)=S(~mask).*cm(~mask);
elseif strcmpi(mode,'pastel')
    Yp=round(Y*st)+1;
    cp=Cpastel(Yp);
    S=min(S,1);
    mask=(cp<1/512);
    C(~mask)=S(~mask).*cp(~mask);
elseif strcmpi(mode,'native') 
    Hp=round(H/(2*pi)*st)+1;
    Yp=round(Y*st)+1;

	Hp(isnan(Hp))=1;
	cm=Cmax(sub2ind([1 1]*st+1,Hp,Yp)); % explodes here if hue is NaN
		
    cp=Cpastel(Yp);
    S=min(S,cm./cp);
    mask=(cm<1/512);
    C(~mask)=S(~mask).*cp(~mask);
end

yc(:,:,2)=C.*cos(H); % B
yc(:,:,3)=C.*sin(H); % R
yc(:,:,1)=Y;

% do YPbPr transform here just to save 12ms
pict(:,:,1)=sum(bsxfun(@times,yc,Ai(1,:,:)),3);
pict(:,:,2)=sum(bsxfun(@times,yc,Ai(2,:,:)),3);
pict(:,:,3)=sum(bsxfun(@times,yc,Ai(3,:,:)),3);

outpict=max(min(pict,1),0);

end



