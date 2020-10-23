clc;
clear;
close all;

scaleFactor = 3;

trainUpsampledDirName = '.\trainUpsampledImages';
trainResidualDirName = '.\trainResidualImages';
validationUpsampledDirName = '.\validationUpsampledImages';
validationResidualDirName = '.\validationResidualImages';

if ~isfolder(trainUpsampledDirName)
    mkdir(trainUpsampledDirName);
end
if ~isfolder(trainResidualDirName)
    mkdir(trainResidualDirName);
end
if ~isfolder(validationUpsampledDirName)
    mkdir(validationUpsampledDirName);
end
if ~isfolder(validationResidualDirName)
    mkdir(validationResidualDirName);
end

dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\imagesDirForTrainAndValidation510x510','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
%dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\iaprtc12\00-10','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
%dsImages = imageDatastore('imagesForTry','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);

numImage = length(dsImages.Files);

endIndexTrain = round(0.8*numImage);

for i=1:numImage
    [Image,info] = read(dsImages);
    [~,fileName,~] = fileparts(info.Filename);
    disp(fileName);   
    if (size(Image,3) == 3)
        Image = rgb2gray(Image);
    end
    Image = imcrop(Image,[0,0,510,510]);
    [DIM1,DIM2] = size(Image);
    ImageDouble = im2double(Image);
    
    UpsampledImageDouble = imresize(imresize(ImageDouble,1/scaleFactor,'bicubic'),[DIM1,DIM2],'bicubic');
    
    ResidualImageDouble = ImageDouble - UpsampledImageDouble;
    
    if (i < endIndexTrain)
        save([trainUpsampledDirName filesep fileName '.mat'], 'UpsampledImageDouble');
        save([trainResidualDirName filesep fileName '.mat'], 'ResidualImageDouble'); 
    else
        save([validationUpsampledDirName filesep fileName '.mat'], 'UpsampledImageDouble');
        save([validationResidualDirName filesep fileName '.mat'], 'ResidualImageDouble'); 
    end
end