//
//  GameScene.swift
//  Cars
//
//  Created by Suresh Thotakura on 12/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let carSize = CGSize(width: 52, height: 88.75)
    let lanes = 4
    let carsPerLane = 2
    
    var userCar = SKSpriteNode()
    var gameState = SceneState.notStarted
    var rowHeight: CGFloat = 0
    
    override func didMove(to view: SKView) {
        setUp()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState != .started {
            return
        }
        
        updateScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .notStarted {
            gameState = .started
            startScene()
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

    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.userCarCategory | PhysicsCategories.trafficCategory {
            sceneOver()
        }
    }

    
    func setUp() {
        setupScene()
        setupPhysics()
    }
    
    func setupScene() {
        setupUserCar()
        setupRoad()
        setupTraffic()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func setupUserCar(){
        userCar = SKSpriteNode(imageNamed: "blue-car")
        userCar.name = "userCar"
        userCar.size = carSize
        userCar.position.x = 160
        userCar.position.y = 82
        userCar.zPosition = ZPositions.cars
        
        userCar.physicsBody = SKPhysicsBody(circleOfRadius: userCar.size.height / 2)
        userCar.physicsBody?.categoryBitMask = PhysicsCategories.userCarCategory
        userCar.physicsBody?.contactTestBitMask = PhysicsCategories.trafficCategory
        userCar.physicsBody?.collisionBitMask = PhysicsCategories.none
        userCar.physicsBody?.affectedByGravity = false
        
        addChild(userCar)
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
        let laneWidth = frame.size.width / CGFloat(lanes)
        rowHeight = frame.size.height / CGFloat(carsPerLane)

        for lane in 0..<lanes {
            let perLane = lane == 1 ? carsPerLane - 1 : carsPerLane
            for car in 1...perLane {
                let currentLaneX = laneWidth * CGFloat(lane)
                let randomNameIndex = Int(arc4random_uniform(UInt32(4)))
                
                let trafficCar = SKSpriteNode(imageNamed: Cars.names[randomNameIndex])
                trafficCar.name = "trafficCar"
                trafficCar.position.x = currentLaneX + (laneWidth - carSize.width) / 2 + CGFloat(30)
                trafficCar.position.y = Helper.randomBetweenTwoNumbers(firstNumber: lane == 1 ? userCar.position.y + 100 : frame.maxY - CGFloat(car) * rowHeight, secondNumber: frame.maxY - CGFloat(car - 1) * rowHeight)
                trafficCar.size = carSize
                trafficCar.zPosition = ZPositions.cars
                
                trafficCar.physicsBody = SKPhysicsBody(circleOfRadius: trafficCar.size.height / 2)
                trafficCar.physicsBody?.categoryBitMask = PhysicsCategories.trafficCategory
                trafficCar.physicsBody?.collisionBitMask = PhysicsCategories.none
                trafficCar.physicsBody?.isDynamic = false
                
                addChild(trafficCar)
            }
        }
    }
    
    func startScene() {
        userCar.run(SKAction.moveTo(y: userCar.position.y + frame.size.height / 8, duration: 1.0))
    }
        
    func updateScene() {
        enumerateChildNodes(withName: "road", using: { (node, error) in
            let road = node as! SKSpriteNode
            
            road.position.y -= 10
            
            if(road.position.y + road.size.height < self.frame.minY) {
                road.position.y += self.frame.size.height * 3
            }
        })
        
        enumerateChildNodes(withName: "trafficCar", using:  { (node, error) in
            let car = node as! SKSpriteNode

            car.position.y -= 10

            if(car.position.y + car.size.height < self.frame.minY) {
                car.position.y = self.frame.maxY + CGFloat(arc4random_uniform(UInt32(4))) * self.rowHeight
            }
        })
    }
    
    func sceneOver() {
        let menuScene = MenuScene(size: self.view!.bounds.size)
        self.view!.presentScene(menuScene)
    }
}
