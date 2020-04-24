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
    static let edge: UInt32 = 0x01
    static let userCar: UInt32 = 0x01 << 1
    static let trafficCar: UInt32 = 0x01 << 2
    static let coin : UInt32 = 0x01 << 3
}

enum ZPositions {
    static let road : CGFloat = 0
    static let coins : CGFloat = 1
    static let cars : CGFloat = 2
    static let score : CGFloat = 3
    static let smoke : CGFloat = 4
}

class Helper {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(0xFFFFFFFF)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }    
}

extension CGPoint {
    
    static public func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static public func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
}

class GameConfig {
    static let TrafficLayout : [[Int]] = [
        [1,0,0,0],
        [0,1,0,1],
        [1,0,0,0],
        [0,0,1,0],
    ]
    
    static let CoinsLayout : [[Int]] = [
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0],
        [0,0,0,0],
        [0,1,0,1],
        [1,0,1,0],
        [0,0,1,0],
        [1,0,1,1],
        [0,1,1,0],
        [0,1,1,0],
        [0,1,0,0],
        [0,1,0,0],
        [0,1,0,0],
        [1,0,0,1],
        [0,0,0,0],
        [0,0,0,0],
    ]
    
    static let CoinSize = CGSize(width: 30, height: 30)
    
    static let Lanes = 4

    static let RoadSpeed = CGFloat(8)
}
