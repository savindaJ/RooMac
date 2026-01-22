//
//  BrowserDataCleaner.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import Foundation
import SwiftUI
import Combine

struct BrowserData: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let cacheSize: Int64
    let historySize: Int64
    let cookiesSize: Int64
    let paths: [String]
}

class BrowserDataCleaner: ObservableObject {
    @Published var browsers: [BrowserData] = []
    @Published var isScanning = false
    @Published var isCleaning = false
    
    func scanBrowsers() {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            let homeURL = fileManager.homeDirectoryForCurrentUser
            
            var foundBrowsers: [BrowserData] = []
            
            // Chrome
            let chromePaths = [
                homeURL.appendingPathComponent("Library/Application Support/Google/Chrome/Default/Cache").path,
                homeURL.appendingPathComponent("Library/Application Support/Google/Chrome/Default/Code Cache").path,
                homeURL.appendingPathComponent("Library/Caches/Google/Chrome").path
            ]
            let chromeSize = self.calculateBrowserSize(paths: chromePaths)
            if chromeSize > 0 {
                foundBrowsers.append(BrowserData(
                    name: "Google Chrome",
                    icon: "globe",
                    cacheSize: chromeSize,
                    historySize: 0,
                    cookiesSize: 0,
                    paths: chromePaths
                ))
            }
            
            // Safari
            let safariPaths = [
                homeURL.appendingPathComponent("Library/Caches/com.apple.Safari").path,
                homeURL.appendingPathComponent("Library/Safari/LocalStorage").path,
                homeURL.appendingPathComponent("Library/Safari/Databases").path
            ]
            let safariSize = self.calculateBrowserSize(paths: safariPaths)
            if safariSize > 0 {
                foundBrowsers.append(BrowserData(
                    name: "Safari",
                    icon: "safari",
                    cacheSize: safariSize,
                    historySize: 0,
                    cookiesSize: 0,
                    paths: safariPaths
                ))
            }
            
            // Firefox
            let firefoxPaths = [
                homeURL.appendingPathComponent("Library/Caches/Firefox").path,
                homeURL.appendingPathComponent("Library/Application Support/Firefox/Profiles").path
            ]
            let firefoxSize = self.calculateBrowserSize(paths: firefoxPaths)
            if firefoxSize > 0 {
                foundBrowsers.append(BrowserData(
                    name: "Firefox",
                    icon: "flame",
                    cacheSize: firefoxSize,
                    historySize: 0,
                    cookiesSize: 0,
                    paths: firefoxPaths
                ))
            }
            
            // Edge
            let edgePaths = [
                homeURL.appendingPathComponent("Library/Application Support/Microsoft Edge/Default/Cache").path,
                homeURL.appendingPathComponent("Library/Caches/Microsoft Edge").path
            ]
            let edgeSize = self.calculateBrowserSize(paths: edgePaths)
            if edgeSize > 0 {
                foundBrowsers.append(BrowserData(
                    name: "Microsoft Edge",
                    icon: "e.circle",
                    cacheSize: edgeSize,
                    historySize: 0,
                    cookiesSize: 0,
                    paths: edgePaths
                ))
            }
            
            // Brave
            let bravePaths = [
                homeURL.appendingPathComponent("Library/Application Support/BraveSoftware/Brave-Browser/Default/Cache").path,
                homeURL.appendingPathComponent("Library/Caches/BraveSoftware").path
            ]
            let braveSize = self.calculateBrowserSize(paths: bravePaths)
            if braveSize > 0 {
                foundBrowsers.append(BrowserData(
                    name: "Brave",
                    icon: "shield",
                    cacheSize: braveSize,
                    historySize: 0,
                    cookiesSize: 0,
                    paths: bravePaths
                ))
            }
            
            DispatchQueue.main.async {
                self.browsers = foundBrowsers.sorted { $0.cacheSize > $1.cacheSize }
                self.isScanning = false
            }
        }
    }
    
    private func calculateBrowserSize(paths: [String]) -> Int64 {
        var totalSize: Int64 = 0
        let fileManager = FileManager.default
        
        for path in paths {
            let url = URL(fileURLWithPath: path)
            
            guard fileManager.fileExists(atPath: path),
                  let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                    options: [.skipsHiddenFiles]
                  ) else { continue }
            
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
        }
        
        return totalSize
    }
    
    func cleanBrowser(_ browser: BrowserData, completion: @escaping (Bool, Int64) -> Void) {
        isCleaning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            var cleanedSize: Int64 = browser.cacheSize
            var success = true
            
            for path in browser.paths {
                let url = URL(fileURLWithPath: path)
                
                guard fileManager.fileExists(atPath: path) else { continue }
                
                do {
                    let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                    for item in contents {
                        try fileManager.removeItem(at: item)
                    }
                } catch {
                    success = false
                }
            }
            
            DispatchQueue.main.async {
                self.isCleaning = false
                completion(success, cleanedSize)
                if success {
                    self.scanBrowsers()
                }
            }
        }
    }
}
