//
//  TrashManager.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine
import AppKit

class TrashManager: ObservableObject {
    @Published var trashSize: Int64 = 0
    @Published var trashItemCount: Int = 0
    @Published var trashItems: [FileItem] = []
    @Published var isScanning = false
    @Published var isEmptying = false
    @Published var needsPermission = false
    
    func scanTrash() {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first!
            
            var items: [FileItem] = []
            var totalSize: Int64 = 0
            var itemCount = 0
            
            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: trashURL,
                    includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey],
                    options: []
                )
                
                print("🗑️ Found \(contents.count) items in trash directory")
                
                for url in contents {
                    do {
                        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isDirectoryKey])
                        let size = self.calculateItemSize(at: url)
                        let date = resourceValues.contentModificationDate ?? Date()
                        let isDirectory = resourceValues.isDirectory ?? false
                        
                        items.append(FileItem(
                            name: url.lastPathComponent,
                            path: url.path,
                            size: size,
                            date: date,
                            isDirectory: isDirectory,
                            itemCount: isDirectory ? self.countItems(at: url) : nil
                        ))
                        
                        totalSize += size
                        itemCount += 1
                    } catch let error {
                        print("⚠️ Error processing item: \(url.lastPathComponent) - \(error)")
                        continue
                    }
                }
            } catch let error {
                print("❌ Error scanning trash: \(error)")
                print("📁 Trash path: \(trashURL.path)")
                
                // Check if it's a permission error
                let nsError = error as NSError
                if nsError.code == NSFileReadNoPermissionError || nsError.domain == NSCocoaErrorDomain {
                    DispatchQueue.main.async {
                        self.needsPermission = true
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.trashItems = items.sorted { $0.size > $1.size }
                self.trashSize = totalSize
                self.trashItemCount = itemCount
                self.isScanning = false
                print("✅ Trash scan complete: \(itemCount) items, \(totalSize) bytes")
            }
        }
    }
    
    func emptyTrash(completion: @escaping (Bool, String) -> Void) {
        isEmptying = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            guard let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async {
                    self.isEmptying = false
                    completion(false, "Could not find trash directory")
                }
                return
            }
            
            var deletedCount = 0
            var deletedSize: Int64 = 0
            var errors: [String] = []
            
            do {
                let contents = try fileManager.contentsOfDirectory(at: trashURL, includingPropertiesForKeys: nil, options: [])
                print("🗑️ Attempting to delete \(contents.count) items from trash")
                
                for item in contents {
                    do {
                        // Get size before deleting
                        let size = self.calculateItemSize(at: item)
                        
                        // Delete the item
                        try fileManager.removeItem(at: item)
                        deletedCount += 1
                        deletedSize += size
                        print("✅ Deleted: \(item.lastPathComponent)")
                    } catch {
                        errors.append(item.lastPathComponent)
                        print("❌ Failed to delete: \(item.lastPathComponent) - \(error.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.isEmptying = false
                    
                    if deletedCount > 0 {
                        let formatter = ByteCountFormatter()
                        formatter.countStyle = .file
                        let sizeStr = formatter.string(fromByteCount: deletedSize)
                        
                        var message = "Successfully emptied \(deletedCount) items\nFreed \(sizeStr)"
                        if !errors.isEmpty {
                            message += "\n\n⚠️ Could not delete \(errors.count) items (may require manual deletion)"
                        }
                        
                        completion(true, message)
                        self.scanTrash()
                    } else {
                        completion(false, "No items were deleted. Check app permissions.")
                    }
                }
            } catch {
                print("❌ Error accessing trash: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isEmptying = false
                    completion(false, "Failed to access trash: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func calculateItemSize(at url: URL) -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            if let isDirectory = resourceValues.isDirectory, isDirectory {
                guard let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey],
                    options: []
                ) else { return 0 }
                
                for case let fileURL as URL in enumerator {
                    do {
                        let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                        if let isDir = values.isDirectory, !isDir {
                            totalSize += Int64(values.fileSize ?? 0)
                        }
                    } catch {
                        continue
                    }
                }
            } else {
                let values = try url.resourceValues(forKeys: [.fileSizeKey])
                totalSize = Int64(values.fileSize ?? 0)
            }
        } catch {
            return 0
        }
        
        return totalSize
    }
    
    private func countItems(at url: URL) -> Int {
        let fileManager = FileManager.default
        var count = 0
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return 0 }
        
        for _ in enumerator {
            count += 1
        }
        
        return count
    }
}
