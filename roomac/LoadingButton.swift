//
//  LoadingButton.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct LoadingButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let colors: [Color]
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        colors: [Color] = [.blue, .cyan],
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.colors = colors
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(isLoading ? "Loading..." : title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
            )
            .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: 15, x: 0, y: 8)
            .opacity(isLoading ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

struct SmallLoadingButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: icon)
                }
                Text(isLoading ? "..." : title)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .opacity(isLoading ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}
