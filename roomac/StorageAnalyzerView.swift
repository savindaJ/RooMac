//
//  StorageAnalyzerView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct StorageAnalyzerView: View {
    @StateObject private var analyzer = StorageAnalyzer()
    @State private var selectedCategory: StorageCategory?
    @State private var showingFileList = false
    @State private var showingClearSuccess = false
    @State private var showingCacheSummary = false
    @State private var clearMessage = ""
    @State private var cacheFileCount = 0
    @State private var cacheTotalSize: Int64 = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage Analyzer")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Detailed breakdown of your Mac's storage")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                LoadingButton(
                    title: "Analyze",
                    icon: "arrow.clockwise",
                    isLoading: analyzer.isAnalyzing,
                    colors: [Color.blue, Color.cyan]
                ) {
                    analyzer.analyzeStorage()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Progress bar
            if analyzer.isAnalyzing {
                VStack(spacing: 12) {
                    HStack {
                        Text("Scanning files...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(analyzer.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(analyzer.progress), height: 8)
                                .shadow(color: Color.blue.opacity(0.6), radius: 5, x: 0, y: 2)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 24)
            }
            
            // Cache Banner
            if let cacheCategory = analyzer.categories.first(where: { $0.name == "Cache Files" }), cacheCategory.size > 0 {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "tray.full.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cache Files Detected")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(analyzer.formatBytes(cacheCategory.size)) can be cleaned")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if cacheCategory.size > 1_000_000_000 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
            }
            
            // Categories
            if !analyzer.categories.isEmpty {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        ForEach(analyzer.categories) { category in
                            if category.name == "Cache Files" {
                                CacheCategoryCardView(
                                    category: category,
                                    totalSize: analyzer.storageInfo.usedSpace,
                                    onClear: {
                                        analyzer.getCacheSummary { fileCount, totalSize in
                                            cacheFileCount = fileCount
                                            cacheTotalSize = totalSize
                                            showingCacheSummary = true
                                        }
                                    },
                                    onTap: {
                                        selectedCategory = category
                                        showingFileList = true
                                    }
                                )
                            } else {
                                CategoryCardView(
                                    category: category,
                                    totalSize: analyzer.storageInfo.usedSpace
                                )
                                .onTapGesture {
                                    selectedCategory = category
                                    showingFileList = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            } else if !analyzer.isAnalyzing {
                VStack(spacing: 16) {
                    Image(systemName: "externaldrive")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No Analysis Yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Click Analyze to scan your storage")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingFileList) {
            if let category = selectedCategory {
                FileListView(category: category)
            }
        }
        .overlay {
            if showingCacheSummary {
                CacheCleanupSummaryView(
                    totalFiles: cacheFileCount,
                    totalSize: cacheTotalSize,
                    onConfirm: {
                        showingCacheSummary = false
                        analyzer.clearCache { success, message in
                            clearMessage = message
                            showingClearSuccess = true
                        }
                    },
                    onCancel: {
                        showingCacheSummary = false
                    }
                )
            }
        }
        .alert("Success", isPresented: $showingClearSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(clearMessage)
        }
        .onAppear {
            analyzer.analyzeStorage()
        }
    }
}
