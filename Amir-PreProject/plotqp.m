indexes=[1 10 19 28 37 46 55 64];
for i=1:8
    subplot(2,4,i)
    plot(q(1:16,indexes(i)),P(1:16,indexes(i)),'r',q(1:16,indexes(i)),q(1:16,indexes(i)),'b')
    t=strcat('Mapping Function (',num2str(i),',',num2str(i),')');
    title(t)
end
