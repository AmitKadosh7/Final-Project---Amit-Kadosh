clc; clear; close all;

load SLT_P %Loading H,H_trans,K
sigma = 25; %Standard deviation
data = 0;
label = 0;

for k=1:K
    dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\Denoising\grayImageDataSet',...
        'FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true); %Load all the image paths from the folder
    dataAndLabel = cell(1,2);
    for i=1:length(dsImages.Files)
        [Image,info] = read(dsImages); %Reading an image from the folder into the variable 'Image'
        [~,fileName,~] = fileparts(info.Filename);
        disp(fileName);   
        if (size(Image,3) == 3) %If the image is color scale, we will convert it to gray scale
            Image = rgb2gray(Image);
        end
        [DIM1,DIM2] = size(Image);
        ImageNoisy = double(Image) + randn(DIM1,DIM2)*sigma; %Make the image noisy
        ImageNoisy(ImageNoisy<0) = 0;
        ImageNoisy(ImageNoisy>255) = 255;
        ImageNoisy = uint8(ImageNoisy);
        
        ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(k,:,:))))); %Two-dimensional convolution to the noisy image with a particular filter
        ImageAfterHk = double(conv2(Image,double(squeeze(H(k,:,:))))); %Two-dimensional convolution to the noise-free image with a particular filter
        dataAndLabel{1,1} = [dataAndLabel{1,1};reshape(ImageNoisyAfterHk.', [], 1)];
        dataAndLabel{1,2} = [dataAndLabel{1,2};reshape(ImageAfterHk.', [], 1)];
    end
    nameFile = "DataSetScalarStd25\" + int2str(k-1) + ".mat";
    save(nameFile, 'dataAndLabel');
end