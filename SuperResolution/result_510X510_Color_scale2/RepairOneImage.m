clc; clear; close;
net = importKerasNetwork('.\buildTheNetwork-adam,4layers,256-256-256-256,relu\model.h5');
scaleFactor = 3;
ImageRGB = imread('C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\colorImageDataSet\colorImage24DataSet.png');
if (size(ImageRGB,3) ~= 3)
    ImageRGB = cat(3,ImageRGB,ImageRGB,ImageRGB);
end
ImageRGB = imcrop(ImageRGB,[0,0,510,510]);
ImageRGBDouble = im2double(ImageRGB);     
ImageYCbCrDouble = rgb2ycbcr(ImageRGBDouble);
ImageYDouble = ImageYCbCrDouble(:,:,1);
ImageCbDouble = ImageYCbCrDouble(:,:,2);
ImageCrDouble = ImageYCbCrDouble(:,:,3);

ImageRGBDoubleLR = imresize(ImageRGBDouble,1/scaleFactor,'bicubic');
UpsampledImageRGBDouble = imresize(ImageRGBDoubleLR,scaleFactor,'bicubic');
UpsampledImageYCbCrDouble = rgb2ycbcr(UpsampledImageRGBDouble);
UpsampledImageYDouble = UpsampledImageYCbCrDouble(:,:,1);

ResidualImageYDouble =  double(activations(net,UpsampledImageYDouble,length(net.Layers)));
ImageYDoubleRepairByNet = UpsampledImageYDouble + ResidualImageYDouble;

BicubicPSNR = psnr(UpsampledImageYDouble,ImageYDouble);
NetworkPSNR = psnr(ImageYDoubleRepairByNet,ImageYDouble);
BicubicSSIM = ssim(UpsampledImageYDouble,ImageYDouble);
NetworkSSIM = ssim(ImageYDoubleRepairByNet,ImageYDouble);

UpsampledImageCbDouble = UpsampledImageYCbCrDouble(:,:,2);
UpsampledImageCrDouble = UpsampledImageYCbCrDouble(:,:,3);

ImageYCbCrDoubleRepairByNet = cat(3,ImageYDoubleRepairByNet,UpsampledImageCbDouble,UpsampledImageCrDouble);
ImageRGBDoubleRepairByNet = ycbcr2rgb(ImageYCbCrDoubleRepairByNet);

UpsampledImageYCbCrDouble = cat(3,UpsampledImageYDouble,UpsampledImageCbDouble,UpsampledImageCrDouble);
UpsampledImageRGBDouble = ycbcr2rgb(UpsampledImageYCbCrDouble);

image1 = subplot(1,3,1);
imshow(im2uint8(ImageRGBDoubleLR));
title({'Image Low','Resolution'});
image2 = subplot(1,3,2);
imshow(im2uint8(UpsampledImageRGBDouble));
title({'Bicubic:',[' psnr = ',num2str(BicubicPSNR)],[' ssim = ',num2str(BicubicSSIM)]});
image3 = subplot(1,3,3);
imshow(im2uint8(ImageRGBDoubleRepairByNet));
title({'Network:',[' psnr = ',num2str(NetworkPSNR)],[' ssim = ',num2str(NetworkSSIM)]});
linkaxes([image1,image2,image3])
