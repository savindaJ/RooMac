//
//  ContentView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case storage = "Storage"
    case trash = "Trash Manager"
    case largeFiles = "Large Files"
    case oldFiles = "Old Files"
    case browser = "Browser Data"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .storage: return "externaldrive.fill"
        case .trash: return "trash.fill"
        case .largeFiles: return "doc.text.magnifyingglass"
        case .oldFiles: return "clock.badge.checkmark"
        case .browser: return "globe"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard: return .cyan
        case .storage: return .blue
        case .trash: return .orange
        case .largeFiles: return .purple
        case .oldFiles: return .green
        case .browser: return .blue
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: NavigationItem = .dashboard
    @State private var animateSidebar = false
    @State private var showPermissionGuide = false
    @AppStorage("hasSeenPermissionGuide") private var hasSeenPermissionGuide = false
    
    var body: some View {
        ZStack {
            // Background gradient with 3D depth
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3),
                    Color(red: 0.05, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .frame(width: CGFloat.random(in: 50...150))
                    .position(
                        x: CGFloat.random(in: 0...1400),
                        y: CGFloat.random(in: 0...900)
                    )
                    .blur(radius: 30)
            }
            
            HStack(spacing: 0) {
                // Sidebar
                VStack(spacing: 0) {
                    // App Logo & Title
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: Color.cyan.opacity(0.5), radius: 15, x: 0, y: 5)
                            
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("RooMAC")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("v1.0")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                    .scaleEffect(animateSidebar ? 1.0 : 0.8)
                    .opacity(animateSidebar ? 1 : 0)
                    
                    // Navigation Items
                    VStack(spacing: 8) {
                        ForEach(Array(NavigationItem.allCases.enumerated()), id: \.element) { index, item in
                            SidebarButton(
                                item: item,
                                isSelected: selectedItem == item
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedItem = item
                                }
                            }
                            .opacity(animateSidebar ? 1 : 0)
                            .offset(x: animateSidebar ? 0 : -20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animateSidebar)
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, 12)
                        
                        Button(action: {
                            showPermissionGuide = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                Text("Setup Guide")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 12)
                        
                        Text("Made with ❤️")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.bottom, 20)
                    }
                }
                .frame(width: 240)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.05), Color.clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                )
                
                // Main Content Area
                VStack(spacing: 0) {
                    // Content based on selection
                    Group {
                        switch selectedItem {
                        case .dashboard:
                            DashboardView()
                        case .storage:
                            StorageAnalyzerView()
                        case .trash:
                            TrashManagerView()
                        case .largeFiles:
                            LargeFilesView()
                        case .oldFiles:
                            OldFilesView()
                        case .browser:
                            BrowserDataView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(width: 1000, height: 720)
        .overlay {
            if showPermissionGuide {
                PermissionGuideView(isPresented: $showPermissionGuide)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateSidebar = true
            }
            
            // Show permission guide on first launch
            if !hasSeenPermissionGuide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showPermissionGuide = true
                    hasSeenPermissionGuide = true
                }
            }
        }
    }
}

struct SidebarButton: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [item.color.opacity(0.3), item.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                    }
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? item.color : .white.opacity(0.6))
                        .frame(width: 40, height: 40)
                }
                
                Text(item.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(item.color)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? Color.white.opacity(0.08) :
                        isHovered ? Color.white.opacity(0.05) : Color.clear
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ContentView()
}
