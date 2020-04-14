//
//  GameScene.swift
//  Cars
//
//  Created by Suresh Thotakura on 12/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let carSize = CGSize(width: 52, height: 88.75)
    var userCar = SKSpriteNode()
    var gameState = SceneState.notStarted
    
    override func didMove(to view: SKView) {
        setUp()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState != .started {
            return
        }
        
        moveRoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .notStarted {
            gameState = .started
            userCar.run(SKAction.moveTo(y: userCar.position.y + frame.size.height / 8, duration: 1.0))
            return
        }
        
        if gameState == .started {
            if userCar.position.x < frame.midX {
                let diff = frame.midX - userCar.position.x + userCar.size.width
                userCar.run(SKAction.moveTo(x: userCar.position.x + diff, duration: 0.25))
            }
            else {
                let diff = userCar.position.x - frame.midX + userCar.size.width
                userCar.run(SKAction.moveTo(x: userCar.position.x - diff, duration: 0.25))
            }
        }
    }
    
    func setUp() {
        setupUserCar()
        setupRoad()
        setupTraffic()
    }
    
    func setupUserCar(){
        userCar = childNode(withName: "userCar") as! SKSpriteNode
        userCar.physicsBody = SKPhysicsBody()
        userCar.physicsBody?.isDynamic = false
        userCar.physicsBody?.collisionBitMask = PhysicsCategories.userCarCategory
    }
    
    func setupRoad() {
        for i in 0...3 {
            let road = SKSpriteNode(imageNamed: "road")
            road.name = "road"
            road.zPosition = ZPositions.road
            road.size = CGSize(width: frame.size.width, height: frame.size.height)
            road.anchorPoint = CGPoint(x: 0, y: 0)
            road.position = CGPoint(x: frame.minX, y:  CGFloat(i) * frame.size.height)
            
            addChild(road)
        }
    }
    
    func setupTraffic() {
        let random = Int(arc4random_uniform(UInt32(4)))
        let randomCar = SKSpriteNode(imageNamed: Cars.names[random])
        randomCar.position.x = frame.midX
        randomCar.position.y = frame.midY
        randomCar.size = carSize
        randomCar.zPosition = ZPositions.trafficCar
        randomCar.physicsBody = SKPhysicsBody()
        
        addChild(randomCar)
    }
    
    func moveRoad() {
        enumerateChildNodes(withName: "road", using: { (node, error) in
            let road = node as! SKSpriteNode
            
            road.position.y -= 10
            
            if(road.position.y + road.size.height < self.frame.minY) {
                road.position.y += self.frame.size.height * 3
            }
        })
    }
}
