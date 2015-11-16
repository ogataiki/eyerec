import UIKit
import AVFoundation
import AssetsLibrary
import GPUImage
import MobileCoreServices

class ViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, GPUImageMovieDelegate
{

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var changeCreateModeBtn: UIBarButtonItem!
    
    var createMode = Stereogram.ColorPattern.p1;
    func createModeString(p: Stereogram.ColorPattern) -> String {
        switch p{
        case .random1:
            return "MagicEye"
        case .p1:
            return "Stereogram1"
        case .p2:
            return "Stereogram2"
        case .p3:
            return "Stereogram3"
        case .p4:
            return "Stereogram4"
        }
    }
    
    var original: UIImage? = nil;
    var stereogram: UIImage? = nil;
    
    var leftVideoView : GPUImageView!;
    var rightVideoView : GPUImageView!;
    var videoRote: CGFloat = 0;
    var leftMovie: GPUImageMovie!;
    var rightMovie: GPUImageMovie!;
    var videoURL : NSURL!;
    
    var isVideo = false
    
    private var myActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.image = nil;
        
        // インジケータを作成する.
        myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.frame = CGRectMake(0, 0, 50, 50)
        
        // アニメーションが停止している時もインジケータを表示させる.
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // インジケータをViewに追加する.
        self.view.addSubview(myActivityIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated);

        myActivityIndicator.center = imageView.center
        
        changeCreateModeBtn.title = createModeString(createMode);

