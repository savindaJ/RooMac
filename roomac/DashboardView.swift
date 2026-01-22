//
//  DashboardView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var analyzer = StorageAnalyzer()
    @StateObject private var trashManager = TrashManager()
    @State private var animateTitle = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        .scaleEffect(animateTitle ? 1.0 : 0.8)
                        .opacity(animateTitle ? 1 : 0)
                    
                    Text("Overview of your Mac's storage and cleanup opportunities")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Storage Overview Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Storage Overview")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        LoadingButton(
                            title: "Refresh",
                            icon: "arrow.clockwise",
                            isLoading: analyzer.isAnalyzing,
                            colors: [Color.blue, Color.cyan]
                        ) {
                            analyzer.analyzeStorage()
                            trashManager.scanTrash()
                        }
                    }
                    
                    // Storage Ring
                    StorageRingView(storageInfo: analyzer.storageInfo)
                    
                    // Storage Stats
                    HStack(spacing: 20) {
                        DashboardStatCard(
                            icon: "externaldrive.fill",
                            title: "Total",
                            value: formatBytes(analyzer.storageInfo.totalSpace),
                            color: .blue
                        )
                        
                        DashboardStatCard(
                            icon: "chart.pie.fill",
                            title: "Used",
                            value: formatBytes(analyzer.storageInfo.usedSpace),
                            color: .cyan
                        )
                        
                        DashboardStatCard(
                            icon: "checkmark.circle.fill",
                            title: "Free",
                            value: formatBytes(analyzer.storageInfo.freeSpace),
                            color: Color(red: 0.4, green: 0.6, blue: 1.0)
                        )
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                
                // Quick Actions Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Quick Actions")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        QuickActionCard(
                            icon: "trash.fill",
                            title: "Trash",
                            subtitle: trashManager.trashItemCount > 0 ?
                                "\(trashManager.trashItemCount) items • \(formatBytes(trashManager.trashSize))" :
                                "Empty",
                            color: .orange,
                            hasAlert: trashManager.trashItemCount > 0
                        )
                        
                        if let cacheCategory = analyzer.categories.first(where: { $0.name == "Cache Files" }), cacheCategory.size > 0 {
                            QuickActionCard(
                                icon: "tray.full.fill",
                                title: "Cache Files",
                                subtitle: formatBytes(cacheCategory.size),
                                color: .red,
                                hasAlert: cacheCategory.size > 1_000_000_000
                            )
                        }
                        
                        QuickActionCard(
                            icon: "doc.text.magnifyingglass",
                            title: "Large Files",
                            subtitle: "Find space hogs",
                            color: .purple,
                            hasAlert: false
                        )
                        
                        QuickActionCard(
                            icon: "clock.badge.checkmark",
                            title: "Old Files",
                            subtitle: "Clean unused files",
                            color: .green,
                            hasAlert: false
                        )
                        
                        QuickActionCard(
                            icon: "globe",
                            title: "Browser Data",
                            subtitle: "Clear browser cache",
                            color: .blue,
                            hasAlert: false
                        )
                    }
                    .padding(.horizontal, 24)
                }
                
                // Storage Categories
                if !analyzer.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Storage Categories")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 20) {
                            ForEach(analyzer.categories.prefix(6)) { category in
                                CategorySummaryCard(
                                    category: category,
                                    totalSize: analyzer.storageInfo.usedSpace
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateTitle = true
            }
            analyzer.analyzeStorage()
            trashManager.scanTrash()
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct DashboardStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(animate ? 1.0 : 0.9)
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                animate = true
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let hasAlert: Bool
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if hasAlert {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isHovered ? 0.08 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.4), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct CategorySummaryCard: View {
    let category: StorageCategory
    let totalSize: Int64
    
    var percentage: Double {
        guard totalSize > 0 else { return 0 }
        return Double(category.size) / Double(totalSize) * 100
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(category.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(formatBytes(category.size))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(String(format: "%.1f%%", percentage))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(category.color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
