//
//  OldFilesView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct OldFilesView: View {
    @StateObject private var cleaner = OldFilesCleaner()
    @State private var selectedDays: Int = 365
    @State private var selectedFiles: Set<UUID> = []
    @State private var showingDeleteConfirm = false
    @State private var showingSuccess = false
    @State private var successMessage = ""
    
    let dayOptions: [(String, Int)] = [
        ("6 months", 180),
        ("1 year", 365),
        ("2 years", 730),
        ("3 years", 1095)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Old Files Cleaner")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Find unused files")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    // Days selector
                    HStack(spacing: 8) {
                        Text("Older than:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Menu {
                            ForEach(dayOptions, id: \.1) { option in
                                Button(option.0) {
                                    selectedDays = option.1
                                    cleaner.daysOld = option.1
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(dayOptions.first(where: { $0.1 == selectedDays })?.0 ?? "1 year")
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
                        isLoading: cleaner.isSearching,
                        colors: [Color.green, Color.teal]
                    ) {
                        cleaner.findOldFiles()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Progress bar
            if cleaner.isSearching {
                VStack(spacing: 12) {
                    HStack {
                        Text("Searching for old files...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(cleaner.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(cleaner.progress), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 24)
            }
            
            // Results
            if cleaner.oldFiles.isEmpty && !cleaner.isSearching {
                VStack(spacing: 16) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No Old Files Found")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Click Search to find files not used in \(dayOptions.first(where: { $0.1 == selectedDays })?.0 ?? "")")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("\(cleaner.oldFiles.count) files")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            
                            if !selectedFiles.isEmpty {
                                Text("(\(selectedFiles.count) selected)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                        }
                        
                        if !selectedFiles.isEmpty {
                            let totalSize = cleaner.oldFiles
                                .filter { selectedFiles.contains($0.id) }
                                .reduce(0) { $0 + $1.size }
                            
                            Button(action: {
                                showingDeleteConfirm = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 16))
                                    Text("Remove (\(formatBytes(totalSize)))")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(cleaner.oldFiles) { file in
                                OldFileRow(
                                    file: file,
                                    isSelected: selectedFiles.contains(file.id)
                                ) {
                                    if selectedFiles.contains(file.id) {
                                        selectedFiles.remove(file.id)
                                    } else {
                                        selectedFiles.insert(file.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("Remove Files", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                let filesToRemove = cleaner.oldFiles.filter { selectedFiles.contains($0.id) }
                cleaner.moveToTrash(files: filesToRemove) { count, size in
                    successMessage = "Successfully moved \(count) files to trash\nFreed \(formatBytes(size))"
                    cleaner.oldFiles.removeAll { selectedFiles.contains($0.id) }
                    selectedFiles.removeAll()
                    showingSuccess = true
                }
            }
        } message: {
            Text("Are you sure you want to move \(selectedFiles.count) files to trash?")
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct OldFileRow: View {
    let file: FileItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .green : .white.opacity(0.3))
                
                Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(formatDate(file.date))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Text(formatBytes(file.size))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.teal)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
