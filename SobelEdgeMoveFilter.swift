import GPUImage

class SobelEdgeMoveFilter : GPUImageSobelEdgeDetectionFilter
{
    override init() {
        var fragmentShaderPathname = NSBundle.mainBundle().pathForResource("SobelEdgeMoveFilter", ofType: "fsh");
        var fragmentShaderString = NSString(contentsOfFile: fragmentShaderPathname!, encoding: NSUTF8StringEncoding, error: nil);
        super.init(fragmentShaderFromString: fragmentShaderString as! String);
    }    
}

