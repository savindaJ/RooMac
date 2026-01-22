//
//  LargeFileFinder.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine

class LargeFileFinder: ObservableObject {
    @Published var largeFiles: [FileItem] = []
    @Published var isSearching = false
    @Published var progress: Double = 0.0
    @Published var minimumSize: Int64 = 100_000_000 // 100MB default
    
    func findLargeFiles() {
        isSearching = true
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            let homeURL = fileManager.homeDirectoryForCurrentUser
            
            var foundFiles: [FileItem] = []
            
            // Search in common directories
            let searchPaths = [
                homeURL.appendingPathComponent("Documents"),
                homeURL.appendingPathComponent("Downloads"),
                homeURL.appendingPathComponent("Desktop"),
                homeURL.appendingPathComponent("Movies"),
                homeURL.appendingPathComponent("Pictures"),
                homeURL.appendingPathComponent("Music")
            ]
            
            let totalPaths = searchPaths.count
            
            for (index, path) in searchPaths.enumerated() {
                self.searchDirectory(at: path, files: &foundFiles)
                
                DispatchQueue.main.async {
                    self.progress = Double(index + 1) / Double(totalPaths)
                }
            }
            
            DispatchQueue.main.async {
                self.largeFiles = foundFiles.sorted { $0.size > $1.size }
                self.isSearching = false
            }
        }
    }
    
    private func searchDirectory(at url: URL, files: inout [FileItem]) {
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey])
                
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    let size = Int64(resourceValues.fileSize ?? 0)
                    
                    if size >= minimumSize {
                        let date = resourceValues.contentModificationDate ?? Date()
                        
                        files.append(FileItem(
                            name: fileURL.lastPathComponent,
                            path: fileURL.path,
                            size: size,
                            date: date,
                            isDirectory: false,
                            itemCount: nil
                        ))
                    }
                }
            } catch {
                continue
            }
        }
    }
    
    func moveToTrash(file: FileItem, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            let fileURL = URL(fileURLWithPath: file.path)
            
            do {
                try fileManager.trashItem(at: fileURL, resultingItemURL: nil)
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
