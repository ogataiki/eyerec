import UIKit
import CoreImage
import GPUImage

class ImageProcessing
{
    class var COLORFILTERS : [String] {
        struct Static {
            static let strings : [String] = [
                "brightness (輝度調整)"
                , "exposure (露出調整)"
                , "contrast (コントラスト調整)"
                , "gamma (ガンマ値調整)"
                , "colorMatrix (カラーマトリクス変換)"
                , "rgb (RGB変換)"
                , "hue (色相変換)"
                , "toneCurve (トーンカーブ調整)"
                , "highlightShadow (ハイライト調整)"
                , "colorInvert (色反転)"
                , "grayscale (グレースケール加工)"
                , "falseColor (単色変換)"
                , "sepia (セピア加工)"
                , "opacity (透明加工)"
                , "luminanceThreshold (二値化)"
                , "averageLuminanceThreshold (二値化[平均輝度ベース])"
            ];
        }
        return Static.strings;
    };
    class var PROCESSFILTERS : [String] {
        struct Static {
            static let strings : [String] = [
                "transform2D (2D変形)"
                , "transform3D (3D変形)"
                , "crop (クリッピング)"
                , "lanczosResampling (ダウンサンプリング)"
                , "sharpen (シャープネス)"
                , "unsharpMask (アンシャープマスク)"
                , "gaussianBlur (ガウスぼかし)"
                , "gaussianSelectiveBlur (円形フォーカスぼかし)"
                , "tiltShift (チルトシフトぼかし)"
                , "boxBlur (平滑化ぼかし)"
                , "convolution3x3 (色の畳み込み)"
                , "sobelEdge (エッジ検出[ゾーベル法])"
                , "cannyEdge (エッジ検出[キャニー法])"
                , "dilation (拡張フィルタ　輝度ベース)"
                , "rgbDilation (拡張フィルタ 色ベース)"
                , "erosion (侵食フィルタ 輝度ベース)"
                , "rgbErosion (侵食フィルタ 色ベース)"
                , "opening (同半径侵食フィルタ 輝度ベース)"
                , "rgbOpening (同半径侵食フィルタ 色ベース)"
                , "closing (同半径拡張フィルタ 輝度ベース)"
                , "rgbClosing (同半径拡張フィルタ 色ベース)"
                , "lowPass (ローパスフィルタ)"
                , "highPass (ハイパスフィルタ)"
                , "motionDetector (動き検出)"
            ];
        }
        return Static.strings;
    };
    class var BLENDFILTERS : [String] {
        struct Static {
            static let strings : [String] = [
                "chromaKey (選択透明)"
                , "chromaKeyBlend (選択色置換)"
                , "dissolveBlend (融解合成)"
                , "multiplyBlend (乗算合成)"
                , "addBlend (加算合成)"
                , "divideBlend (分割合成)"
                , "overlayBlend (重ね合成)"
                , "darkenBlend (最小値合成)"
                , "lightenBlend (最大値合成)"
                , "colorBurnBlend (焼き込み合成)"
                , "colorDodgeBlend (覆い焼き合成)"
                , "screenBlend (スクリーン合成)"
                , "exclusionBlend (排他合成)"
                , "differenceBlend (差分合成)"
                , "hardLightBlend (?)"
                , "softLightBlend (?)"
                , "alphaBlend (透明度合成)"
            ];
        }
        return Static.strings;
    };
    class var VISUALEFFECTFILTERS : [String] {
        struct Static {
            static let strings : [String] = [
                "pixellate (ドット絵とかモザイク)"
                , "polarPixellate (集中線的なpixellate)"
                , "polkaDot (丸ドット化)"
                , "halftone (ハーフトーン)"
                , "crosshatch (クロスハッチ)"
                , "sketch (スケッチ)"
                , "toon (漫画)"
                , "smoothToon (ノイズ低減漫画)"
                , "emboss (エンボス)"
                , "posterize (色減少)"
                , "swirl (渦巻き歪み)"
                , "bulgeDistortion (膨らみ歪み)"
                , "pinchDistortion (挟み込み歪み)"
                , "stretchDistortion (伸縮歪み)"
                , "vignette (ふんわりフレーム)"
                , "kuwahara (質のいい減色的な)"
            ];
        }
        return Static.strings;
    };
    class var FILTERSECTIONS : [String] {
        struct Static {
            static let sections : [String] = [
                "color (色)"
                , "processiong (変形)"
                , "blend (合成)"
                , "visual effect (特殊効果)"
            ];
        }
        return Static.sections;
    }

    
    //
    // original filters
    //

    // フォーカスぼかし
    class func focusBlurFilter(_ baseImage: UIImage
        , radius: CGFloat
        , point: CGPoint
        ) -> UIImage
    {
        let filter = GPUImageGaussianSelectiveBlurFilter();
        filter.excludeCircleRadius = radius;
        filter.excludeCirclePoint = point;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // アニメスタイル
//    class func animeStyleFilter(baseImage: UIImage
//        ) -> UIImage
//    {
//    }
    
    //
    // GPUImage how to use
    //
    
    //
    // Color adjustments
    //
    
    // 輝度
    class func brightnessFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageBrightnessFilter();
        filter.brightness = 0.1;
        return filter.image(byFilteringImage: baseImage);
    }
    class func brightnessFilter(_ baseImage: UIImage
        , brightness: CGFloat
        ) -> UIImage
    {
        // brightness : -1.0 ~ 1.0
        let filter = GPUImageBrightnessFilter();
        filter.brightness = brightness;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 露出(ISO)
    class func exposureFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageExposureFilter();
        filter.exposure = 0.5;
        return filter.image(byFilteringImage: baseImage);
    }
    class func exposureFilter(_ baseImage: UIImage
        , exposure: CGFloat
        ) -> UIImage
    {
        // exposure : -10.0 ~ 10.0
        let filter = GPUImageExposureFilter();
        filter.exposure = exposure;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // コントラスト
    class func contrastFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageContrastFilter();
        filter.contrast = 1.5;
        return filter.image(byFilteringImage: baseImage);
    }
    class func contrastFilter(_ baseImage: UIImage
        , contrast: CGFloat
        ) -> UIImage
    {
        // contrast : 0.0 ~ 4.0
        let filter = GPUImageContrastFilter();
        filter.contrast = contrast;
        return filter.image(byFilteringImage: baseImage);
    }