        let ud = NSUserDefaults.standardUserDefaults();
        if let _ = ud.objectForKey("tutorial") {
            if isVideo == false && myActivityIndicator.isAnimating() == false && imageView.image == nil {
                pickSelect();
            }
        }
        else {
            if isTutorial == false {
                tutorialExec();
                isTutorial = true;
            }
        }
    }
    
    struct TutorialStrings {
        var t = "";
        var m = "";
    }
    var tutorial: [TutorialStrings] = [
        TutorialStrings(t: "はじめまして！", m: "立体君をインストールしてくれてありがとう！"),
        TutorialStrings(t: "このアプリは", m: "写真や画像を立体視で遊べるように加工します！"),
        TutorialStrings(t: "立体視とは", m: "2枚の写真や画像が重なるように視点を前後に移動することで、一部が立体的に飛び出して見えることを言います！"),
        TutorialStrings(t: "これで遊ぶと", m: "視力回復の効果が期待できるかも！？"),
        TutorialStrings(t: "それはともかく", m: "楽しいのでぜひ遊んでみてください！"),
        TutorialStrings(t: "遊び方は簡単", m: "画面下にあるカメラアイコンをタッチして写真や画像を選ぶだけ！"),
        TutorialStrings(t: "飛び出して見えない画像は", m: "画面左下をタップして加工のパターンを変えてみよう！"),
        TutorialStrings(t: "それでは", m: "好きな写真を選んで遊んでみてください！"),
    ];
    var tutorialIndex: Int = 0;
    var isTutorial = false;
    func tutorialExec() {
        if tutorialIndex >= tutorial.count {
            let ud = NSUserDefaults.standardUserDefaults();
            ud.setObject(NSNumber(bool: true), forKey: "tutorial");
            return;
        }
        let alert = UIAlertController(title: tutorial[tutorialIndex].t,
            message: tutorial[tutorialIndex].m,
            preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                self.tutorialIndex++;
                self.tutorialExec();
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func procAlart() {
        let alert = UIAlertController(title:"画像処理中です。",
            message: nil,
            preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func toolbarCameraAction(sender: AnyObject) {
        if myActivityIndicator.isAnimating() {
            procAlart();
            return;
        }
        pickSelect()
    }
    
    @IBAction func modeChangeAction(sender: UIBarButtonItem) {
        if myActivityIndicator.isAnimating() {
            procAlart();
            return;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:"パターン選択",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        //立体視1
        let s1Action:UIAlertAction = UIAlertAction(title: "ステレオグラム1",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.createMode = Stereogram.ColorPattern.p1;
                sender.title = self.createModeString(self.createMode);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(s1Action)

        //立体視2
        let s2Action:UIAlertAction = UIAlertAction(title: "ステレオグラム2",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.createMode = Stereogram.ColorPattern.p2;
                sender.title = self.createModeString(self.createMode);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(s2Action)

        //立体視3
        let s3Action:UIAlertAction = UIAlertAction(title: "ステレオグラム3",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.createMode = Stereogram.ColorPattern.p3;
                sender.title = self.createModeString(self.createMode);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(s3Action)

        //立体視4
        let s4Action:UIAlertAction = UIAlertAction(title: "ステレオグラム4",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.createMode = Stereogram.ColorPattern.p4;
                sender.title = self.createModeString(self.createMode);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(s4Action)

        //マジカルアイ
        let m1Action:UIAlertAction = UIAlertAction(title: "マジカルアイ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.createMode = Stereogram.ColorPattern.random1;
                sender.title = self.createModeString(self.createMode);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(m1Action)

        presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func otherAction(sender: AnyObject) {
        
        if myActivityIndicator.isAnimating() {
            procAlart();
            return;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:"オプション操作",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        if let i = self.imageView.image {
            let saveAction:UIAlertAction = UIAlertAction(title: "表示中画像を保存",
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction) -> Void in
                    
                    UIImageWriteToSavedPhotosAlbum(i
                        , self
                        , "onSaveImageFinish:didFinishSavingWithError:contextInfo:"
                        , nil);
            })
            actionSheet.addAction(saveAction)
        }

        /*
        if let _ = videoURL {
            //Default 複数指定可
            let lroteAction = UIAlertAction(title: "右回転",
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.videoRote += 90.0;
                    if self.videoRote >= 360 {
                        self.videoRote = self.videoRote - 360;
                    }

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.leftMovie.delegate = nil;
                        self.rightMovie.delegate = nil;
                        
                        self.leftMovie.removeAllTargets();
                        self.rightMovie.removeAllTargets();
                        self.leftVideoView.removeFromSuperview();
                        self.rightVideoView.removeFromSuperview();

                        // UIの更新があるのでメインスレッドで
                        self.movieStart(self.videoURL);
                    })
            })
            
            let rroteAction = UIAlertAction(title: "左回転",
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.videoRote -= 90.0;
                    if self.videoRote < 0 {
                        self.videoRote = 360 + self.videoRote;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        // UIの更新があるのでメインスレッドで
                        
                        self.leftMovie.delegate = nil;
                        self.rightMovie.delegate = nil;
                        
                        self.leftMovie.removeAllTargets();
                        self.rightMovie.removeAllTargets();
                        self.leftVideoView.removeFromSuperview();
                        self.rightVideoView.removeFromSuperview();

                        self.movieStart(self.videoURL);
                    })
            })
            
            actionSheet.addAction(lroteAction)
            actionSheet.addAction(rroteAction)
        }
        */
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func onSaveImageFinish(image: UIImage
        , didFinishSavingWithError error: NSError!
        , contextInfo: UnsafeMutablePointer<Void>)
    {
        if error != nil {
            let alert = UIAlertController(title:"保存失敗",
                message: nil,
                preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler:{
                    (action:UIAlertAction) -> Void in
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title:"保存しました",
                message: nil,
                preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler:{
                    (action:UIAlertAction) -> Void in
            })
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func pickSelect() {
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:"画像を選択",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        
        //Default 複数指定可
        let cameraAction = UIAlertAction(title: "写真撮影",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.movieStop();
                self.pickImageFromCamera()
        })
        
        let libraryAction = UIAlertAction(title: "写真ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.movieStop();
                self.pickImageFromLibrary()
        })
        
        /*
        let videoAction = UIAlertAction(title: "動画ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.movieStop();
                self.pickMovieFromLibrary()
        })*/
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        //actionSheet.addAction(videoAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func imageFilter_left(video: Bool = false) -> GPUImageFilterGroup {
        
        //return ImageProcessing.groupFilter([
            //ImageProcessing.luminanceThresholdFilter() as GPUImageFilter
            //ImageProcessing.sobelEdgeMoveFilter() as GPUImageFilter
        //]);
        return ImageProcessing.groupFilter(ImageProcessing.lowPassMoveFilter()
            , filters: [
                ImageProcessing.gaussianBlurFilter() as GPUImageFilter
            ])
        //return ImageProcessing.lowPassMoveFilter();

        /*
        var transform3D = CATransform3DIdentity;
        transform3D.m34 = 0.5;
        let angle: CGFloat = 0.1;
        if video {
            let rote = videoRote;
            if rote <= 45 || rote > 270+45 {
                transform3D = CATransform3DRotate(transform3D, angle, 0.0, 1.0, 0.0);
            }
            else if rote > 45 && rote <= 90+45 {
                transform3D = CATransform3DRotate(transform3D, angle, 1.0, 0.0, 0.0);
            }
            else if rote > 90+45 && rote <= 180+45 {
                transform3D = CATransform3DRotate(transform3D, angle*(-1), 0.0, 1.0, 0.0);
            }
            else if rote > 180+45 && rote <= 270+45 {
                transform3D = CATransform3DRotate(transform3D, angle*(-1), 1.0, 0.0, 0.0);
            }
        }
        else {
            transform3D = CATransform3DRotate(transform3D, angle, 0.0, 1.0, 0.0);
        }
        
        return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
        */
    }

    func imageFilter_left(image: UIImage, video: Bool = false) -> UIImage {
        
        //return ImageProcessing.groupFilter([
            //ImageProcessing.luminanceThresholdFilter() as GPUImageFilter
            //ImageProcessing.sobelEdgeMoveFilter() as GPUImageFilter
        //]).imageByFilteringImage(image);
        return ImageProcessing.groupFilter(image
            , baseGroup: ImageProcessing.lowPassMoveFilter()
            , filters: [
                ImageProcessing.gaussianBlurFilter() as GPUImageFilter
            ])
        //return ImageProcessing.lowPassMoveFilter().imageByFilteringImage(image);
    }
    
    func imageFilter_right(video: Bool = false) -> GPUImageFilterGroup {
        
        return ImageProcessing.lowPassMoveFilter();

        /*
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        if video {
            let rote = videoRote;
            if rote <= 45 || rote > 270+45 {
                transform = CATransform3DRotate(transform, -0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 45 && rote <= 90+45 {
                transform = CATransform3DRotate(transform, -0.025, 1.0, 0.0, 0.0);
            }
            else if rote > 90+45 && rote <= 180+45 {
                transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 180+45 && rote <= 270+45 {
                transform = CATransform3DRotate(transform, 0.025, 1.0, 0.0, 0.0);
            }
        }
        else {
            transform = CATransform3DRotate(transform, -0.025, 0.0, 1.0, 0.0);
        }
        
        return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
        */
    }
    func imageFilter_right(image: UIImage, video: Bool = false) -> UIImage {
        
        return ImageProcessing.lowPassMoveFilter().imageByFilteringImage(image);
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
            controller.mediaTypes = [kUTTypeMovie as String];
            controller.allowsEditing = false;
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }

    
    // 写真や動画を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        picker.dismissViewControllerAnimated(true, completion: nil)

        let mediaType: CFString = info[UIImagePickerControllerMediaType] as! CFString;
        if mediaType == kUTTypeMovie {
            
            videoURL = info[UIImagePickerControllerMediaURL] as! NSURL;

            movieStart(videoURL);
            
            isVideo = true
        }
        else if info[UIImagePickerControllerOriginalImage] != nil {

            self.original = info[UIImagePickerControllerOriginalImage] as? UIImage;
            
            exec();
        }
    }
    
    func exec() {
        
        let origImage = self.original!;
        
        self.imageView.image = origImage;
        
        self.myActivityIndicator.startAnimating();
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        
        // 撮影時の向き反映
        var image: UIImage = origImage;
        
        // 処理速度向上のためサイズを縮小 & 撮影時の向きを反映
        let baseWidth: CGFloat = 320;
        let ratio: CGFloat = baseWidth / image.size.width;
        let newSize = CGSize(width: (image.size.width * ratio), height: (image.size.height * ratio))
        UIGraphicsBeginImageContext(newSize);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        let kuwahara = ImageProcessing.kuwaharaFilter(image, radius: 3);
        //self.imageView.image = kuwahara;
        //NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        //sleep(1);
        
        let filtered = kuwahara;
        //let filtered = ImageProcessing.luminanceThresholdFilter(kuwahara, threshold: 0.5);
        //self.imageView.image = filtered;
        //NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        //sleep(1);
        
        //let filtered = ImageProcessing.luminanceThresholdFilter(image, threshold: 0.5);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.stereogram = Stereogram().generateStereogramImage(kuwahara, depthImage: filtered, colorPattern: self.createMode);
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                
                self.myActivityIndicator.stopAnimating();
                
                if let s = self.stereogram {
                    
                    self.imageView.image = s;
                    self.imageView.setNeedsDisplay();
                }
                else {
                    let alert = UIAlertController(title:"画像作成に失敗しました。",
                        message: nil,
                        preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Cancel,
                        handler:{
                            (action:UIAlertAction) -> Void in
                    })
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        })
    }
    
    func movieStart(url: NSURL) {
        
        leftMovie = GPUImageMovie(URL: url);
        rightMovie = GPUImageMovie(URL: url);
        
        leftMovie.delegate = self;
        rightMovie.delegate = self;
        
        leftMovie.playAtActualSpeed = true;
        rightMovie.playAtActualSpeed = true;
        
        //leftMovie.shouldRepeat = true;
        //rightMovie.shouldRepeat = true;
        
        leftVideoView = GPUImageView();
        leftVideoView.frame = CGRectMake(0, 0, self.view.frame.size.width*0.5, self.view.frame.size.height);
        self.view.addSubview(leftVideoView);
        
        rightVideoView = GPUImageView();
        rightVideoView.frame = CGRectMake(self.view.frame.size.width*0.5, 0, self.view.frame.size.width*0.5, self.view.frame.size.height);
        self.view.addSubview(rightVideoView);
        
        movieRotation(videoRote);

        let left_filter = imageFilter_left(true);
        left_filter.addTarget(leftVideoView);
        leftMovie.addTarget(left_filter);
        //leftMovie.addTarget(leftVideoView);
        
        //let right_filter = imageFilter_right(video:true);
        //right_filter.addTarget(rightVideoView);
        //rightMovie.addTarget(right_filter);
        rightMovie.addTarget(rightVideoView);
        
        leftMovie.startProcessing();
        rightMovie.startProcessing();
    }
    func movieStop() {
        if isVideo {
            
            leftMovie.delegate = nil;
            rightMovie.delegate = nil;
            leftMovie.cancelProcessing();
            rightMovie.cancelProcessing();
            leftMovie.removeAllTargets();
            rightMovie.removeAllTargets();
            leftVideoView.removeFromSuperview();
            rightVideoView.removeFromSuperview();
            
            isVideo = false;
        }
    }
    func movieRotation(rote: CGFloat) {
        leftVideoView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * rote / 180.0);
        rightVideoView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * rote / 180.0);
    }
    
    var movieFinish: Int = 0;
    func didCompletePlayingMovie() {
        if movieFinish == 0 {
            movieFinish++;
        }
        else {
            movieFinish = 0;
            
            dispatch_async(dispatch_get_main_queue()) {
                
                // UIの更新があるのでメインスレッドで
                
                self.leftMovie.removeAllTargets();
                self.rightMovie.removeAllTargets();
                self.leftVideoView.removeFromSuperview();
                self.rightVideoView.removeFromSuperview();
                
                self.movieStart(self.videoURL);
            }
        }
    }
    
    func fixOrientation(image: UIImage) -> UIImage
    {
        
        if image.imageOrientation == UIImageOrientation.Up {
            return image
        }
        
        var transform = CGAffineTransformIdentity
        
        switch image.imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2));
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2));
            
        case .Up, .UpMirrored:
            break
        }
        
        
        switch image.imageOrientation {
            
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1);
            
        default:
            break;
        }
        
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGBitmapContextCreate(
            nil,
            Int(image.size.width),
            Int(image.size.height),
            CGImageGetBitsPerComponent(image.CGImage),
            0,
            CGImageGetColorSpace(image.CGImage),
            UInt32(CGImageGetBitmapInfo(image.CGImage).rawValue)
        )
        
        CGContextConcatCTM(ctx, transform);
        
        switch image.imageOrientation {
            
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height,image.size.width), image.CGImage);
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width,image.size.height), image.CGImage);
            break;
        }
        
        let cgimg = CGBitmapContextCreateImage(ctx)
        
        let img = UIImage(CGImage: cgimg!)
        
        return img;
        
    }

    override func shouldAutorotate() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
}
