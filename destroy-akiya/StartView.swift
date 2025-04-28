//
//  StartView.swift
//  destroy-akiya
//
//  Created by 杉本優 on 2025/04/27.
//
import SwiftUI

struct StartView: View {
    @State private var isARActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景画像
                Image("with_button_p1") // Assetsに登録している名前に合わせる
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // スタートボタンのタップ領域
                Button(action: {
                    isARActive = true
                }) {
                    Color.clear // 透明なタップエリア
                }
                .frame(width: 250, height: 80) // ← スタートボタンの大きさに合わせて調整
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.85) 
                // 画面の幅中央、画面高さの85%あたり
            }
            .navigationBarHidden(true) // ナビゲーションバーを消す
            .navigationDestination(isPresented: $isARActive) {
                ContentView()
            }
        }
    }
}

#Preview {
    StartView()
}