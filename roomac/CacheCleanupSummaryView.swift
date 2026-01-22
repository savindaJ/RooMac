//
//  CacheCleanupSummaryView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct CacheCleanupSummaryView: View {
    let totalFiles: Int
    let totalSize: Int64
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @State private var animate = false
    @State private var isDeleting = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Summary Card
            ScrollView {
                VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 8)
                            .scaleEffect(animate ? 1.0 : 0.8)
                        
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    Text("Safe Cache Cleanup")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("These files are safe to delete")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Summary Stats
                VStack(spacing: 16) {
                    HStack(spacing: 30) {
                        StatBox(
                            icon: "doc.fill",
                            value: "\(totalFiles)",
                            label: "Files",
                            color: .blue
                        )
                        
                        StatBox(
                            icon: "internaldrive.fill",
                            value: formatBytes(totalSize),
                            label: "Space to Free",
                            color: .cyan
                        )
                    }
                    
                    // Safety Info Box
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            
                            Text("What will be deleted:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            SafetyItem(text: "Cache & temporary files", icon: "checkmark.circle.fill")
                            SafetyItem(text: "Old log files", icon: "checkmark.circle.fill")
                        }
                        .padding(.leading, 26)
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                            .padding(.vertical, 6)
                        
                        HStack(spacing: 10) {
                            Image(systemName: "shield.checkmark.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("What's protected:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            SafetyItem(text: "Documents & personal files", icon: "xmark.circle.fill", color: .blue)
                            SafetyItem(text: "Application settings", icon: "xmark.circle.fill", color: .blue)
                        }
                        .padding(.leading, 26)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 16)
                
                // Important Note
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                    
                    Text("Apps will recreate caches automatically - Safe operation")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 25)
                .padding(.bottom, 16)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if !isDeleting {
                            onCancel()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .opacity(isDeleting ? 0.5 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isDeleting)
                    
                    Button(action: {
                        if !isDeleting {
                            isDeleting = true
                            onConfirm()
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isDeleting {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "trash.fill")
                            }
                            Text(isDeleting ? "Cleaning..." : "Clean \(formatBytes(totalSize))")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.green.opacity(0.5), radius: 12, x: 0, y: 6)
                        )
                        .opacity(isDeleting ? 0.7 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isDeleting)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                }
            }
            .frame(width: 550)
            .frame(maxHeight: 650)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.15, blue: 0.3),
                                Color(red: 0.05, green: 0.1, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 40, x: 0, y: 20)
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB]
        return formatter.string(fromByteCount: bytes)
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(animate ? 1.0 : 0.8)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animate = true
            }
        }
    }
}

struct SafetyItem: View {
    let text: String
    let icon: String
    var color: Color = .green
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}
