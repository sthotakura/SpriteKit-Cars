//
//  Car.swift
//  Cars
//
//  Created by Suresh Thotakura on 15/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit

class Car : SKSpriteNode {
    static let DefaultSize = CGSize(width: 52, height: 88.75)
    
    var lane: Int = 0
    var carSpeed: CGFloat
    
    init(imageNamed: String, carSpeed: CGFloat = 0.0, lane: Int) {
        self.carSpeed = carSpeed
        self.lane = lane

        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: texture.size())
        
        self.size = Car.DefaultSize
        self.zPosition = ZPositions.cars
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.userCar
        physicsBody?.contactTestBitMask = PhysicsCategory.trafficCar | PhysicsCategory.coin
        physicsBody?.collisionBitMask = PhysicsCategory.trafficCar | PhysicsCategory.edge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

