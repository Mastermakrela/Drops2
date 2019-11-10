//
//  Levels.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 10/11/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import SpriteKit

class Levels: GameScenePrototype {
    // MARK: - Constants
    
    private let colsPerScreen = 42
    private let levelsCount = 10
    private let tileSize = 32
    private let colCount: ((Int) -> Int) = { 10 + ($0 + 1) * 12 }
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        let wid = CGFloat(integerLiteral: tileSize * colCount(levelsCount))
        super.init(size: CGSize(width: wid, height: size.height))
        scene?.scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let wid = CGFloat(integerLiteral: tileSize * colCount(levelsCount))
        self.size = CGSize(width: wid, height: size.height)
        scene?.scaleMode = .aspectFill
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        prepareLevelGateways()
        
        ball.position.x = (-size.width / 2) + CGFloat(11 * tileSize)
        ball.position.y = (-size.height / 2) + 96
    }
    
    func prepareLevelGateways() {
        gatewaysTileMap.numberOfColumns = colCount(levelsCount)
        gatewaysTileMap.userData = [:]
        
        guard let gatewaysTileSet = SKTileSet(named: "Gateways Grid Tile Set") else {
            fatalError("Gateways Grid Tile Set not found")
        }
        
        guard let gatewayTile = gatewaysTileSet.tileGroups.first(where: { $0.name == "Gateway" }) else {
            fatalError("No Gateway tile definition found")
        }
        
        var count = 0
        func addGateway(withName name: String, atColumn col: Int) {
            count += 1
            let gateway = gatewayTile
            gatewaysTileMap.userData!["g\(count)"] = name
            gatewaysTileMap.setTileGroup(gateway, forColumn: col, row: 11)
            
            let label = SKLabelNode(text: name.replacingOccurrences(of: "_", with: " "))
            label.fontSize = 42
            label.position.y = -96
            label.position.x = (-size.width / 2) + CGFloat((col + 1) * tileSize)
            gatewaysTileMap.addChild(label)
        }
        
        addGateway(withName: "Menu", atColumn: 10)
        
        for i in 1...levelsCount {
            addGateway(withName: "Level_\(i)", atColumn: 10 + i * 12)
        }
        
        prepareGateways()
    }
    
    override func ballTouchedGateway(_ gateway: SKNode) {
        if let sceneName = gateway.name?.replacingOccurrences(of: "_", with: "") {
            presentSceneWith(fileName: sceneName)
        }
    }
}

// MARK: - Camera movement

extension Levels {
    // Horizontal camera scrolling, moving only in x-axis
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        if let camera = camera {
            let scrWid = CGFloat(integerLiteral: tileSize * colsPerScreen) / 2
            
            let leftBound = (-size.width / 2) + scrWid
            let rightBound = (size.width / 2) - scrWid
            
            camera.position.x = ball.position.x
            if camera.position.x <= leftBound {
                camera.position.x = leftBound
            } else if camera.position.x >= rightBound {
                camera.position.x = rightBound
            }
        }
    }
}
