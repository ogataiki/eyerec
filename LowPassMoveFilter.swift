import GPUImage

class LowPassMoveFilter : GPUImageFilterGroup
{
    var lowPassFilter: GPUImageLowPassFilter;
    var frameComparisonFilter: GPUImageTwoInputFilter;
    var averageColor: GPUImageAverageColor;

    var lowPassFilterStrength: CGFloat = 0.5;
    var motionDetectionBlock: ((motionCentroid: CGPoint, motionIntensity: CGFloat, frameTime: CMTime) -> Void)? = nil;
    
    override init() {
        
        // Start with a low pass filter to define the component to be removed
        lowPassFilter = GPUImageLowPassFilter();
        
        // Take the difference of the current frame from the low pass filtered result to get the high pass
        frameComparisonFilter = GPUImageTwoInputFilter(fragmentShaderFromFile: "LowPassMoveFilter");
        
        // Texture location 0 needs to be the original image for the difference blend
        lowPassFilter.addTarget(frameComparisonFilter, atTextureLocation:1);
        
        // End with the average color for the scene to determine the centroid
        averageColor = GPUImageAverageColor();
        
        self.lowPassFilterStrength = 0.5;
        
        super.init();
        
        self.addFilter(lowPassFilter);
        self.addFilter(frameComparisonFilter);

        unowned var weakSelf: LowPassMoveFilter = self;
        
        averageColor.colorAverageProcessingFinishedBlock = {(redComponent: CGFloat, greenComponent: CGFloat, blueComponent: CGFloat, alphaComponent: CGFloat, frameTime: CMTime) -> Void in
            if weakSelf.motionDetectionBlock != nil {
                weakSelf.motionDetectionBlock!(motionCentroid: CGPointMake(redComponent / alphaComponent, greenComponent / alphaComponent), motionIntensity: alphaComponent, frameTime: frameTime);
            }
        }

        self.frameComparisonFilter.addTarget(averageColor);

        self.initialFilters = [lowPassFilter, frameComparisonFilter];
        self.terminalFilter = frameComparisonFilter;
    }
}