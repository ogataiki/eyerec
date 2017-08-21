import UIKit
import AVFoundation
import AssetsLibrary
import GPUImage
import MobileCoreServices
import GoogleMobileAds

class ViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, GPUImageMovieDelegate
, GADBannerViewDelegate
, GADInterstitialDelegate
{
    @IBOutlet weak var backImageView: UIImageView!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var baseDotView: UIView!
    
    @IBOutlet weak var changeCreateModeBtn: UIBarButtonItem!
    @IBOutlet weak var randomDotBtn: UIBarButtonItem!
    
    var createMode = Stereogram.ColorPattern.p1;
    func createModeString(_ p: Stereogram.ColorPattern) -> String {
        switch p {
        case .p1:
            return NSLocalizedString("modepattern1", comment: "モードパターン1")
        case .p2:
            return NSLocalizedString("modepattern2", comment: "モードパターン2")
        case .p3:
            return NSLocalizedString("modepattern3", comment: "モードパターン3")
        case .p4:
            return NSLocalizedString("modepattern4", comment: "モードパターン4")
        case .p5:
            return NSLocalizedString("modepattern5", comment: "モードパターン5")
        }
    }
    
    var randomDot: Bool = false;
    func randomDotString(_ v: Bool) -> String {
        if v {
            return NSLocalizedString("RandomDotONBtn", comment: "ランダムドットON")
        }
        else {
            return NSLocalizedString("RandomDotOFFBtn", comment: "ランダムドットOFF")
        }
    }
    var leftDotView: UIView?;
    var rightDotView: UIView?;
    var marginSize: Int = 0;
    
    var original: UIImage? = nil;
    var stereogram: UIImage? = nil;
    var back: UIImage? = nil;
    
    var leftVideoView : GPUImageView!;
    var rightVideoView : GPUImageView!;
    var videoRote: CGFloat = 0;
    var leftMovie: GPUImageMovie!;
    var rightMovie: GPUImageMovie!;
    var videoURL : URL!;
    
    var isVideo = false
    
    fileprivate var myActivityIndicator: UIActivityIndicatorView!
    
    var bannerView: GADBannerView!;
    var interstitial: GADInterstitial?;
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(#function);

        // 画面回転によるautolayoutの制約再適用を許可
        self.view!.translatesAutoresizingMaskIntoConstraints = true;
        
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.image = nil;
        
        if let _ = original {}
        else {
            original = UIImage(named: "DefaultImage\(1+arc4random()%3)");
        }
        
        if let _ = back {}
        else {
            back = UIImage(named: "BackImage\(1+arc4random()%2)");
        }
        
        // インジケータを作成する.
        myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        // アニメーションが停止している時もインジケータを表示させる.
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        // インジケータをViewに追加する.
        self.view.addSubview(myActivityIndicator)
        
        // AdMob広告設定
        bannerView = GADBannerView();
        bannerView = GADBannerView(adSize:kGADAdSizeBanner)
        bannerView.frame.origin = CGPoint(x:0, y:UIApplication.shared.statusBarFrame.height)
        bannerView.frame.size = CGSize(width:self.view.frame.width, height:bannerView.frame.height)
        // AdMobで発行された広告ユニットIDを設定
        bannerView.adUnitID = "ca-app-pub-9023231672440164/8613935274"
        bannerView.delegate = self
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        // テスト用の広告を表示する時のみ使用（申請時に削除）
        gadRequest.testDevices = [kGADSimulatorID, "0adae163022cf263d158cc181326be34"]
        bannerView.load(gadRequest)
        self.view.addSubview(bannerView)
        
        // 端末の向きがかわったらNotificationを呼ばす設定.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated);
        
        print(#function);

    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews();
        
        print(#function);
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews();
        
        print(#function);
        
        self.view!.layoutIfNeeded();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated);
        
        print(#function);
        
        myActivityIndicator.center = imageView.center
        
        changeCreateModeBtn.title = NSLocalizedString("patterntitle", comment: "パターンタイトル");
        randomDotBtn.title = NSLocalizedString("RandomDotTitle", comment: "ランダムドットタイトル");
        
        backImageView.image = back;
        
        let ud = UserDefaults.standard;
        if let _ = ud.object(forKey: "tutorial") {
            
            if isVideo == false && myActivityIndicator.isAnimating == false && imageView.image == nil {
                exec();
            }
        }
        else {
            if isTutorial == false {
                tutorialExec();
                isTutorial = true;
            }
        }
    }
    
    // 端末の向きがかわったら呼び出される.
    func onOrientationChange(_ notification: Notification){
        
        print(#function);
        
        // 現在のデバイスの向きを取得.
        //let deviceOrientation: UIDeviceOrientation!  = UIDevice.currentDevice().orientation
        
        if(bannerView != nil)
        {
            bannerView.frame.origin = CGPoint(
                x:(self.view.frame.size.width/2) - (bannerView.frame.size.width/2),
                y:UIApplication.shared.statusBarFrame.height)
        }

        if original != nil && stereogram != nil {
            self.updateDots(stereogram!, marginSize: marginSize);
        }
        
        myActivityIndicator.center = imageView.center
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
            let ud = UserDefaults.standard;
            ud.set(NSNumber(value: true as Bool), forKey: "tutorial");
            
            if isVideo == false && myActivityIndicator.isAnimating == false && imageView.image == nil {
                exec();
            }

            return;
        }
        let alert = UIAlertController(title: tutorial[tutorialIndex].t,
            message: tutorial[tutorialIndex].m,
            preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                self.tutorialIndex += 1;
                self.tutorialExec();
        })
        alert.addAction(cancelAction)
        
        //For ipad And Univarsal Device
        alert.popoverPresentationController?.sourceView = self.view!;
        alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func procAlart() {
        let alert = UIAlertController(title:NSLocalizedString("Processing", comment: "画像処理中です。"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        alert.addAction(cancelAction)
        
        //For ipad And Univarsal Device
        alert.popoverPresentationController?.sourceView = self.view!;
        alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

        present(alert, animated: true, completion: nil)
    }

    @IBAction func toolbarCameraAction(_ sender: AnyObject) {
        if myActivityIndicator.isAnimating {
            procAlart();
            return;
        }
        pickSelect()
    }
    
    @IBAction func modeChangeAction(_ sender: UIBarButtonItem) {
        if myActivityIndicator.isAnimating {
            procAlart();
            return;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:NSLocalizedString("Select pattern", comment: "パターン選択"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        // マジックアイは使わない
        for i in 0 ..< Stereogram.ColorPattern.count() {
            let p = Stereogram.ColorPattern.getFromRawValue(i);
            let alert:UIAlertAction = UIAlertAction(title: createModeString(p),
                style: UIAlertActionStyle.default,
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

        //For ipad And Univarsal Device
        actionSheet.popoverPresentationController?.sourceView = self.view!;
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width*0.28), y: self.view!.frame.height-44, width: 0, height: 0);

        present(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func randomDotAction(_ sender: UIBarButtonItem) {
        //UIActionSheet
        let actionSheet = UIAlertController(title:NSLocalizedString("Select mode", comment: "モード選択"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        let alert_true:UIAlertAction = UIAlertAction(title: randomDotString(true),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.randomDot = true;
                self.randomDotBtn.title = self.randomDotString(true);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(alert_true)
        
        let alert_false:UIAlertAction = UIAlertAction(title: randomDotString(false),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.randomDot = false;
                self.randomDotBtn.title = self.randomDotString(false);
                if self.original != nil {
                    self.exec();
                }
        })
        actionSheet.addAction(alert_false)
        
        //For ipad And Univarsal Device
        actionSheet.popoverPresentationController?.sourceView = self.view!;
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width*0.55), y: self.view!.frame.height-44, width: 0, height: 0);

        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func helpAction(_ sender: UIBarButtonItem) {
        helpIndex = 0;
        helpExec();
    }
    
    var help: [TutorialStrings] = [
        TutorialStrings(t: NSLocalizedString("TT2", comment: "TT2"), m: NSLocalizedString("TM2", comment: "TM2")),
        TutorialStrings(t: NSLocalizedString("TT3", comment: "TT3"), m: NSLocalizedString("TM3", comment: "TM3")),
        TutorialStrings(t: NSLocalizedString("TT4", comment: "TT4"), m: NSLocalizedString("TM4", comment: "TM4")),
        TutorialStrings(t: NSLocalizedString("TT5", comment: "TT5"), m: NSLocalizedString("TM5", comment: "TM5")),
        TutorialStrings(t: NSLocalizedString("TT6", comment: "TT6"), m: NSLocalizedString("TM6", comment: "TM6")),
        TutorialStrings(t: NSLocalizedString("TT7", comment: "TT7"), m: NSLocalizedString("TM7", comment: "TM7")),
        TutorialStrings(t: NSLocalizedString("TT8", comment: "TT8"), m: NSLocalizedString("TM8", comment: "TM8")),
    ]
    var helpIndex: Int = 0;
    func helpExec() {
        if helpIndex >= help.count {
            helpIndex = 0;
            return;
        }
        let alert = UIAlertController(title: help[helpIndex].t,
            message: help[helpIndex].m,
            preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
                self.helpIndex += 1;
                self.helpExec();
        })
        alert.addAction(cancelAction)
        
        //For ipad And Univarsal Device
        alert.popoverPresentationController?.sourceView = self.view!;
        alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func otherAction(_ sender: AnyObject) {
        
        if myActivityIndicator.isAnimating {
            procAlart();
            return;
        }
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:NSLocalizedString("Option", comment: "オプション"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)

        if let i = self.imageView.image {
            let saveAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Save image", comment: "表示中画像を保存"),
                style: UIAlertActionStyle.default,
                handler:{
                    (action:UIAlertAction) -> Void in
                    
                    UIImageWriteToSavedPhotosAlbum(i
                        , self
                        , #selector(ViewController.onSaveImageFinish(_:didFinishSavingWithError:contextInfo:))
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
        
        //For ipad And Univarsal Device
        actionSheet.popoverPresentationController?.sourceView = self.view!;
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width*0.95), y: self.view!.frame.height-44, width: 0, height: 0);

        present(actionSheet, animated: true, completion: nil)
    }
    
    func onSaveImageFinish(_ image: UIImage
        , didFinishSavingWithError error: NSError!
        , contextInfo: UnsafeMutableRawPointer)
    {
        if error != nil {
            let alert = UIAlertController(title:NSLocalizedString("Save image error", comment: "保存失敗"),
                message: nil,
                preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.cancel,
                handler:{
                    (action:UIAlertAction) -> Void in
            })
            alert.addAction(cancelAction)
            
            //For ipad And Univarsal Device
            alert.popoverPresentationController?.sourceView = self.view!;
            alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

            present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title:NSLocalizedString("Save image success", comment: "保存しました"),
                message: nil,
                preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.cancel,
                handler:{
                    (action:UIAlertAction) -> Void in
            })
            alert.addAction(cancelAction)
            
            //For ipad And Univarsal Device
            alert.popoverPresentationController?.sourceView = self.view!;
            alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

            present(alert, animated: true, completion: nil)
        }
    }
    
    func pickSelect() {
        
        //UIActionSheet
        let actionSheet = UIAlertController(title:NSLocalizedString("Select image", comment: "画像を選択"),
            message: nil,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Cancel 一つだけしか指定できない
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "やめる"),
            style: UIAlertActionStyle.cancel,
            handler:{
                (action:UIAlertAction) -> Void in
        })
        
        //Default 複数指定可
        let cameraAction = UIAlertAction(title: NSLocalizedString("Take a photo", comment: "写真を撮影"),
            style: UIAlertActionStyle.default,
            handler:{
                (action:UIAlertAction) -> Void in
                self.movieStop();
                self.pickImageFromCamera()
        })
        
        let libraryAction = UIAlertAction(title: NSLocalizedString("Photo album", comment: "カメラロールから選ぶ"),
            style: UIAlertActionStyle.default,
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
        
        //For ipad And Univarsal Device
        actionSheet.popoverPresentationController?.sourceView = self.view!;
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width*0.05), y: self.view!.frame.height-44, width: 0, height: 0);

        present(actionSheet, animated: true, completion: nil)
    }
    
    func imageFilter_left(_ video: Bool = false) -> GPUImageFilterGroup {
        
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

    func imageFilter_left(_ image: UIImage, video: Bool = false) -> UIImage {
        
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
    
    func imageFilter_right(_ video: Bool = false) -> GPUImageFilterGroup {
        
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
    func imageFilter_right(_ image: UIImage, video: Bool = false) -> UIImage {
        
        return ImageProcessing.lowPassMoveFilter().image(byFilteringImage: image);
    }


    // 写真を撮ってそれを選択
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.camera
            controller.modalPresentationStyle = UIModalPresentationStyle.currentContext;
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            controller.modalPresentationStyle = UIModalPresentationStyle.currentContext;
            controller.allowsEditing = false;
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから動画を選択する
    func pickMovieFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            controller.mediaTypes = [kUTTypeMovie as String];
            controller.allowsEditing = false;
            self.present(controller, animated: true, completion: nil)
        }
    }

    // 選択キャンセル時
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 写真や動画を選択した時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true, completion: nil)

        let mediaType: CFString = info[UIImagePickerControllerMediaType] as! CFString;
        if mediaType == kUTTypeMovie {
            
            videoURL = info[UIImagePickerControllerMediaURL] as! URL;

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
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.0));
        
        // 撮影時の向き反映
        var image: UIImage = origImage;
        
        // 処理速度向上のためサイズを縮小 & 撮影時の向きを反映
        let baseWidth: CGFloat = 640;
        let ratio: CGFloat = baseWidth / image.size.width;
        let newSize = CGSize(width: (image.size.width * ratio), height: (image.size.height * ratio))
        UIGraphicsBeginImageContext(newSize);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        image = UIGraphicsGetImageFromCurrentImageContext()!;
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
        
        DispatchQueue.global(qos: .default).async {
            
            let ret = Stereogram().generateStereogramImage(kuwahara, depthImage: kuwahara, colorPattern: self.createMode, randomDot: self.randomDot);
            self.stereogram = ret.image;
            DispatchQueue.main.sync(execute: { () -> Void in
                
                self.myActivityIndicator.stopAnimating();
                
                if let s = self.stereogram {
                    
                    self.imageView.image = s;
                    self.imageView.setNeedsDisplay();
                    
                    self.marginSize = ret.marginSize;
                    
                    self.updateDots(s, marginSize: ret.marginSize);

                    let alert = UIAlertController(title:NSLocalizedString("How to title", comment: "左右の画像が重なるように視点を移動しよう！"),
                        message: NSLocalizedString("How to message", comment: "画像の奥を見るよう意識してみよう。"),
                        preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.cancel,
                        handler:{
                            (action:UIAlertAction) -> Void in
                    })
                    alert.addAction(cancelAction)
                    
                    //For ipad And Univarsal Device
                    alert.popoverPresentationController?.sourceView = self.view!;
                    alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title:NSLocalizedString("Process error", comment: "画像作成に失敗しました。"),
                        message: nil,
                        preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction:UIAlertAction = UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.cancel,
                        handler:{
                            (action:UIAlertAction) -> Void in
                    })
                    alert.addAction(cancelAction)
                    
                    //For ipad And Univarsal Device
                    alert.popoverPresentationController?.sourceView = self.view!;
                    alert.popoverPresentationController?.sourceRect = CGRect(x: (self.view!.frame.width/2), y: (self.view!.frame.height/2), width: 0, height: 0);

                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func updateDots(_ image: UIImage, marginSize: Int) {
        
        for subview in self.baseDotView.subviews {
            subview.removeFromSuperview()
        }
        
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: self.imageView.bounds);
        //print("frame: \(frame)");
        let margin = (frame.width / image.size.width) * CGFloat(marginSize);
        //print("margin: \(margin)");
        let dissMarginWidth = frame.size.width - (margin * 2);
        
        let leftDotView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        leftDotView.center = CGPoint(x: (self.baseDotView.frame.size.width/2) - (dissMarginWidth/4), y: self.baseDotView.frame.size.height/2.0);
        leftDotView.backgroundColor = UIColor.black
        leftDotView.layer.cornerRadius = leftDotView.bounds.width / 2.0
        self.baseDotView.addSubview(leftDotView)
        
        let rightDotView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        rightDotView.center = CGPoint(x: (self.baseDotView.frame.size.width/2) + (dissMarginWidth/4), y: self.baseDotView.frame.size.height/2.0);
        rightDotView.backgroundColor = UIColor.black
        rightDotView.layer.cornerRadius = leftDotView.bounds.width / 2.0
        self.baseDotView.addSubview(rightDotView)
    }
    
    func movieStart(_ url: URL) {
        
        leftMovie = GPUImageMovie(url: url);
        rightMovie = GPUImageMovie(url: url);
        
        leftMovie.delegate = self;
        rightMovie.delegate = self;
        
        leftMovie.playAtActualSpeed = true;
        rightMovie.playAtActualSpeed = true;
        
        //leftMovie.shouldRepeat = true;
        //rightMovie.shouldRepeat = true;
        
        leftVideoView = GPUImageView();
        leftVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width*0.5, height: self.view.frame.size.height);
        self.view.addSubview(leftVideoView);
        
        rightVideoView = GPUImageView();
        rightVideoView.frame = CGRect(x: self.view.frame.size.width*0.5, y: 0, width: self.view.frame.size.width*0.5, height: self.view.frame.size.height);
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
    func movieRotation(_ rote: CGFloat) {
        leftVideoView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * rote / 180.0);
        rightVideoView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * rote / 180.0);
    }
    
    var movieFinish: Int = 0;
    func didCompletePlayingMovie() {
        if movieFinish == 0 {
            movieFinish += 1;
        }
        else {
            movieFinish = 0;
            
            DispatchQueue.main.async {
                
                // UIの更新があるのでメインスレッドで
                
                self.leftMovie.removeAllTargets();
                self.rightMovie.removeAllTargets();
                self.leftVideoView.removeFromSuperview();
                self.rightVideoView.removeFromSuperview();
                
                self.movieStart(self.videoURL);
            }
        }
    }
    
    func fixOrientation(_ image: UIImage) -> UIImage
    {
        
        if image.imageOrientation == UIImageOrientation.up {
            return image
        }
        
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi));
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0);
            transform = transform.rotated(by: CGFloat((Double.pi / 2)));
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height);
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)));
            
        case .up, .upMirrored:
            break
        }
        
        
        switch image.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
            
        default:
            break;
        }
        
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: (image.cgImage?.bitsPerComponent)!,
            bytesPerRow: 0,
            space: (image.cgImage?.colorSpace!)!,
            bitmapInfo: UInt32((image.cgImage?.bitmapInfo.rawValue)!)
        )
        
        ctx?.concatenate(transform);
        
        switch image.imageOrientation {
            
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height,height: image.size.width));
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width,height: image.size.height));
            break;
        }
        
        let cgimg = ctx?.makeImage()
        
        let img = UIImage(cgImage: cgimg!)
        
        return img;
        
    }
    
    override var shouldAutorotate : Bool {
        return true;
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all;
    }
    override func viewWillTransition(to size: CGSize
        , with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator);
        
        print(#function);
    }
}
