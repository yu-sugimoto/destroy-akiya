//
//  EndView.swift
//  destroy-akiya
//
//  Created by 杉本優 on 2025/04/27.
//

import SwiftUI

struct EndView2: View {
    @State private var isARActive = false

    var body: some View {
        ZStack {
            // NavigationStackはここには書かない！！！

            // 背景画像
            Image("with_button_p4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 「次へ」ボタンのタップ領域
            NavigationLink(destination: EndView3()) {
                Color.clear // 透明なリンク
            }
            .frame(width: 250, height: 80)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.90)
        }
        .navigationBarHidden(true) // これはそのままでOK
    }
}

#Preview {
    NavigationStack { // プレビュー用だけ、外側にNavigationStackをつける
        EndView2()
    }
}