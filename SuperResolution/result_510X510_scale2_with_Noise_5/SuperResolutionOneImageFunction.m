function ImageRepair = SuperResolutionOneImageFunction(ImageLR,netSuperResolution) 
    UpsampledImageDouble = imresize(im2double(ImageLR),[510,510],'bicubic');
    ResidualImageDoubleRepairByNet = double(activations(netSuperResolution,UpsampledImageDouble,length(netSuperResolution.Layers)));
    ImageDoubleRepairByNet = UpsampledImageDouble + ResidualImageDoubleRepairByNet;
    ImageRepair = im2uint8(ImageDoubleRepairByNet);
end