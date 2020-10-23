clc; clear; close all;

load SLT_P
sigma = 25;
Test_Image = {'barbara.png','boat.png','fingerprint.png','house.png','lena.png','peppers256.png'};
Num_of_Test_Images = length(Test_Image);
Num_iteration_for_average = 10;
PSNR = zeros(Num_of_Test_Images,Num_iteration_for_average+1);
SSIM = zeros(Num_of_Test_Images,Num_iteration_for_average+1);
netCell = {};

net = importKerasNetwork("model.h5");

for iteration=1:Num_iteration_for_average
    disp(iteration);
    for i=1:Num_of_Test_Images 
        Image = imread("C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\" + Test_Image{i});
        [DIM1,DIM2] = size(Image);
        ImageNoisy = double(Image) + randn(DIM1,DIM2)*sigma;
        ImageNoisy(ImageNoisy<0) = 0;
        ImageNoisy(ImageNoisy>255) = 255;
        ImageNoisy = uint8(ImageNoisy);
        ImageRepair = 0;
        %for size
        ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(1,:,:)))));
        [DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk] = size(ImageNoisyAfterHk); 
        inputMatrix = zeros(K,DIM1ImageNoisyAfterHk*DIM2ImageNoisyAfterHk);
        for k=1:K
            ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(k,:,:)))));
            [DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk] = size(ImageNoisyAfterHk);
            inputMatrix(k,:) = ImageNoisyAfterHk(:).';
        end
        inputMatrix = (net.Layers(2).Weights)*inputMatrix + repmat((net.Layers(2).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(4).Weights)*inputMatrix + repmat((net.Layers(4).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(6).Weights)*inputMatrix + repmat((net.Layers(6).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(8).Weights)*inputMatrix + repmat((net.Layers(8).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(10).Weights)*inputMatrix + repmat((net.Layers(10).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(12).Weights)*inputMatrix + repmat((net.Layers(12).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (net.Layers(14).Weights)*inputMatrix + repmat((net.Layers(14).Bias), 1, length(inputMatrix));
        for k=1:K
            ImageNoisyAfterHkAfterNet = inputMatrix(k,:);
            ImageNoisyAfterHkAfterNet = reshape(ImageNoisyAfterHkAfterNet,DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk);
            ImageRepair = ImageRepair + double(conv2(ImageNoisyAfterHkAfterNet,double(squeeze(H_trans(k,:,:)))));
        end
        ImageRepair = uint8(ImageRepair(N:end-N+1,N:end-N+1));
        PSNR(i,iteration) = psnr(Image,ImageRepair);
        SSIM(i,iteration) = ssim(Image,ImageRepair);
        if iteration==1
            ImageNoisy = uint8(ImageNoisy);
            figure(i); subplot(1,3,1); imshow(Image); title('Image');
            subplot(1,3,2); imshow(ImageNoisy); title('ImageNoisy');
            subplot(1,3,3); imshow(ImageRepair); title('ImageRepair');
            saveas(figure(i), "result" + Test_Image(i) + ".fig");
        end
    end
end
for i=1:Num_of_Test_Images 
    PSNR(i,Num_iteration_for_average+1) = mean(PSNR(i,1:Num_iteration_for_average));
    SSIM(i,Num_iteration_for_average+1) = mean(SSIM(i,1:Num_iteration_for_average));
end
save PSNR PSNR
save SSIM SSIM