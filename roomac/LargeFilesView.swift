//
//  LargeFilesView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct LargeFilesView: View {
    @StateObject private var fileFinder = LargeFileFinder()
    @State private var selectedSize: Int64 = 100_000_000 // 100MB
    @State private var showingDeleteConfirm = false
    @State private var fileToDelete: FileItem?
    
    let sizeOptions: [(String, Int64)] = [
        ("50 MB", 50_000_000),
        ("100 MB", 100_000_000),
        ("500 MB", 500_000_000),
        ("1 GB", 1_000_000_000),
        ("5 GB", 5_000_000_000)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Large Files Finder")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Find and remove large files")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    // Size selector
                    HStack(spacing: 8) {
                        Text("Min:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Menu {
                            ForEach(sizeOptions, id: \.1) { option in
                                Button(option.0) {
                                    selectedSize = option.1
                                    fileFinder.minimumSize = option.1
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(sizeOptions.first(where: { $0.1 == selectedSize })?.0 ?? "100 MB")
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                    }
                    
                    Spacer()
                    
                    LoadingButton(
                        title: "Search",
                        icon: "magnifyingglass",
                        isLoading: fileFinder.isSearching,
                        colors: [Color.purple, Color.pink]
                    ) {
                        fileFinder.findLargeFiles()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Progress bar
            if fileFinder.isSearching {
                VStack(spacing: 12) {
                    HStack {
                        Text("Searching for large files...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(fileFinder.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(fileFinder.progress), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 24)
            }
            
            // Results
            if fileFinder.largeFiles.isEmpty && !fileFinder.isSearching {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No Large Files Found")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Click Search to find files larger than \(formatBytes(selectedSize))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("\(fileFinder.largeFiles.count) files")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("Total: \(formatBytes(fileFinder.largeFiles.reduce(0) { $0 + $1.size }))")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 24)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(fileFinder.largeFiles) { file in
                                LargeFileRow(file: file) {
                                    fileToDelete = file
                                    showingDeleteConfirm = true
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Move to Trash", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Move", role: .destructive) {
                if let file = fileToDelete {
                    fileFinder.moveToTrash(file: file) { success in
                        if success {
                            fileFinder.largeFiles.removeAll { $0.id == file.id }
                        }
                    }
                }
            }
        } message: {
            Text("Are you sure you want to move '\(fileToDelete?.name ?? "")' to trash?")
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct LargeFileRow: View {
    let file: FileItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForFile(file.name))
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(file.path)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(formatBytes(file.size))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.pink)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func iconForFile(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "mp4", "mov", "avi", "mkv": return "film.fill"
        case "mp3", "wav", "aac", "m4a": return "music.note"
        case "jpg", "jpeg", "png", "gif", "heic": return "photo.fill"
        case "zip", "rar", "7z", "tar", "gz": return "doc.zipper"
        case "dmg", "iso": return "opticaldiscdrive.fill"
        default: return "doc.fill"
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
