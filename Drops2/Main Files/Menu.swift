//
//  Menu.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 10/11/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import SpriteKit

class Menu: GameScenePrototype {
    override func ballTouchedGateway(_ gateway: SKNode) {
        switch gateway.name {
        case "settings":
            print("goto settings")
        case"start":
            print("goto game")
            presentSceneWith(fileName: "Level1")

        case "levels":
            print("goto level selection")
            presentSceneWith(fileName: "Levels", fadeDuration: 1, scaleMode: .aspectFill)

        default:
            break
        }
    }
}
