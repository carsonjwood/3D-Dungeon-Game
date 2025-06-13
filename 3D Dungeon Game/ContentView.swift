//
//  ContentView.swift
//  3D Dungeon Game
//
//  Created by Carson Wood on 4/28/25.
//
import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 600) // or whatever size you want
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
