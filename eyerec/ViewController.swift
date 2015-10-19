import UIKit
import AVFoundation
import AssetsLibrary
import GPUImage
import MobileCoreServices

class ViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
{

    @IBOutlet weak var left_image: UIImageView!
    @IBOutlet weak var right_image: UIImageView!
    
    var leftVideoView : GPUImageView!;
    var rightVideoView : GPUImageView!;
    var videoURL : NSURL!;
    
    var isVideo = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        left_image.image = nil;
        right_image.image = nil;
    }
    
    override func viewDidAppear(animated: Bool) {
        if isVideo == false && (left_image.image == nil || right_image.image == nil) {
            pickSelect()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toolbarCameraAction(sender: AnyObject) {
        pickSelect()
    }
    
    @IBAction func leftImageAction(sender: AnyObject) {
    }
    
    @IBAction func rightImageAction(sender: AnyObject) {
    }
    
    func pickSelect() {
        
        if isVideo {
            leftVideoView.removeFromSuperview();
            rightVideoView.removeFromSuperview();
            
            isVideo = false;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:"画像を選択",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        
        //Default 複数指定可
        let cameraAction = UIAlertAction(title: "写真撮影",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.pickImageFromCamera()
        })
        
        let libraryAction = UIAlertAction(title: "写真ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.pickImageFromLibrary()
        })
        
        let videoAction = UIAlertAction(title: "動画ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.pickMovieFromLibrary()
        })
        

        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(videoAction)
        
        if let video = videoURL {
            let videoRetryAction = UIAlertAction(title: "動画リトライ",
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    self.movieStart(video)
            })
            actionSheet.addAction(videoRetryAction)
        }

        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func imageFilter_left() -> GPUImageTransformFilter {
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        transform = CATransform3DRotate(transform, -0.15, 0.0, 1.0, 0.0);
        return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
    }

    func imageFilter_left(image: UIImage) -> UIImage {
        
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        transform = CATransform3DRotate(transform, -0.15, 0.0, 1.0, 0.0);
        return ImageProcessing.transformFilter(image, transform: transform, ignoreAspectRatio: true);

        /*
        // image が 元画像のUIImage
        let ciImage:CIImage = CIImage(image:image);
        
        let ciFilter:CIFilter = CIFilter(name: "CIHatchedScreen" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)

        /* モザイク的な
        let ciFilter:CIFilter = CIFilter(name: "CIPixellate" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(10.0, forKey: "inputScale")
        */
        
        /* 色調整
        let ciFilter:CIFilter = CIFilter(name: "CIColorControls" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(1.0, forKey: "inputSaturation")
        ciFilter.setValue(0.5, forKey: "inputBrightness")
        ciFilter.setValue(0.8, forKey: "inputContrast")
         */
        
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect:ciFilter.outputImage.extent())
        
        //加工後のUIImage
        return UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Up)!
        */
    }
    
    func imageFilter_right() -> GPUImageTransformFilter {
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        transform = CATransform3DRotate(transform, 0.15, 0.0, 1.0, 0.0);
        return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
    }
    func imageFilter_right(image: UIImage) -> UIImage {
        
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        transform = CATransform3DRotate(transform, 0.15, 0.0, 1.0, 0.0);
        return ImageProcessing.transformFilter(image, transform: transform, ignoreAspectRatio: true);
        
        
        /*
        // image が 元画像のUIImage
        let ciImage:CIImage = CIImage(image:image);

        let ciFilter:CIFilter = CIFilter(name: "CIPerspectiveTransform" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(CIVector(x: 100, y: 100), forKey: "inputTopLeft")
        ciFilter.setValue(CIVector(x: 100, y: 100), forKey: "inputTopRight")
        ciFilter.setValue(CIVector(x: 100, y: 100), forKey: "inputBottomRight")
        ciFilter.setValue(CIVector(x: 100, y: 100), forKey: "inputBottomLeft")

        /* モザイク的な
        let ciFilter:CIFilter = CIFilter(name: "CIPixellate" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(10.0, forKey: "inputScale")
        */

        /* 色調整
        let ciFilter:CIFilter = CIFilter(name: "CIColorControls" )
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(1.0, forKey: "inputSaturation")
        ciFilter.setValue(0.5, forKey: "inputBrightness")
        ciFilter.setValue(1.2, forKey: "inputContrast")
        */
        
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect:ciFilter.outputImage.extent())
        
        //加工後のUIImage
        return UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Up)!
        */
    }


    // 写真を撮ってそれを選択
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            controller.allowsEditing = false;
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから動画を選択する
    func pickMovieFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            controller.mediaTypes = [kUTTypeMovie];
            controller.allowsEditing = false;
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

    
    // 写真や動画を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        let mediaType: CFString = info[UIImagePickerControllerMediaType] as! CFString;
        if mediaType == kUTTypeMovie {
            
            videoURL = info[UIImagePickerControllerMediaURL] as! NSURL;

            movieStart(videoURL);
            
            isVideo = true
        }
        else if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            left_image.image = image;
            //right_image.image = image;
            //left_image.image = imageFilter_left(image);
            right_image.image = imageFilter_right(image);
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func movieStart(url: NSURL) {
        
        let left_movie = GPUImageMovie(URL: url);
        let right_movie = GPUImageMovie(URL: url);
        
        leftVideoView = GPUImageView();
        leftVideoView.frame = left_image.frame;
        self.view.addSubview(leftVideoView);
        
        rightVideoView = GPUImageView();
        rightVideoView.frame = right_image.frame;
        self.view.addSubview(rightVideoView);
        
        //let left_filter = imageFilter_left();
        //left_filter.addTarget(leftVideoView);
        //left_movie.addTarget(left_filter.addTarget);
        left_movie.addTarget(leftVideoView);
        
        let right_filter = imageFilter_right();
        right_filter.addTarget(rightVideoView);
        right_movie.addTarget(right_filter);
        //right_movie.addTarget(rightVideoView);
        
        left_movie.startProcessing();
        right_movie.startProcessing();
    }
    
    override func shouldAutorotate() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
}

