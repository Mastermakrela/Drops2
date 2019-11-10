//
//  GameViewController.swift
//  Drops2
//
//  Created by Krzysztof Kostrzewa on 27/10/2019.
//  Copyright © 2019 Krzysztof Kostrzewa. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    @IBOutlet var gameSceneView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = gameSceneView {
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
            view.showsDrawCount = true

            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "Menu") {
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
