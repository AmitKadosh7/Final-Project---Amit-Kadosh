function ImageRGBRepairByNet = SuperResolutionOneImageFunction(ImageRGBLR,netSuperResolution,scaleFactor) 
    UpsampledImageRGBDouble = imresize(im2double(ImageRGBLR),scaleFactor,'bicubic');
    UpsampledImageYCbCrDouble = rgb2ycbcr(UpsampledImageRGBDouble);
    UpsampledImageYDouble = UpsampledImageYCbCrDouble(:,:,1);

    ResidualImageYDouble =  double(activations(net,UpsampledImageYDouble,length(net.Layers)));
    ImageYDoubleRepairByNet = UpsampledImageYDouble + ResidualImageYDouble;
    
    UpsampledImageCbDouble = UpsampledImageYCbCrDouble(:,:,2);
    UpsampledImageCrDouble = UpsampledImageYCbCrDouble(:,:,3);

    ImageYCbCrDoubleRepairByNet = cat(3,ImageYDoubleRepairByNet,UpsampledImageCbDouble,UpsampledImageCrDouble);
    ImageRGBDoubleRepairByNet = ycbcr2rgb(ImageYCbCrDoubleRepairByNet);
    ImageRGBRepairByNet = im2uint8(ImageRGBDoubleRepairByNet);
end