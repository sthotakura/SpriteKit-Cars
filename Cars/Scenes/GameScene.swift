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
    
    var userCar = SKSpriteNode()
    var gameState = SceneState.notStarted
    
    var rowHeight: CGFloat = 0
    var laneWidth: CGFloat = 0
    
    var leftX: CGFloat = 0
    var rightX: CGFloat = 0
    
    let carsLayout: [[Int]] = [
        [1,0,0,0],
        [0,1,0,1],
        [1,0,0,0],
        [0,0,1,0],
    ]
    
    var laneSpeeds = [CGFloat]()
    
    var frames : Int = 0
    var score : Int = 0
    let scoreLabel = SKLabelNode(text: "Score: 0")
    
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
            startScene()
            return
        }
        
        if gameState == .started {
            if userCar.position.x < frame.midX {
                userCar.run(SKAction.moveTo(x: rightX, duration: 0.25))
            }
            else {
                userCar.run(SKAction.moveTo(x: leftX, duration: 0.25))
            }
        }
        
        run(SKAction.playSoundFileNamed("Woosh", waitForCompletion: false))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if gameState != .started { return }
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategory.userCar | PhysicsCategory.trafficCar {
            sceneOver()
        }
    }

    
    func setUp() {
        setupScene()
    }
    
    func setupScene() {
        laneWidth = frame.size.width / CGFloat(lanes)
        leftX = laneWidth + (laneWidth - carSize.width) / 2 + CGFloat(30)
        rightX = 2 * laneWidth + (laneWidth - carSize.width) / 2 + CGFloat(30)
        laneSpeeds = [
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5)
        ]
        
        setupUserCar()
        setupRoad()
        setupTraffic()
        setupScoreLabel()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func setupUserCar(){
        userCar = Car(imageNamed: "blue-car")
        userCar.position.x = leftX
        userCar.position.y = 82
        userCar.zPosition = ZPositions.cars
        
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
        rowHeight = carSize.height * 1.5
        
        for row in 0..<carsLayout.count {
            let rowMax = frame.maxY - CGFloat(row) * rowHeight
            let rowMin = frame.maxY - CGFloat(row + 1) * rowHeight
            
            for lane in 0..<lanes {
                let currentLaneX = laneWidth * CGFloat(lane)
                let laneSpeed = laneSpeeds[lane]
                if carsLayout[row][lane] == 1 {
                    let x = currentLaneX + (laneWidth - carSize.width) / 2 + CGFloat(30)
                    var y = Helper.random(min: rowMin, max: rowMax)
                    if y - carSize.height < rowMin {
                        y = rowMin + carSize.height + CGFloat(15)
                    }
                    let position = CGPoint(x: x, y: y)

                    let trafficCar = TrafficCar(imageNamed: getRandomCarName(), row: row, col: lane, position: position, carSpeed: laneSpeed)
                    trafficCar.zPosition = ZPositions.cars
                    
                    addChild(trafficCar)
                }
            }
        }
    }
    
    func setupScoreLabel() {
        scoreLabel.fontSize = 20.0
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = UIColor.black //UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        scoreLabel.position = CGPoint(x: frame.maxX - 60, y: frame.maxY - 30)
        scoreLabel.zPosition = ZPositions.score
        
        addChild(scoreLabel)
    }
    
    func startScene() {
        setupPhysics()
        userCar.run(SKAction.moveTo(y: userCar.position.y + frame.size.height / 8, duration: 1.0))
        gameState = .started
    }
        
    func updateScene() {
        moveRoad()
        updateTraffic()
        updateScore()
    }
    
    func moveRoad() {
        enumerateChildNodes(withName: "road", using: { (node, error) in
            let road = node as! SKSpriteNode
            
            road.position.y -= 8
            
            if(road.position.y + road.size.height < self.frame.minY) {
                road.position.y += self.frame.size.height * 3
            }
        })
    }
    
    func updateTraffic() {
        enumerateChildNodes(withName: "trafficCar", using:  { (node, error) in
            let car = node as! TrafficCar

            car.position.y -= car.carSpeed

            if(car.position.y + car.size.height < self.frame.minY) {
                car.position.y = self.frame.maxY + car.initialPosition.y
                car.texture = SKTexture(imageNamed: self.getRandomCarName())
            }
        })
    }
    
    func updateScore() {
        frames += 1
        score = frames / 60
        scoreLabel.text = "Score: \(score)"
    }
    
    func getRandomCarName() -> String{
        return Cars.names[Int(arc4random_uniform(4))]
    }
    
    func sceneOver() {
        gameState = .stopped
        
        UserDefaults.standard.set(score, forKey: "Score")
        if score > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }

        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
