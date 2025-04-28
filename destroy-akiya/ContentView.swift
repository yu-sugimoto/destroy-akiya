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
    @State private var loadNewModels: [String: Entity] = [:] // 新しいモデル名とEntityのマップ
    @State private var hasGoneOutside = false // 外に出たかどうかのフラグ
    @State private var hasTapped = false // タップしたかどうかのフラグ
    @State private var navigateToEnd = false // 終了画面へ遷移するかどうか
    @State private var mainAnchor: AnchorEntity? = nil // 主となるアンカー
    @State private var newModels: [Entity] = [] // タップされたモデルを保持する配列
    @State private var remainingModels: Int = 0 // カウント関数
    
    var body: some View {
        // SwiftUIにおける画面遷移管理（「ARの画面」→「終了画面」）
        NavigationStack {
            // ZStack：上に重ねるレイアウト
            ZStack {
                // ARviewに渡す変数
                ARViewContainer(arView: $arView, loadNewModels: $loadNewModels, mainAnchor: $mainAnchor, newModels: $newModels, remainingModels: $remainingModels)
                    .edgesIgnoringSafeArea(.all) //ARViewを画面いっぱいに広げる
                    // 配置
                    .onAppear {
                        loadFirstModel() // 最初（家の中）のモデル読み込み
                    }

                // VStack：縦に並べるレイアウト
                VStack {
                    HStack {
                        Spacer()
                        Text("残り: \(remainingModels)個")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.trailing, 16)
                    }
                    Spacer() // 上側に余白を取って、ボタンを画面の一番下にする
                    // 三項演算子（条件 ? 真のときの値 : 偽のときの値）
                    Button(hasGoneOutside ? "終了" : "トドメをさす") {
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
                    .disabled(remainingModels > 0)
                    .opacity(remainingModels > 0 ? 0.5 : 1.0)
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
            // モデルの読み込み（コメントアウト部分はメモリ次第）
            async let entity0 = Entity(named: "house_before")
            async let entity1 = Entity(named: "table_before")
            async let entity2 = Entity(named: "chair_before")
            async let entity3 = Entity(named: "table_after")
            async let entity4 = Entity(named: "chair_after")
            // async let entity5 = Entity(named: "toilet_before")
            // async let entity6 = Entity(named: "toilet_after")
            
            // 各モデルに識別のための名前を付与
            if let house1 = try? await entity0, let table1 = try? await entity1, let chair1 = try? await entity2, let table = try? await entity3, let chair = try? await entity4 {
                
                house1.name = "house_before"
                table1.name = "table_before"
                chair1.name = "chair_before"
                // toilet1.name = "toilet_before"
                table.name = "table_after"
                chair.name = "chair_after"
                // toilet.name = "toilet_after"
                
                // タップ後のモデルを保持
                loadNewModels["table_after"] = table
                loadNewModels["chair_after"] = chair
                // loadNewModels["toilet_after"] = toilet
                
                // モデルに当たり判定を付与
                table1.generateCollisionShapes(recursive: true)
                chair1.generateCollisionShapes(recursive: true)
                // toilet1.generateCollisionShapes(recursive: true)
                
                // MainActorによってメインスレッドを処理（メインスレッドでUIの更新を行う）
                await MainActor.run {
                    house1.position = [0, 0, 0]
                    table1.position = [0.3, 0, -0.5]
                    chair1.position = [-0.1, 0, -0.3]
                    // toilet1.position = [-6, 0, -5]
                    mainAnchor?.addChild(house1)
                    mainAnchor?.addChild(table1)
                    mainAnchor?.addChild(chair1)
                    // mainAnchor?.addChild(toilet1)
                    
                    // モデル数をカウント
                    remainingModels = 2
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
            if let model = try? await Entity(named: "house_before") {
                checkAnchoringComponents(entity: model) // 固定ターゲットの確認（if 固定 → 解除）
                model.generateCollisionShapes(recursive: true) // モデルに当たり判定を付与
                // MainActorによってメインスレッドを処理（メインスレッドでUIの更新を行う）
                await MainActor.run {
                    model.position = [0, 0, -1]
                    model.scale = [0.1, 0.1, 0.1]
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
    // 外側（ContentView側）でもloadNewdModelsを操作できるようにする
    @Binding var loadNewModels: [String: Entity]
    // 外側（ContentView側）でもAnchorEntityを操作できるようにする
    @Binding var mainAnchor: AnchorEntity?
    // 外側（ContentView側）でも[Entity]を操作できるようにする
    @Binding var newModels: [Entity]
    // 外側（ContentView側）でもremainingModelsを操作できるようにする
    @Binding var remainingModels: Int
    

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
                
                var targetEntity = tappedModel
                
                // 親をたどる：Scene直下（AnchorEntityなど）にぶら下がってる一個手前までたどる
                while let parent = targetEntity.parent, !(parent is AnchorEntity) {
                    targetEntity = parent
                }
                
                print("タップされたモデル: '\(tappedModel.name)'")

                let position = tappedModel.position // モデルの座標を取得 ※世界視点：relativeTo: nil
                print("タップされたモデルの座標： '\(position)' ")
                // 非同期処理（ここではタップされた場所に新しいモデルを置く）
                Task {
                    await self.replaceModel(at: position, in: arView, entity: tappedModel)
                    await targetEntity.removeFromParent() // モデルの削除
                }
                
            } else {
                print("タップされたが、モデルが存在しない")
            }
        }

        // 新しいモデルを設置する関数
        func replaceModel(at position: SIMD3<Float>, in arView: ARView, entity tappedModel: Entity) async {
            
            // タップされたエンティティから最大の親をたどる
            var rootEntity = tappedModel
            while let parent = rootEntity.parent, !(parent is AnchorEntity) {
                rootEntity = parent
            }

            // rootEntity配下を探索して、対象のモデル名を探す
            var newModelName: String? = nil
            
            if let matchName = findMatchingName(in: rootEntity) {
                var newModelName: String? = nil
                switch matchName {
                case "table_before":
                    newModelName = "table_after"
                case "chair_before":
                    newModelName = "chair_after"
                case "toilet_before":
                    newModelName = "toilet_after"
                default:
                    break
                }
                
                if let modelName = newModelName, let templateModel = self.container.loadNewModels[modelName] {
                    let newModel = templateModel.clone(recursive: true)
                    newModel.name = modelName
                    
                    checkAnimations(entity: newModel)
                    print(" 古いモデル '\(matchName)' → 新しいモデル '\(newModel.name)'")
                    
                    await MainActor.run {
                        newModel.position = position
                        self.container.mainAnchor?.addChild(newModel)
                        self.container.newModels.append(newModel)
                        self.container.remainingModels -= 1 // カウント減少
                    }
                } else {
                    print("新しいモデルが見つかりませんでした")
                }
            }

        }

        // entityの子要素に該当の名前があるかを探索する関数
        func findMatchingName(in entity: Entity) -> String? {
            if entity.name == "table_before" || entity.name == "chair_before" || entity.name == "toilet_before" {
                return entity.name
            }
            for child in entity.children {
                if let match = findMatchingName(in: child) {
                    return match
                }
            }
            return nil
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
