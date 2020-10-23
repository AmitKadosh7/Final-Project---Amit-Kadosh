function  psnr=psnr(im,noiseim,maxval)
dif=double(im(:))-double(noiseim(:));
avdif2=mean(dif.*dif);
psnr=10*(log10((maxval^2)/(avdif2)));