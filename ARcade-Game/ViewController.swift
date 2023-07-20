//
//  ViewController.swift
//  ARcade-Game
//
//  Created by Abhay Pramod on 20/06/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var trackerNode: SCNNode!
    var mainContainer: SCNNode!
    var gameHasStarted = false
    var gameHasEnded = false
    var foundSurface = false
    var gamePos = SCNVector3Make(0.0, 0.0, 0.0)
    var randPos : [SCNVector3] = [SCNVector3Make(4,2,1.5),SCNVector3Make(2.3,2,4.5),SCNVector3Make(-0.3,2,6),SCNVector3Make(-2.2,2,5.1),SCNVector3Make(-3,2,1.5),SCNVector3Make(-4.3,2,-2),SCNVector3Make(-1.4,2,-5.7),SCNVector3Make(1.3,2,-6)]
    //var textures: CGImage = ["sun.jpg"]
    var planetSize = [0.15, 0.37, 0.39, 0.21, 2.5, 2, 1, 1]
    var planetName : [String] = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune"]
    var planetTex : [String] = ["mercury.jpeg","venus.jpeg","earth.jpeg","mars.jpeg","jupiter.jpeg","saturn.png","uranus.png","Neptune.png"]
    
    var dialogue: [String] = ["Hey, I'm Astro, And today I have a little challenge for you.","you see, you are in space and your job is to collect all the planets to make our solar system.","there are 8 planets to collect from mercury to neptune","But remember, there is next to no air in space, so you dont have much time","So Lets go..."]
    
    var endGameLabel: UILabel!
    var scoreLable: UILabel!
    var diaLabel: UILabel!
    var mascotImage: UIImage!
    var uiImage: UIImageView!
    
    var score = 0 {
        didSet{
            scoreLable.text = "\(score)"
        }
    }
    
    var diaCount = -1 {
        didSet{
            diaLabel.text = dialogue[diaCount]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var scene = SCNScene()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        scene = SCNScene(named: "art.scnassets/SolarSystem.dae")!
        
        sceneView.scene = scene
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func addPlanet(nodeName :String, texture: String, pos: SCNVector3){
        
//        let planetModel = SCNSphere(radius: radius)
//        let planetNode = SCNNode(geometry: planetModel)
//        //let planetNode = sceneView.scene.rootNode.childNode(withName: "planet", recursively: false)?.copy() as! SCNNode
//
//        planetNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: texture)
        
        
        let planetNode = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: false)?.copy() as! SCNNode
        planetNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: texture)
        
        mainContainer.addChildNode(planetNode)
        
        planetNode.isHidden = false
        planetNode.position = pos

        

        planetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        planetNode.physicsBody?.isAffectedByGravity = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameHasEnded{
            foundSurface = false
            gameHasEnded = false
            endGameLabel.removeFromSuperview()
            mainContainer.enumerateChildNodes{(node,stop) in node.removeFromParentNode()}
        }
        
        if gameHasStarted{
            
            guard let touch = touches.first else{ return }
            let touchLocation = touch.location(in: view)
            
            guard let nodeHitTest = sceneView.hitTest(touchLocation, options: nil).first else { return }
            let hitNode = nodeHitTest.node
            
            guard let pName = hitNode.name else {return}
            
            if planetName.contains(pName){
                score += 1
                hitNode.removeFromParentNode()
            }
            
        }else{
            guard foundSurface else {return}
            
            trackerNode.removeFromParentNode() //we dont need to find the surface
            
            if diaCount >= 0{
                diaLabel.removeFromSuperview()
            }
            
            
            
            if (diaCount < dialogue.count-1){
                
                diaLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height*0.4))
                diaLabel.textAlignment = .center
                diaLabel.font = UIFont(name: "Marker Felt", size: view.frame.width * 0.04)
                diaLabel.numberOfLines = 2
                diaLabel.text = "\(dialogue[0])"
                mascotImage = UIImage(named: "astro.png")
                uiImage = UIImageView(image: mascotImage)
                
                uiImage.frame = CGRect(x: 0, y: view.frame.minY + 400, width: 300, height: 300)
                
                view.addSubview(uiImage)
                view.addSubview(diaLabel)
                
                diaCount += 1;
            }
            
            else{
                diaLabel.removeFromSuperview()
                uiImage.removeFromSuperview()
                
                gameHasStarted = true
                
                scoreLable = UILabel(frame: CGRect(x: 0.0, y: view.frame.minY, width: view.frame.width, height: view.frame.height * 0.5))
                
                scoreLable.textAlignment = .center
                scoreLable.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
                scoreLable.textColor = .white
                scoreLable.text = "\(score)"
                
                view.addSubview(scoreLable)
                
                mainContainer = sceneView.scene.rootNode.childNode(withName: "mainContainer", recursively: false)!
                
                mainContainer.isHidden = false
                mainContainer.position = gamePos
                
                for i in 0...7{
                    addPlanet(nodeName: planetName[i],texture: planetTex[i],pos: randPos[i])
                }
                let saturn = sceneView.scene.rootNode.childNode(withName: "Saturn", recursively: false)!
                let satRing = saturn.childNode(withName: "RingsTop", recursively: false)!
                
                
                Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(endGame), userInfo: nil, repeats: false)
            }
            
            
        }
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard !gameHasStarted else { return } //if the  game has started this block doesnt run
        guard let hitTest = sceneView.hitTest(CGPoint(x: view.frame.midX, y: view.frame.midY), types:[.existingPlane, .featurePoint]).last else {return}  //checking where the ground is
        
        let trans = SCNMatrix4(hitTest.worldTransform)
        gamePos = SCNVector3Make(trans.m41, trans.m42, trans.m43) //the location of the game
        
        if !foundSurface{
            let trackerPlane = SCNPlane(width: 0.2, height: 0.2)
            trackerPlane.firstMaterial?.diffuse.contents = UIImage(named: "circle.png")
            
            trackerNode = SCNNode(geometry: trackerPlane)
            trackerNode.eulerAngles.x = .pi * -0.5
            
            sceneView.scene.rootNode.addChildNode(trackerNode)
            
        }
        trackerNode.position = gamePos
        foundSurface = true
        
    }
    
    @objc func endGame(){
        
        scoreLable.removeFromSuperview()
        gameHasStarted = false
        gameHasEnded = true
        
        endGameLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height*0.5))
        endGameLabel.font = UIFont(name: "Marker Felt", size: view.frame.width * 0.1)
        endGameLabel.textAlignment = .center
        endGameLabel.numberOfLines = 3
        
        if score < 8{
            
            endGameLabel.text = "It seems you could only collect \(score) planets. Better luck next time"
        }else{
            endGameLabel.text = "YAAAY!!! You were able to collect all 8 planets!! Well Done"
        }
        
        sceneView.addSubview(endGameLabel)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
