% single precision
clear all
close all
clc
tic
N=8; % NxN DCT 
K=N^2; % number of sub-bands
B=zeros(N^2); % DCT basis functions image
H=zeros(N^2,N,N); % 64x8x8 matrix containing all basis functions

Y=imread('im3_s.jpg'); % Input Image
% extract training examples
[DIM1 DIM2]=size(Y); % DIM1=720, DIM2=1080 for im3_s.jpg
DIM=120;
R=DIM1/DIM*DIM2/DIM; % number of examples
Yr=uint8(zeros(R,DIM,DIM));
r=0; % example counter
for i=1:(DIM1/DIM)
    for j=1:(DIM2/DIM)
        r=r+1; 
        Yr(r,:,:)=Y((i-1)*DIM+1:(i-1)*DIM+DIM,(j-1)*DIM+1:(j-1)*DIM+DIM); % crop smaller image
    end
end
% Create Noisy Image
sigma=0;
Y_current=squeeze(Yr(1,:,:));
X=single(Y_current)+single(randn(DIM)*sigma);
%%%%%%%%%%%%%%%%%%%%
%XB=zeros(N^2,DIM+N-1,DIM+N-1); % Subband images
XB=single(zeros(N^2,DIM,DIM)); % Subband images
T=dctmtx(N); % 1D DCT Matrix
inverse=0;
k=0;
% Build DCT Basis
for n2=1:N
    for n1=1:N
        k=k+1;
        I=zeros(N);
        I(n1,n2)=1;
        dct_basis_function=single(T'*I*T);
        B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
        H(k,:,:)=dct_basis_function;
%       XB(k,:,:)=conv2(double(X),dct_basis_function);
%       inverse=inverse+conv2(dct_basis_function,fliplr(flipud(dct_basis_function)))/N^2;
    end
end
figure(1)
imshow(B,[]) % DCT basis functions

% Analysis 
Range=zeros(K,2); % Range(k,1)= min(band_k), Range(k,2)= max(band_k)
max_range=zeros(R,1); 
min_range=zeros(R,1);
for k=1:K
    for r=1:R
        Y_current=single(squeeze(Yr(r,:,:)));
        XB(k,:,:)=single(conv2(Y_current,single(squeeze(H(k,:,:))),'same'));
        min_range(r)=min(min(squeeze(XB(k,:,:))));
        max_range(r)=max(max(squeeze(XB(k,:,:))));
    end
    Range(k,1)=min(min_range);
    Range(k,2)=max(max_range);    
end

% Synthesis
Ye=0;
for k=1:N^2
    % Multiband reconstruction
    Ye=Ye+conv2(squeeze(XB(k,:,:)),fliplr(flipud(squeeze(H(k,:,:)))))/N^2;
end
Ye=uint8(Ye(N:end-N+1,N:end-N+1)); % Reconstructed Image
%Ye=uint8(Ye(N/2:end-N/2+1,N/2:end-N/2+1)); % Reconstructed Image
figure(3)
imshow(Ye)

%%%%%%%%%%%

% Build L Matrix

l=0; % column counter of L
hi_total=0; % out of range component
M=15; % Number of bins
q=zeros(M+1,K);
L=single(zeros((DIM)^2,N*N*(M+1)));
%L=zeros((DIM+N-1)^2,N*N*(M+1));
for k=1:K
    % Build Hk
    XB_tmp=squeeze(XB(k,:,:));
    [S q(:,k) h]=Sq2(XB_tmp(:),M,Range(k,1),Range(k,2));
    basis_tmp=single(fliplr(flipud(squeeze(H(k,:,:)))));
    for i=1:M+1
        l=l+1;
%         Hi=conv2(reshape(full(S(:,i)),DIM+N-1,DIM+N-1),basis_tmp,'same');
       Hi=single(conv2(single(reshape(full(S(:,i)),DIM,DIM)),basis_tmp,'same'));
        
        L(:,l)= single(Hi(:));
       % hi=conv2(reshape(h,DIM+N-1,DIM+N-1),basis_tmp,'same');
        hi=single(conv2(reshape(single(h),DIM,DIM),basis_tmp,'same'));
        
        hi_total=hi_total+hi;
    end
end
lamda=(0.005*DIM*DIM/M)^2;
Q=q(:);
p=inv(L'*L+lamda*eye(N*N*(M+1)))*(L'*(single(Y_current(:))-hi_total(:))+lamda*Q);
toc
figure(4)
plot(p)

