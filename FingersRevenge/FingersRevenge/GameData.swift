//
//  GameData
//  Shooter
//
//  Created by jefferson on 9/15/16.
//  Copyright © 2016 tony. All rights reserved.
//

import SpriteKit

struct GameData{
    init(){
        fatalError("The GameData struct is a singleton")
    }
    static let maxLevel = 3
    struct font{
        static let mainFont = "AvenirNextCondenced-DemiBold"
    }
    
    struct hud{
        static let backgroundColor = SKColor.black
        static let fontSize = CGFloat(64.0)
        static let fontColorWhite = SKColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        static let marginV = CGFloat(12.0)
        static let marginH = CGFloat(12.0)
        static let shipMaxSpeedPerSecond = CGFloat(800.0)
    }
    
    struct image{
        static let startScreenLogo = "alien_top_01"
        static let background = "background"
        static let player_A = "spaceflier_01_a"
        static let player_B = "spaceflier_01_b"
        static let arrow = "arrow"
    }
    
    struct scene {
        static let backgroundColor = SKColor.darkGray
    }
}

struct CollisionMask {
    static let none         : UInt32 = 0
    static let all          : UInt32 = UInt32.max
    static let wall         : UInt32 = 0b1
    static let unbreakable  : UInt32 = 0b10
    static let gate         : UInt32 = 0b100
    static let button       : UInt32 = 0b1000
    static let player       : UInt32 = 0b10000
    static let projectile   : UInt32 = 0b100000
    static let finish       : UInt32 = 0b1000000
}

