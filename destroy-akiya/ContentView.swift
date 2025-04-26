//
//  ContentView.swift
//  destroy-akiya
//
//  Created by 杉本優 on 2025/04/27.
//

import SwiftUI
import RealityKit

struct ContentView : View {

    var body: some View {
        RealityView { content in

            // Create a cube model(デフォルトのモデル)
            let defaultModel = Entity()
            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
            defaultModel.components.set(ModelComponent(mesh: mesh, materials: [material]))
            defaultModel.position = [-0.2, 0.05, 0]

            // Load Unity model (ダウンロードしたusdzファイル)
            do {
                let unityModel = try await Entity(named: "chair_swan")
                unityModel.position = [0.2, 0.05, 0]

                // Create horizontal plane anchor for the content
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))

                anchor.addChild(defaultModel)
                anchor.addChild(unityModel)

                content.add(anchor)
                content.camera = .spatialTracking
            } catch {
                print("Unityモデル読み込み失敗: \(error)")
            }

        }
        .edgesIgnoringSafeArea(.all)
    }

}

#Preview {
    ContentView()
}
