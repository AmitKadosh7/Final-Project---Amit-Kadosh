function  [binMap,binEdges]=calcSepFiltLUT_opt3(im,nim,filtMat,binsNum,rstrength,binType,nsigma,varWeight)

%   [binMap,binEdges]=calcSepFiltLUT_opt3(im,nim,filtMat,binsNum,rstrength,binType)
% 
% Calculates  LUTs using option3: 
% OPTION3: g*\sum_i {f'_i*LUT_i(f_i*nim) }= im  where g is a correction term
% Note, the correction term in option3 is delta if the set {f_i) has flat response.
% 
% im - clean image
% nim - noisy image
% filtMat - seperable filters to be applied
% binsNum - number of bins in the SLT
% rstrength - regularization parameter (should be in [0 1])
% binType - The SLT type, can be either 'constant' or 'linear'
%
% binEdges - a vector array in which each vector represents the edges of
% the corresponding SLT
%binMap - a vector array in which each vector represents the mapping of the
%corresponding SLT
% 
% Last modified: Y. Hel-Or, 31.07.05, written by D. Shaked Oct 07.
% ---
% 

if ~exist('binType')
    binType='linear';  %default
end;

wsize=size(filtMat,1);

total_memory=1e7;
im_size=length(im(:));
frac_size=total_memory/(binsNum*wsize^2);
ndivs=ceil(im_size/frac_size);   % K denotes the number of image divisions  (for saving memory);

frac_size=ceil(im_size/ndivs);

% image_frac defines the indices of each image fraction
image_frac=cell(ndivs,1);
for i=1:ndivs-1,
    image_frac{i}=[frac_size*(i-1)+1 : frac_size*i ]';
end;
image_frac{ndivs}=[frac_size*(ndivs-1)+1 : im_size]';

% calculate the LUTs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b=zeros(size(im(:)));
idle_lutVec=[];

% calculate b , edges , and lutVec_0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = waitbar(0,'Computing b...1st of 3 waitbars');

for i=1:wsize,
    for j=1:wsize,
        waitbar(((i-1)*wsize+j)/wsize^2,h)

        cfilt=filtMat(i,:)' ;
        rfilt=filtMat(j,:) ;

        fim=sepConv2(cfilt,rfilt,im);
        cfim=sepConjConv2(cfilt,rfilt,fim);

        b=b+cfim(:);

    end;
end;
close (h);
clear fim cfim;
pack;

% for k=1:ndivs
%     eval(['save MComp' num2str(k) ' ndivs;']);
% end

IntFactor = (2^15-1)/wsize;

% if 1
binEdges=zeros(binsNum+1,wsize,wsize);
h = waitbar(0,'Storing M matrices ... 2 of 3 waitbars');
set(h,'Color', [0.5 0.5 0])

FID = zeros(1,ndivs);
for k=1:ndivs
    FID(k) = fopen(['Tmp\MCompDump' num2str(k)],'wb');
end

for i=1:wsize,
    for j=1:wsize,
        CompNumber=(i-1)*wsize+j;
        waitbar((CompNumber-1)/wsize^2,h);

        cfilt=filtMat(i,:)' ;
        rfilt=filtMat(j,:) ;

        fnim=sepConv2(cfilt,rfilt,nim);
        [fn_binIm,edges,fn_residual]=SLT(fnim,binsNum,binType);
        binEdges(:,i,j)=edges;
        cfn_binIm=sepConjConv2binIm(cfilt,rfilt,fn_binIm,size(im));
        cfn_residual=sepConjConv2(cfilt,rfilt,reshape(fn_residual,size(im)));
        b=b-cfn_residual(:);
        
        if max(abs(cfn_binIm(:)))*IntFactor > (2^15-1)
            error('IntFactor is wrong');
        end;

        set(h,'Color', [0.8 0.8 0.8])
        for k=1:ndivs
            waitbar((k+ndivs*(CompNumber-1))/(ndivs*wsize^2),h)
            Count = fwrite(FID(k), cfn_binIm(image_frac{k},:)*IntFactor, 'int16');
            if (Count~=prod(size(cfn_binIm(image_frac{k},:))))
                ThisisAproblem=1;
            end
            %             eval(['M' num2str(CompNumber) '=cfn_binIm(image_frac{' num2str(k) '},:);']);
            %             eval(['save MComp' num2str(k) ' M' num2str(CompNumber) ' -APPEND;']);
        end

        set(h,'Color', [0.5 0.5 0])

        switch binType
            case 'constant'
                lutVec0=(edges(1:end-1)+edges(2:end))/2;
            case 'linear'
                lutVec0=edges;
            case 'try'
                lutVec0=[ edges(:) ; 1] ;
        end;

        idle_lutVec=[idle_lutVec ; lutVec0(:)];

    end;
end;

close (h);
fclose all;

%     for k=1:ndivs
%         fclose(FID(k));
%     end

switch binType
    case 'constant'
        domain_size=binsNum;
    case 'linear'
        domain_size=binsNum+1;
    case 'try'
        domain_size=binsNum+2;
end;

% else
%     for i=1:wsize,
%         for j=1:wsize,
%             edges=binEdges(:,i,j);
%
%             bin_cent=(edges(1:end-1)+edges(2:end))/2;
%             bin_cent=bin_cent(:);
%             lutVec0=bin_cent;
%
%             idle_lutVec=[idle_lutVec ; lutVec0];
%         end
%     end
% end


% calculates the M matrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lutVec_dims=length(idle_lutVec);
MtM=zeros(lutVec_dims,lutVec_dims);
Mtb=zeros(lutVec_dims,1);
h = waitbar(0,'Computing M matrices ... 3 of 3 waitbars');
% set(h,'Color', [0.5 0.5 0])

for k=1:ndivs,   % construction MtM and Mtb from stored data

    waitbar((k-1)/ndivs,h)
    %     eval(['load MComp' num2str(k)]);
    M=[];

    set(h,'Color', [0.8 0.8 0.8])
    %     for i=1:wsize,
    %         for j=1:wsize,
    %             CompNumber=(i-1)*wsize+j;
    %             waitbar(((k-1)*wsize^2+CompNumber)/(ndivs*wsize^2),h)
    %
    %             eval(['M = [M M' num2str(CompNumber) '];']);
    %
    %         end;
    %     end;

    ThisFID = fopen(['Tmp\MCompDump' num2str(k)],'r');
    M=fread(ThisFID,[length(image_frac{k})  wsize^2*domain_size], 'int16');
    M = double(M)/IntFactor;
    fclose(ThisFID);

    set(h,'Color', [0.5 0.5 0])
    MtM=MtM+M'*M;
    Mtb=Mtb+M'*b(image_frac{k});

end;


close(h);
for k=1:ndivs
    system( ['del ' 'Tmp\MCompDump' num2str(k)] );
end;
pack;

imlength=length(im(:));
eps=(rstrength*imlength/binsNum); %regularization strength
eps=eps*eps;

lutVec=pinv(MtM+eps*eye(size(idle_lutVec,1)))*(Mtb(:)+eps*idle_lutVec);   % calculate the LUT option2
binMap=zeros(domain_size,wsize,wsize);

save  MtMFile MtM Mtb idle_lutVec wsize binsNum imlength binEdges ;

ind=0;
for i=1:wsize,
    for j=1:wsize,
        binMap(:,i,j)=lutVec(ind*domain_size+1 : (ind+1)*domain_size);
        ind=ind+1;
    end;
end;

