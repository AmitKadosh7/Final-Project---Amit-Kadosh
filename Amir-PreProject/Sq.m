function [S q h]=Sq(x,M,a,b)
N=length(x);
h=zeros(size(x));
% Creat Uniform Grid
t=0:1/M:1; 
q=t'*(b-a)+a; 
%%%%%%%%%%%%%%%%%%%%%%%
S=zeros(N,M+1);
c=bin2(x,q);
out_of_range=find(c==0);
h(out_of_range)=x(out_of_range);
for i=1:N
    for j=1:M+1
        if c(i)==j
            S(i,j+1)=res(x(i),q,c(i));
        elseif c(i)==j+1
            S(i,j+1)=1-res(x(i),q,c(i));
        end
    end
end
function r=res(x,q,bin_indexes)

r=(x-q(bin_index))./(q(bin_index+1)-q(bin_index));
