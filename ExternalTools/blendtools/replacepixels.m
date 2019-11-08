function outpict=replacepixels(newcolor,inpict,mask)
%   REPLACEPIXELS(NEWCOLOR, INPICT, MASK)
%   REPLACEPIXELS(NEWPICT, INPICT, MASK)
%       returns a copy of INPICT with all selected pixels replaced by NEWCOLOR.
%       alternatively, replacement can be sourced from NEWPICT
%       mask may be logical or intensity
%       mask can be specified using multimask() or findpixels()
%
%   INPICT is an image or 4-D image array (I/IA or RGB/RGBA)
%   NEWCOLOR is a 3-element row vector specifying the replacement color
%   NEWPICT is an image array (I/IA or RGB/RGBA)
%   MASK is an image or 4-D array specifying pixel locations to replace
%       MASK can have 1,2,3, or 4 channels, depending on dim3 of INPICT
%
%   CLASS SUPPORT:
%       inputs may be 'uint8','uint16','int16','single','double', or 'logical'
%
%       return class matches INPICT class unless NEWCOLOR contains NaN
%       when sum(isnan(newcolor))~=0, return class is double
%       Using NaN in NEWCOLOR invokes extra dimension restrictions and speed penalties


% safeguard things so bsxfun doesn't explode
try
	[mask maskclass]=imcast(mask,'double');
catch b
	error('REPLACEPIXELS: Unsupported image class for MASK')
end
try
	[inpict inclass]=imcast(inpict,'double');
catch b
	error('REPLACEPIXELS: Unsupported image class for INPICT')
end
try
	newcolor=imcast(newcolor,'double');
catch b
	error('REPLACEPIXELS: Unsupported image class for NEWPICT/NEWCOLOR')
end

% expanding inputs and mask along dimension 3 is solved with bsxfun later
if mod(size(inpict,3),size(mask,3))~=0
	fprintf('MASK has %d channels\nINPICT has %d channels\n',size(mask,3),size(inpict,3));
    error('REPLACEPIXELS: dim3 of INPICT must be integer multiple of dim3 of MASK')
end

% check if height & width match
sFG=size(newcolor);
sBG=size(inpict);
sMASK=size(mask); 
if any(sFG(1:2)~=sBG(1:2)) && numel(newcolor)~=3
    error('REPLACEPIXELS: fg/bg dimension mismatch')
elseif any(sBG(1:2)~=sMASK(1:2)) 
    error('REPLACEPIXELS: mask/image dimension mismatch')
end

if numel(newcolor)==3
	newcolor=reshape(newcolor,[1 1 3]);
	iscolor=1;
else
	iscolor=0;
end

% multiplicative masking doesn't work with NaNs
logmask=strcmp(maskclass,'logical');
mch=size(mask,3);
mfr=size(mask,4);
nch=size(newcolor,3);
nfr=size(newcolor,4);

if sum(sum(sum(sum(isnan(inpict)))))~=0 && logmask
	mask=logical(mask);
	a=zeros(size(inpict));
	for f=1:size(inpict,4)
		mf=min(f,mfr);
		for c=1:size(inpict,3)
			mc=min(c,mch);
			
			thism=logical(1-mask(:,:,mc,mf));
			
			inchan=inpict(:,:,c,f);
			outchan=a(:,:,c,f);
			outchan(thism)=inchan(thism);
			
			a(:,:,c,f)=outchan;
		end
	end
else 
	a=bsxfun(@times,inpict,1-mask);
end
if sum(sum(sum(isnan(newcolor))))~=0 && logmask
	mask=logical(mask);
	b=zeros(size(inpict));
	for f=1:size(inpict,4)
		mf=min(f,mfr);
		nf=min(f,nfr);
		for c=1:size(inpict,3)
			mc=min(c,mch);
			nc=min(c,nch);
			outchan=b(:,:,c,f);
			if iscolor
				outchan(mask(:,:,mc,mf))=newcolor(:,:,c);
			else
				inchan=newcolor(:,:,nc,nf);
				outchan(mask(:,:,mc,mf))=inchan(mask(:,:,mc,mf));
			end
			
			b(:,:,c,f)=outchan;
		end
	end
else 
	b=bsxfun(@times,newcolor,mask);
end

outpict=bsxfun(@plus,a,b);

% int classes do not support NaN
if sum(sum(sum(isnan(outpict))))~=0
	disp('REPLACEPIXELS: output contain NaNs; Output class forced double.')
    inclass='double';
end

outpict=imcast(outpict,inclass);

end











