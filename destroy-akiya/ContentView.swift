////
////  ContentView.swift
////  destroy-akiya
////
////  Created by 杉本優 on 2025/04/27.
////
//
//import SwiftUI
//import RealityKit
//
//struct ContentView : View {
//    @State private var isShowingSecondModel = false
//    @State private var arAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//
//    // 最初のモデルをロードする非同期関数
//    func loadFirstModel() async -> Entity? {
//        do {
//            let defaultModel = Entity()
//            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//            defaultModel.components.set(ModelComponent(mesh: mesh, materials: [material]))
//            defaultModel.position = [-0.2, 0.05, 0]
//
//            let unityModel = try await Entity(named: "chair_swan")
//            unityModel.position = [0.2, 0.05, 0]
//
//            let groupEntity = Entity()
//            groupEntity.addChild(defaultModel)
//            groupEntity.addChild(unityModel)
//            return groupEntity
//        } catch {
//            print("最初のUnityモデル読み込み失敗: \(error)")
//            return nil
//        }
//    }
//
//    // 新しいモデルをロードする非同期関数
//    func loadSecondModel() async -> Entity? {
//        do {
//            let unityModel = try await Entity(named: "test_anim_cube")
//            unityModel.position = [0, 0.05, 0]
//
//            if let animationResource = unityModel.availableAnimations.first {
//                // アニメーション再生
//                let animationPlaybackController = unityModel.playAnimation(
//                    animationResource,
//                    transitionDuration: 0.5,
//                    startsPaused: false
//                )
//                
//                // アニメーションの再生が開始されたか確認
//                if animationPlaybackController.isPlaying {
//                    print("アニメーションが正常に再生されています。")
//                } else {
//                    print("アニメーションの再生開始に失敗しました。")
//                }
//            } else {
//                print("bakeToilet モデルにアニメーションが含まれていません。")
//            }
//
//            return unityModel
//        } catch {
//            print("新しいUnityモデル読み込み失敗: \(error)")
//            return nil
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            RealityView { content in
//                content.add(arAnchor)
//                content.camera = .spatialTracking
//
//                Task {
//                    if isShowingSecondModel {
//                        if let secondModel = await loadSecondModel() {
//                            // 既存の子をすべて削除
//                            arAnchor.children.forEach { $0.removeFromParent() }
//                            arAnchor.addChild(secondModel)
//                        }
//                    } else {
//                        if let firstModel = await loadFirstModel() {
//                            // 既存の子をすべて削除
//                            arAnchor.children.forEach { $0.removeFromParent() }
//                            arAnchor.addChild(firstModel)
//                        }
//                    }
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//
//            // 切り替えボタン
//            VStack {
//                Spacer()
//                Button(isShowingSecondModel ? "家の中に入る" : "家の外に出る") {
//                    isShowingSecondModel.toggle()
//                    Task {
//                        if isShowingSecondModel {
//                            if let secondModel = await loadSecondModel() {
//                                // 既存の子をすべて削除
//                                arAnchor.children.forEach { $0.removeFromParent() }
//                                arAnchor.addChild(secondModel)
//                            }
//                        } else {
//                            if let firstModel = await loadFirstModel() {
//                                // 既存の子をすべて削除
//                                arAnchor.children.forEach { $0.removeFromParent() }
//                                arAnchor.addChild(firstModel)
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//            .padding()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var isShowingSecondModel = false
    @State private var hasGoneOutside = false
    @State private var navigateToEnd = false
    @State private var arAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))

    func loadFirstModel() async -> Entity? {
        do {
            let defaultModel = Entity()
            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
            defaultModel.components.set(ModelComponent(mesh: mesh, materials: [material]))
            defaultModel.position = [-0.2, 0.05, 0]

            let unityModel = try await Entity(named: "chair_swan")
            unityModel.position = [0.2, 0.05, 0]

            let groupEntity = Entity()
            groupEntity.addChild(defaultModel)
            groupEntity.addChild(unityModel)
            return groupEntity
        } catch {
            print("最初のUnityモデル読み込み失敗: \(error)")
            return nil
        }
    }

    func loadSecondModel() async -> Entity? {
        do {
            let unityModel = try await Entity(named: "test_anim_cube")
            unityModel.position = [0, 0.05, 0]
            return unityModel
        } catch {
            print("新しいUnityモデル読み込み失敗: \(error)")
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RealityView { content in
                    content.add(arAnchor)
                    content.camera = .spatialTracking

                    Task {
                        if let firstModel = await loadFirstModel() {
                            arAnchor.addChild(firstModel)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Button {
                        if hasGoneOutside {
                            navigateToEnd = true
                        } else {
                            hasGoneOutside = true
                            isShowingSecondModel = true
                            Task {
                                if let secondModel = await loadSecondModel() {
                                    arAnchor.children.forEach { $0.removeFromParent() }
                                    arAnchor.addChild(secondModel)
                                }
                            }
                        }
                    } label: {
                        Text(hasGoneOutside ? "終了" : "家の外に出る")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    .navigationDestination(isPresented: $navigateToEnd) {
                        EndView()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
