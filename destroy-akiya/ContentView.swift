//
//  ContentView.swift
//  destroy-akiya
//
//  Created by 杉本優 on 2025/04/27.
//

import SwiftUI
import RealityKit
import ARKit

// SwiftUIにおけるstruct（構造体）
// - 値型（コピーされる）
// - イミュータブル（基本は変更されない設計）
// - 高速（小さなデータ向き）
// - SwiftUIではViewは全部structで作る

struct ContentView: View {
    @State private var arView = ARView(frame: .zero) // AR表示用ARViewの定義
    @State private var hasGoneOutside = false // 外に出たかどうかのフラグ
    @State private var hasTapped = false // タップしたかどうかのフラグ
    @State private var navigateToEnd = false // 終了画面へ遷移するかどうか
    @State private var mainAnchor: AnchorEntity? = nil // 主となるアンカー
    @State private var newModels: [Entity] = [] // タップされたモデルを保持する配列


    var body: some View {
        // SwiftUIにおける画面遷移管理（「ARの画面」→「終了画面」）
        NavigationStack {
            // ZStack：上に重ねるレイアウト
            ZStack {
                // aRViewとmainAnchorを渡す
                ARViewContainer(arView: $arView, mainAnchor: $mainAnchor, newModels: $newModels)
                    .edgesIgnoringSafeArea(.all) //ARViewを画面いっぱいに広げる
                    // 配置
                    .onAppear {
                        loadFirstModel() // 最初（家の中）のモデル読み込み
                    }

                // VStack：縦に並べるレイアウト
                VStack {
                    Spacer() // 上側に余白を取って、ボタンを画面の一番下にする
                    // 三項演算子（条件 ? 真のときの値 : 偽のときの値）
                    Button(hasGoneOutside ? "終了" : "家の外に出る") {
                        if hasGoneOutside {
                            navigateToEnd = true // 終了画面へ遷移
                        } else {
                            hasGoneOutside = true // 家の外へ切り替え
                            loadSecondModel() // 2つ目（家の外）のモデル読み込み
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            // 特定の条件で画面遷移をするSwiftUIの標準メソッド
            .navigationDestination(isPresented: $navigateToEnd) {
                EndView() // 終了画面へ遷移
            }
        }
    }

    // AR空間に置くための土台（mainAnchor）が設置されていない場合に作る関数
    func setupAnchorIfNeeded() {
        // 最初の一回だけ
        if mainAnchor == nil {
            // AnchorEntity：現実空間に仮想オブジェクトを固定
            // plane: .horizontal：水平な平面にアンカーを置く
            // minimumBounds: [0.2, 0.2]：最低サイズ20cm×20cm以上の平面を認識
            let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
            arView.scene.addAnchor(anchor) // 作ったアンカーをAR空間に追加
            mainAnchor = anchor // mainAnchorに格納
        }
    }

    // 最初（家の中）のモデルを読み込む関数
    // 一旦オブジェクトは1つ（複数の場合はモデル配列を持ちfor文でaddChildを回せばいい）
    func loadFirstModel() {
        setupAnchorIfNeeded() // ない場合にmainAnchorを作成
        // タップで置いたモデルを確実に全部消す
        for newModel in newModels {
            newModel.removeFromParent()
        }
        newModels.removeAll()
        // 元々配置されていたモデルを全部消す
        mainAnchor?.children.forEach { $0.removeFromParent() } // mainAnchorの子（モデル群）を削除

        // 非同期処理
        Task {
            async let entity1 = Entity(named: "table_idle")
            async let entity2 = Entity(named: "chair_idle")
            
            if let model1 = try? await entity1, let model2 = try? await entity2 {
                // debug
                print(model1.name)
                print(model2.name)
                
                
                // 固定ターゲットの確認（if 固定 → 解除）
                checkAnchoringComponents(entity: model1)
                checkAnchoringComponents(entity: model2)
                // モデルに当たり判定を付与
                model1.generateCollisionShapes(recursive: true)
                model2.generateCollisionShapes(recursive: true)
                // MainActorによってメインスレッドを処理（メインスレッドでUIの更新を行う）
                await MainActor.run {
                    model1.position = [0.3, 0, -0.5]
                    model2.position = [-0.3, 0, -0.5]
                    mainAnchor?.addChild(model1)
                    mainAnchor?.addChild(model2)
                }
            }
        }
    }

    // 2つ目（家の外）のモデルを読み込む関数
    func loadSecondModel() {
        setupAnchorIfNeeded() // ない場合にmainAnchorを作成
        // タップで置いたモデルを確実に全部消す
        for newModel in newModels {
            newModel.removeFromParent()
        }
        newModels.removeAll()
        // 元々配置されていたモデルを全部消す
        mainAnchor?.children.forEach { $0.removeFromParent() } // mainAnchorの子（モデル群）を削除

        // 非同期処理
        Task {
            if let model = try? await Entity(named: "chair_idle") {
                checkAnchoringComponents(entity: model) // 固定ターゲットの確認（if 固定 → 解除）
                model.generateCollisionShapes(recursive: true) // モデルに当たり判定を付与
                // MainActorによってメインスレッドを処理（メインスレッドでUIの更新を行う）
                await MainActor.run {
                    model.position = [0, 0, -0.5]
                    mainAnchor?.addChild(model)
                }
            }
        }
    }
}

// ARViewを表示するコンテナ
struct ARViewContainer: UIViewRepresentable {
    // 外側（ContentView側）でもARViewを操作できるようにする
    @Binding var arView: ARView
    // 外側（ContentView側）でもAnchorEntityを操作できるようにする
    @Binding var mainAnchor: AnchorEntity?
    // 外側（ContentView側）でも[Entity]を操作できるようにする
    @Binding var newModels: [Entity]


    // ARViewのセットアップ
    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration() // ARWorldのトラッキングを設定
        config.planeDetection = [.horizontal] // 水平面検出
        config.environmentTexturing = .automatic // 周囲の環境（光の具合）を反映
        arView.session.run(config) // 上記設定を使用してARセッションを開始

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture) // タップジェスチャーを認識する

        return arView
    }

    // ARView側を更新する際に使用（一旦何もしない）
    func updateUIView(_ uiView: ARView, context: Context) {}

    // タップイベントを管理するクラス（Coordinator）を作って渡す
    func makeCoordinator() -> Coordinator {
        Coordinator(container: self)
    }

    // タップイベントの処理
    class Coordinator: NSObject {
        var container: ARViewContainer // 親（ARViewContainer）の取得

        init(container: ARViewContainer) {
            self.container = container // 親（ARViewContainer）のセット
        }

        // 処理開始
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return } // タップされたViewを取得
            let tapLocation = sender.location(in: arView) // タップされた位置を取得

            // タップされた場所にモデルがあるかを探し、あれば下記処理を実行
            if let tappedModel = arView.entity(at: tapLocation) {
                print("タップされたモデル: '\(tappedModel.name)'")

                let position = tappedModel.position // モデルの座標を取得 ※世界視点：relativeTo: nil
                print("タップされたモデルの座標： '\(position)' ")
                // 非同期処理（ここではタップされた場所に新しいモデルを置く）
                Task {
                    await self.replaceModel(at: position, in: arView, entity: tappedModel)
                    await tappedModel.removeFromParent() // モデルの削除
                }
                
            } else {
                print("タップされたが、モデルが存在しない")
            }
        }

        // 新しいモデルを設置する関数
        func replaceModel(at position: SIMD3<Float>, in arView: ARView, entity tappedModel: Entity) async {
            
            if let newModel = try? await Entity(named: "test7_color") {
                checkAnchoringComponents(entity: newModel) // 固定ターゲットの確認（if 固定 → 解除）
                checkAnimations(entity: newModel) // アニメーションの確認（if あり → 再生）
                print(" 古いモデル '\(await tappedModel.name)' → 新しいモデル '\(await newModel.name)'")
                
                // 非同期処理
                await MainActor.run {
                    newModel.position = position
                    self.container.mainAnchor?.addChild(newModel)
                    self.container.newModels.append(newModel)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

// デバッグ関数の定義

// モデルのアニメーションの有無を確認する関数（if あり → 再生）
func checkAnimations(entity: Entity){
    if let animationResource = entity.availableAnimations.first{
        print("モデル '\(entity.name)' のアニメーションあり： \(animationResource)")
        // アニメーション処理を実行
        entity.playAnimation(animationResource, startsPaused: true)
    } else {
        print("モデル '\(entity.name)' のアニメーションなし")
    }
}

// モデルの固定ターゲットを確認する関数（if 固定 → 解除）
// ※モデルのエクスポート時点でのシーン（metadata）は確認・操作できない
func checkAnchoringComponents(entity: Entity) {
    if let anchoring = entity.components[AnchoringComponent.self] {
        switch anchoring.target {
        case .camera:
            print("モデル '\(entity.name)' はカメラに固定")
            entity.components.remove(AnchoringComponent.self)
        case .plane:
            print("モデル '\(entity.name)' は平面に固定")
            entity.components.remove(AnchoringComponent.self)
        case .image:
            print("モデル '\(entity.name)' は画像に固定")
            entity.components.remove(AnchoringComponent.self)
        case .face:
            print("モデル '\(entity.name)' は顔に固定")
            entity.components.remove(AnchoringComponent.self)
        default:
            print("モデル '\(entity.name)' の固定ターゲットは不明")
            entity.components.remove(AnchoringComponent.self)
        }
    } else {
        print("モデル '\(entity.name)' のAnchoringComponentなし")
    }

    for child in entity.children {
        checkAnchoringComponents(entity: child)
    }
}
