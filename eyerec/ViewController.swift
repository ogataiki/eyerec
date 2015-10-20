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

    @IBOutlet weak var left_image: UIImageView!
    @IBOutlet weak var right_image: UIImageView!
    
    var leftVideoView : GPUImageView!;
    var rightVideoView : GPUImageView!;
    var videoRote: CGFloat = 0;
    var leftMovie: GPUImageMovie!;
    var rightMovie: GPUImageMovie!;
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
    
    @IBAction func otherAction(sender: AnyObject) {
        //UIActionSheet
        let actionSheet = UIAlertController(title:"オプション操作",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: "やめる",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        actionSheet.addAction(cancelAction)

        if let video = videoURL {
            //Default 複数指定可
            let lroteAction = UIAlertAction(title: "右回転",
                style: UIAlertActionStyle.Default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    
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
                    (action:UIAlertAction!) -> Void in
                    
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
        
        presentViewController(actionSheet, animated: true, completion: nil)
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
                (action:UIAlertAction!) -> Void in
        })
        
        //Default 複数指定可
        let cameraAction = UIAlertAction(title: "写真撮影",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.movieStop();
                self.pickImageFromCamera()
        })
        
        let libraryAction = UIAlertAction(title: "写真ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.movieStop();
                self.pickImageFromLibrary()
        })
        
        let videoAction = UIAlertAction(title: "動画ライブラリ",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.movieStop();
                self.pickMovieFromLibrary()
        })
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(videoAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func imageFilter_left(video: Bool = false) -> GPUImageFilterGroup {
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        if video {
            let rote = videoRote;
            if rote <= 45 || rote > 270+45 {
                transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 45 && rote <= 90+45 {
                transform = CATransform3DRotate(transform, 0.025, 1.0, 0.0, 0.0);
            }
            else if rote > 90+45 || rote <= 180+45 {
                transform = CATransform3DRotate(transform, -0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 180+45 || rote <= 270+45 {
                transform = CATransform3DRotate(transform, -0.025, 1.0, 0.0, 0.0);
            }
        }
        else {
            transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
        }
        return ImageProcessing.groupFilter([
            //ImageProcessing.kuwaharaFilter() as GPUImageFilter,
            ImageProcessing.transformFilter(transform, ignoreAspectRatio: true) as GPUImageFilter
        ]);
        //return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
    }

    func imageFilter_left(image: UIImage, video: Bool = false) -> UIImage {
        
        var transform = CATransform3DIdentity;
        transform.m34 = 0.5;
        if video {
            let rote = videoRote;
            if rote <= 45 || rote > 270+45 {
                transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 45 && rote <= 90+45 {
                transform = CATransform3DRotate(transform, 0.025, 1.0, 0.0, 0.0);
            }
            else if rote > 90+45 && rote <= 180+45 {
                transform = CATransform3DRotate(transform, -0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 180+45 && rote <= 270+45 {
                transform = CATransform3DRotate(transform, -0.025, 1.0, 0.0, 0.0);
            }
        }
        else {
            transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
        }
        return ImageProcessing.groupFilter(image,
            filters:[
                //ImageProcessing.kuwaharaFilter() as GPUImageFilter,
                ImageProcessing.transformFilter(transform, ignoreAspectRatio: true) as GPUImageFilter
            ]);
        //return ImageProcessing.transformFilter(image, transform: transform, ignoreAspectRatio: true);
    }
    
    func imageFilter_right(video: Bool = false) -> GPUImageFilterGroup {
        
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
        
        return ImageProcessing.groupFilter([
            //ImageProcessing.kuwaharaFilter() as GPUImageFilter,
            ImageProcessing.transformFilter(transform, ignoreAspectRatio: true) as GPUImageFilter
        ]);
        //return ImageProcessing.transformFilter(transform, ignoreAspectRatio: true);
    }
    func imageFilter_right(image: UIImage, video: Bool = false) -> UIImage {
        
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
            else if rote > 90+45 || rote <= 180+45 {
                transform = CATransform3DRotate(transform, 0.025, 0.0, 1.0, 0.0);
            }
            else if rote > 180+45 || rote <= 270+45 {
                transform = CATransform3DRotate(transform, 0.025, 1.0, 0.0, 0.0);
            }
        }
        else {
            transform = CATransform3DRotate(transform, -0.025, 0.0, 1.0, 0.0);
        }
        return ImageProcessing.groupFilter(image,
            filters:[
                //ImageProcessing.kuwaharaFilter() as GPUImageFilter,
                ImageProcessing.transformFilter(transform, ignoreAspectRatio: true) as GPUImageFilter
            ]);
        //return ImageProcessing.transformFilter(image, transform: transform, ignoreAspectRatio: true);
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
            
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // 撮影時の向きを反映させるおまじない
            UIGraphicsBeginImageContext(image.size);
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height));
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // おまじない終わり
            
            //left_image.image = image;
            //right_image.image = image;
            left_image.image = imageFilter_left(image);
            right_image.image = imageFilter_right(image);
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
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
        leftVideoView.frame = left_image.frame;
        self.view.addSubview(leftVideoView);
        
        rightVideoView = GPUImageView();
        rightVideoView.frame = right_image.frame;
        self.view.addSubview(rightVideoView);
        
        movieRotation(videoRote);

        let left_filter = imageFilter_left(video:true);
        left_filter.addTarget(leftVideoView);
        leftMovie.addTarget(left_filter);
        //leftMovie.addTarget(leftVideoView);
        
        let right_filter = imageFilter_right(video:true);
        right_filter.addTarget(rightVideoView);
        rightMovie.addTarget(right_filter);
        //rightMovie.addTarget(rightVideoView);
        
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
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
}
