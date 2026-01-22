//
//  FileListView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI
import Combine
import AppKit

struct FileListView: View {
    let category: StorageCategory
    @StateObject private var fileManager = FileListManager()
    @StateObject private var safetyRecommendations = SafetyRecommendations()
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirm = false
    @State private var showProtectedAlert = false
    @State private var fileToDelete: FileItem?
    @State private var protectedFileName = ""
    @State private var selectedFiles = Set<UUID>()
    @State private var currentPath: String
    @State private var pathHistory: [String] = []
    @State private var isOpeningFinder = false
    
    init(category: StorageCategory) {
        self.category = category
        _currentPath = State(initialValue: category.path)
    }
    
    var body: some View {
        ZStack {
            // Background
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
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { 
                            if pathHistory.isEmpty {
                                dismiss()
                            } else {
                                currentPath = pathHistory.removeLast()
                                fileManager.loadFiles(from: currentPath)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(pathHistory.isEmpty ? "Back" : "Up")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 10) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(category.color)
                                
                                Text(category.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(fileManager.files.count) items")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Actions
                        HStack(spacing: 12) {
                            Button(action: {
                                if !isOpeningFinder {
                                    isOpeningFinder = true
                                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: currentPath)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isOpeningFinder = false
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if isOpeningFinder {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "folder.fill")
                                    }
                                    Text(isOpeningFinder ? "Opening..." : "Open in Finder")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                                )
                                .opacity(isOpeningFinder ? 0.7 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isOpeningFinder)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    
                    // Breadcrumb navigation
                    if !pathHistory.isEmpty || currentPath != category.path {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(getBreadcrumbs(), id: \.self) { crumb in
                                    HStack(spacing: 6) {
                                        Text(crumb)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        if crumb != getBreadcrumbs().last {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                        }
                        .background(Color.black.opacity(0.1))
                    }
                }
                .background(Color.black.opacity(0.2))
                
                // Safety Recommendations Banner
                if !safetyRecommendations.recommendations.isEmpty && !fileManager.isLoading {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Safe Cleanup Recommendations")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("\(safetyRecommendations.recommendations.count) safe files • \(formatBytes(safetyRecommendations.potentialSavings)) can be freed")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.green.opacity(0.4), Color.clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 12)
                }
                
                // Files list
                if fileManager.isLoading {
                    VStack(spacing: 20) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.cyan)
                        Text("Loading files...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                } else if fileManager.files.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No files found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(fileManager.files) { file in
                                FileRowView(
                                    file: file,
                                    onDelete: {
                                        let safety = FileSafetyInfo.evaluate(file: file)
                                        if safety.canDelete {
                                            fileToDelete = file
                                            showDeleteConfirm = true
                                        } else {
                                            protectedFileName = file.name
                                            showProtectedAlert = true
                                        }
                                    },
                                    onOpen: {
                                        if file.isDirectory {
                                            // Navigate into folder
                                            pathHistory.append(currentPath)
                                            currentPath = file.path
                                            fileManager.loadFiles(from: file.path)
                                        } else {
                                            // Open file in Finder
                                            NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
                                        }
                                    }
                                )
                            }
                        }
                        .padding(30)
                    }
                }
            }
        }
        .frame(width: 1200, height: 720)
        .alert("Delete File", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let file = fileToDelete {
                    fileManager.deleteFile(file)
                    // Refresh recommendations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        safetyRecommendations.analyzeFiles(fileManager.files)
                    }
                }
            }
        } message: {
            if let file = fileToDelete {
                let safety = FileSafetyInfo.evaluate(file: file)
                Text("\(safety.reason)\n\nAre you sure you want to delete '\(file.name)'? This will move it to Trash.")
            }
        }
        .alert("Protected System File", isPresented: $showProtectedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("'\(protectedFileName)' is a system file and cannot be deleted. Deleting this file could damage your macOS system.\n\nThis protection keeps your Mac safe and secure.")
        }
        .onAppear {
            fileManager.loadFiles(from: currentPath)
        }
        .onChange(of: fileManager.files) { newFiles in
            safetyRecommendations.analyzeFiles(newFiles)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        return formatter.string(fromByteCount: bytes)
    }
    
    private func getBreadcrumbs() -> [String] {
        let components = currentPath.components(separatedBy: "/").filter { !$0.isEmpty }
        return components.suffix(3).map { $0 } // Show last 3 components
    }
}

