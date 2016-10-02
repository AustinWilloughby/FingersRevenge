//
//  GameViewController.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // MARK: - ivars - 
    var gameScene: GameScene?
    var skView: SKView!
    let showDebugData = true
    let screenSize = CGSize(width: 1080, height: 1920) // iPhone 6+, 16:9 (1.77) aspect ratio
    let scaleMode = SKSceneScaleMode.aspectFill
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = self.view as! SKView
        loadHomeScene()
        
        //debug stuff
        skView.ignoresSiblingOrder = true
        skView.showsFPS = showDebugData
        skView.showsNodeCount = showDebugData
        skView.showsPhysics = true
    }
    
    // MARK: - Scene Management -
    func loadHomeScene(){
        let scene = HomeScene(size: screenSize, scaleMode: scaleMode, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameScene(levelNum:Int, totalScore:Int){
        gameScene = GameScene(size:screenSize, scaleMode: scaleMode, levelNum: levelNum, totalScore: totalScore, sceneManager: self)
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadLevelFinishScene(results: LevelResults){
        gameScene = nil
        let scene = LevelFinishScene(size: screenSize, scaleMode: scaleMode, results: results, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameOverScene(results: LevelResults){
        gameScene = nil
        let scene = GameOverScene(size: screenSize, scaleMode: scaleMode, results: results, sceneManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: reveal)
    }
    
    // MARK: - Lifecycle -
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
