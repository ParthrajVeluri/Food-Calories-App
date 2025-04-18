//
//  ProgressView.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 13/4/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: ["leaf", "flame", "bolt", "heart", "star"].randomElement()!)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.black)

            Text("DishWish")
                .font(.largeTitle.bold())
                .foregroundColor(.black)
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
