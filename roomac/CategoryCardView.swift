//
//  CategoryCardView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI
import AppKit

struct CategoryCardView: View {
    let category: StorageCategory
    let totalSize: Int64
    @State private var isHovered = false
    @State private var animate = false
    let formatter = ByteCountFormatter()
    
    init(category: StorageCategory, totalSize: Int64) {
        self.category = category
        self.totalSize = totalSize
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB]
    }
    
    var percentage: Double {
        guard totalSize > 0 else { return 0 }
        return Double(category.size) / Double(totalSize) * 100
    }
    
    var body: some View {
        ZStack {
            // Card background with 3D effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: category.color.opacity(isHovered ? 0.6 : 0.3), radius: isHovered ? 25 : 15, x: 0, y: isHovered ? 15 : 10)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Icon with 3D effect
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        category.color.opacity(0.8),
                                        category.color.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: category.color.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        // Size badge
                        Text(formatter.string(fromByteCount: category.size))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(category.color.opacity(0.3))
                                    .overlay(
                                        Capsule()
                                            .stroke(category.color.opacity(0.5), lineWidth: 1)
                                    )
                            )
                        
                        // Click hint
                        HStack(spacing: 4) {
                            Text("View Files")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [category.color, category.color.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: animate ? geometry.size.width * CGFloat(percentage / 100) : 0, height: 8)
                                .shadow(color: category.color.opacity(0.6), radius: 5, x: 0, y: 2)
                        }
                    }
                    .frame(height: 8)
                    
                    Text(String(format: "%.1f%% of total", percentage))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
        }
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .rotation3DEffect(
            .degrees(isHovered ? 5 : 0),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                animate = true
            }
        }
    }
}
