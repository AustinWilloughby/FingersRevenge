//
//  GameOverScene.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import SpriteKit
class GameOverScene: SKScene {
    // MARK: - ivars -
    let sceneManager:GameViewController
    let results:LevelResults
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    let audioNode:SKNode = SKNode()
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode:SKSceneScaleMode, results: LevelResults,sceneManager:GameViewController) {
        self.results = results
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        backgroundColor = GameData.scene.backgroundColor
        
        let label = SKLabelNode(fontNamed: GameData.font.mainFont)
        label.text = "Game Over"
        label.fontSize = 140
        label.position = CGPoint(x:size.width/2, y:size.height/2 + 300)
        addChild(label)
        
        let label3 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label3.text = "Your finger's score: \(results.levelScore)"
        label3.fontSize = 90
        label3.position = CGPoint(x:size.width/2, y:size.height/2 - 100)
        addChild(label3)
        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.text = "Tap to play again"
        label4.fontColor = UIColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        label4.fontSize = 120
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 400)
        addChild(label4)
        
        self.addChild(audioNode)
        audioNode.run(SKAction.playSoundFileNamed("DeathSound.mp3", waitForCompletion: false))
        
    }
    
    
    // MARK: - Events -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        audioNode.run(SKAction.playSoundFileNamed("Ding.mp3", waitForCompletion: true))
        sceneManager.loadHomeScene()  
    }
}

