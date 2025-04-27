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
            VStack {
                Spacer()
                Button("AR体験を始める") {
                    isARActive = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            }
            .navigationTitle("スタート")
            .navigationDestination(isPresented: $isARActive) {
                ContentView()
            }
        }
    }
}

#Preview {
    StartView()
}
