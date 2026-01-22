//
//  TrashManagerView.swift
//  roomac
//
//  Created by savinda jayasekara on 2026-01-22.
//

import SwiftUI

struct TrashManagerView: View {
    @StateObject private var trashManager = TrashManager()
    @State private var showingConfirm = false
    @State private var showingSuccess = false
    @State private var successMessage = ""
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Trash Manager")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Manage and empty your trash")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                LoadingButton(
                    title: "Scan",
                    icon: "arrow.clockwise",
                    isLoading: trashManager.isScanning,
                    colors: [Color.orange, Color.red]
                ) {
                    trashManager.scanTrash()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Trash Stats
            if trashManager.trashItemCount > 0 {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TrashStatCard(
                            icon: "trash.fill",
                            title: "Items",
                            value: "\(trashManager.trashItemCount)",
                            color: .orange
                        )
                        
                        TrashStatCard(
                            icon: "externaldrive.fill",
                            title: "Total Size",
                            value: formatBytes(trashManager.trashSize),
                            color: .red
                        )
                    }
                    
                    Button(action: {
                        showingConfirm = true
                    }) {
                        HStack(spacing: 10) {
                            if trashManager.isEmptying {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(trashManager.isEmptying ? "Emptying..." : "Empty Trash")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: trashManager.isEmptying ? [Color.gray, Color.gray.opacity(0.8)] : [Color.red, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color.red.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(trashManager.isEmptying)
                }
                .padding(.horizontal, 24)
            }
            
            // File List
            if trashManager.isScanning {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.cyan)
                    
                    Text("Scanning trash...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if trashManager.trashItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "trash.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Trash is Empty")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Your trash bin doesn't contain any items")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(trashManager.trashItems) { item in
                            TrashFileRow(item: item)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            trashManager.scanTrash()
        }
        .onChange(of: trashManager.needsPermission) { needsPermission in
            if needsPermission {
                showingPermissionAlert = true
            }
        }
        .alert("Full Disk Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                    NSWorkspace.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("RooMAC needs Full Disk Access to manage your trash.\n\n1. Click 'Open Settings'\n2. Click the lock and authenticate\n3. Enable Full Disk Access for RooMAC\n4. Restart the app")
        }
        .alert("Empty Trash", isPresented: $showingConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Empty", role: .destructive) {
                trashManager.emptyTrash { success, message in
                    successMessage = message
                    showingSuccess = true
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete \(trashManager.trashItemCount) items? This action cannot be undone.")
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

struct TrashStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TrashFileRow: View {
    let item: FileItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(formatDate(item.date))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text(formatBytes(item.size))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.cyan)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
