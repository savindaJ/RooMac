//
//  FileSafetyChecker.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine

enum FileSafetyLevel {
    case safe           // Safe to delete
    case caution        // Can delete but be careful
    case protected      // System file - DO NOT DELETE
    case recommended    // Recommended for deletion
}

struct FileSafetyInfo {
    let level: FileSafetyLevel
    let reason: String
    let color: Color
    let icon: String
    let canDelete: Bool
    
    static func evaluate(file: FileItem) -> FileSafetyInfo {
        let path = file.path.lowercased()
        let name = file.name.lowercased()
        let ext = (file.name as NSString).pathExtension.lowercased()
        
        // PROTECTED - System files that should NEVER be deleted
        if isSystemProtected(path: path, name: name) {
            return FileSafetyInfo(
                level: .protected,
                reason: "System file - Required by macOS",
                color: .red,
                icon: "exclamationmark.shield.fill",
                canDelete: false
            )
        }
        
        // RECOMMENDED - Files safe and recommended to delete
        if isRecommendedForDeletion(path: path, name: name, ext: ext, file: file) {
            return FileSafetyInfo(
                level: .recommended,
                reason: "Safe to delete - Frees up space",
                color: .green,
                icon: "checkmark.circle.fill",
                canDelete: true
            )
        }
        
        // CAUTION - Can delete but be careful
        if isCautionFile(path: path, name: name, ext: ext) {
            return FileSafetyInfo(
                level: .caution,
                reason: "Delete with caution - May contain important data",
                color: .orange,
                icon: "exclamationmark.triangle.fill",
                canDelete: true
            )
        }
        
        // SAFE - Regular files safe to delete
        return FileSafetyInfo(
            level: .safe,
            reason: "User file - Safe to delete",
            color: .blue,
            icon: "checkmark.circle",
            canDelete: true
        )
    }
    
    // System-critical files that must be protected
    private static func isSystemProtected(path: String, name: String) -> Bool {
        // System directories
        let protectedPaths = [
            "/system/",
            "/library/",
            "/applications/",
            "/usr/",
            "/bin/",
            "/sbin/",
            "/private/",
            "/etc/",
            "/var/",
            "/cores/",
            ".app/",
            ".framework/",
            ".bundle/",
            ".kext/"
        ]
        
        for protectedPath in protectedPaths {
            if path.contains(protectedPath) {
                return true
            }
        }
        
        // System files by name
        let protectedNames = [
            ".ds_store",
            ".localized",
            ".fseventsd",
            ".spotlight-v100",
            ".trashes",
            ".documentrevisions-v100",
            ".pkinstallsandboxmanager",
            "library",
            "system",
            "applications",
            ".bash_profile",
            ".zshrc",
            ".ssh",
            ".gnupg"
        ]
        
        for protectedName in protectedNames {
            if name == protectedName || name.hasPrefix(protectedName) {
                return true
            }
        }
        
        return false
    }
    
    // Files recommended for deletion
    private static func isRecommendedForDeletion(path: String, name: String, ext: String, file: FileItem) -> Bool {
        // Cache files
        if path.contains("/caches/") || path.contains("/cache/") {
            return true
        }
        
        // Temporary files
        if path.contains("/tmp/") || path.contains("/temp/") || name.hasPrefix("tmp") || name.hasPrefix("temp") {
            return true
        }
        
        // Log files
        if path.contains("/logs/") || ext == "log" {
            return true
        }
        
        // Old downloads (larger than 100MB and older than 30 days)
        if path.contains("/downloads/") && file.size > 100_000_000 {
            let daysSinceModified = Calendar.current.dateComponents([.day], from: file.date, to: Date()).day ?? 0
            if daysSinceModified > 30 {
                return true
            }
        }
        
        // Trash files
        if path.contains("/.trash/") || path.contains("/trash/") {
            return true
        }
        
        // Duplicate files (simple check by name patterns)
        if name.contains("copy") || name.contains("duplicate") || name.contains(" (1)") || name.contains(" (2)") {
            return true
        }
        
        // Old installers and DMG files
        if (ext == "dmg" || ext == "pkg" || ext == "zip") && file.size > 50_000_000 {
            let daysSinceModified = Calendar.current.dateComponents([.day], from: file.date, to: Date()).day ?? 0
            if daysSinceModified > 7 {
                return true
            }
        }
        
        // Screenshot files older than 7 days
        if (name.hasPrefix("screen shot") || name.hasPrefix("screenshot")) && ext == "png" {
            let daysSinceModified = Calendar.current.dateComponents([.day], from: file.date, to: Date()).day ?? 0
            if daysSinceModified > 7 {
                return true
            }
        }
        
        return false
    }
    
    // Files to be cautious with
    private static func isCautionFile(path: String, name: String, ext: String) -> Bool {
        // Documents
        let documentExts = ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "pdf", "pages", "numbers", "keynote"]
        if documentExts.contains(ext) {
            return true
        }
        
        // Code files
        let codeExts = ["swift", "py", "js", "java", "cpp", "c", "h", "php", "rb", "go"]
        if codeExts.contains(ext) {
            return true
        }
        
        // Database files
        if ext == "db" || ext == "sqlite" || ext == "sql" {
            return true
        }
        
        // Configuration files
        if ext == "plist" || ext == "conf" || ext == "config" || ext == "json" || ext == "xml" {
            return true
        }
        
        return false
    }
}

class SafetyRecommendations: ObservableObject {
    @Published var recommendations: [FileItem] = []
    @Published var potentialSavings: Int64 = 0
    
    func analyzeFiles(_ files: [FileItem]) {
        var recommendedFiles: [FileItem] = []
        var totalSize: Int64 = 0
        
        for file in files {
            if !file.isDirectory {
                let safety = FileSafetyInfo.evaluate(file: file)
                if safety.level == .recommended {
                    recommendedFiles.append(file)
                    totalSize += file.size
                }
            }
        }
        
        DispatchQueue.main.async {
            self.recommendations = recommendedFiles.sorted { $0.size > $1.size }
            self.potentialSavings = totalSize
        }
    }
}
