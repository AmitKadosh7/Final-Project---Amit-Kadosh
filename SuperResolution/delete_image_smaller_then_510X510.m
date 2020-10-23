clc;
clear;

dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\imagesDirForTrainAndValidation510x510','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
numImage = length(dsImages.Files);
scaleFactor = 2;
for i=1:numImage
    [Image,info] = read(dsImages);
    [~,fileName,~] = fileparts(info.Filename);
    disp(fileName);   
    if (size(Image,3) == 3)
        Image = rgb2gray(Image);
    end
    Image = imcrop(Image,[0,0,512,512]);
    [DIM1,DIM2] = size(Image);
    ImageDouble = im2double(Image);
    UpsampledImageDouble = imresize(imresize(ImageDouble,1/scaleFactor,'bicubic'),[DIM1,DIM2],'bicubic');
    s = size(UpsampledImageDouble);
    if (s(1)<512 || s(2)<512)
        cell_file_name = dsImages.Files(i);
        delete(cell_file_name{1})
    end
end

