空き家を壊せ！
======================

AR空間上に空き家及び家具の3Dモデルを配置し, ひたすら壊していくiosアプリです. 
壊すことによるストレス発散の場と空き家を結びつけ, 空き家問題の認知拡大を目的に開発しました. 

## 概要

このSwiftアプリでは, 全ての3Dモデルの構築（Unity）, 3Dモデルの破壊アニメーションの作成（Blender）, ARゲームの実装（SwiftUi）を行いました. 
ユーザーがカメラを現実世界に向けて、20(cm)×20(cm)の水平面を認識すると, 予め3Dモデルが配置されたAR空間が出現します（また, AR空間内の主観カメラ位置も考慮されているためAR空間内を自由に歩くことができます）. タップモーションによって配置された家具（オブジェクト）を全て壊すと, 次の画面で空き家の外観3Dモデルが現れ, それを消滅させる（時間の都合上アニメーションなし）ことでARゲーム自体は終了し, 空き家問題の説明画面に移ります. なお, このアプリは2025/0426-29に開催された「WakeUp Hackathon」の成果物になります. 

### ARゲームの実装  
※3Dモデルの読み込みから破壊モーション、AR機能の全ロジックをSwiftUIで実装
1. Unity / Blender で作成されたアニメーション付き3Dモデルの読み込み  
2. ARKitによる現実世界の認識やトラッキング（e.g. カメラ映像から床や机を検出, 周囲の光の具合を調整）
3. RealityKitによるAR空間内でのモデル操作（e.g. 配置する, 当たり判定をつける, タップでアニメーションを再生する）

## デモ
https://github.com/user-attachments/assets/1d0a3fb0-ca60-48a3-8e92-d61818211f61

## 使用技術

- Swift 6.0.3
- Unity
- Blender
- ARKit
- RealityKit 

## ディレクトリ構造

```
.
├── LICENSE
├── README.md
├── destroy-akiya
│   ├── AppDelegate.swift
│   ├── Assets.xcassets
│   ├── ContentView.swift
│   ├── EndView.swift
│   ├── EndView1.swift
│   ├── EndView2.swift
│   ├── EndView3.swift
│   ├── EndView4.swift
│   ├── EndView5.swift
│   ├── PictureContent
│   ├── Preview Content
│   ├── RealityKit Content
│   └── StartView.swift
├── destroy-akiya.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   └── xcuserdata
├── destroy-akiyaTests
│   └── destroy_akiyaTests.swift
└── destroy-akiyaUITests
    ├── destroy_akiyaUITests.swift
    └── destroy_akiyaUITestsLaunchTests.swift
```
