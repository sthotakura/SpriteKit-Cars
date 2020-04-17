//
//  TrafficCar.swift
//  Cars
//
//  Created by Suresh Thotakura on 15/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit

class TrafficCar : Car {
    var row: Int = 0
    var col: Int = 0
    var initialPosition = CGPoint()
    
    init(imageNamed: String, row: Int, col: Int, position: CGPoint, carSpeed: CGFloat = 5.0) {
        super.init(imageNamed: imageNamed, carSpeed: carSpeed)
        
        self.name = "trafficCar"
        self.row = row
        self.col = col
        self.initialPosition = position
        
        self.position = position
        self.zPosition = ZPositions.cars
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.trafficCar
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}