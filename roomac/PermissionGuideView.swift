//
//  PermissionGuideView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI
import AppKit

struct PermissionGuideView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Content Card
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Title
                VStack(spacing: 8) {
                    Text("Welcome to RooMAC!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Storage Analyzer & Cleaner")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Permission Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("To fully analyze and clean your storage, RooMAC needs Full Disk Access permission.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PermissionStep(
                            number: 1,
                            title: "Open System Settings",
                            description: "Click the button below to open Settings"
                        )
                        
                        PermissionStep(
                            number: 2,
                            title: "Navigate to Privacy & Security",
                            description: "Go to Privacy & Security → Full Disk Access"
                        )
                        
                        PermissionStep(
                            number: 3,
                            title: "Enable for RooMAC",
                            description: "Toggle on RooMAC in the list"
                        )
                        
                        PermissionStep(
                            number: 4,
                            title: "Restart the App",
                            description: "Quit and reopen RooMAC for changes to take effect"
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                .padding(.horizontal, 8)
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "gear")
                                .font(.system(size: 16))
                            Text("Open System Settings")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("I'll Do This Later")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(32)
            .frame(width: 500)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 20)
            )
        }
    }
}

struct PermissionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}