/* フィルターの種類
CICategoryBlur
CIBoxBlur
CIDiscBlur
CIGaussianBlur
CIMaskedVariableBlur
CIMedianFilter
CIMotionBlur
CINoiseReduction
CIZoomBlur

CICategoryColorAdjustment
CIColorClamp
CIColorControls
CIColorMatrix
CIColorPolynomial
CIExposureAdjust
CIGammaAdjust
CIHueAdjust
CILinearToSRGBToneCurve
CISRGBToneCurveToLinear
CITemperatureAndTint
CIToneCurve
CIVibrance
CIWhitePointAdjust

CICategoryColorEffect
CIColorCrossPolynomial
CIColorCube
CIColorCubeWithColorSpace
CIColorInvert
CIColorMap
CIColorMonochrome
CIColorPosterize
CIFalseColor
CIMaskToAlpha
CIMaximumComponent
CIMinimumComponent
CIPhotoEffectChrome
CIPhotoEffectFade
CIPhotoEffectInstant
CIPhotoEffectMono
CIPhotoEffectNoir
CIPhotoEffectProcess
CIPhotoEffectTonal
CIPhotoEffectTransfer
CISepiaTone
CIVignette
CIVignetteEffect

CICategoryCompositeOperation
CIAdditionCompositing
CIColorBlendMode
CIColorBurnBlendMode
CIColorDodgeBlendMode
CIDarkenBlendMode
CIDifferenceBlendMode
CIDivideBlendMode
CIExclusionBlendMode
CIHardLightBlendMode
CIHueBlendMode
CILightenBlendMode
CILinearBurnBlendMode
CILinearDodgeBlendMode
CILuminosityBlendMode
CIMaximumCompositing
CIMinimumCompositing
CIMultiplyBlendMode
CIMultiplyCompositing
CIOverlayBlendMode
CIPinLightBlendMode
CISaturationBlendMode
CIScreenBlendMode
CISoftLightBlendMode
CISourceAtopCompositing
CISourceInCompositing
CISourceOutCompositing
CISourceOverCompositing
CISubtractBlendMode

CICategoryDistortionEffect
CIBumpDistortion
CIBumpDistortionLinear
CICircleSplashDistortion
CICircularWrap
CIDroste
CIDisplacementDistortion
CIGlassDistortion
CIGlassLozenge
CIHoleDistortion
CILightTunnel
CIPinchDistortion
CIStretchCrop
CITorusLensDistortion
CITwirlDistortion
CIVortexDistortion

CICategoryGenerator
CIAztecCodeGenerator
CICheckerboardGenerator
CICode128BarcodeGenerator
CIConstantColorGenerator
CILenticularHaloGenerator
CIPDF417BarcodeGenerator
CIQRCodeGenerator
CIRandomGenerator
CIStarShineGenerator
CIStripesGenerator
CISunbeamsGenerator

CICategoryGeometryAdjustment
CIAffineTransform
CICrop
CILanczosScaleTransform
CIPerspectiveCorrection
CIPerspectiveTransform
CIPerspectiveTransformWithExtent
CIStraightenFilter

CICategoryGradient
CIGaussianGradient
CILinearGradient
CIRadialGradient
CISmoothLinearGradient

CICategoryHalftoneEffect
CICircularScreen
CICMYKHalftone
CIDotScreen
CIHatchedScreen
CILineScreen

CICategoryReduction
CIAreaAverage
CIAreaHistogram
CIRowAverage
CIColumnAverage
CIHistogramDisplayFilter
CIAreaMaximum
CIAreaMinimum
CIAreaMaximumAlpha
CIAreaMinimumAlpha

CICategorySharpen
CISharpenLuminance
CIUnsharpMask

CICategoryStylize
CIBlendWithAlphaMask
CIBlendWithMask
CIBloom
CIComicEffect
CIConvolution3X3
CIConvolution5X5
CIConvolution7X7
CIConvolution9Horizontal
CIConvolution9Vertical
CICrystallize
CIDepthOfField
CIEdges
CIEdgeWork
CIGloom
CIHeightFieldFromMask
CIHexagonalPixellate
CIHighlightShadowAdjust
CILineOverlay
CIPixellate
CIPointillize
CIShadedMaterial
CISpotColor
CISpotLight

CICategoryTileEffect
CIAffineClamp
CIAffineTile
CIEightfoldReflectedTile
CIFourfoldReflectedTile
CIFourfoldRotatedTile
CIFourfoldTranslatedTile
CIGlideReflectedTile
CIKaleidoscope
CIOpTile
CIParallelogramTile
CIPerspectiveTile
CISixfoldReflectedTile
CISixfoldRotatedTile
CITriangleKaleidoscope
CITriangleTile
CITwelvefoldReflectedTile

CICategoryTransition
CIAccordionFoldTransition
CIBarsSwipeTransition
CICopyMachineTransition
CIDisintegrateWithMaskTransition
CIDissolveTransition
CIFlashTransition
CIModTransition
CIPageCurlTransition
CIPageCurlWithShadowTransition
CIRippleTransition
CISwipeTransition
*/
