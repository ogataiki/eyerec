import UIKit
import AVFoundation
import AssetsLibrary
import GPUImage
import MobileCoreServices
import iAd

class ViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, GPUImageMovieDelegate
{

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var baseDotView: UIView!
    
    @IBOutlet weak var changeCreateModeBtn: UIBarButtonItem!
    @IBOutlet weak var randomDotBtn: UIBarButtonItem!
    
    var createMode = Stereogram.ColorPattern.p1;
    func createModeString(p: Stereogram.ColorPattern) -> String {
        switch p {
        case .p1:
            return NSLocalizedString("modepattern1", comment: "モードパターン1")
        case .p2:
            return NSLocalizedString("modepattern2", comment: "モードパターン2")
        case .p3:
            return NSLocalizedString("modepattern3", comment: "モードパターン3")
        case .p4:
            return NSLocalizedString("modepattern4", comment: "モードパターン4")
        }
    }
    
    var randomDot: Bool = false;
    func randomDotString(v: Bool) -> String {
        if v {
            return NSLocalizedString("RamdomDotOFFBtn", comment: "ランダムドットOFF")
        }
        else {
            return NSLocalizedString("RamdomDotONBtn", comment: "ランダムドットON")
        }
    }
    var leftDotView: UIView?;
    var rightDotView: UIView?;
    
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
        
        
        original = UIImage(named: "DefaultImage\(1+arc4random()%3)");
        
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
        randomDotBtn.title = randomDotString(randomDot);

