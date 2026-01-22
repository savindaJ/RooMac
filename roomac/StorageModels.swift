//
//  StorageModels.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI

struct StorageCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let size: Int64
    let color: Color
    let path: String
    var files: [FileItem] = []
}

struct FileItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let path: String
    let size: Int64
    let date: Date
    let isDirectory: Bool
    var itemCount: Int? // For folders, number of items inside
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StorageInfo {
    var totalSpace: Int64 = 0
    var usedSpace: Int64 = 0
    var freeSpace: Int64 = 0
    
    var usedPercentage: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace) * 100
    }
}
