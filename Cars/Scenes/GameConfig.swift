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

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let userCarCategory: UInt32 = 0x01
    static let trafficCategory: UInt32 = 0x01 << 1
}

enum ZPositions {
    static let road : CGFloat = 0
    static let userCar : CGFloat = 1
    static let trafficCar : CGFloat = ZPositions.userCar
}
