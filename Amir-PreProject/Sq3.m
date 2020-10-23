function [S, q, h]=Sq3(x,M,a,b)
% Symmetric MF
x=double(x);
N=length(x);
h=zeros(size(x));
% Creat Uniform Grid
t=0:1/M:1; 
t=t.^3;
q=t'*(b-a)+a; 
%%%%%%%%%%%%%%%%%%%%%%%

bin_indexes_vector=bin3(x,q);
out_of_range=find(bin_indexes_vector==0);
in_range=find(bin_indexes_vector~=0);
h(out_of_range)=x(out_of_range);
R=res3(x,q,bin_indexes_vector);
NN=1:N;
sign_x=sign(x(in_range));
Term_1=sign_x.*(1-R(in_range));
Term_2=sign_x.*R(in_range);
S=sparse([NN(in_range) NN(in_range)],[bin_indexes_vector(in_range); bin_indexes_vector(in_range)+1],[Term_1; Term_2],N,M+1);

function r=res3(x,q,bin_indexes_vector)
N=length(x);
M=length(q);
in_range=find(bin_indexes_vector~=0);
NN=1:N;
A=sparse(NN(in_range),bin_indexes_vector(in_range),ones(length(in_range),1),N,M);
A1=sparse(NN(in_range),bin_indexes_vector(in_range)+1,ones(length(in_range),1),N,M);
sign_x=sign(x);
r=(sign_x.*x-A*q)./(A1*q-A*q);
