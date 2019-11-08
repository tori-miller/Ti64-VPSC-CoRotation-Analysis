function outpict=rgb2hsy(inpict,mode)
%   RGB2HSY(INPICT, {MODE})
%       Convert an rgb image to a normalized polar adaptation of YPbPr
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
%       'normal' normalizes and bounds to the extent of the projected RGB space (HSY) (default)
%       'pastel' normalizes and bounds to the maximal biconic subset of the projected RGB space (HSYp)
%       'native' normalizes as in 'pastel' mode, but bounds as in 'normal' mode (HSYn)
%
%   Output is of type double, in the range:
%       H \in [0 360)
%       S \in [0 1]
%       Y \in [0 1]
%
%   See also: HSY2RGB, RGB2HUSL, HUSL2RGB, RGB2LCH, LCH2RGB, MAXCHROMA, CSVIEW.

% Since this method uses a LUT to normalize S, this dimension is quantized.
% if some smaller step size is desired, modify 'st'

if ~exist('mode','var')
    mode='normal';
end

st=255; % <<< change this to alter LUT size
A=[0.299,0.587,0.114;-0.1687367,-0.331264,0.5;0.5,-0.418688,-0.081312];
Axyz=circshift(A,-1);

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

% do YPbPr transform here just to save 12ms
pict=imcast(inpict,'double');
A=permute(A,[1 3 2]);
yc(:,:,1)=sum(bsxfun(@times,pict,A(1,:,:)),3);
yc(:,:,2)=sum(bsxfun(@times,pict,A(2,:,:)),3);
yc(:,:,3)=sum(bsxfun(@times,pict,A(3,:,:)),3);

H=mod(atan2(yc(:,:,3),yc(:,:,2)),2*pi); % color angle
C=sqrt(yc(:,:,3).^2+yc(:,:,2).^2); % color magnitude
Y=yc(:,:,1);
S=zeros(size(C));

% normalize and clamp S
if strcmpi(mode,'normal')
    Hp=round(H/(2*pi)*st)+1;
    Yp=round(Y*st)+1;
    cm=Cmax(sub2ind([1 1]*st+1,Hp,Yp));
    mask=(cm<1/512);
    S(~mask)=C(~mask)./cm(~mask);
    S=min(S,1);
elseif strcmpi(mode,'pastel')
    Yp=round(Y*st)+1;
    cp=Cpastel(Yp);
    mask=(cp<1/512);
    S(~mask)=C(~mask)./cp(~mask);
    S=min(S,1);
elseif strcmpi(mode,'native') 
    Hp=round(H/(2*pi)*st)+1;
    Yp=round(Y*st)+1;
    cm=Cmax(sub2ind([1 1]*st+1,Hp,Yp));
    cp=Cpastel(Yp);
    mask=(cm<1/512);
    S(~mask)=C(~mask)./cp(~mask);
    S=min(S,cm./cp);
end

    
% align output H with cube corner
% instead of PbPr plane
H=mod(H-rd,2*pi); 
H=H*180/pi;

outpict=cat(3,H,S,Y);

end








