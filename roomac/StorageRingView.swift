//
//  StorageRingView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct StorageRingView: View {
    let storageInfo: StorageInfo
    @State private var animateRing = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 30
                )
                .blur(radius: 20)
                .scaleEffect(animateRing ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateRing)
            
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 25)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animateRing ? CGFloat(storageInfo.usedPercentage / 100) : 0)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.blue,
                            Color.cyan,
                            Color.blue.opacity(0.8),
                            Color(red: 0.4, green: 0.6, blue: 1.0),
                            Color.blue
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 25, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 0)
            
            // Inner shadow circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
            
            // Center content
            VStack(spacing: 8) {
                Text(String(format: "%.1f%%", storageInfo.usedPercentage))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                
                Text("Used")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 250, height: 250)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animateRing = true
            }
        }
    }
}
