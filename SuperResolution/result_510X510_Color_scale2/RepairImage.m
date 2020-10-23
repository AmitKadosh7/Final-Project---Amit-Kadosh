clc; clear; close all;
net = importKerasNetwork('C:\Users\user\Desktop\Studies\Semester 8\myProject\SuperResolution\result_510X510_scale2\buildTheNetwork-adam,4layers,256-256-256-256,relu\model.h5');
scaleFactor = 2;

TestImagesSetNames = {'DIV2K_valid_HR','Urban100','Manga109','Flickr1024/Test'};
Num_of_Sets_Test_Images = length(TestImagesSetNames);
PSNR = cell(3,Num_of_Sets_Test_Images+1); 
SSIM = cell(3,Num_of_Sets_Test_Images+1);
PSNR{2,1}='PSNR_Bicubic';PSNR{3,1}='PSNR_Network';
PSNR{1,2}='DIV2K_valid_HR';PSNR{1,3}='Urban100';PSNR{1,4}='Manga109';PSNR{1,5}='Flickr1024/Test';
SSIM{2,1}='SSIM_Bicubic';PSNR{3,1}='SSIM_Network';
SSIM{1,2}='DIV2K_valid_HR';SSIM{1,3}='Urban100';SSIM{1,4}='Manga109';SSIM{1,5}='Flickr1024/Test';
    
for numSet=1:Num_of_Sets_Test_Images
    testImages = imageDatastore("C:\Users\user\Desktop\Studies\Semester 8\myProject\SuperResolution\training_and_testing_imageDataSets\" + TestImagesSetNames{numSet} + "\",'FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
    numImage = length(testImages.Files);
    for i=1:numImage
        [ImageRGB,info] = read(testImages);
        [~,fileName,~] = fileparts(info.Filename);
        disp(fileName);   
        if (size(ImageRGB,3) ~= 3)
            ImageRGB = cat(3,ImageRGB,ImageRGB,ImageRGB);
        end
        ImageRGB = imcrop(ImageRGB,[0,0,510,510]);
        ImageRGBDouble = im2double(ImageRGB);     
        ImageYCbCrDouble = rgb2ycbcr(ImageRGBDouble);
        ImageYDouble = ImageYCbCrDouble(:,:,1);

        ImageRGBDoubleLR = imresize(ImageRGBDouble,1/scaleFactor,'bicubic');
        UpsampledImageRGBDouble = imresize(ImageRGBDoubleLR,scaleFactor,'bicubic');
        UpsampledImageYCbCrDouble = rgb2ycbcr(UpsampledImageRGBDouble);
        UpsampledImageYDouble = UpsampledImageYCbCrDouble(:,:,1);

        ResidualImageYDouble =  double(activations(net,UpsampledImageYDouble,length(net.Layers)));
        ImageYDoubleRepairByNet = UpsampledImageYDouble + ResidualImageYDouble;

        BicubicPSNR(i) = psnr(UpsampledImageYDouble,ImageYDouble);
        NetworkPSNR(i) = psnr(ImageYDoubleRepairByNet,ImageYDouble);
        BicubicSSIM(i) = ssim(UpsampledImageYDouble,ImageYDouble);
        NetworkSSIM(i) = ssim(ImageYDoubleRepairByNet,ImageYDouble);
    end
    PSNR{2,numSet+1} = mean(BicubicPSNR);
    PSNR{3,numSet+1} = mean(NetworkPSNR);
    SSIM{2,numSet+1} = mean(BicubicSSIM);
    SSIM{3,numSet+1} = mean(NetworkSSIM);  
end
save PSNR PSNR
save SSIM SSIM
