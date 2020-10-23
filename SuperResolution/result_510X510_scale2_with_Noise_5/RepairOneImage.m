ק
clc; clear; close;
sigma=5;
scaleFactor = 2;
load("SLT_P.mat","H","H_trans","K","N")
load("C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\DATA_SET_GRAY_VECTOR_NORMALIZED\Std"+int2str(sigma)+"\normalized.mat")
netDeNoise = importKerasNetwork("C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\vector-std"+int2str(sigma)+"\Normalized,adam,4layers,256-256-256-256,sigmoid\model.h5");
netSuperResolution = importKerasNetwork("C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\Super Resolution - Python\result_510X510_scale"+int2str(scaleFactor)+"\buildTheNetwork-adam,4layers,256-256-256-256,relu\model.h5");
netDeNoiseAndSuperResolution = importKerasNetwork("model.h5");

Image = imread('C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\grayImageDataSet\image08DataSet.png');
if (size(Image,3) == 3)
    Image = rgb2gray(Image);
end
Image = imcrop(Image,[0,0,510,510]);
[DIM1,DIM2] = size(Image);
ImageDouble = im2double(Image); 
ImageLR = imresize(Image, 1/scaleFactor, 'bicubic');
[DIM1_ImageLR,DIM2_ImageLR] = size(ImageLR);  
ImageLRnoisy = double(ImageLR) + randn(DIM1_ImageLR,DIM2_ImageLR)*sigma;
ImageLRnoisy(ImageLRnoisy<0) = 0;
ImageLRnoisy(ImageLRnoisy>255) = 255;
ImageLRnoisy = uint8(ImageLRnoisy);

%Algorithem1
ImageLRnoisyDoubleAfterDeNoise = im2double(DeNoiseOneImageFunction(ImageLRnoisy,netDeNoise,normalized,H,H_trans,K,N));
ImageDoubleRepairByAlgorithem1 = imresize(ImageLRnoisyDoubleAfterDeNoise,[DIM1,DIM2],'bicubic');

%Algorithem2
UpsampledImageAfterDeNoiseDouble = imresize(ImageLRnoisyDoubleAfterDeNoise,[DIM1,DIM2],'bicubic');
ImageDoubleRepairByAlgorithem2 = im2double(SuperResolutionOneImageFunction(im2uint8(UpsampledImageAfterDeNoiseDouble),netSuperResolution));

%Algorithem3
ImageLRnoisyDouble = im2double(ImageLRnoisy);
UpsampledImageNoisyDouble = imresize(ImageLRnoisyDouble,[DIM1,DIM2],'bicubic'); 
ResidualImageNoisyDoubleRepairByAlgorithem3 =  double(activations(netDeNoiseAndSuperResolution,UpsampledImageNoisyDouble,length(netDeNoiseAndSuperResolution.Layers)));
ImageDoubleRepairByAlgorithem3 = UpsampledImageNoisyDouble + ResidualImageNoisyDoubleRepairByAlgorithem3;

Algorithem1PSNR = psnr(ImageDoubleRepairByAlgorithem1,ImageDouble);
Algorithem2PSNR = psnr(ImageDoubleRepairByAlgorithem2,ImageDouble);
Algorithem3PSNR = psnr(ImageDoubleRepairByAlgorithem3,ImageDouble);
Algorithem1SSIM = ssim(ImageDoubleRepairByAlgorithem1,ImageDouble);
Algorithem2SSIM = ssim(ImageDoubleRepairByAlgorithem2,ImageDouble);
Algorithem3SSIM = ssim(ImageDoubleRepairByAlgorithem3,ImageDouble);

image1 = subplot(1,4,1);
imshow(ImageLRnoisy);
title({'Image Low','Resolution Noisy'});
image2 = subplot(1,4,2);
imshow(im2uint8(ImageDoubleRepairByAlgorithem1));
title({'Algorithem 1:',[' psnr = ',num2str(Algorithem1PSNR)],[' ssim = ',num2str(Algorithem1SSIM)]});
image3 = subplot(1,4,3);
imshow(im2uint8(ImageDoubleRepairByAlgorithem2));
title({'Algorithem 2:',[' psnr = ',num2str(Algorithem2PSNR)],[' ssim = ',num2str(Algorithem2SSIM)]});
image4 = subplot(1,4,4);
imshow(im2uint8(ImageDoubleRepairByAlgorithem3));
title({'Algorithem 2:',[' psnr = ',num2str(Algorithem3PSNR)],[' ssim = ',num2str(Algorithem3SSIM)]});
linkaxes([image1,image2,image3,image4]);
