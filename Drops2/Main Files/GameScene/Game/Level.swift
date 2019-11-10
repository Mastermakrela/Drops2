//
//  GameScene.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 27/10/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import SpriteKit

class Level: GameScenePrototype {
    var levelNumber: Int? {
        return scene?.userData?["levelNo"] as? Int
    }

    override func ballTouchedHole(_ hole: SKNode) {
        switch hole.name {
        case "WinHole":
            if let ln = levelNumber {
                presentSceneWith(fileName: "Level\(ln+1)")
            }
        default:
            presentSceneWith(fileName: "Menu")
        }
    }
}
