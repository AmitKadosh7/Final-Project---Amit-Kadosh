function b=bin2(x,q)
b=zeros(size(x));
for i=1:length(q)-1
    values_in_current_bin=find( (x>=q(i)) & (x<q(i+1)));
    b(values_in_current_bin)=i;
end

    
