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
    
    enum CreateMode: Int {
        case magiceye
        case stereogram
        
        // 各列挙値に対して文字列で返す
        func toString () -> String {
            switch self{
            case .magiceye:
                return "MagicEye"
            case .stereogram:
                return "Stereogram"
            }
        }
    }
    var createMode = CreateMode.stereogram;
    
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
        
        changeCreateModeBtn.title = createMode.toString();

        if isVideo == false && myActivityIndicator.isAnimating() == false && imageView.image == nil {
            pickSelect();
        }
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
        
        switch createMode {
        case .magiceye:
            createMode = CreateMode.stereogram;
            break;
        case .stereogram:
            createMode = CreateMode.magiceye;
            break;
        }
        sender.title = createMode.toString();
        
        if original != nil {
            exec();
        }
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
        
        var origImage = self.original!;
        
        // 撮影時の向きを反映させるおまじない
        UIGraphicsBeginImageContext(origImage.size);
        origImage.drawInRect(CGRectMake(0, 0, origImage.size.width, origImage.size.height));
        origImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // おまじない終わり
        
        self.imageView.image = origImage;
        
        self.myActivityIndicator.startAnimating();
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        
        let image: UIImage;
        if origImage.size.width < 320 || origImage.size.height < 480 {
            let baseSize = CGSizeMake(640, 960);
            let ratio: CGFloat;
            if origImage.size.height > origImage.size.width {
                ratio = baseSize.height / origImage.size.height;
            }
            else {
                ratio = baseSize.width / origImage.size.width;
            }
            let newSize = CGSize(width: (origImage.size.width * ratio), height: (origImage.size.height * ratio))
            
            UIGraphicsBeginImageContext(newSize);
            origImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else {
            image = origImage;
        }
        
        let kuwahara = ImageProcessing.kuwaharaFilter(image, radius: 2 + UInt(arc4random() % 4));
        //self.imageView.image = kuwahara;
        //NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        //sleep(1);
        
        let filtered = ImageProcessing.luminanceThresholdFilter(kuwahara, threshold: 0.5);
        //self.imageView.image = filtered;
        //NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.0));
        //sleep(1);
        
        //let filtered = ImageProcessing.luminanceThresholdFilter(image, threshold: 0.5);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let randomColor = (self.createMode == CreateMode.magiceye) ? true : false;
            self.stereogram = Stereogram().generateStereogramImage(kuwahara, depthImage: filtered, colorRandom: randomColor);
            //self.stereogram = Stereogram().generateStereogramImage(origImage, depthImage: filtered, colorRandom: randomColor);
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                
                self.myActivityIndicator.stopAnimating();
                
                if let s = self.stereogram {
                    
                    /*
                    let size = image.size;
                    let widthRatio = size.width / s.size.width
                    let heightRatio = size.height / s.size.height
                    let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
                    let resizedSize = CGSize(width: (s.size.width * ratio), height: (s.size.height * ratio))
                    UIGraphicsBeginImageContext(resizedSize)
                    s.drawInRect(CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    self.imageView.image = resizedImage;
                    */
                    
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

    override func shouldAutorotate() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
}
