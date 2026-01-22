//
//  StorageAnalyzer.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine
import AppKit

class StorageAnalyzer: ObservableObject {
    @Published var storageInfo = StorageInfo()
    @Published var categories: [StorageCategory] = []
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    
    func analyzeStorage() {
        isAnalyzing = true
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Get disk information
            let homeURL = FileManager.default.homeDirectoryForCurrentUser
            do {
                let values = try homeURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
                let totalSpace = values.volumeTotalCapacity ?? 0
                let availableSpace = values.volumeAvailableCapacity ?? 0
                let usedSpace = totalSpace - availableSpace
                
                DispatchQueue.main.async {
                    self.storageInfo = StorageInfo(
                        totalSpace: Int64(totalSpace),
                        usedSpace: Int64(usedSpace),
                        freeSpace: Int64(availableSpace)
                    )
                }
            } catch {
                print("Error getting disk info: \(error)")
            }
            
            // Analyze categories
            var tempCategories: [StorageCategory] = []
            
            // Documents
            self.updateProgress(0.15)
            let documentsSize = self.calculateDirectorySize(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
            tempCategories.append(StorageCategory(
                name: "Documents",
                icon: "doc.fill",
                size: documentsSize,
                color: Color.blue.opacity(0.8),
                path: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
            ))
            
            // Downloads
            self.updateProgress(0.30)
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            let downloadsSize = self.calculateDirectorySize(at: downloadsURL)
            tempCategories.append(StorageCategory(
                name: "Downloads",
                icon: "arrow.down.circle.fill",
                size: downloadsSize,
                color: Color.cyan.opacity(0.8),
                path: downloadsURL?.path ?? ""
            ))
            
            // Desktop
            self.updateProgress(0.45)
            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
            let desktopSize = self.calculateDirectorySize(at: desktopURL)
            tempCategories.append(StorageCategory(
                name: "Desktop",
                icon: "desktopcomputer",
                size: desktopSize,
                color: Color.blue.opacity(0.6),
                path: desktopURL?.path ?? ""
            ))
            
            // Pictures
            self.updateProgress(0.60)
            let picturesURL = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
            let picturesSize = self.calculateDirectorySize(at: picturesURL)
            tempCategories.append(StorageCategory(
                name: "Pictures",
                icon: "photo.fill",
                size: picturesSize,
                color: Color.indigo.opacity(0.8),
                path: picturesURL?.path ?? ""
            ))
            
            // Movies
            self.updateProgress(0.75)
            let moviesURL = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first
            let moviesSize = self.calculateDirectorySize(at: moviesURL)
            tempCategories.append(StorageCategory(
                name: "Movies",
                icon: "film.fill",
                size: moviesSize,
                color: Color.blue.opacity(0.9),
                path: moviesURL?.path ?? ""
            ))
            
            // Music
            self.updateProgress(0.75)
            let musicURL = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
            let musicSize = self.calculateDirectorySize(at: musicURL)
            tempCategories.append(StorageCategory(
                name: "Music",
                icon: "music.note",
                size: musicSize,
                color: Color.cyan.opacity(0.7),
                path: musicURL?.path ?? ""
            ))
            
            // Cache Files
            self.updateProgress(0.85)
            let cacheURLs = self.getCacheDirectories()
            var totalCacheSize: Int64 = 0
            for cacheURL in cacheURLs {
                totalCacheSize += self.calculateDirectorySize(at: cacheURL)
            }
            tempCategories.append(StorageCategory(
                name: "Cache Files",
                icon: "tray.full.fill",
                size: totalCacheSize,
                color: Color.orange.opacity(0.8),
                path: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path ?? ""
            ))
            
            // Application Support
            self.updateProgress(0.92)
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            let appSupportSize = self.calculateDirectorySize(at: appSupportURL)
            tempCategories.append(StorageCategory(
                name: "App Data",
                icon: "app.fill",
                size: appSupportSize,
                color: Color.purple.opacity(0.8),
                path: appSupportURL?.path ?? ""
            ))
            
            self.updateProgress(1.0)
            
            DispatchQueue.main.async {
                self.categories = tempCategories.sorted { $0.size > $1.size }
                self.isAnalyzing = false
            }
        }
    }
    
    private func updateProgress(_ value: Double) {
        DispatchQueue.main.async {
            self.progress = value
        }
    }
    
    private func calculateDirectorySize(at url: URL?) -> Int64 {
        guard let url = url else { return 0 }
        
        var totalSize: Int64 = 0
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    totalSize += Int64(resourceValues.fileSize ?? 0)
                }
            } catch {
                continue
            }
        }
        
        return totalSize
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        return formatter.string(fromByteCount: bytes)
    }
    
    func openInFinder(path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
    
    private func getCacheDirectories() -> [URL] {
        var cacheURLs: [URL] = []
        
        // User Caches directory
        if let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheURLs.append(cachesURL)
        }
        
        // User Library Logs
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        let logsURL = homeURL.appendingPathComponent("Library/Logs")
        if FileManager.default.fileExists(atPath: logsURL.path) {
            cacheURLs.append(logsURL)
        }
        
        // Temporary files
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        if FileManager.default.fileExists(atPath: tmpURL.path) {
            cacheURLs.append(tmpURL)
        }
        
        return cacheURLs
    }
    
    func getCacheSummary(completion: @escaping (Int, Int64) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var fileCount = 0
            var totalSize: Int64 = 0
            let fileManager = FileManager.default
            
            // Get cache directories
            let cacheDirectories = self.getCacheDirectories()
            
            for cacheURL in cacheDirectories {
                guard let enumerator = fileManager.enumerator(
                    at: cacheURL,
                    includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                    options: [.skipsHiddenFiles]
                ) else { continue }
                
                for case let fileURL as URL in enumerator {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                        if let isDirectory = resourceValues.isDirectory, !isDirectory {
                            fileCount += 1
                            totalSize += Int64(resourceValues.fileSize ?? 0)
                        }
                    } catch {
                        continue
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(fileCount, totalSize)
            }
        }
    }
    
    func clearCache(completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var clearedSize: Int64 = 0
            var clearedCount = 0
            var errors: [String] = []
            let fileManager = FileManager.default
            
            // Get cache directories
            let cacheDirectories = self.getCacheDirectories()
            
            for cacheURL in cacheDirectories {
                guard let enumerator = fileManager.enumerator(
                    at: cacheURL,
                    includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                    options: [.skipsHiddenFiles]
                ) else { continue }
                
                for case let fileURL as URL in enumerator {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                        if let isDirectory = resourceValues.isDirectory, !isDirectory {
                            let size = Int64(resourceValues.fileSize ?? 0)
                            try fileManager.removeItem(at: fileURL)
                            clearedSize += size
                            clearedCount += 1
                        }
                    } catch {
                        errors.append(fileURL.lastPathComponent)
                    }
                }
            }
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            let message = "Successfully cleaned \(clearedCount) files\nFreed \(formatter.string(fromByteCount: clearedSize)) of space"
            
            DispatchQueue.main.async {
                completion(true, message)
                // Refresh analysis
                self.analyzeStorage()
            }
        }
    }
}
