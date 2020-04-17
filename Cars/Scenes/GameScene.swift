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

    var userCar = SKSpriteNode()
    var gameState = SceneState.notStarted
    
    var rowHeight: CGFloat = 0
    var laneWidth: CGFloat = 0
    
    var leftX: CGFloat = 0
    var rightX: CGFloat = 0
    
    var laneSpeeds = [CGFloat]()
    
    var frames : Int = 0
    var score : Int = 0
    var timeScore : Int = 0
    var coinScore : Int = 0
    let scoreLabel = SKLabelNode(text: "0")
    
    var scorePosition = CGPoint(x: 0, y: 0)
    
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

                    let trafficCar = TrafficCar(imageNamed: getRandomCarName(), row: row, col: lane, position: CGPoint(x: x, y: y), carSpeed: laneSpeed)
                    
                    addChild(trafficCar)
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
        updateScore()
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

            car.position.y -= car.carSpeed

            if(car.position.y + car.size.height < self.frame.minY) {
                car.position.y = self.frame.maxY + car.initialPosition.y
                car.texture = SKTexture(imageNamed: self.getRandomCarName())
            }
        })
    }
    
    func moveCoins() {
        enumerateChildNodes(withName: "coin", using: { (node, error) in
            let coin = node as! Coin
            
            if coin.collected {
                coin.collected = false
                coin.position.y += self.frame.size.height * 2
            }
            else {
                coin.position.y -= coin.coinSpeed
                
                if(coin.position.y + coin.size.height < self.frame.minY) {
                    coin.position.y += self.frame.size.height * 2
                }
            }
        })
    }
    
    func updateScore() {
        frames += 1
        timeScore = frames / 60
        score = timeScore + coinScore
        scoreLabel.text = "\(score)"
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
    
    func collectCoin(coin: Coin) {
        coin.collected = true
        coinScore += coin.score
        score = timeScore + coinScore
        
        run(SKAction.playSoundFileNamed("collect", waitForCompletion: false))
    }
}
