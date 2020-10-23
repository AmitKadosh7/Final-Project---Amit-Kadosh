clc
clear
close

N = 16; % NxN DCT 
K = N^2; % number of sub-bands
B = zeros(N^2); % DCT basis functions image
H = zeros(N^2,N,N); % 81x9x9 matrix containing all basis functions
H_trans = H; % % 81x9x9 matrix containing all transposed basis functions

T=dctmtx(N); % 1D DCT Matrix
k=0;
% Build DCT Basis
for n2=1:N
    for n1=1:N
        k = k+1;
        I = zeros(N);
        I(n1,n2) = 1;
        dct_basis_function = single(T'*I*T)/N;
        B((n1-1)*N+1:(n1-1)*N+N,(n2-1)*N+1:(n2-1)*N+N) = dct_basis_function;
        H(k,:,:) = dct_basis_function;
        H_trans(k,:,:) = fliplr(flipud(dct_basis_function));
    end
end

for i = 1:K
    H_new_dim(:,:,1,i) = squeeze(H(i,:,:));
    H_trans_new_dim(:,:,i) = squeeze(H_trans(i,:,:));
end

save('H_and_Htrans_for_python_9x9', 'H_new_dim', 'H_trans_new_dim')