        let ud = NSUserDefaults.standardUserDefaults();
        if let _ = ud.objectForKey("tutorial") {
            if isVideo == false && myActivityIndicator.isAnimating() == false && imageView.image == nil {
                exec();
            }
            
            // iAdを使用する
            self.canDisplayBannerAds = true;
            
            // iAd(インタースティシャル)の自動表示
            self.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Automatic;
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
        TutorialStrings(t: NSLocalizedString("TT1", comment: "TT1"), m: NSLocalizedString("TM1", comment: "TM1")),
        TutorialStrings(t: NSLocalizedString("TT2", comment: "TT2"), m: NSLocalizedString("TM2", comment: "TM2")),
        TutorialStrings(t: NSLocalizedString("TT3", comment: "TT3"), m: NSLocalizedString("TM3", comment: "TM3")),
        TutorialStrings(t: NSLocalizedString("TT4", comment: "TT4"), m: NSLocalizedString("TM4", comment: "TM4")),
        TutorialStrings(t: NSLocalizedString("TT5", comment: "TT5"), m: NSLocalizedString("TM5", comment: "TM5")),
        TutorialStrings(t: NSLocalizedString("TT6", comment: "TT6"), m: NSLocalizedString("TM6", comment: "TM6")),
        TutorialStrings(t: NSLocalizedString("TT7", comment: "TT7"), m: NSLocalizedString("TM7", comment: "TM7")),
        TutorialStrings(t: NSLocalizedString("TT8", comment: "TT8"), m: NSLocalizedString("TM8", comment: "TM8")),
    ]
    var tutorialIndex: Int = 0;
    var isTutorial = false;
    func tutorialExec() {
        if tutorialIndex >= tutorial.count {
            let ud = NSUserDefaults.standardUserDefaults();
            ud.setObject(NSNumber(bool: true), forKey: "tutorial");
            
            if isVideo == false && myActivityIndicator.isAnimating() == false && imageView.image == nil {
                exec();
            }

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
        let alert = UIAlertController(title:NSLocalizedString("Processing", comment: "画像処理中です。"),
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
        let actionSheet = UIAlertController(title:NSLocalizedString("Select pattern", comment: "パターン選択"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        // マジックアイは使わない
        for i in 0 ..< Stereogram.ColorPattern.count() {
            let p = Stereogram.ColorPattern.getFromRawValue(i);
            let alert:UIAlertAction = UIAlertAction(title: createModeString(p),
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction) -> Void in
                    self.createMode = p;
                    sender.title = self.createModeString(self.createMode);
                    if self.original != nil {
                        self.exec();
                    }
            })
            actionSheet.addAction(alert)
        }

        presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func randomDotAction(sender: UIBarButtonItem) {
        if randomDot {
            randomDot = false;
        }
        else {
            randomDot = true;
        }
        randomDotBtn.title = randomDotString(randomDot);
        exec();
    }
    
    @IBAction func otherAction(sender: AnyObject) {
        
        if myActivityIndicator.isAnimating() {
            procAlart();
            return;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:NSLocalizedString("Option", comment: "オプション"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        if let i = self.imageView.image {
            let saveAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Save image", comment: "表示中画像を保存"),
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
            let alert = UIAlertController(title:NSLocalizedString("Save image error", comment: "保存失敗"),
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
            let alert = UIAlertController(title:NSLocalizedString("Save image success", comment: "保存しました"),
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
        let actionSheet = UIAlertController(title:NSLocalizedString("Select image", comment: "画像を選択"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        
        //Default 複数指定可
        let cameraAction = UIAlertAction(title: NSLocalizedString("Take a photo", comment: "写真を撮影"),
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.movieStop();
                self.pickImageFromCamera()
        })
        
        let libraryAction = UIAlertAction(title: NSLocalizedString("Photo album", comment: "カメラロールから選ぶ"),
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
            controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext;
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            controller.modalPresentationStyle = UIModalPresentationStyle.CurrentContext;
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
        let baseWidth: CGFloat = 640;
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
        
        //let filtered = kuwahara;
        //let filtered = ImageProcessing.luminanceThresholdFilter(kuwahara, threshold: 0.5);
        //self.imageView.image = filtered;
        //NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        //sleep(1);
        
        //let filtered = ImageProcessing.luminanceThresholdFilter(image, threshold: 0.5);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let ret = Stereogram().generateStereogramImage(kuwahara, depthImage: kuwahara, colorPattern: self.createMode, randomDot: self.randomDot);
            self.stereogram = ret.image;
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                
                self.myActivityIndicator.stopAnimating();
                
                if let s = self.stereogram {
                    
                    self.imageView.image = s;
                    self.imageView.setNeedsDisplay();
                    
                    self.updateDots(s, marginSize: ret.marginSize);

                    let alert = UIAlertController(title:NSLocalizedString("How to title", comment: "左右の画像が重なるように視点を移動しよう！"),
                        message: NSLocalizedString("How to message", comment: "画像の奥を見るよう意識してみよう。"),
                        preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Cancel,
                        handler:{
                            (action:UIAlertAction) -> Void in
                    })
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title:NSLocalizedString("Process error", comment: "画像作成に失敗しました。"),
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
    
    func updateDots(image: UIImage, marginSize: Int) {
        
        for subview in self.baseDotView.subviews {
            subview.removeFromSuperview()
        }
        
        let frame = AVMakeRectWithAspectRatioInsideRect(image.size, self.imageView.bounds);
        print("frame: \(frame)");
        let margin = (frame.width / image.size.width) * CGFloat(marginSize);
        print("margin: \(margin)");
        let dissMarginWidth = frame.size.width - (margin * 2);
        
        let leftDotView = UIView(frame: CGRectMake(0, 0, 6, 6))
        leftDotView.center = CGPointMake((self.baseDotView.frame.size.width/2) - (dissMarginWidth/4), self.baseDotView.frame.size.height/2.0);
        leftDotView.backgroundColor = UIColor.blackColor()
        leftDotView.layer.cornerRadius = CGRectGetWidth(leftDotView.bounds) / 2.0
        self.baseDotView.addSubview(leftDotView)
        
        let rightDotView = UIView(frame: CGRectMake(0, 0, 6, 6))
        rightDotView.center = CGPointMake((self.baseDotView.frame.size.width/2) + (dissMarginWidth/4), self.baseDotView.frame.size.height/2.0);
        rightDotView.backgroundColor = UIColor.blackColor()
        rightDotView.layer.cornerRadius = CGRectGetWidth(leftDotView.bounds) / 2.0
        self.baseDotView.addSubview(rightDotView)
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
