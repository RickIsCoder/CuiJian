//
//  GameViewController.swift
//  CuiJian
//
//  Created by Rick on 16/1/11.
//  Copyright (c) 2016年 Rick. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion
import MediaPlayer

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet var rootView: UIView!
    @IBOutlet weak var sceneView: SCNView!
    
    var videoControlView: UIView?
    var videoView: UIView?
    var guideView: UIView?
    var icePlayer: MPMoviePlayerController?
    var clicked:Int?
    
    var motionManager: CMMotionManager?
    let camerasNode: SCNNode? = SCNNode()
    var cameraRollNode: SCNNode?
    var cameraPitchNode: SCNNode?
    var cameraYawNode: SCNNode?
    let groundPos :CGFloat = -20
    var ufoNode :SCNNode?
    var player:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.player = AVAudioPlayer(contentsOfURL: NSURL(string: NSBundle.mainBundle().pathForResource("bg", ofType: "mp3")!)!)
            self.player?.numberOfLoops = Int.max
        } catch {
            print("wrong audio")
        }
        
        self.view.backgroundColor = UIColor.blackColor()
        self.sceneView!.backgroundColor = UIColor.blackColor()
        self.sceneView.delegate = self

        // 第一次使用应用
        let defaults = NSUserDefaults.standardUserDefaults()
        let isFirstUse = defaults.boolForKey("isFirstUse")
        if !isFirstUse {
            // video
            self.loadGuideView()
            self.loadVideo()
            self.addVideoControlView()
            defaults.setBool(true, forKey: "isFirstUse")
        }
        else{
            self.initSence()
        }
    }
    
    func tapHandle(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self.sceneView)
        let hitResults = self.sceneView!.hitTest(location, options: nil)
        if hitResults.count > 0 {
        let hitedNode =  hitResults[0].node
            if hitedNode.name?.hasPrefix("icetree_") == true{
                self.clicked = 1
                self.performSegueWithIdentifier("open nav", sender: self)
            }
            else if hitedNode.name?.hasPrefix("ufo_") == true{
                self.clicked = 2
                self.performSegueWithIdentifier("open nav", sender: self)
            }
            else if hitedNode.name?.hasPrefix("team_") == true{
                self.clicked = 3
                self.performSegueWithIdentifier("open nav", sender: self)
            }
            else if hitedNode.name?.hasPrefix("mvs_") == true{
                self.clicked = 4
                self.performSegueWithIdentifier("open nav", sender: self)
            }
            else {
                self.clicked = 0
            }
        }
    }
    
    func initSence(){
        let rootScene = SCNScene()
        self.sceneView!.scene = rootScene
        self.sceneView!.autoenablesDefaultLighting = true
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapHandle:"))
        self.sceneView!.addGestureRecognizer(tapGesture)
        
        let camera = SCNCamera()
        camera.xFov = 45
        camera.yFov = 45
        camera.zFar = 700
        
        self.camerasNode!.camera = camera
        self.camerasNode!.position = SCNVector3(0,20,0)
        self.camerasNode!.eulerAngles = SCNVector3Make(GLKMathDegreesToRadians(-90), 0, 0)
        
        self.cameraRollNode = SCNNode()
        self.cameraRollNode!.addChildNode(self.camerasNode!)
        self.cameraPitchNode = SCNNode()
        self.cameraPitchNode!.addChildNode(self.cameraRollNode!)
        self.cameraYawNode = SCNNode()
        self.cameraYawNode!.addChildNode(self.cameraPitchNode!)
        rootScene.rootNode.addChildNode(self.cameraYawNode!)
        self.sceneView!.pointOfView = camerasNode
        self.motionManager = CMMotionManager()
        self.motionManager?.deviceMotionUpdateInterval = 1/60
        self.motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical)
        
        rootScene.background.contents = [UIImage(named: "skybox1")!,UIImage(named: "skybox2")!,UIImage(named: "skybox3")!,UIImage(named: "skybox4")!,UIImage(named: "skybox5")!,UIImage(named: "skybox6")!] as NSArray
        
        // Floor ground
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial!.diffuse.contents = UIImage(named: "ground")
        let floorNode = SCNNode()
        floorNode.geometry = floor
        floorNode.position = SCNVector3(0, groundPos, 0)
        rootScene.rootNode.addChildNode(floorNode)
        
        let iceTree = addNode(6, fileName: "iceTree/ice_tree.dae", namePre: "icetree_")
        iceTree.position = SCNVector3(0, self.groundPos, -50)
        iceTree.scale = SCNVector3(10,10,10)
        rootScene.rootNode.addChildNode(iceTree)
        
        let light = SCNLight()
        light.type = SCNLightTypeOmni
        light.color = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(0, 0, 0)
        lightNode.light = light
        rootScene.rootNode.addChildNode(lightNode)
        
        let light1 = SCNLight()
        light1.type = SCNLightTypeDirectional
        light1.color = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        let lightNode1 = SCNNode()
        lightNode1.rotation = SCNVector4Make(1, 0, 0, Float(-M_PI / 2))
        lightNode1.light = light1
        lightNode1.position = SCNVector3(0, 500, 0)
        rootScene.rootNode.addChildNode(lightNode1)
        
        let light2 = SCNLight()
        light2.type = SCNLightTypeSpot
        light2.color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        let lightNode2 = SCNNode()
        lightNode2.rotation = SCNVector4Make(1, 0, 0, Float(-M_PI / 2))
        lightNode2.light = light2
        lightNode2.position = SCNVector3(0, 900, 0)
        rootScene.rootNode.addChildNode(lightNode2)
        
        let m1 = addNode("mountain/mountain_A.dae")
        m1.position = SCNVector3(500, self.groundPos - 3, -350)
        m1.scale = SCNVector3(20,20,20)
        rootScene.rootNode.addChildNode(m1)
        
        let m11 = m1.clone()
        m11.position = SCNVector3(400, self.groundPos - 3, 500)
        m11.rotation.y = 90
        rootScene.rootNode.addChildNode(m11)
        
        let m2 = addNode("mountain/mountain_B.dae")
        m2.position = SCNVector3(-500, self.groundPos - 3, 350)
        m2.scale = SCNVector3(10,10,10)
        rootScene.rootNode.addChildNode(m2)

        let star5 = addNode("star/Star_5.dae")
        star5.position = SCNVector3(200, 100, -200)
        star5.scale = SCNVector3(20,20,20)
        rootScene.rootNode.addChildNode(star5)
        
        let redStar = addNode("star/Star_4.dae")
        redStar.position = SCNVector3(-50, 0, 400)
        redStar.scale = SCNVector3(50,50,50)
        rootScene.rootNode.addChildNode(redStar)
        
        let moon = addNode("star/Star_3.dae")
        moon.position = SCNVector3(400, 400, 400)
        moon.scale = SCNVector3(80,80,80)
        rootScene.rootNode.addChildNode(moon)
        
        let shadow = addNode("shadow/shadow.dae")
        
        
        let guitar = addNode("guitar/guitar.dae")
        guitar.scale = SCNVector3(15,15,15)
        guitar.position = SCNVector3(120, self.groundPos - 1, -90)
        rootScene.rootNode.addChildNode(guitar)
        let shadowguitar = shadow.clone()
        shadowguitar.scale = SCNVector3(48, 20, 24)
        shadowguitar.position = SCNVector3(120, self.groundPos + 0.1, -90)
        rootScene.rootNode.addChildNode(shadowguitar)

        
        let boy = addNode("dolls/MudDoll_boy.dae")
        boy.position = SCNVector3(50, self.groundPos + 1, 40)
        boy.rotation = SCNVector4Make(0, 1, 0, Float(-M_PI / 4.0))
        rootScene.rootNode.addChildNode(boy)
        let shadowboy = shadow.clone()
        shadowboy.position = SCNVector3(50, self.groundPos + 1, 40)
        rootScene.rootNode.addChildNode(shadowboy)
        
        let boy1 = boy.clone()
        boy1.position = SCNVector3(80, self.groundPos + 1, 40)
        boy.rotation = SCNVector4Make(0, 1, 0, Float(-M_PI / 2.0))
        rootScene.rootNode.addChildNode(boy1)
        let shadowboy1 = shadow.clone()
        shadowboy1.position = SCNVector3(80, self.groundPos + 1, 40)
        rootScene.rootNode.addChildNode(shadowboy1)

        let boy3 = boy.clone()
        boy3.scale = SCNVector3(700,700,700)
        boy3.rotation = SCNVector4Make(1, 0, 0, Float(M_PI/12))
        boy3.position = SCNVector3(50, -10, 0)
        rootScene.rootNode.addChildNode(boy3)
        
        let girl = addNode("dolls/MudDoll_girl.dae")
        girl.rotation = SCNVector4Make(0, 1, 0, Float(-M_PI))
        girl.position = SCNVector3(35, self.groundPos + 1, -15)
        rootScene.rootNode.addChildNode(girl)
        shadow.scale = SCNVector3(24, 20, 12)
        shadow.position = SCNVector3(38, self.groundPos + 1, -17)
        rootScene.rootNode.addChildNode(shadow)
        
        let girl1 = girl.clone()
        girl1.rotation = SCNVector4Make(0, 1, 0, Float(M_PI / 2))
        girl1.position = SCNVector3(40, self.groundPos + 1, -20)
        rootScene.rootNode.addChildNode(girl1)
        
        self.ufoNode = addNode(0, fileName: "UFO/UFO.dae", namePre: "ufo_")
        self.ufoNode!.position = SCNVector3(50, self.groundPos + 10, 0)
        self.ufoNode!.scale = SCNVector3(8,8,8)
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = NSValue(SCNVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(SCNVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * M_PI)))
        spin.duration = 3
        spin.repeatCount = .infinity
        self.ufoNode!.addAnimation(spin, forKey: "ufoAni")
        rootScene.rootNode.addChildNode(self.ufoNode!)
        
        let teamCuijian = addNode(0, fileName: "cuijianTeam/cuijian_team.dae", namePre: "team_")
        teamCuijian.position = SCNVector3(0, self.groundPos + 2, -30)
        teamCuijian.scale = SCNVector3(12,12,12)
        rootScene.rootNode.addChildNode(teamCuijian)

        let lavaBall = addNode(0, fileName: "aboutCuijian/LavaBall.dae", namePre: "mvs_")
        lavaBall.position = SCNVector3(-50, -15, 0)
        lavaBall.scale = SCNVector3(1500,1500,1500)
        rootScene.rootNode.addChildNode(lavaBall)
        
        let stone = addNode("star/Star_2.dae");
        stone.scale = SCNVector3(12, 12, 12)
        stone.position = SCNVector3(-50, 0, 50)
        rootScene.rootNode.addChildNode(stone)
        
        let stone2 = stone.clone()
        stone2.position = SCNVector3(-60, 10, -60)
        rootScene.rootNode.addChildNode(stone2)
        
        let stone3 = stone.clone()
        stone3.position = SCNVector3(50, 15, 50)
        rootScene.rootNode.addChildNode(stone3)
        
        let starStone = addNode("star/Star.dae");
        starStone.scale = SCNVector3(4, 4, 4)
        starStone.position = SCNVector3(-55, 5, 40)
        rootScene.rootNode.addChildNode(starStone)
        
        let starStone2 = starStone.clone()
        starStone2.position = SCNVector3(50, 15, 70)
        rootScene.rootNode.addChildNode(starStone2)
        
    }
    
    func addNode(fileName: String) -> SCNNode{
        var node = SCNNode()
        if let subScene = SCNScene(named: "art.scnassets/\(fileName)") {
            if let subNode = subScene.rootNode.childNodes.first {
                node = subNode
            }
        }
        return node

    }
    
    func addNode(duration:CFTimeInterval, fileName: String, namePre: String) -> SCNNode {
        let node = self.addNode(fileName)
        stopAnimation(duration, node: node, namePre: namePre);
        return node
    }
    
    func stopAnimation(duration:CFTimeInterval, node:SCNNode, namePre: String){
        node.name = namePre + node.name!
        if duration > 0{
            for key in node.animationKeys{
                let animation = node.animationForKey(key)!
                animation.duration = duration
                node.removeAnimationForKey(key)
                //animation.repeatCount = 0
                //animation.removedOnCompletion = true
                //animation.beginTime = CACurrentMediaTime() + 5.0
                //animation.fillMode = kCAFillModeForwards
                node.addAnimation(animation, forKey: key)
            }
        }
        for n in node.childNodes{
            self.stopAnimation(duration, node: n, namePre: namePre)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (UIApplication.sharedApplication().delegate as! AppDelegate).songPlayer.player?.playing != true{
            self.player?.play()
        }
        super.viewWillAppear(true)
        self.sceneView!.scene?.paused = false
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        self.navigationController?.navigationBarHidden = true
        //add observer to video player
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEnd", name: MPMoviePlayerPlaybackDidFinishNotification, object: icePlayer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.player?.pause()
        super.viewWillDisappear(true)
        self.sceneView!.scene?.paused = true
        // remove observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    func renderer(renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: NSTimeInterval) {
        if self.cameraRollNode != nil && self.cameraPitchNode != nil && self.cameraYawNode != nil && self.motionManager!.deviceMotion != nil{
            self.cameraRollNode!.eulerAngles.z = -Float(self.motionManager!.deviceMotion!.attitude.roll)
            self.cameraPitchNode!.eulerAngles.x = Float(self.motionManager!.deviceMotion!.attitude.pitch)
            self.cameraYawNode!.eulerAngles.y = Float(self.motionManager!.deviceMotion!.attitude.yaw)
        }
    }
    
    // MARK: - Video
    func loadVideo() {
        let path = NSBundle.mainBundle().pathForResource("ice", ofType:"mov")
        let url = NSURL(fileURLWithPath: path!)
        if let moviePlayer = MPMoviePlayerController(contentURL: url) {
            self.icePlayer = moviePlayer
            moviePlayer.view.frame = self.view.bounds
            moviePlayer.scalingMode = .AspectFill
            moviePlayer.fullscreen = true
            moviePlayer.prepareToPlay()
            moviePlayer.controlStyle = .None
            moviePlayer.shouldAutoplay = false
            videoView = moviePlayer.view
            self.view.addSubview(videoView!)
        }
    }
    
    func addVideoControlView() {
        videoControlView = UIView.loadFromNibNamed("VideoControlView")
        videoControlView!.frame = self.view.bounds
        self.view.addSubview(videoControlView!)
        let tapGesture = UITapGestureRecognizer(target: self, action: "playIceVideo")
        videoControlView!.addGestureRecognizer(tapGesture)
    }
    
    func playIceVideo() {
        self.videoControlView!.removeFromSuperview()
        self.videoControlView = nil
        self.icePlayer?.play()
    }
    
    func videoEnd() {
        self.initSence()
        self.icePlayer = nil
        self.videoView?.removeFromSuperview()
        self.videoView = nil
    }
    
    // guide view
    func loadGuideView() {
        self.guideView = UIView.loadFromNibNamed("GuideView")
        self.guideView!.frame = self.view.bounds
        self.view.addSubview(self.guideView!)
        let tapGesture = UITapGestureRecognizer(target: self, action: "removeGuide")
        self.guideView!.addGestureRecognizer(tapGesture)
    }
    
    func removeGuide() {
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.guideView?.alpha = 0
            }) { (finished) -> Void in
                self.guideView?.removeFromSuperview()
                self.guideView = nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let target = segue.destinationViewController as! UINavigationController
        target.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        target.navigationBar.shadowImage = UIImage()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)

        if self.clicked == 1{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("songViewController") as UIViewController
            target.pushViewController(controller, animated: true)
        }
        else if self.clicked == 2{
            let newsController:NewsViewController = NewsViewController();
            target.pushViewController(newsController, animated: true)
        }
        else if self.clicked == 3{
            let storyboard = UIStoryboard(name: "MVStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("aboutController") as UIViewController
            target.pushViewController(controller, animated: true)
        }
        else if self.clicked == 4{
            let storyboard = UIStoryboard(name: "MVStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("MvController") as UIViewController
            target.pushViewController(controller, animated: true)
        }
        self.clicked = 0
    }
    
}


// MARK: - ContentViewController
// description: by doing this can use navigationController
extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}