struct FileRowView: View {
    let file: FileItem
    let onDelete: () -> Void
    let onOpen: () -> Void
    @State private var isHovered = false
    @State private var isDeleting = false
    @State private var isOpening = false
    
    private var safetyInfo: FileSafetyInfo {
        FileSafetyInfo.evaluate(file: file)
    }
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: file.isDirectory ? 
                [Color.orange.opacity(0.6), Color.yellow.opacity(0.4)] :
                [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var deleteButtonGradient: LinearGradient {
        LinearGradient(
            colors: safetyInfo.level == .protected ?
                [Color.gray, Color.gray.opacity(0.8)] :
            safetyInfo.level == .recommended ?
                [Color.green, Color.green.opacity(0.8)] :
                [Color.red, Color.red.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // File/Folder icon
            fileIconView
            
            // File/Folder info
            fileInfoView
            
            Spacer()
            
            // Action buttons
            if isHovered {
                actionButtonsView
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovered ? 0.08 : 0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: Color.blue.opacity(isHovered ? 0.3 : 0.1), radius: isHovered ? 15 : 5, x: 0, y: isHovered ? 8 : 4)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func fileIcon(for file: FileItem) -> String {
        if file.isDirectory {
            return "folder.fill"
        }
        
        let ext = (file.name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.text.fill"
        case "doc", "docx": return "doc.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "chart.bar.doc.horizontal.fill"
        case "jpg", "jpeg", "png", "gif", "heic": return "photo.fill"
        case "mp4", "mov", "avi": return "film.fill"
        case "mp3", "wav", "m4a": return "music.note"
        case "zip", "rar", "7z": return "doc.zipper"
        case "dmg": return "internaldrive.fill"
        default: return "doc.fill"
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - View Components
    
    private var fileIconView: some View {
        ZStack {
            Circle()
                .fill(iconGradient)
                .frame(width: 44, height: 44)
            
            Image(systemName: fileIcon(for: file))
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
    }
    
    private var fileInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(file.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if file.isDirectory {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    safetyBadgeView
                }
            }
            
            HStack(spacing: 12) {
                if file.isDirectory {
                    if let itemCount = file.itemCount {
                        Text("\(itemCount) items")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("Folder")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    Text(formatBytes(file.size))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text("•")
                    .foregroundColor(.white.opacity(0.4))
                
                Text(formatDate(file.date))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if !file.isDirectory && (isHovered || safetyInfo.level == .recommended || safetyInfo.level == .protected) {
                Text(safetyInfo.reason)
                    .font(.system(size: 12))
                    .foregroundColor(safetyInfo.color.opacity(0.9))
                    .padding(.top, 2)
            }
        }
    }
    
    private var safetyBadgeView: some View {
        HStack(spacing: 4) {
            Image(systemName: safetyInfo.icon)
                .font(.system(size: 10))
            if safetyInfo.level == .recommended {
                Text("Recommended")
                    .font(.system(size: 10, weight: .semibold))
            } else if safetyInfo.level == .protected {
                Text("Protected")
                    .font(.system(size: 10, weight: .semibold))
            }
        }
        .foregroundColor(safetyInfo.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(safetyInfo.color.opacity(0.15))
        )
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 10) {
            openButtonView
            if !file.isDirectory {
                deleteButtonView
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var openButtonView: some View {
        Button(action: {
            if !isOpening {
                isOpening = true
                onOpen()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isOpening = false
                }
            }
        }) {
            HStack(spacing: 6) {
                if isOpening {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: file.isDirectory ? "arrow.right.circle.fill" : "eye.fill")
                }
                Text(isOpening ? "..." : (file.isDirectory ? "Open" : "Show"))
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .opacity(isOpening ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isOpening)
    }
    
    private var deleteButtonView: some View {
        Button(action: {
            if !isDeleting && safetyInfo.level != .protected {
                isDeleting = true
                onDelete()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isDeleting = false
                }
            }
        }) {
            HStack(spacing: 6) {
                if isDeleting {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if safetyInfo.level == .protected {
                    Image(systemName: "lock.fill")
                    Text("Protected")
                } else {
                    Image(systemName: "trash.fill")
                    Text(safetyInfo.level == .recommended ? "Clean Up" : "Delete")
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(deleteButtonGradient)
            )
            .opacity((safetyInfo.level == .protected || isDeleting) ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(safetyInfo.level == .protected || isDeleting)
    }
}

class FileListManager: ObservableObject {
    @Published var files: [FileItem] = []
    @Published var isLoading = false
    
    func loadFiles(from path: String) {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var loadedFiles: [FileItem] = []
            let fileManager = FileManager.default
            
            print("📂 Loading files from: \(path)")
            
            // Check if directory exists
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
                print("❌ Directory does not exist or is not a directory: \(path)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let enumerator = fileManager.enumerator(
                at: URL(fileURLWithPath: path),
                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey, .contentModificationDateKey],
                options: [.skipsSubdirectoryDescendants]
            ) else {
                print("❌ Failed to create enumerator for: \(path)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            for case let fileURL as URL in enumerator {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey, .contentModificationDateKey])
                    
                    if let isDirectory = resourceValues.isDirectory {
                        if isDirectory {
                            // It's a folder
                            var folderSize: Int64 = 0
                            var itemCount: Int? = nil
                            
                            // Count items in folder
                            if let contents = try? fileManager.contentsOfDirectory(atPath: fileURL.path) {
                                itemCount = contents.count
                            }
                            
                            // Calculate folder size (quick estimate)
                            if let folderEnum = fileManager.enumerator(
                                at: fileURL,
                                includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                                options: [.skipsHiddenFiles]
                            ) {
                                var fileCount = 0
                                for case let subURL as URL in folderEnum {
                                    if fileCount > 100 { break } // Limit for performance
                                    if let subValues = try? subURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey]),
                                       let isSubDir = subValues.isDirectory, !isSubDir {
                                        folderSize += Int64(subValues.fileSize ?? 0)
                                        fileCount += 1
                                    }
                                }
                            }
                            
                            let fileItem = FileItem(
                                name: fileURL.lastPathComponent,
                                path: fileURL.path,
                                size: folderSize,
                                date: resourceValues.contentModificationDate ?? Date(),
                                isDirectory: true,
                                itemCount: itemCount
                            )
                            loadedFiles.append(fileItem)
                        } else {
                            // It's a file
                            let fileItem = FileItem(
                                name: fileURL.lastPathComponent,
                                path: fileURL.path,
                                size: Int64(resourceValues.fileSize ?? 0),
                                date: resourceValues.contentModificationDate ?? Date(),
                                isDirectory: false,
                                itemCount: nil
                            )
                            loadedFiles.append(fileItem)
                        }
                    }
                } catch {
                    print("⚠️ Error reading file: \(fileURL.path) - \(error)")
                    continue
                }
            }
            
            print("✅ Loaded \(loadedFiles.count) items from \(path)")
            
            // Sort: folders first (alphabetically), then files by size (largest first)
            loadedFiles.sort { item1, item2 in
                if item1.isDirectory && !item2.isDirectory {
                    return true
                } else if !item1.isDirectory && item2.isDirectory {
                    return false
                } else if item1.isDirectory && item2.isDirectory {
                    return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
                } else {
                    return item1.size > item2.size
                }
            }
            
            DispatchQueue.main.async {
                self.files = loadedFiles
                self.isLoading = false
            }
        }
    }
    
    func deleteFile(_ file: FileItem) {
        do {
            try FileManager.default.trashItem(at: URL(fileURLWithPath: file.path), resultingItemURL: nil)
            files.removeAll { $0.id == file.id }
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}
