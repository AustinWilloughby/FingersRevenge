//
//  LevelResults.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation

class LevelResults{
    let levelNum:Int
    let levelScore:Int
    let totalScore:Int
    let avoidanceMode:Bool
    let msg:String
    init(levelNum:Int, levelScore:Int, totalScore:Int, avoidance:Bool, msg:String){
        self.levelNum = levelNum
        self.levelScore = levelScore
        self.totalScore = totalScore
        self.msg = msg
        self.avoidanceMode = avoidance
    }
}
