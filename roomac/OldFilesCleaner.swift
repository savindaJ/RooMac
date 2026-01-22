//
//  OldFilesCleaner.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine

class OldFilesCleaner: ObservableObject {
    @Published var oldFiles: [FileItem] = []
    @Published var isSearching = false
    @Published var progress: Double = 0.0
    @Published var daysOld: Int = 365 // 1 year default
    
    func findOldFiles() {
        isSearching = true
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            let homeURL = fileManager.homeDirectoryForCurrentUser
            
            var foundFiles: [FileItem] = []
            
            // Calculate cutoff date
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -self.daysOld, to: Date()) ?? Date()
            
            // Search in common directories
            let searchPaths = [
                homeURL.appendingPathComponent("Documents"),
                homeURL.appendingPathComponent("Downloads"),
                homeURL.appendingPathComponent("Desktop")
            ]
            
            let totalPaths = searchPaths.count
            
            for (index, path) in searchPaths.enumerated() {
                self.searchDirectory(at: path, cutoffDate: cutoffDate, files: &foundFiles)
                
                DispatchQueue.main.async {
                    self.progress = Double(index + 1) / Double(totalPaths)
                }
            }
            
            DispatchQueue.main.async {
                self.oldFiles = foundFiles.sorted { $0.date < $1.date }
                self.isSearching = false
            }
        }
    }
    
    private func searchDirectory(at url: URL, cutoffDate: Date, files: inout [FileItem]) {
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .contentAccessDateKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .contentAccessDateKey, .isDirectoryKey])
                
                // Get the most recent date (access or modification)
                let modDate = resourceValues.contentModificationDate ?? Date.distantPast
                let accessDate = resourceValues.contentAccessDate ?? Date.distantPast
                let mostRecentDate = max(modDate, accessDate)
                
                if mostRecentDate < cutoffDate {
                    let size = Int64(resourceValues.fileSize ?? 0)
                    let isDirectory = resourceValues.isDirectory ?? false
                    
                    files.append(FileItem(
                        name: fileURL.lastPathComponent,
                        path: fileURL.path,
                        size: size,
                        date: mostRecentDate,
                        isDirectory: isDirectory,
                        itemCount: nil
                    ))
                }
            } catch {
                continue
            }
        }
    }
    
    func moveToTrash(files: [FileItem], completion: @escaping (Int, Int64) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            var movedCount = 0
            var totalSize: Int64 = 0
            
            for file in files {
                let fileURL = URL(fileURLWithPath: file.path)
                
                do {
                    try fileManager.trashItem(at: fileURL, resultingItemURL: nil)
                    movedCount += 1
                    totalSize += file.size
                } catch {
                    continue
                }
            }
            
            DispatchQueue.main.async {
                completion(movedCount, totalSize)
            }
        }
    }
}
