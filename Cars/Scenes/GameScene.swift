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

    let scoreLabel = SKLabelNode(text: "0")
    let gameSounds = GameSounds.sharedInstance

    var userCar = SKSpriteNode()
    var gameState = SceneState.notStarted
    
    var rowHeight: CGFloat = 0
    var laneWidth: CGFloat = 0
    
    var leftX: CGFloat = 0
    var rightX: CGFloat = 0
    
    var laneSpeeds = [CGFloat]()
    
    var frames : Int = 0 {
        didSet {
            timeScore = frames / 60
        }
    }
    var score : Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var timeScore : Int = 0 {
        didSet {
            score = timeScore + coinScore
        }
    }
    var coinScore : Int = 0 {
        didSet {
            score = timeScore + coinScore
        }
    }
    
    var scorePosition = CGPoint(x: 0, y: 0)
    
    var traffic = [Int: Set<TrafficCar>]()
    
    override func didMove(to view: SKView) {
        setUp()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState != .started {
            return
        }
        
        updateScene()
        frames += 1
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
            
            run(gameSounds.switchLane)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if gameState != .started { return }
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategory.userCar | PhysicsCategory.trafficCar {
            if let trafficCar = contact.bodyA.node?.name == "userCar" ? contact.bodyB.node as? TrafficCar : contact.bodyA.node as? TrafficCar {
                sceneOver(with: trafficCar, at: contact.contactPoint)
            }
        }
        
        if contactMask == PhysicsCategory.userCar | PhysicsCategory.coin {
            if let coin = contact.bodyA.node?.name == "userCar" ? contact.bodyB.node as? Coin : contact.bodyA.node as? Coin {
                collectCoin(coin: coin)
            }
        }
    }

    
    func setUp() {
        setupScene()
    }
    
    func setupScene() {
        laneWidth = frame.size.width / CGFloat(GameConfig.Lanes)
        leftX = laneWidth + (laneWidth - Car.DefaultSize.width) / 2 + CGFloat(30)
        rightX = 2 * laneWidth + (laneWidth - Car.DefaultSize.width) / 2 + CGFloat(30)
        
        laneSpeeds = [
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5),
            Helper.random(min: 1, max: 5)
        ]
        scorePosition = CGPoint(x: frame.maxX - 50, y: frame.maxY - 30)
        
        setupUserCar()
        setupRoad()
        setupTraffic()
        setupCoins()
        setupScoreLabel()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func setupUserCar(){
        userCar = Car(imageNamed: "blue-car")
        userCar.name = "userCar"
        userCar.position.x = leftX
        userCar.position.y = 82
        
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
        rowHeight = Car.DefaultSize.height * 1.5
        
        for lane in 0..<GameConfig.Lanes {
            traffic[lane] = Set<TrafficCar>()
        }
        
        for row in 0..<GameConfig.TrafficLayout.count {
            let rowMax = frame.maxY - CGFloat(row) * rowHeight
            let rowMin = frame.maxY - CGFloat(row + 1) * rowHeight
            
            for lane in 0..<GameConfig.Lanes {
                let currentLaneX = laneWidth * CGFloat(lane)
                let laneSpeed = laneSpeeds[lane]
                if GameConfig.TrafficLayout[row][lane] == 1 {
                    let x = currentLaneX + (laneWidth - Car.DefaultSize.width) / 2 + CGFloat(30)
                    var y = Helper.random(min: rowMin, max: rowMax)
                    if y - Car.DefaultSize.height < rowMin {
                        y = rowMin + Car.DefaultSize.height + CGFloat(15)
                    }

                    let trafficCar = TrafficCar(imageNamed: Cars.names.randomElement()!, row: row, lane: lane, position: CGPoint(x: x, y: y), carSpeed: laneSpeed)
                    
                    addChild(trafficCar)
                    
                    traffic[lane]?.insert(trafficCar)
                }
            }
        }
    }
    
    func setupCoins() {
        for lane in 1...2 {
            
            let currentLaneX = laneWidth * CGFloat(lane)
            let x = currentLaneX + (laneWidth - GameConfig.CoinSize.width) / 2 +  GameConfig.CoinSize.width / 2 + GameConfig.CoinSize.width / 8
            let y = frame.maxY - Helper.random(min: 0, max: frame.size.height / 4) * CGFloat(lane)
            
            for c in 1...GameConfig.CoinsPerLane {
                let coin = Coin(position: CGPoint(x: x, y: y - (CGFloat(c - 1 ) * (GameConfig.CoinSize.height + CGFloat(5)))))

                addChild(coin)
                
                let coinActions = SKAction.sequence([
                    SKAction.scale(to: 0.85, duration: 0.25),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.scale(to: 1.0, duration: 0.25)])
                
                coin.run(SKAction.repeatForever(coinActions))
            }
        }
    }
    
    func setupScoreLabel() {
        scoreLabel.fontSize = 20.0
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = scorePosition
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
        moveTraffic()
        moveCoins()
    }
    
    func moveRoad() {
        enumerateChildNodes(withName: "road", using: { (node, error) in
            let road = node as! SKSpriteNode
            
            road.position.y -= GameConfig.RoadSpeed
            
            if(road.position.y + road.size.height < self.frame.minY) {
                road.position.y += self.frame.size.height * 3
            }
        })
    }
    
    func moveTraffic() {
        enumerateChildNodes(withName: "trafficCar", using:  { (node, error) in
            let car = node as! TrafficCar
            
            car.position.y -= car.carSpeed;
            
            if(car.position.y + car.size.height < self.frame.minY) {
                var newY = self.frame.maxY + car.initialPosition.y

                let laneTraffic = self.traffic[car.lane]!.sorted(by: { (carOne, carTwo) -> Bool in
                    carOne.position.y > carTwo.position.y
                })

                for laneCar in laneTraffic {
                    if abs(newY - laneCar.position.y) < Car.DefaultSize.height {
                        newY = laneCar.position.y + Car.DefaultSize.height + 50
                    }
                }

                car.position.y = newY
                car.texture = SKTexture(imageNamed: Cars.names.randomElement()!)
            }
        })
    }
    
    func moveCoins() {
        enumerateChildNodes(withName: "coin", using: { (node, error) in
            let coin = node as! Coin
            
            if coin.collected {
                coin.collected = false
                coin.position.y += self.frame.maxY * 2
            }
            else {
                coin.position.y -= coin.coinSpeed
                
                if(coin.position.y + coin.size.height < self.frame.minY) {
                    coin.position.y += self.frame.maxY * 2
                }
            }
        })
    }
        
    func sceneOver(with trafficCar: TrafficCar, at point: CGPoint) {
        gameState = .stopped
        
        run(gameSounds.crash)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        
        let impulse = calculateImpulse(first: userCar.position, second: trafficCar.position)

        trafficCar.physicsBody?.applyImpulse(impulse, at: point)
        
        UserDefaults.standard.set(score, forKey: "Score")
        if score > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }

        if let collisionParticles = SKEmitterNode(fileNamed: "Collision") {
            collisionParticles.position = point + CGPoint(x: userCar.size.width / 2, y: 0);
            collisionParticles.zPosition = ZPositions.smoke
            collisionParticles.targetNode = userCar
            addChild(collisionParticles)
            
            collisionParticles.run(SKAction.wait(forDuration: 2), completion: {
                self.presentMenu()
            })
        } else {
            presentMenu()
        }
    }
    
    func presentMenu() {
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    func calculateImpulse(first a: CGPoint, second b: CGPoint) -> CGVector {
        let impulse = CGFloat(100)
        var dx = CGFloat(0)
        var dy = CGFloat(0)
        
        if a.x < b.x {
            dx = impulse
        }
        
        if a.x > b.x {
            dx = -impulse
        }
        
        if a.y < b.y {
            dy = impulse
        }
        
        if a.y > b.y {
            dy = -impulse
        }
        
        return CGVector(dx: dx, dy: dy)
    }
    
    func collectCoin(coin: Coin) {
        coin.collected = true
        coinScore += coin.score
        score = timeScore + coinScore
        
        if let particles = SKEmitterNode(fileNamed: "Collection") {
            particles.position = coin.position
            addChild(particles)

            let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
            particles.run(removeAfterDead)
        }
        
        run(gameSounds.collectCoin)
    }
}
