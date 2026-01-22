# RooMAC - Advanced Mac Storage Manager

<div align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" />
  <img src="https://img.shields.io/badge/SwiftUI-Latest-green?style=for-the-badge" />
</div>

## 🌟 Overview

RooMAC is a powerful and beautiful macOS storage management application that helps you analyze, clean, and optimize your Mac's storage space. Built with SwiftUI, it features a modern UI with smooth animations and comprehensive storage management tools.

## ✨ Features

### 📊 Dashboard
- **Real-time Storage Overview**: Visual representation of your Mac's storage using an animated ring chart
- **Quick Actions**: Fast access to all cleanup tools
- **Storage Categories**: Detailed breakdown of where your space is being used
- **Smart Alerts**: Get notified when action is needed

### 💾 Storage Analyzer
- **Deep Directory Scanning**: Analyzes Documents, Downloads, Desktop, Pictures, Movies, Music, and App Data
- **Visual Category Cards**: Beautiful cards showing size and percentage of each category
- **File Browsing**: Drill down into categories to see individual files
- **Smart Progress Tracking**: Real-time progress indicator during analysis

### 🗑️ Trash Manager
- **Trash Overview**: See exactly what's in your trash and how much space it takes
- **Detailed Item List**: Browse all items with size and date information
- **One-Click Empty**: Safely empty your trash with confirmation
- **Space Recovery**: See how much space you'll recover

### 📦 Large Files Finder
- **Customizable Size Threshold**: Find files larger than 50MB, 100MB, 500MB, 1GB, or 5GB
- **Smart Search**: Scans common directories (Documents, Downloads, Desktop, Movies, Pictures, Music)
- **File Type Recognition**: Icons for different file types (videos, music, images, archives, etc.)
- **Individual Deletion**: Move files to trash one by one
- **Total Size Calculation**: See the total size of all large files found

### 📅 Old Files Cleaner
- **Time-Based Filtering**: Find files not used in 6 months, 1 year, 2 years, or 3 years
- **Batch Selection**: Select multiple files for cleanup
- **Smart Date Detection**: Uses both modification and access dates
- **Bulk Removal**: Move multiple files to trash at once
- **Safety First**: Files are moved to trash, not permanently deleted

### 🌐 Browser Data Cleaner
- **Multi-Browser Support**: 
  - Google Chrome
  - Safari
  - Firefox
  - Microsoft Edge
  - Brave
- **Cache Cleanup**: Remove temporary cache files
- **Size Detection**: See how much space each browser is using
- **Individual Control**: Clean each browser separately
- **Safe Cleaning**: Only removes cache and temporary files

## 🎨 UI Design

### Modern Dark Theme
- Beautiful gradient backgrounds
- Smooth animations and transitions
- Glass morphism effects
- Responsive hover states
- Particle background effects

### Sidebar Navigation
- Clean and intuitive navigation
- Color-coded sections
- Smooth page transitions
- Active state indicators

### Color Scheme
- **Primary**: Cyan/Blue gradients
- **Trash**: Orange/Red gradients
- **Large Files**: Purple/Pink gradients
- **Old Files**: Green/Teal gradients
- **Browser**: Blue/Cyan gradients

## 🚀 Getting Started

### Requirements
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/roomac.git
cd roomac
```

2. Open the project in Xcode:
```bash
open roomac.xcodeproj
```

3. Build and run the project (⌘R)

## 🛠️ Technical Details

### Architecture
- **MVVM Pattern**: Clean separation of views and business logic
- **ObservableObject**: Reactive state management
- **Async Operations**: Background processing for scanning and cleanup
- **SwiftUI**: Modern declarative UI framework

### Key Components

#### Storage Analysis
- Real-time disk space calculation
- Recursive directory scanning
- File size aggregation
- Category-based organization

#### Safety Features
- All deletions move to trash first
- Confirmation dialogs for destructive actions
- Hidden files are skipped by default
- System files are protected

#### Performance
- Background thread processing
- Progress tracking
- Efficient file enumeration
- Memory-conscious scanning

## 📝 Permissions

RooMAC requires the following permissions:
- **File System Access**: To scan and analyze your files
- **Trash Access**: To empty the trash
- **User Directories**: To access Documents, Downloads, Desktop, etc.

### First Launch Setup

When you first launch RooMAC, you'll see a welcome screen with step-by-step instructions to enable **Full Disk Access**:

1. Click "Open System Settings" button
2. Navigate to **Privacy & Security** → **Full Disk Access**
3. Click the lock icon and authenticate
4. Toggle on **RooMAC** in the list
5. Restart the app

You can access this guide anytime by clicking the **"Setup Guide"** button in the sidebar footer.

### Why Full Disk Access?

Full Disk Access allows RooMAC to:
- Scan your trash directory
- Access all user directories for accurate storage analysis
- Clean browser cache files
- Provide comprehensive storage information

## 🔒 Privacy

- **No Data Collection**: RooMAC doesn't collect or send any data
- **Local Processing**: All analysis happens on your Mac
- **No Network Access**: The app doesn't require internet connection
- **Open Source**: Transparent code you can review

## 🐛 Known Issues

- Some system cache directories may require additional permissions
- Browser cleaning works best when browsers are closed
- Very large directories may take time to scan

## 🗺️ Roadmap

- [ ] Duplicate file finder
- [ ] Custom directory scanning
- [ ] Scheduled automatic cleaning
- [ ] Export storage reports
- [ ] Dark/Light theme toggle
- [ ] Localization support
- [ ] Menu bar integration

## 👨‍💻 Development

### Project Structure
```
roomac/
├── Models/
│   └── StorageModels.swift
├── Views/
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── StorageAnalyzerView.swift
│   ├── TrashManagerView.swift
│   ├── LargeFilesView.swift
│   ├── OldFilesView.swift
│   └── BrowserDataView.swift
├── ViewModels/
│   ├── StorageAnalyzer.swift
│   ├── TrashManager.swift
│   ├── LargeFileFinder.swift
│   ├── OldFilesCleaner.swift
│   └── BrowserDataCleaner.swift
└── Components/
    ├── CategoryCardView.swift
    ├── LoadingButton.swift
    ├── StorageRingView.swift
    └── FileListView.swift
```

### Building
```bash
# Debug build
xcodebuild -scheme roomac -configuration Debug

# Release build
xcodebuild -scheme roomac -configuration Release
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Built with SwiftUI
- Icons from SF Symbols
- Inspired by modern macOS design principles

## 📧 Contact

For questions, suggestions, or issues, please open an issue on GitHub.

---

<div align="center">
  Made with ❤️ for macOS
</div>
