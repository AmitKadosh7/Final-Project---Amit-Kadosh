% single precision, multiple patches, with out of range treatment
clear all
close all
clc
tic
N=8; % NxN DCT 
K=N^2; % number of sub-bands
B=zeros(N^2); % DCT basis functions image
H=zeros(N^2,N,N); % 64x8x8 matrix containing all basis functions
H_trans=H; % % 64x8x8 matrix containing all transposed basis functions
l=0; % column counter of L
hi_total=0; % out of range component
M=15; % Number of bins
q=zeros(M+1,K);

X=imread('im3_s.jpg'); % Training Image
% Create Noisy Image
sigma=20;
Y=single(X)+single(randn(size(X))*sigma); % Noisy Training Image
% extract training examples
[DIM1 DIM2]=size(X); % DIM1=720, DIM2=1080 for im3_s.jpg
DIM=240;
R=floor(DIM1/DIM)*floor(DIM2/DIM); % number of examples
Xr=single(zeros(R,DIM,DIM)); % clean example pathces
Yr=single(zeros(R,DIM,DIM)); % noisy example pathces
YB=zeros(K,DIM+N-1,DIM+N-1); % Subband noisy images
XB=zeros(K,DIM+N-1,DIM+N-1); % Subband clean images

Range=zeros(K,2); % Range(k,1)= min(band_k), Range(k,2)= max(band_k)
max_range=zeros(R,1); 
min_range=zeros(R,1);

% Extarct patches
r=0; % example counter
for i=1:floor(DIM1/DIM)
    for j=1:floor(DIM2/DIM)
        r=r+1; 
        Xr(r,:,:)=X((i-1)*DIM+1:(i-1)*DIM+DIM,(j-1)*DIM+1:(j-1)*DIM+DIM); % crop smaller image
        Yr(r,:,:)=Y((i-1)*DIM+1:(i-1)*DIM+DIM,(j-1)*DIM+1:(j-1)*DIM+DIM); % crop smaller image
    end
end


T=dctmtx(N); % 1D DCT Matrix
inverse=0;
k=0;
% Build DCT Basis
for n2=1:N
    for n1=1:N
        k=k+1;
        I=zeros(N);
        I(n1,n2)=1;
        dct_basis_function=single(T'*I*T)/N;
        B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
        H(k,:,:)=dct_basis_function;
        H_trans(k,:,:)=fliplr(flipud(dct_basis_function));
    end
end


% SLT range calculation per band

for k=1:K
    for r=1:R
        Y_current=single(squeeze(Yr(r,:,:)));
        YB(k,:,:)=single(conv2(Y_current,single(squeeze(H(k,:,:)))));
        min_range(r)=min(min(squeeze(YB(k,:,:))));
        max_range(r)=max(max(squeeze(YB(k,:,:))));
    end
    Range(k,1)=min(min_range);
    Range(k,2)=max(max_range); 
    if k>1
        Range_Length=Range(k,2)-Range(k,1);
        Range_Middle=Range(k,1)+Range_Length/2;
        New_Range_Length=0.98*Range_Length; % Use 98% of full range
        New_Min=Range_Middle-New_Range_Length/2;
        New_Max=Range_Middle+New_Range_Length/2;
        Range(k,1)=New_Min;
        Range(k,2)=New_Max;
    end
end

LL=0; % L'*L
L_Trans=0; %L'(x-h)
for r=1:R
    r
    Y_current=squeeze(Yr(r,:,:));
    X_current=squeeze(Xr(r,:,:));
    L=single(zeros((DIM+2*N-2)^2,N*N*(M+1)));
    L_Trans_X=zeros(K*(M+1),1);
    l=0;
    L_Trans_h=0;
    h_e=0;
    for k=1:K
        k
        % Multiband decomposition
        tmp_conv_Y=single(conv2(single(Y_current),single(squeeze(H(k,:,:)))));
        tmp_conv_X=single(conv2(single(X_current),single(squeeze(H(k,:,:)))));

        YB(k,:,:)=tmp_conv_Y;
        YB_tmp=squeeze(YB(k,:,:));
        
        [Sy q(:,k) hy]=Sq2(YB_tmp(:),M,Range(k,1),Range(k,2));
        basis_tmp=squeeze(H_trans(k,:,:));
        for i=1:M+1
            l=l+1;
            Hi=single(conv2(single(reshape(full(Sy(:,i)),DIM+N-1,DIM+N-1)),basis_tmp));
            L(:,l)= single(Hi(:));
        end
        % L_Transpose_X calculation
        XB(k,:,:)=tmp_conv_X;
        XB_tmp=squeeze(XB(k,:,:));
        [Sx q(:,k) hx]=Sq2(XB_tmp(:),M,Range(k,1),Range(k,2));
        L_Trans_X((k-1)*(M+1)+1:k*(M+1)) = single(full(Sy)')*XB_tmp(:);
        % calc out-of-range subbadn k componenet of L_Transpose
        Bh=single(conv2(single(reshape(hx,DIM+N-1,DIM+N-1)),basis_tmp));
        h_e=h_e+Bh(:);
        
    end
    L_Trans_h=L'*h_e;
    LL=LL+L'*L;
    clear L
    L_Trans=L_Trans+L_Trans_X-L_Trans_h;
    clear Y_current X_current L_Trans_X L_Trans_h
    
end

lamda=(0.005*DIM*DIM/M)^2;
Q=q(:);
p=inv(LL+lamda*eye(K*(M+1)))*(L_Trans+lamda*Q);
toc
figure(4)
plot(p)

save SLT_P N M K p q H H_trans Range sigma