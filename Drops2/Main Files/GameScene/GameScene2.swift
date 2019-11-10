//
//  GameScene.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 27/10/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import SpriteKit

class GameScene2: GameScenePrototype {
    
    override func ballTouchedHole(_ hole: SKNode) {
        switch hole.name {
        case "WinHole":
            print("You Won")
        default:
            guard let scene = SKScene(fileNamed: "GameScene2") else { return }
            scene.scaleMode = .aspectFit
            
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.5))
        }
    }
    
}
