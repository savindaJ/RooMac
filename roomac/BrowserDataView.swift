//
//  BrowserDataView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct BrowserDataView: View {
    @StateObject private var browserCleaner = BrowserDataCleaner()
    @State private var showingConfirm = false
    @State private var browserToClean: BrowserData?
    @State private var showingSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Browser Data Cleaner")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Clean cache and temporary data")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                LoadingButton(
                    title: "Scan",
                    icon: "arrow.clockwise",
                    isLoading: browserCleaner.isScanning,
                    colors: [Color.blue, Color.cyan]
                ) {
                    browserCleaner.scanBrowsers()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Browser List
            if browserCleaner.browsers.isEmpty && !browserCleaner.isScanning {
                VStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No Browser Data Found")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Click Scan to detect installed browsers")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(browserCleaner.browsers) { browser in
                            BrowserCard(browser: browser) {
                                browserToClean = browser
                                showingConfirm = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            browserCleaner.scanBrowsers()
        }
        .alert("Clean Browser Data", isPresented: $showingConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Clean", role: .destructive) {
                if let browser = browserToClean {
                    browserCleaner.cleanBrowser(browser) { success, size in
                        if success {
                            successMessage = "Successfully cleaned \(browser.name)\nFreed \(formatBytes(size))"
                            showingSuccess = true
                        }
                    }
                }
            }
        } message: {
            Text("This will delete cache and temporary files from \(browserToClean?.name ?? ""). Make sure the browser is closed.")
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

struct BrowserCard: View {
    let browser: BrowserData
    let onClean: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Browser Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 4)
                
                Image(systemName: browser.icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            
            // Browser Info
            VStack(alignment: .leading, spacing: 6) {
                Text(browser.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    DataTypeView(
                        icon: "tray.fill",
                        label: "Cache",
                        size: browser.cacheSize
                    )
                }
            }
            
            Spacer()
            
            // Clean Button
            Button(action: onClean) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 16))
                    Text("Clean")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
                .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct DataTypeView: View {
    let icon: String
    let label: String
    let size: Int64
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.cyan)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(formatBytes(size))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.cyan)
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
