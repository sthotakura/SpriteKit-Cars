//
//  GameConfig.swift
//  Cars
//
//  Created by Suresh Thotakura on 13/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit

enum SceneState {
    case notStarted, started, stopped
}

enum Cars {
    static let names = [
        "red-car", "orange-car", "purple-car", "sky-blue-car"
    ]
}

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let userCar: UInt32 = 0x01
    static let trafficCar: UInt32 = 0x01 << 1
}

enum ZPositions {
    static let road : CGFloat = 0
    static let cars : CGFloat = 1
    static let score : CGFloat = 2
}

class Helper {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(0xFFFFFFFF)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }    
}
