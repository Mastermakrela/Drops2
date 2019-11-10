//
//  GameScenePrototype.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 08/11/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import CoreMotion
import SpriteKit

class GameScenePrototype: SKScene, SKPhysicsContactDelegate {
    private let motionMenager = CMMotionManager()
    private let lightImpactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
    private let heavyImpactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Children
    
    private var wallsTileMap: SKTileMapNode!
    private var holesTileMap: SKTileMapNode!
    var gatewaysTileMap: SKTileMapNode!
    private var ballTileMap: SKTileMapNode!
    var ball: SKSpriteNode!
    
    // MARK: - Main Logic
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        physicsWorld.contactDelegate = self
        
        ball = (childNode(withName: "//Ball") as! SKSpriteNode)
        
        prepareSceneEdge()
        prepareWalls()
        prepareHoles()
        prepareGateways()
        prepareBall()
        
        motionMenager.startDeviceMotionUpdates()
        motionMenager.deviceMotionUpdateInterval = 1.0 / 30.0
    }
    
    private func prepareSceneEdge() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.friction = 0
        borderBody.categoryBitMask = 2
        physicsBody = borderBody
    }
    
    private func prepareWalls() {
        guard let wtm = childNode(withName: "wallsTileNode") as? SKTileMapNode else {
            fatalError("Walls not loaded")
        }
        wallsTileMap = wtm
        let tileSize = wallsTileMap.tileSize
        let halfWidth = CGFloat(wallsTileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(wallsTileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<wallsTileMap.numberOfColumns {
            for row in 0..<wallsTileMap.numberOfRows {
                if let tileDefinition = wallsTileMap.tileDefinition(atColumn: col, row: row) {
                    let position = tileDefinition.userData?["position"] as? String
                    var x = CGFloat(col) * tileSize.width - halfWidth
                    var y = CGFloat(row) * tileSize.height - halfHeight
                    var rect = CGRect(x: 0, y: 0, width: 0, height: 0)
                    var physicsBody: SKPhysicsBody?
                    
                    switch position {
                    case "UpEdge":
                        rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height / 2)
                        physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                        
                    case "RightEdge":
                        rect = CGRect(x: 0, y: 0, width: tileSize.width / 2, height: tileSize.height)
                        physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                        
                    case "DownEdge":
                        rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height / 2)
                        physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                        y += tileSize.height / 2
                        
                    case "LeftEdge":
                        rect = CGRect(x: 0, y: 0, width: tileSize.width / 2, height: tileSize.height)
                        physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                        x += tileSize.height / 2
                        
                    case "UpperRightEdge":
                        physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width / 2)
                        
                    case "LowerRightEdge":
                        physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width / 2)
                        y += tileSize.width
                        
                    case "LowerLeftEdge":
                        physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width / 2)
                        y += tileSize.width
                        x += tileSize.width
                        
                    case "UpperLeftEdge":
                        physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width / 2)
                        x += tileSize.width
                        
                    case "UpperLeftCorner",
                         "UpperRightCorner",
                         "LowerLeftCorner",
                         "LowerRightCorner":
                        continue
                        
                    default:
                        rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                        physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                    }
                    
                    guard let pb = physicsBody else { continue }
                    let tileNode = SKShapeNode(rect: rect)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.lineWidth = 0
                    tileNode.alpha = 0
                    tileNode.name = "Wall"
                    
                    pb.isDynamic = false
                    pb.categoryBitMask = 8
                    tileNode.physicsBody = pb
                    
                    wallsTileMap.addChild(tileNode)
                }
            }
        }
    }
    
    private func prepareHoles() {
        guard let htm = childNode(withName: "holesTileNode") as? SKTileMapNode else {
            fatalError("Holes not loaded")
        }
        holesTileMap = htm
        
        let tileSize = holesTileMap.tileSize
        let halfWidth = CGFloat(holesTileMap.numberOfColumns) / 2 * tileSize.width
        let halfHeight = CGFloat(holesTileMap.numberOfRows) / 2 * tileSize.height
        
        for col in 0..<holesTileMap.numberOfColumns {
            for row in 0..<holesTileMap.numberOfRows {
                if let tileDefinition = holesTileMap.tileDefinition(atColumn: col, row: row), let name = tileDefinition.name {
                    let x = CGFloat(col) * tileSize.width - halfWidth + tileSize.width
                    let y = CGFloat(row) * tileSize.height - halfHeight + tileSize.height
                    
                    let tileNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.name = name.isEmpty ? "Hole" : name
                    tileNode.physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width * 0.8)
                    tileNode.physicsBody?.categoryBitMask = 4
                    tileNode.physicsBody?.isDynamic = false
                    holesTileMap.addChild(tileNode)
                }
            }
        }
    }
    
    func prepareGateways() {
        guard let gtm = childNode(withName: "gatewaysTileNode") as? SKTileMapNode else {
            fatalError("Holes not loaded")
        }
        gatewaysTileMap = gtm
        
        var count = 0
        let names = gatewaysTileMap.userData as? [String: String] ?? [:]
        
        let tileSize = gatewaysTileMap.tileSize
        let halfWidth = CGFloat(gatewaysTileMap.numberOfColumns) / 2 * tileSize.width
        let halfHeight = CGFloat(gatewaysTileMap.numberOfRows) / 2 * tileSize.height
        
        for col in 0..<gatewaysTileMap.numberOfColumns {
            for row in 0..<gatewaysTileMap.numberOfRows {
                if gatewaysTileMap.tileDefinition(atColumn: col, row: row) != nil {
                    count += 1
                    let tileNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
                    
                    let x = CGFloat(col) * tileSize.width - halfWidth + tileSize.width
                    let y = CGFloat(row) * tileSize.height - halfHeight + tileSize.height
                    tileNode.position = CGPoint(x: x, y: y)
                    
                    let name = names["g\(count)"] ?? ""
                    tileNode.name = name.isEmpty ? "Gateway" : name
                    
                    tileNode.physicsBody = SKPhysicsBody(circleOfRadius: tileSize.width * 0.8)
                    tileNode.physicsBody?.categoryBitMask = 16
                    tileNode.physicsBody?.isDynamic = false
                    gatewaysTileMap.addChild(tileNode)
                }
            }
        }
    }
    
    private func prepareBall() {
        guard let btm = childNode(withName: "ballTileNode") as? SKTileMapNode else {
            fatalError("Ball not loaded")
        }
        ballTileMap = btm
        
        let tileSize = ballTileMap.tileSize
        let halfWidth = CGFloat(ballTileMap.numberOfColumns) / 2 * tileSize.width
        let halfHeight = CGFloat(ballTileMap.numberOfRows) / 2 * tileSize.height
        
        for col in 0..<ballTileMap.numberOfColumns {
            for row in 0..<ballTileMap.numberOfRows {
                if let tileDefinition = ballTileMap.tileDefinition(atColumn: col, row: row), let name = tileDefinition.name {
                    let x = CGFloat(col) * tileSize.width - halfWidth + tileSize.width
                    let y = CGFloat(row) * tileSize.height - halfHeight + tileSize.height
                    
                    switch name {
                    case "StartPoint":
                        ball.position = CGPoint(x: x, y: y)
                        ball.isHidden = false
                        
                    case "Camera":
                        let cameraNode = SKCameraNode()
                        cameraNode.position = CGPoint(x: x, y: y)
                        addChild(cameraNode)
                        camera = cameraNode
                        
                    default:
                        break
                    }
                }
            }
        }
        
        ballTileMap.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        heavyImpactFeedbackgenerator.prepare()
        lightImpactFeedbackgenerator.prepare()
        
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        if nodeA.physicsBody?.categoryBitMask != 1, nodeB.physicsBody?.categoryBitMask != 1 { return }
        let notBall = nodeA.physicsBody?.categoryBitMask != 1 ? nodeA : nodeB
        
        // Contact with Scene
        if notBall.physicsBody?.categoryBitMask == 2 {
            print("Ball to Edge")
            heavyImpactFeedbackgenerator.impactOccurred()
            ballTouchedEdge()
        }
        
        // Contact with Hole
        if notBall.physicsBody?.categoryBitMask == 4 {
            print("Ball to Hole")
            ballTouchedHole(notBall)
        }
        
        // Contact with Wall
        if notBall.physicsBody?.categoryBitMask == 8 {
            print("Ball to Wall")
            lightImpactFeedbackgenerator.impactOccurred()
            ballTouchedWall()
        }
        
        // Contact with Gateway
        if notBall.physicsBody?.categoryBitMask == 16 {
            print("Ball to Gateway")
            ballTouchedGateway(notBall)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let deviceMotion = motionMenager.deviceMotion {
            updateBall(deviceMotion: deviceMotion)
        }
        
        // position of ball in grid
//        let position = ball.position
//        let column = wallsTileMap.tileColumnIndex(fromPosition: position)
//        let row = wallsTileMap.tileRowIndex(fromPosition: position)
    }
    
    // MARK: - Functions for subclasses
    
    func ballTouchedEdge() {}
    
    func ballTouchedWall() {}
    
    func ballTouchedHole(_ hole: SKNode) {}
    
    func ballTouchedGateway(_ gateway: SKNode) {}
    
    func presentSceneWith(fileName: String, fadeDuration: Double = 1.5, scaleMode: SKSceneScaleMode = .aspectFit) {
        guard let scene = SKScene(fileNamed: fileName) else { return }
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: fadeDuration))
    }
}

// MARK: - Ball functions

extension GameScenePrototype {
    // Update balls position using CGVector
    fileprivate func updateBall(deviceMotion: CMDeviceMotion) {
        let sensivity = 0.05
        let steps = CGFloat(2)
        
        let setVelocity = { (x: CGFloat, y: CGFloat) in
            self.ball.physicsBody!.velocity = CGVector(dx: self.ball.physicsBody!.velocity.dx + x, dy: self.ball.physicsBody!.velocity.dy + y)
        }
        
        if deviceMotion.attitude.pitch > sensivity { setVelocity(steps, 0) }
        
        if deviceMotion.attitude.pitch < -sensivity { setVelocity(-steps, 0) }
        
        if deviceMotion.attitude.roll > sensivity { setVelocity(0, steps) }
        
        if deviceMotion.attitude.roll < -sensivity { setVelocity(0, -steps) }
    }
}