    // ガンマ値
    class func gammaFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageGammaFilter();
        filter.gamma = 1.1;
        return filter.image(byFilteringImage: baseImage);
    }
    class func gammaFilter(_ baseImage: UIImage
        , gamma: CGFloat
        ) -> UIImage
    {
        // gamma : 0.0 ~ 3.0
        let filter = GPUImageGammaFilter();
        filter.gamma = gamma;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // カラーマトリクス変換
    class func colorMatrixFilter(_ matrix: GPUMatrix4x4
        , intensity: CGFloat
        ) -> GPUImageColorMatrixFilter
    {
        // GPUMatrix4x4(one: GPUVector4(one: GLfloat, two: GLfloat, three: GLfloat, four: GLfloat), two: GPUVector4, three: GPUVector4, four: GPUVector4);
        
        // colorMatrix : GPUMatrix4x4 画像の各色を変換するために使用
        // intensity : 新たに形質転換色各画素の元の色を置き換える度合い
        let filter = GPUImageColorMatrixFilter();
        filter.colorMatrix = matrix;
        filter.intensity = intensity;
        return filter;
    }
    class func colorMatrixFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageColorMatrixFilter();
        let r : GLfloat = 0.0;
        let g : GLfloat = 1.0;
        let b : GLfloat = 0.0;
        let a : GLfloat = 0.0;
        filter.colorMatrix = GPUMatrix4x4(
            one:    GPUVector4(one: r, two: r, three: r, four: r),
            two:    GPUVector4(one: g, two: g, three: g, four: g),
            three:  GPUVector4(one: b, two: b, three: b, four: b),
            four:   GPUVector4(one: a, two: a, three: a, four: a));
        filter.intensity = 0.1;
        return filter.image(byFilteringImage: baseImage);
    }
    class func colorMatrixFilter(_ baseImage: UIImage
        , matrix: GPUMatrix4x4
        , intensity: CGFloat
        ) -> UIImage
    {
        // GPUMatrix4x4(one: GPUVector4(one: GLfloat, two: GLfloat, three: GLfloat, four: GLfloat), two: GPUVector4, three: GPUVector4, four: GPUVector4);
        
        // colorMatrix : GPUMatrix4x4 画像の各色を変換するために使用
        /* 黒を透明化
        GPUMatrix4x4(
            one:    GPUVector4(one: 0.0, two: 0.0, three: 0.0, four: 1.0),
            two:    GPUVector4(one: 0.0, two: 0.0, three: 0.0, four: 1.0),
            three:  GPUVector4(one: 0.0, two: 0.0, three: 0.0, four: 1.0),
            four:   GPUVector4(one: 1.0, two: 0.0, three: 0.0, four: 0.0)
        )
        */
        /* 白を透明化
        GPUMatrix4x4(
            one:    GPUVector4(one: 1.0, two: 1.0, three: 1.0, four: 0.0),
            two:    GPUVector4(one: 1.0, two: 1.0, three: 1.0, four: 0.0),
            three:  GPUVector4(one: 1.0, two: 1.0, three: 1.0, four: 0.0),
            four:   GPUVector4(one: 0.0, two: 1.0, three: 1.0, four: 1.0)
        )
        */

        // intensity : 新たに形質転換色各画素の元の色を置き換える度合い
        let filter = GPUImageColorMatrixFilter();
        filter.colorMatrix = matrix;
        filter.intensity = intensity;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // RGB調整
    class func rgbFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageRGBFilter();
        filter.red = 0.5;
        filter.green = 1.0;
        filter.blue = 0.0;
        return filter.image(byFilteringImage: baseImage);
    }
    class func rgbFilter(_ baseImage: UIImage
        , red: CGFloat
        , green: CGFloat
        , blue: CGFloat
        ) -> UIImage
    {
        // red,green,blue : 0.0 ~ 1.0
        let filter = GPUImageRGBFilter();
        filter.red = red;
        filter.green = green;
        filter.blue = blue;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 色相変換 角度で指定(180.0で逆になる？)
    class func hueFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageHueFilter();
        filter.hue = 90;
        return filter.image(byFilteringImage: baseImage);
    }
    class func hueFilter(_ baseImage: UIImage
        , hue: CGFloat
        ) -> UIImage
    {
        // hue : 180で逆になる？
        let filter = GPUImageHueFilter();
        filter.hue = hue;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // トーンカーブ##
    class func toneCurveFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageToneCurveFilter();
        let rArray = NSArray(arrayLiteral:
            NSValue(cgPoint: CGPoint(x: 0.0, y: 0.0)),
            NSValue(cgPoint: CGPoint(x: 0.25, y: 0.75)),
            NSValue(cgPoint: CGPoint(x: 0.5, y: 0.5)),
            NSValue(cgPoint: CGPoint(x: 0.75, y: 0.25)),
            NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0)));
        let gArray = NSArray(arrayLiteral:
            NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0)),
            NSValue(cgPoint: CGPoint(x: 0.25, y: 0.75)),
            NSValue(cgPoint: CGPoint(x: 0.5, y: 0.5)),
            NSValue(cgPoint: CGPoint(x: 0.75, y: 0.25)),
            NSValue(cgPoint: CGPoint(x: 0.0, y: 0.0)));
        let bArray = NSArray(arrayLiteral:
            NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0)),
            NSValue(cgPoint: CGPoint(x: 0.25, y: 0.75)),
            NSValue(cgPoint: CGPoint(x: 0.5, y: 0.5)),
            NSValue(cgPoint: CGPoint(x: 0.75, y: 0.25)),
            NSValue(cgPoint: CGPoint(x: 0.0, y: 0.0)));
        filter.redControlPoints = rArray as [AnyObject];
        filter.greenControlPoints = gArray as [AnyObject];
        filter.blueControlPoints = bArray as [AnyObject];
        return filter.image(byFilteringImage: baseImage);
    }
    class func toneCurveFilter(_ baseImage: UIImage
        , redPoints: NSArray
        , greenPoints: NSArray
        , bluePoints: NSArray
        ) -> UIImage
    {
        // redPoints,greenPoints,bluePoints : NSArray from CGPoint
        // CGPoint : (0.0, 0.0) ~ (1.0, 1.0)
        // NSArray Default : [(0.0, 0.0), (0.5, 0.5), (1.0, 1.0)]
        let filter = GPUImageToneCurveFilter();
        filter.redControlPoints = redPoints as [AnyObject];
        filter.greenControlPoints = greenPoints as [AnyObject];
        filter.blueControlPoints = bluePoints as [AnyObject];
        return filter.image(byFilteringImage: baseImage);
    }
    class func toneCurveFilter(_ baseImage: UIImage
        , points: NSArray
        ) -> UIImage
    {
        // CGPoint : (0.0, 0.0) ~ (1.0, 1.0)
        // NSArray Default : [(0.0, 0.0), (0.5, 0.5), (1.0, 1.0)]
        let filter = GPUImageToneCurveFilter();
        filter.rgbCompositeControlPoints = points as [AnyObject];
        return filter.image(byFilteringImage: baseImage);
    }
    class func toneCurveFilter(_ baseImage: UIImage
        , redPoints: NSArray
        , greenPoints: NSArray
        , bluePoints: NSArray
        , rgbCompositePoints: NSArray
        ) -> UIImage
    {
        let filter = GPUImageToneCurveFilter();
        filter.redControlPoints = redPoints as [AnyObject];
        filter.greenControlPoints = greenPoints as [AnyObject];
        filter.blueControlPoints = bluePoints as [AnyObject];
        filter.rgbCompositeControlPoints = rgbCompositePoints as [AnyObject];
        return filter.image(byFilteringImage: baseImage);
    }

    // ハイライト調整
    class func highlightShadowFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageHighlightShadowFilter();
        filter.shadows = 0.2;
        filter.highlights = 0.8;
        return filter.image(byFilteringImage: baseImage);
    }
    class func highlightShadowFilter(_ baseImage: UIImage
        , shadows: CGFloat
        , highlights: CGFloat
        ) -> UIImage
    {
        // shadows : 0.0 ~ 1.0 Default 0.0
        // highlights : 0.0 ~ 1.0 Default 1.0
        let filter = GPUImageHighlightShadowFilter();
        filter.shadows = shadows;
        filter.highlights = highlights;
        return filter.image(byFilteringImage: baseImage);
    }

    // 色反転
    class func colorInvertFilter() -> GPUImageColorInvertFilter
    {
        return GPUImageColorInvertFilter();
    }
    class func colorInvertFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageColorInvertFilter().image(byFilteringImage: baseImage);
    }
    
    // グレースケール変換
    class func grayscaleFilter() -> GPUImageGrayscaleFilter
    {
        return GPUImageGrayscaleFilter();
    }
    class func grayscaleFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageGrayscaleFilter().image(byFilteringImage: baseImage);
    }
    
    // 単色変換
    class func falseColorFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageFalseColorFilter().image(byFilteringImage: baseImage);
    }
    class func falseColorFilter(_ baseImage: UIImage
        , firstColor: GPUVector4
        , secondColor: GPUVector4
        ) -> UIImage
    {
        // 各画素の輝度に基づいて、単色バージョンに画像を変換する
        // firstColor, secondColor : GPUVector4(one: GLfloat, two: GLfloat, three: GLfloat, four: GLfloat)
        let filter = GPUImageFalseColorFilter();
        filter.firstColor = firstColor;
        filter.secondColor = secondColor;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // セピア
    class func sepiaFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageSepiaFilter().image(byFilteringImage: baseImage);
    }
    class func sepiaFilter(_ baseImage: UIImage
        , intensity: CGFloat
        ) -> UIImage
    {
        // intensity : 0.0 ~ 1.0
        let filter = GPUImageSepiaFilter();
        filter.intensity = intensity;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // アルファチャンネル調整
    class func opacityFilter() -> GPUImageOpacityFilter
    {
        let filter = GPUImageOpacityFilter();
        filter.opacity = 0.5;
        return filter;
    }
    class func opacityFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageOpacityFilter();
        filter.opacity = 0.5;
        return filter.image(byFilteringImage: baseImage);
    }
    class func opacityFilter(_ baseImage: UIImage
        , opacity: CGFloat
        ) -> UIImage
    {
        // opacity : 0.0 ~ 1.0
        let filter = GPUImageOpacityFilter();
        filter.opacity = opacity;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 輝度による2値化
    class func luminanceThresholdFilter() -> GPUImageLuminanceThresholdFilter
    {
        return GPUImageLuminanceThresholdFilter();
    }
    class func luminanceThresholdFilter(_ threshold: CGFloat) -> GPUImageLuminanceThresholdFilter
    {
        let filter = GPUImageLuminanceThresholdFilter();
        filter.threshold = threshold;
        return filter;
    }
    class func luminanceThresholdFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageLuminanceThresholdFilter().image(byFilteringImage: baseImage);
    }
    class func luminanceThresholdFilter(_ baseImage: UIImage
        , threshold: CGFloat
        ) -> UIImage
    {
        // threshold : 0.0 ~ 1.0 Default 0.5
        let filter = GPUImageLuminanceThresholdFilter();
        filter.threshold = threshold;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 平均輝度による2値化
    class func averageLuminanceThresholdFilter() -> GPUImageAverageLuminanceThresholdFilter
    {
        return GPUImageAverageLuminanceThresholdFilter();
    }
    class func averageLuminanceThresholdFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageAverageLuminanceThresholdFilter().image(byFilteringImage: baseImage);
    }
    class func averageLuminanceThresholdFilter(_ baseImage: UIImage
        , thresholdMultiplier: CGFloat
        ) -> UIImage
    {
        // これは、閾値が継続的にシーンの平均輝度に基づいて調整される閾値化操作を適用する
        // threshold : 0.0 ~ 1.0 Default 0.5
        let filter = GPUImageAverageLuminanceThresholdFilter();
        filter.thresholdMultiplier = thresholdMultiplier;
        return filter.image(byFilteringImage: baseImage);
    }
    

    //
    // Image processing
    //
    
    // 2D変形
    class func transformFilter(_ transform: CGAffineTransform
        , ignoreAspectRatio: Bool
        ) -> GPUImageTransformFilter
    {
        // パラメータ例
        //var t: CGAffineTransform;
        //t = CGAffineTransformMakeScale(0.75, 0.75); //　縮小
        //t = CGAffineTransformTranslate(t, 0, 0.5);  // 移動
        
        let filter = GPUImageTransformFilter();
        filter.affineTransform = transform;
        filter.ignoreAspectRatio = ignoreAspectRatio;
        return filter;
    }

    class func transform2DFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageTransformFilter();
        var transform: CGAffineTransform;
        transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        transform = transform.translatedBy(x: 0, y: 0.5);
        filter.affineTransform = transform;
        filter.ignoreAspectRatio = true;
        return filter.image(byFilteringImage: baseImage);
    }
    class func transformFilter(_ baseImage: UIImage
        , transform: CGAffineTransform
        , ignoreAspectRatio: Bool
        ) -> UIImage
    {
        // パラメータ例
        //var t: CGAffineTransform;
        //t = CGAffineTransformMakeScale(0.75, 0.75); //　縮小
        //t = CGAffineTransformTranslate(t, 0, 0.5);  // 移動
        
        let filter = GPUImageTransformFilter();
        filter.affineTransform = transform;
        filter.ignoreAspectRatio = ignoreAspectRatio;
        return filter.image(byFilteringImage: baseImage);
    }

    // 3D変形
    class func transform3DFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageTransformFilter();
        var transform = CATransform3DIdentity;
        transform.m34 = 0.4;
        transform.m33 = 0.4;
        transform = CATransform3DRotate(transform, 0.75, 1.0, 0.0, 0.0);
        filter.transform3D = transform;
        filter.ignoreAspectRatio = true;
        return filter.image(byFilteringImage: baseImage);
    }
    class func transformFilter(_ baseImage: UIImage
        , transform: CATransform3D
        , ignoreAspectRatio: Bool
        ) -> UIImage
    {
        // パラメータ例
        //var t = CATransform3DIdentity;
        //t.m34 = 0.4;
        //t.m33 = 0.4;
        //t = CATransform3DRotate(t, 0.75, 1.0, 0.0, 0.0);

        let filter = GPUImageTransformFilter();
        filter.transform3D = transform;
        filter.ignoreAspectRatio = ignoreAspectRatio;
        return filter.image(byFilteringImage: baseImage);
    }
    class func transformFilter(_ transform: CATransform3D
        , ignoreAspectRatio: Bool
        ) -> GPUImageTransformFilter
    {
        let filter = GPUImageTransformFilter();
        filter.transform3D = transform;
        filter.ignoreAspectRatio = ignoreAspectRatio;
        return filter;
    }

    // クリッピング
    class func cropFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageCropFilter();
        filter.cropRegion = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5);

        // GPUImageCropFilterのforceProcessingAtSizeが動かないので
        let tmp = GPUImageTransformFilter();
        tmp.forceProcessing(at: baseImage.size);
        return tmp.image(byFilteringImage: filter.image(byFilteringImage: baseImage));
    }
    class func cropFilter(_ baseImage: UIImage
        , cropRegion: CGRect
        ) -> UIImage
    {
        let filter = GPUImageCropFilter();
        filter.cropRegion = cropRegion;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // ダウンサンプリング
    class func lanczosResamplingFilter(_ baseImage:UIImage) -> UIImage
    {
        return GPUImageLanczosResamplingFilter().image(byFilteringImage: baseImage);
    }
    
    // シャープネス
    class func sharpenFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageSharpenFilter();
        filter.sharpness = 0.5;
        return filter.image(byFilteringImage: baseImage);
    }
    class func sharpenFilter(_ baseImage: UIImage
        , sharpness: CGFloat
        ) -> UIImage
    {
        // sharpness : -4.0 ~ 4.0 Default 0.0
        let filter = GPUImageSharpenFilter();
        filter.sharpness = sharpness;
        return filter.image(byFilteringImage: baseImage);
    }

    // アンシャープマスク
    class func unsharpMaskFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageUnsharpMaskFilter();
        filter.blurRadiusInPixels = 2.0;
        filter.intensity = 2.0;
        return filter.image(byFilteringImage: baseImage);
    }
    class func unsharpMaskFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , intensity: CGFloat
        ) -> UIImage
    {
        // blurRadiusInPixels : 0.0 ~ Default 1.0
        // intensity : 0.0 ~ Default 1.0
        let filter = GPUImageUnsharpMaskFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.intensity = intensity;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // ガウスぼかし
    class func gaussianBlurFilter() -> GPUImageGaussianBlurFilter
    {
        let filter = GPUImageGaussianBlurFilter();
        filter.blurRadiusInPixels = 2.0;
        return filter;
    }
    class func gaussianBlurFilter(_ blurSize: CGFloat
        ) -> GPUImageGaussianBlurFilter
    {
        // blurSize : 0.0 ~ Default 1.0
        let filter = GPUImageGaussianBlurFilter();
        filter.blurRadiusInPixels = blurSize;
        return filter;
    }
    class func gaussianBlurFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageGaussianBlurFilter();
        filter.blurRadiusInPixels = 2.0;
        return filter.image(byFilteringImage: baseImage);
    }
    class func gaussianBlurFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        ) -> UIImage
    {
        // blurSize : 0.0 ~ Default 1.0
        let filter = GPUImageGaussianBlurFilter();
        filter.blurRadiusInPixels = blurSize;
        return filter.image(byFilteringImage: baseImage);
    }
 
    // 円形フォーカス的ぼかし
    class func gaussianSelectiveBlurFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageGaussianSelectiveBlurFilter();
        filter.blurRadiusInPixels = 5.0;
        filter.excludeCircleRadius = 0.4;
        filter.excludeCirclePoint = CGPoint(x: 0.5, y: 0.5);
        filter.excludeBlurSize = 0.2;
        filter.aspectRatio = 1.0;
        return filter.image(byFilteringImage: baseImage);
    }
    class func gaussianSelectiveBlurFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , radius: CGFloat
        , point: CGPoint
        , exBlurSize: CGFloat
        , aspectRatio: CGFloat
        ) -> UIImage
    {
        // blurSize : 0.0 ~ Defalut 1.0 ぼかし強度
        // radius : 0.0 ~ 1.0 ぼかし除外(フォーカス)半径
        // point : (0.0, 0.0) ~ (1.0, 1.0) ぼかし除外(フォーカス)円の中心位置
        // exBlurSize : 0.0 ~ フォーカス範囲とぼかし範囲の境界をどれくらいの幅にするか
        // aspectRatio : Default 1.0 円の歪み(0.0だと縦長？よくわからない)
        let filter = GPUImageGaussianSelectiveBlurFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.excludeCircleRadius = radius;
        filter.excludeCirclePoint = point;
        filter.excludeBlurSize = exBlurSize;
        filter.aspectRatio = aspectRatio;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // チルトシフト(上下ぼかし)
    class func tiltShiftFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageTiltShiftFilter();
        filter.blurRadiusInPixels = 3.0;
        filter.topFocusLevel = 0.4;
        filter.bottomFocusLevel = 0.6;
        filter.focusFallOffRate = 0.2;
        return filter.image(byFilteringImage: baseImage);
    }
    class func tiltShiftFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , topFocusLevel: CGFloat
        , bottomFocusLevel: CGFloat
        , focusFallOffRate: CGFloat
        ) -> UIImage
    {
        // blurSize : 0.0 ~ Default 2.0
        // topFocusLevel : Default 0.4 焦点領域上部 bottomFocusLeveより低く設定
        // bottomFocusLevel : Default 0.6 焦点領域下部 topFocusLevelより高く設定
        // focusFallOffRate : Default 0.2 画像が合焦領域から離れてぼやけを取得する速度(?)
        let filter = GPUImageTiltShiftFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.topFocusLevel = topFocusLevel;
        filter.bottomFocusLevel = bottomFocusLevel;
        filter.focusFallOffRate = focusFallOffRate;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 平滑化ぼかし?
    class func boxBlurFilter(_ baseImage :UIImage) -> UIImage
    {
        let filter = GPUImageBoxBlurFilter();
        filter.blurRadiusInPixels = 2.0;
        return filter.image(byFilteringImage: baseImage);
    }
    class func boxBlurFilter(_ baseImage :UIImage
        , blurSize: CGFloat
        ) -> UIImage
    {
        let filter = GPUImageBoxBlurFilter();
        filter.blurRadiusInPixels = blurSize;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 3x3の畳み込みカーネル##
    class func convolution3x3Filter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImage3x3ConvolutionFilter();
        let kernel = GPUMatrix3x3(
            // 輪郭強調のサンプル
            one:    GPUVector3(one: 0, two: 1, three: 0),
            two:    GPUVector3(one: 1, two: -4, three: 1),
            three:  GPUVector3(one: 0, two: 1, three: 0));
        filter.convolutionKernel = kernel;
        return filter.image(byFilteringImage: baseImage);
    }
    class func convolution3x3Filter(_ baseImage: UIImage
        , kernel: GPUMatrix3x3
        ) -> UIImage
    {
        // 畳み込みカーネルは、ピクセルとその周囲8画素に適用する値の3×3行列である。
        // 行列は、左上ピクセルの幸福のone.oneと右下のthree.threeで、行優先順に指定されている。
        // 行列の値が1.0にならない場合は、イメージが明るくまたは暗くすることができた。
        // kernel : GPUMatrix3x3(one: GPUVector3, two: GPUVector3, three: GPUVector3);
        let filter = GPUImage3x3ConvolutionFilter();
        filter.convolutionKernel = kernel;
        return filter.image(byFilteringImage: baseImage);
    }

    // ゾーベルエッジ検出白強調
    class func sobelEdgeDetectionFilter() -> GPUImageSobelEdgeDetectionFilter
    {
        return GPUImageSobelEdgeDetectionFilter();
    }
    class func sobelEdgeDetectionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageSobelEdgeDetectionFilter().image(byFilteringImage: baseImage);
    }
    class func sobelEdgeDetectionFilter(_ baseImage: UIImage
        , texelWidth: CGFloat
        , texelHeight: CGFloat
        ) -> UIImage
    {
        // texelWidth : 0.001くらいが丁度いい
        // texelHeight : 0.001くらいが丁度いい
        let filter = GPUImageSobelEdgeDetectionFilter();
        filter.texelWidth = texelWidth;
        filter.texelHeight = texelHeight;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // キャニー法エッジ検出白強調
    class func cannyEdgeDetectionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageCannyEdgeDetectionFilter().image(byFilteringImage: baseImage);
    }
    class func cannyEdgeDetectionFilter(_ baseImage: UIImage
        , texelWidth: CGFloat
        , texelHeight: CGFloat
        , blurSize: CGFloat
        , upperThreshold: CGFloat
        , lowerThreshold: CGFloat
        ) -> UIImage
    {
        // texelWidth : 0.001くらいが丁度いい
        // texelHeight : 0.001くらいが丁度いい
        // blurSize: 0.0 ~ Default 1.0 検出前にぼかす度合い
        // upperThreshold : Default 0.4 エッジとして検出する閾値
        // lowerThreshold : Default 0.1 エッジとして検出しない閾値
        
        let filter = GPUImageCannyEdgeDetectionFilter();
        filter.texelWidth = texelWidth;
        filter.texelHeight = texelHeight;
        filter.blurRadiusInPixels = blurSize;
        filter.upperThreshold = upperThreshold;
        filter.lowerThreshold = lowerThreshold;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 頂点検出Harris法
    class func harrisCornerDetectionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageHarrisCornerDetectionFilter().image(byFilteringImage: baseImage);
    }
    class func harrisCornerDetectionFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , sensitivity: CGFloat
        , threshold: CGFloat
        ) -> UIImage
    {
        // blurSize : Default 1.0 コーナー検出の実装の一部として適用されるぼかしの相対的な大きさ
        // sensitivity : Default 5.0 内部スケーリング係数は、フィルタで生成cornernessマップのダイナミックレンジを調整するために適用
        // threshold : コーナーとして検出される閾値。
        let filter = GPUImageHarrisCornerDetectionFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.sensitivity = sensitivity;
        filter.threshold = threshold;
        return filter.image(byFilteringImage: baseImage);
    }
 
    // 頂点検出 Noble法
    class func nobleCornerDetectionFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageNobleCornerDetectionFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    class func nobleCornerDetectionFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , sensitivity: CGFloat
        , threshold: CGFloat
        ) -> UIImage
    {
        // blurSize : Default 1.0 コーナー検出の実装の一部として適用されるぼかしの相対的な大きさ
        // sensitivity : Default 5.0 内部スケーリング係数は、フィルタで生成cornernessマップのダイナミックレンジを調整するために適用
        // threshold : コーナーとして検出される閾値。
        let filter = GPUImageNobleCornerDetectionFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.sensitivity = sensitivity;
        filter.threshold = threshold;
        return filter.image(byFilteringImage: baseImage);
    }

    // 頂点検出 ShiTomasi法
    class func shiTomasiFeatureDetectionFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageShiTomasiFeatureDetectionFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    class func shiTomasiFeatureDetectionFilter(_ baseImage: UIImage
        , blurSize: CGFloat
        , sensitivity: CGFloat
        , threshold: CGFloat
        ) -> UIImage
    {
        // blurSize : Default 1.0 コーナー検出の実装の一部として適用されるぼかしの相対的な大きさ
        // sensitivity : Default 5.0 内部スケーリング係数は、フィルタで生成cornernessマップのダイナミックレンジを調整するために適用
        // threshold : コーナーとして検出される閾値。
        let filter = GPUImageShiTomasiFeatureDetectionFilter();
        filter.blurRadiusInPixels = blurSize;
        filter.sensitivity = sensitivity;
        filter.threshold = threshold;
        return filter.image(byFilteringImage: baseImage);
    }

    // ハリスのコーナー検出フィルタの一部として使用される(で、どういう効果なの？)
    class func nonMaximumSuppressionFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageNonMaximumSuppressionFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // ハリスのコーナー検出フィルタの一部として使用される(で、どういう効果なの？)
    // 使ってみたら、青背景に赤と水色で輪郭線が浮き出てきたけど。。。
    class func xyDerivativeFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageXYDerivativeFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 十字ジェネレータ？これはこのまま動かない
    class func crosshairGenerator(_ baseImage: UIImage
        , crosshairWidth: CGFloat
        ) -> UIImage
    {
        let filter = GPUImageCrosshairGenerator();
        filter.crosshairWidth = crosshairWidth;
        return filter.image(byFilteringImage: baseImage);
    }

    // 拡張フィルタ?(使ってみたらグレースケールっぽい画像になったけど。。。)
    // 何度か繰り返し適用したら、重なりのあるドット絵みたいになった！
    class func dilationFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageDilationFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 全てのカラーチャンネルに作用する拡張フィルタ?(使ってみたら何が変わったかかわからない画像になったけど。。。)
    // 何度か繰り返し適用したら、重なりのあるドット絵みたいになった！
    class func rgbDilationFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageRGBDilationFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 侵食フィルタ?(使ってみたらグレースケールっぽい画像になったけど。。。)
    // 何度か繰り返し適用したら、油絵的な感じに滲んだ！
    class func erosionFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageErosionFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 全てのカラーチャンネルに作用する侵食フィルタ?(使ってみたら何が変わったかかわからない画像になったけど。。。)
    // 何度か繰り返し適用したら、油絵的な感じに滲んだ！
    class func rgbErosionFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageRGBErosionFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // これは、同じ半径の膨張が続く画像の赤チャンネル、上の浸食を実行します。半径1-4画素の範囲で、初期化時に設定されている。
    // (使ってみたらグレースケールっぽい画像になったけど。。。)
    class func openingFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageOpeningFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 赤チャネル、すべてのカラーチャンネルに作用することを除いて、GPUImageOpeningFilterと同じである。
    // (使ってみたら何が変わったかかわからない画像になったけど。。。)
    class func rgbOpeningFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageRGBOpeningFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // これは、同じ半径の侵食に続く画像の赤チャンネルに拡張を行う?
    // (使ってみたらグレースケールっぽい画像になったけど。。。)
    class func closingFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageClosingFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 赤チャネル、すべてのカラーチャンネルに作用することを除いて、GPUImageClosingFilterと同じである。
    // (使ってみたら何が変わったかかわからない画像になったけど。。。)
    class func rgbClosingFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageRGBClosingFilter();
        return filter.image(byFilteringImage: baseImage);
    }
    
    // ローパスフィルタ
    class func lowPassFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageLowPassFilter();
        filter.filterStrength = 0.2;
        return filter.image(byFilteringImage: baseImage);
    }
    class func lowPassFilter(_ baseImage: UIImage
        , filterStrength: CGFloat
        ) -> UIImage
    {
        // filterStrength : 0.0 ~ 1.0 Default 0.5
        let filter = GPUImageLowPassFilter();
        filter.filterStrength = filterStrength;
        return filter.image(byFilteringImage: baseImage);
    }

    // ハイパスフィルタ
    class func highPassFilter(_ baseImage: UIImage) -> UIImage
    {
        let filter = GPUImageHighPassFilter();
        filter.filterStrength = 0.2;
        return filter.image(byFilteringImage: baseImage);
    }
    class func highPassFilter(_ baseImage: UIImage
        , filterStrength: CGFloat
        ) -> UIImage
    {
        // filterStrength : 0.0 ~ 1.0 Default 0.5
        let filter = GPUImageHighPassFilter();
        filter.filterStrength = filterStrength;
        return filter.image(byFilteringImage: baseImage);
    }

    // 動き検出器?(使ってみたら、動きのないところが白く、動きのあるところ[滝とか]が水色〜ピンクになった)
    class func motionDetector(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageMotionDetector().image(byFilteringImage: baseImage);
    }
    class func motionDetector(_ baseImage: UIImage
        , lowPassFilterStrength: CGFloat
        ) -> UIImage
    {
        // lowPassFilterStrength : 0.0 ~ 1.0 Default 0.5
        let filter = GPUImageMotionDetector();
        filter.lowPassFilterStrength = lowPassFilterStrength;
        return filter.image(byFilteringImage: baseImage);
    }
    
    
    //
    // Blending modes
    //
    
    // 選択的に第二の画像と最初の画像の色を透明にする
    class func chromaKeyFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageChromaKeyFilter();
        filter.thresholdSensitivity = 0.4;
        filter.smoothing = 0.1;

        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    class func chromaKeyFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        , thresholdSensitivity: CGFloat
        , smoothing: CGFloat
        ) -> UIImage
    {
        // 画像内の指定された色については、これはGPUImageChromaKeyBlendFilterに類似して0にするアルファチャンネルを設定するだけの代わりに、
        // これは単に第二の画像を取り込むとしないマッチング色について第二の画像にブレンディングの所与の色を透明に変わり。
        // thresholdSensitivity : Default 0.4 どれだけの近さを対象にするか
        // smoothing : Default 0.1 どのくらいスムーズに色変えするか
        let filter = GPUImageChromaKeyFilter();
        filter.thresholdSensitivity = thresholdSensitivity;
        filter.smoothing = smoothing;
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 選択的に第二の画像と最初の画像の色を置き換える
    // 同じ画像で片方に他のフィルタかけたものを使うと面白い
    class func chromaKeyBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageChromaKeyBlendFilter();
        filter.thresholdSensitivity = 0.4;
        filter.smoothing = 0.1;

        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    class func chromaKeyBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        , thresholdSensitivity: CGFloat
        , smoothing: CGFloat
        ) -> UIImage
    {
        // thresholdSensitivity : Default 0.4 どれだけの近さを対象にするか
        // smoothing : Default 0.1 どのくらいスムーズに色変えするか
        let filter = GPUImageChromaKeyBlendFilter();
        filter.thresholdSensitivity = thresholdSensitivity;
        filter.smoothing = smoothing;
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    
    // 二つの画像の溶解合成する
    class func dissolveBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageDissolveBlendFilter();
        filter.mix = 0.5;

        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    class func dissolveBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        , mix: CGFloat
        ) -> UIImage
    {
        // mix : 0.0 ~ 1.0 Default 0.5 どの程度上書きを強めるか
        let filter = GPUImageDissolveBlendFilter();
        filter.mix = mix;
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    
    // 二つの画像の乗算ブレンド
    class func multiplyBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageMultiplyBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の加算ブレンド
    class func addBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageAddBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    
    // 二つの画像の分割ブレンド
    class func divideBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageDivideBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の重ねブレンド
    class func overlayBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageOverlayBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の各色最小値をとってブレンド
    class func darkenBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageDarkenBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の各色最大値をとってブレンド
    class func lightenBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageLightenBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の焼き込みブレンド
    class func colorBurnBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageColorBurnBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の覆い焼きブレンド
    class func colorDodgeBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageColorDodgeBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像のスクリーンブレンド
    class func screenBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageScreenBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    
    // 二つの画像の排他ブレンド
    class func exclusionBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageExclusionBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像の差分ブレンド
    class func differenceBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageDifferenceBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像のハード光?ブレンド
    class func hardLightBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageHardLightBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像のソフト光?ブレンド
    class func softLightBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageSoftLightBlendFilter();
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }

    // 二つの画像のアルファブレンド
    class func alphaBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        ) -> UIImage
    {
        let filter = GPUImageAlphaBlendFilter();
        filter.mix = 1.0;

        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    class func alphaBlendFilter(_ baseImage: UIImage
        , overlayImage: UIImage
        , mix: CGFloat
        ) -> UIImage
    {
        // mix : 0.0 ~ 1.0 Default 1.0
        let filter = GPUImageAlphaBlendFilter();
        filter.mix = mix;
        
        let inputPicture = GPUImagePicture(cgImage: baseImage.cgImage, smoothlyScaleOutput: true);
        let overlayPicture = GPUImagePicture(cgImage: overlayImage.cgImage, smoothlyScaleOutput: true);
        inputPicture?.addTarget(filter);
        overlayPicture?.addTarget(filter);
        inputPicture?.processImage();
        overlayPicture?.processImage();
        filter.useNextFrameForImageCapture();
        return filter.imageFromCurrentFramebuffer(with: baseImage.imageOrientation);
    }
    
    
    //
    // Visual effects
    //
    
    // ピクセレート(ドット絵とかモザイクみたいな)フィルタ
    class func pixellateFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImagePixellateFilter().image(byFilteringImage: baseImage);
    }
    class func pixellateFilter(_ baseImage: UIImage
        , fractionalWidthOfAPixel: CGFloat
        ) -> UIImage
    {
        // fractionalWidthOfAPixel : 0.0 ~ 1.0 Default 0.05 ドットの荒さ 0.05は結構荒い
        let filter = GPUImagePixellateFilter();
        filter.fractionalWidthOfAPixel = fractionalWidthOfAPixel;
        return filter.image(byFilteringImage: baseImage);
    }

    // 集中線みたいな形でのピクセレートフィルタ
    class func polarPixellateFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImagePolarPixellateFilter().image(byFilteringImage: baseImage);
    }
    class func polarPixellateFilter(_ baseImage: UIImage
        , center: CGPoint
        , pixelSize: CGSize
        ) -> UIImage
    {
        // center : 0.0 ~ 1.0 集中線の中心点
        // pixelSize : 0.0 ~ 1.0 くらい　ドットの荒さ
        let filter = GPUImagePolarPixellateFilter();
        filter.center = center;
        filter.pixelSize = pixelSize;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // ピクセレートの各ドット領域を丸ドットにするフィルタ
    class func polkaDotFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImagePolkaDotFilter().image(byFilteringImage: baseImage);
    }
    class func polkaDotFilter(_ baseImage: UIImage
        , fractionalWidthOfAPixel: CGFloat
        , dotScaling: CGFloat
        ) -> UIImage
    {
        // fractionalWidthOfAPixel : 0.0 ~ 1.0 Default 0.05 ドットの荒さ 0.05は結構荒い
        // dotScaling : 0.0 ~ 1.0 Default 0.9 ドットのどれくらいを使用して丸にするか
        let filter = GPUImagePolkaDotFilter();
        filter.fractionalWidthOfAPixel = fractionalWidthOfAPixel;
        filter.dotScaling = dotScaling;
        return filter.image(byFilteringImage: baseImage);
    }

    // ハーフトーンフィルタ(なんか、黒い点々になる)
    class func halftoneFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageHalftoneFilter().image(byFilteringImage: baseImage);
    }
    class func halftoneFilter(_ baseImage: UIImage
        , fractionalWidthOfAPixel: CGFloat
        ) -> UIImage
    {
        // fractionalWidthOfAPixel : 0.0 ~ 1.0 Default 0.05 ドットの荒さ 0.05は結構荒い
        let filter = GPUImageHalftoneFilter();
        filter.fractionalWidthOfAPixel = fractionalWidthOfAPixel;
        return filter.image(byFilteringImage: baseImage);
    }

    // クロスハッチフィルタ
    class func crosshatchFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageCrosshatchFilter().image(byFilteringImage: baseImage);
    }
    class func crosshatchFilter(_ baseImage: UIImage
        , crossHatchSpacing: CGFloat
        , lineWidth: CGFloat
        ) -> UIImage
    {
        // crossHatchSpacing : Default 0.03 格子の密度
        // lineWidth : Default 0.003 格子の幅
        let filter = GPUImageCrosshatchFilter();
        filter.crossHatchSpacing = crossHatchSpacing;
        filter.lineWidth = lineWidth;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // スケッチフィルタ
    class func sketchFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageSketchFilter().image(byFilteringImage: baseImage);
    }
    class func sketchFilter(_ baseImage: UIImage
        , texelWidth: CGFloat
        , texelHeight: CGFloat
        ) -> UIImage
    {
        // texelWidth : 0.0005
        // texelHeight : 0.0005
        let filter = GPUImageSketchFilter();
        filter.texelWidth = texelWidth;
        filter.texelHeight = texelHeight;
        return filter.image(byFilteringImage: baseImage);
    }

    // 漫画フィルタ
    class func toonFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageToonFilter().image(byFilteringImage: baseImage);
    }
    class func toonFilter(_ baseImage: UIImage
        , texelWidth: CGFloat
        , texelHeight: CGFloat
        , threshold: CGFloat
        , quantizationLevels: CGFloat
        ) -> UIImage
    {
        // texelWidth : 0.0005
        // texelHeight : 0.0005
        // threshold : 0.0 ~ 1.0 Default 0.2 ソーベルフィルタの感度
        // quantizationLevels : Default 10.0 最終的なカラーレベル
        let filter = GPUImageToonFilter();
        filter.texelWidth = texelWidth;
        filter.texelHeight = texelHeight;
        filter.threshold = threshold;
        filter.quantizationLevels = quantizationLevels;
        return filter.image(byFilteringImage: baseImage);
    }
    
    
    // ノイズ低減漫画フィルタ
    class func smoothToonFilter() -> GPUImageSmoothToonFilter
    {
        return GPUImageSmoothToonFilter();
    }
    class func smoothToonFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageSmoothToonFilter().image(byFilteringImage: baseImage);
    }
    class func smoothToonFilter(_ baseImage: UIImage
        , texelWidth: CGFloat
        , texelHeight: CGFloat
        , blurSize: CGFloat
        , threshold: CGFloat
        , quantizationLevels: CGFloat
        ) -> UIImage
    {
        // texelWidth : 0.0005
        // texelHeight : 0.0005
        // blurSize : 0.0 ~ Default 0.5 ノイズ低減のぼかし度合い
        // threshold : 0.0 ~ 1.0 Default 0.2 ソーベルフィルタの感度
        // quantizationLevels : Default 10.0 最終的なカラーレベル
        let filter = GPUImageSmoothToonFilter();
        filter.texelWidth = texelWidth;
        filter.texelHeight = texelHeight;
        filter.threshold = threshold;
        filter.quantizationLevels = quantizationLevels;
        return filter.image(byFilteringImage: baseImage);
    }

    // エンボスフィルタ
    class func embossFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageEmbossFilter().image(byFilteringImage: baseImage);
    }
    class func embossFilter(_ baseImage: UIImage
        , intensity: CGFloat
        ) -> UIImage
    {
        // intensity : 0.0 ~ 4.0 Default 1.0
        let filter = GPUImageEmbossFilter();
        filter.intensity = intensity;
        return filter.image(byFilteringImage: baseImage);
    }

    // ポスタライズ
    class func posterizeFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImagePosterizeFilter().image(byFilteringImage: baseImage);
    }
    class func posterizeFilter(_ baseImage: UIImage
        , colorLevels: UInt
        ) -> UIImage
    {
        // colorLevels : 1 ~ 256 Default 10
        let filter = GPUImagePosterizeFilter();
        filter.colorLevels = colorLevels;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 渦巻き歪みフィルタ
    class func swirlFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageSwirlFilter().image(byFilteringImage: baseImage);
    }
    class func swirlFilter(_ baseImage: UIImage
        , radius: CGFloat
        , center: CGPoint
        , angle: CGFloat
        ) -> UIImage
    {
        // radius : Default 0.5
        // center : (0.0, 0,0) ~ (1.0, 1.0)
        // angle : Default 1.0
        let filter = GPUImageSwirlFilter();
        filter.radius = radius;
        filter.center = center;
        filter.angle = angle;
        return filter.image(byFilteringImage: baseImage);
    }

    // 膨らみ歪みフィルタ
    class func bulgeDistortionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageBulgeDistortionFilter().image(byFilteringImage: baseImage);
    }
    class func bulgeDistortionFilter(_ baseImage: UIImage
        , radius: CGFloat
        , center: CGPoint
        , scale: CGFloat
        ) -> UIImage
    {
        // radius : Default 0.25
        // center : (0.0, 0,0) ~ (1.0, 1.0)
        // scale : -1.0 ~ 1.0 Default 0.5
        let filter = GPUImageBulgeDistortionFilter();
        filter.radius = radius;
        filter.center = center;
        filter.scale = scale;
        return filter.image(byFilteringImage: baseImage);
    }

    // 挟み込み歪みフィルタ
    class func pinchDistortionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImagePinchDistortionFilter().image(byFilteringImage: baseImage);
    }
    class func pinchDistortionFilter(_ baseImage: UIImage
        , radius: CGFloat
        , center: CGPoint
        , scale: CGFloat
        ) -> UIImage
    {
        // radius : Default 1.0
        // center : (0.0, 0,0) ~ (1.0, 1.0)
        // scale : -2.0 ~ 2.0 Default 1.0
        let filter = GPUImagePinchDistortionFilter();
        filter.radius = radius;
        filter.center = center;
        filter.scale = scale;
        return filter.image(byFilteringImage: baseImage);
    }

    // 伸縮歪みフィルタ
    class func stretchDistortionFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageStretchDistortionFilter().image(byFilteringImage: baseImage);
    }
    class func stretchDistortionFilter(_ baseImage: UIImage
        , center: CGPoint
        ) -> UIImage
    {
        // center : (0.0, 0,0) ~ (1.0, 1.0)
        let filter = GPUImageStretchDistortionFilter();
        filter.center = center;
        return filter.image(byFilteringImage: baseImage);
    }
    
    // 指定した色で外側から侵食するふんわりフレーム的なフィルタ
    class func vignetteFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageVignetteFilter().image(byFilteringImage: baseImage);
    }
    class func vignetteFilter(_ baseImage: UIImage
        , vignetteCenter: CGPoint
        , vignetteColor: GPUVector3
        , vignetteStart: CGFloat
        , vignetteEnd: CGFloat
        ) -> UIImage
    {
        // vignetteCenter : (0.0, 0.0) ~ (1.0, 1.0) どこに向かって侵食するか
        // vignetteColor : GPUVector3(one: 1.0, two: 1.0, three: 1.0)で白
        // vignetteStart : 0.1 くらいがちょうどよかった
        // vignetteEnd : 0.4 くらいがちょうどよかった
        let filter = GPUImageVignetteFilter();
        filter.vignetteCenter = vignetteCenter;
        filter.vignetteColor = vignetteColor;
        filter.vignetteStart = vignetteStart;
        filter.vignetteEnd = vignetteEnd;
        return filter.image(byFilteringImage: baseImage);
    }

    // 質のいいポスタライズみたいな
    class func kuwaharaFilter() -> GPUImageKuwaharaFilter {
        return GPUImageKuwaharaFilter();
    }
    class func kuwaharaFilter(_ baseImage: UIImage) -> UIImage
    {
        return GPUImageKuwaharaFilter().image(byFilteringImage: baseImage);
    }
    class func kuwaharaFilter(_ baseImage: UIImage
        , radius: UInt
        ) -> UIImage
    {
        // radius : Default 4
        let filter = GPUImageKuwaharaFilter();
        filter.radius = radius;
        return filter.image(byFilteringImage: baseImage);
    }
    
    
    
    
    //
    // Original Shaders
    //
    
    // 動き検出で白くなる部分を右に移動する(立体視用テスト)
    class func lowPassMoveFilter() -> LowPassMoveFilter
    {
        return LowPassMoveFilter();
    }
    class func lowPassMoveFilter(_ lowPassFilterStrength: CGFloat
        ) -> LowPassMoveFilter
    {
        // lowPassFilterStrength : 0.0 ~ 1.0 Default 0.5
        let filter = LowPassMoveFilter();
        filter.lowPassFilterStrength = lowPassFilterStrength;
        return filter;
    }
    class func lowPassMoveFilter(_ baseImage: UIImage) -> UIImage
    {
        return LowPassMoveFilter().image(byFilteringImage: baseImage);
    }
    class func lowPassMoveFilter(_ baseImage: UIImage
        , lowPassFilterStrength: CGFloat
        ) -> UIImage
    {
        // lowPassFilterStrength : 0.0 ~ 1.0 Default 0.5
        let filter = LowPassMoveFilter();
        filter.lowPassFilterStrength = lowPassFilterStrength;
        return filter.image(byFilteringImage: baseImage);
    }
    
    
    //
    // other
    //

    
    //フィルタグループを作る
    class func groupFilter(_ filters: [GPUImageFilter]) -> GPUImageFilterGroup
    {
        let group = GPUImageFilterGroup();
        for i in 0 ..< filters.count {
            let f = filters[i];
            group.addFilter(f);
            if i == 0 {
                group.initialFilters = [f];
            }
            else {
                let bf = group.filter(at: UInt(i-1));
                bf?.addTarget(f);
            }
            if i == filters.count-1 {
                group.terminalFilter = f;
            }
        }
        return group;
    }
    class func groupFilter(_ baseGroup: GPUImageFilterGroup, filters: [GPUImageFilter]) -> GPUImageFilterGroup
    {
        let group = baseGroup;
        var fcount = group.filterCount();
        for i in 0 ..< filters.count {
            let f = filters[i];
            group.addFilter(f);
            
            if i == 0 && fcount == 0 {
                group.initialFilters = [f];
            }
            else {
                let bf = group.filter(at: UInt(fcount-1));
                bf?.addTarget(f);
            }
            
            if i == filters.count-1 {
                group.terminalFilter = f;
            }
            
            fcount += 1;
        }
        return group;
    }
    class func groupFilter(_ baseImage: UIImage, filters: [GPUImageFilter]) -> UIImage
    {
        let group = GPUImageFilterGroup();
        for i in 0 ..< filters.count {
            let f = filters[i];
            group.addFilter(f);
            if i == 0 {
                group.initialFilters = [f];
            }
            else {
                let bf = group.filter(at: UInt(i-1));
                bf?.addTarget(f);
            }
            if i == filters.count-1 {
                group.terminalFilter = f;
            }
        }
        
        return group.image(byFilteringImage: baseImage);
    }
    class func groupFilter(_ baseImage: UIImage, baseGroup: GPUImageFilterGroup, filters: [GPUImageFilter]) -> UIImage
    {
        let group = baseGroup;
        var fcount = group.filterCount();
        for i in 0 ..< filters.count {
            let f = filters[i];
            group.addFilter(f);
            if i == 0 && fcount == 0 {
                group.initialFilters = [f];
            }
            else {
                let bf = group.filter(at: UInt(fcount-1));
                bf?.addTarget(f);
            }
            if i == filters.count-1 {
                group.terminalFilter = f;
            }
            
            fcount += 1;
        }
        
        return group.image(byFilteringImage: baseImage);
    }
    // グループの接続
    class func groupFilter(_ baseGroup: GPUImageFilterGroup, groups: [GPUImageFilterGroup]) -> GPUImageFilterGroup
    {
        var group = baseGroup;
        var fcount = group.filterCount();
        for i in 0 ..< groups.count {
            let gfcount = groups[i].filterCount();
            for fi in 0 ..< gfcount {
                if groups[i].filter(at: fi) is GPUImageFilterGroup {
                    let g = groups[i].filter(at: fi) as! GPUImageFilterGroup;
                    group = ImageProcessing.groupFilter(group, groups: [g]);
                    
                    fcount += g.filterCount();
                }
                else if groups[i].filter(at: fi) is GPUImageFilter {
                    let f = groups[i].filter(at: fi) as! GPUImageFilter;
                    group.addFilter(f);
                    
                    if fi == 0 && fcount == 0 {
                        group.initialFilters = [f];
                    }
                    else {
                        let bf = group.filter(at: UInt(fcount-1));
                        bf?.addTarget(f);
                    }
                    
                    if i == groups.count-1 && fi == gfcount-1 {
                        group.terminalFilter = f;
                    }
                    
                    fcount += 1;
                }
            }
        }
        return group;
    }

   
    class func filter_exec(_ image: UIImage, section: Int, row: Int, overlay: UIImage? = nil) -> UIImage
    {
        switch (section) {
        case 0: // color
            return ImageProcessing.filter_exec_colorfilter(image, row: row);
        case 1: // processiong
            return ImageProcessing.filter_exec_proccessfilter(image, row: row);
        case 2: // blend
            if(overlay != nil)
            {
                return ImageProcessing.filter_exec_blendfilter(image, row: row, overlay: overlay!);
            }
        case 3: // visual effect
            return ImageProcessing.filter_exec_visualeffectfilter(image, row: row);
        default:
            break;
        }
        return image;
    }
    class func filter_exec_colorfilter(_ image: UIImage, row: Int) -> UIImage
    {
        switch (row) {
        case 0:
            return brightnessFilter(image);
        case 1:
            return exposureFilter(image);
        case 2:
            return contrastFilter(image);
        case 3:
            return gammaFilter(image);
        case 4:
            return colorMatrixFilter(image);
        case 5:
            return rgbFilter(image);
        case 6:
            return hueFilter(image);
        case 7:
            return toneCurveFilter(image);
        case 8:
            return highlightShadowFilter(image);
        case 9:
            return colorInvertFilter(image);
        case 10:
            return grayscaleFilter(image);
        case 11:
            return falseColorFilter(image);
        case 12:
            return sepiaFilter(image);
        case 13:
            return opacityFilter(image);
        case 14:
            return luminanceThresholdFilter(image);
        case 15:
            return averageLuminanceThresholdFilter(image);
        default:
            break;
        }
        return image;
    }
    class func filter_exec_proccessfilter(_ image: UIImage, row: Int) -> UIImage
    {
        switch (row) {
        case 0:
            return transform2DFilter(image);
        case 1:
            return transform3DFilter(image);
        case 2:
            return cropFilter(image);
        case 3:
            return lanczosResamplingFilter(image);
        case 4:
            return sharpenFilter(image);
        case 5:
            return unsharpMaskFilter(image);
        case 6:
            return gaussianBlurFilter(image);
        case 7:
            return gaussianSelectiveBlurFilter(image);
        case 8:
            return tiltShiftFilter(image);
        case 9:
            return boxBlurFilter(image);
        case 10:
            return convolution3x3Filter(image);
        case 11:
            return sobelEdgeDetectionFilter(image);
        case 12:
            return cannyEdgeDetectionFilter(image);
        case 13:
            return dilationFilter(image);
        case 14:
            return rgbDilationFilter(image);
        case 15:
            return erosionFilter(image);
        case 16:
            return rgbErosionFilter(image);
        case 17:
            return openingFilter(image);
        case 18:
            return rgbOpeningFilter(image);
        case 19:
            return closingFilter(image);
        case 20:
            return rgbClosingFilter(image);
        case 21:
            return lowPassFilter(image);
        case 22:
            return highPassFilter(image);
        case 23:
            return motionDetector(image);
        default:
            break;
        }
        return image;
    }
    class func filter_exec_blendfilter(_ image: UIImage, row: Int, overlay: UIImage) -> UIImage
    {
        switch (row) {
        case 0:
            return chromaKeyFilter(image, overlayImage: overlay);
        case 1:
            return chromaKeyBlendFilter(image, overlayImage: overlay);
        case 2:
            return dissolveBlendFilter(image, overlayImage: overlay);
        case 3:
            return multiplyBlendFilter(image, overlayImage: overlay);
        case 4:
            return addBlendFilter(image, overlayImage: overlay);
        case 5:
            return divideBlendFilter(image, overlayImage: overlay);
        case 6:
            return overlayBlendFilter(image, overlayImage: overlay);
        case 7:
            return darkenBlendFilter(image, overlayImage: overlay);
        case 8:
            return lightenBlendFilter(image, overlayImage: overlay);
        case 9:
            return colorBurnBlendFilter(image, overlayImage: overlay);
        case 10:
            return colorDodgeBlendFilter(image, overlayImage: overlay);
        case 11:
            return screenBlendFilter(image, overlayImage: overlay);
        case 12:
            return exclusionBlendFilter(image, overlayImage: overlay);
        case 13:
            return differenceBlendFilter(image, overlayImage: overlay);
        case 14:
            return hardLightBlendFilter(image, overlayImage: overlay);
        case 15:
            return softLightBlendFilter(image, overlayImage: overlay);
        case 16:
            return alphaBlendFilter(image, overlayImage: overlay);
        default:
            break;
        }
        return image;
    }
    class func filter_exec_visualeffectfilter(_ image: UIImage, row: Int) -> UIImage
    {
        switch (row) {
        case 0:
            return pixellateFilter(image);
        case 1:
            return polarPixellateFilter(image);
        case 2:
            return polkaDotFilter(image);
        case 3:
            return halftoneFilter(image);
        case 4:
            return crosshatchFilter(image);
        case 5:
            return sketchFilter(image);
        case 6:
            return toonFilter(image);
        case 7:
            return smoothToonFilter(image);
        case 8:
            return embossFilter(image);
        case 9:
            return posterizeFilter(image);
        case 10:
            return swirlFilter(image);
        case 11:
            return bulgeDistortionFilter(image);
        case 12:
            return pinchDistortionFilter(image);
        case 13:
            return stretchDistortionFilter(image);
        case 14:
            return vignetteFilter(image);
        case 15:
            return kuwaharaFilter(image);
        default:
            break;
        }
        return image;
    }
}

