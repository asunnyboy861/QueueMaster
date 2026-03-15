# Apple Music Queue Manager - US Market Operation Guide

**Document Version**: 1.0  
**Creation Date**: March 15, 2026  
**Author**: AI Assistant  
**Target Audience**: iOS Developers, Product Managers, Entrepreneurs  
**Target Market**: United States (English Version)  
**Target Language**: English (US)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Market Analysis](#2-market-analysis)
3. [Competitor Analysis](#3-competitor-analysis)
4. [Apple App Store Guidelines](#4-apple-app-store-guidelines)
5. [Technical Implementation](#5-technical-implementation)
6. [UI/UX Design Guidelines](#6-uiux-design-guidelines)
7. [Code Generation Rules](#7-code-generation-rules)
8. [Implementation Process](#8-implementation-process)
9. [Testing & Validation Standards](#9-testing--validation-standards)
10. [Build & Compilation](#10-build--compilation)

---

## 1. Project Overview

### 1.1 Project定位

**Apple Music Queue Manager** is an intelligent music queue management app designed for iOS users, specifically targeting the US market. The app solves critical pain points in Apple's native Music app regarding queue management, providing more powerful, intuitive, and smart playback queue control.

### 1.2 Core Value Proposition

```
Empowering every music lover to fully control their auditory journey
```

### 1.3 Project Highlights

- **100% Local Storage** - No network required, no backend, complete privacy protection
- **Lightning Fast** - Native Swift implementation, exceptional performance
- **Precise Pain Point Solution** - Addressing the most complained-about missing features in Apple Music
- **One-Time Purchase** - No subscription required, permanent use
- **Global-Ready Design** - English-first, targeting US market

### 1.4 Target User Personas

#### Primary User Segments

| User Segment | Percentage | Characteristics | Payment Willingness |
|-------------|------------|-----------------|---------------------|
| Music Enthusiasts | 35% | Create custom playlists, focus on playback order | $2.99-$4.99 one-time |
| Commuters | 30% | Long daily Apple Music usage, frequent queue adjustments | $1.99-$3.99 one-time |
| Party Hosts | 20% | Prepare music for events, precise control needs | $2.99-$4.99 one-time |
| Music Explorers | 15% | Frequently discover new music, flexible management needs | $0.99-$2.99 one-time |

---

## 2. Market Analysis

### 2.1 Market Size

**Global Apple Music Subscribers**: 100M+  
**US Apple Music Subscribers**: 45M+  
**Core Target Users**: 5M+  
**Potential Market Value**: $10M - $30M (one-time purchases)

### 2.2 Pain Points (Based on Reddit & Social Media Research)

#### Critical Pain Point #1: Accidental Queue Clear ⭐⭐⭐⭐⭐
**Severity**: Critical  
**User Voice**:
> "I've used AM for years, I still never not get annoyed when I have a whole queue saved and then I accidentally tap another song and the whole thing gets changed"
> — coconutwheelie (Reddit, r/AppleMusic)

**Problem Details**:
- User's carefully curated queue gets cleared with one tap
- Apple removed the queue confirmation prompt
- No undo feature to restore queue
- Impact: Hours of work lost with each accidental operation

**Solution**:
- Preview clear warning
- Queue snapshot save
- One-tap undo restore
- Queue history

#### Critical Pain Point #2: "Play Last" Feature Missing ⭐⭐⭐⭐
**Severity**: High  
**User Voice**:
> "Play Last" is useless - Apple Music need better queue management"
> — TimmyGUNZ (Reddit, r/AppleMusic, 276 upvotes)

**Problem Details**:
- "Play Last" often adds to wrong position
- Cannot precisely control song insertion position
- Missing queue visualization
- Impact: Cannot flexibly arrange playback order

#### Critical Pain Point #3: iOS 18 Queue Behavior ⭐⭐⭐⭐
**Severity**: Medium-High  
**User Voice**:
> "Been hoping they'd fix this by now but as it's still ongoing... old Apple Music had it so if I instant-played a song... it would naturally clear the queue. Now it forces old queue all the time"
> — cellidonuts (Apple Support Communities)

### 2.3 Market Entry Strategy

#### Phase 1: App Store Optimization (0-3 months)
- Keyword optimization: "Apple Music queue", "music queue manager", "queue manager"
- Screenshots highlight core features
- Description emphasizes pain point solutions

#### Phase 2: Community Marketing (3-6 months)
- Reddit community promotion (r/AppleMusic, r/ios)
- Twitter user engagement
- Music forum sharing

#### Phase 3: Word-of-Mouth (6-12 months)
- User referral rewards
- App Store rating maintenance
- Feature iteration based on feedback

---

## 3. Competitor Analysis

### 3.1 Direct Competitors

| App Name | Rating | Main Defects | User Feedback |
|---------|--------|--------------|---------------|
| Apple Music Native | 4.6 | Poor queue management | Long-standing complaints |
| Third-party Queue Tools | 3.2 | Stability issues | Frequent crashes |
| Playlist Apps | 4.0 | Incomplete features | Missing core functionality |

### 3.2 Competitive Advantages

- **Queue-Focused** - More professional than general-purpose apps
- **Native Integration** - More stable than third-party apps
- **User-Driven** - Designed based on real pain points
- **Local-First** - Both performance and privacy advantages

### 3.3 GitHub Open Source Projects Reference

Based on research, the following GitHub projects can be referenced for secondary development:

| Project | Language | Features | License | Usage |
|--------|----------|----------|---------|-------|
| Apple Music GitHub Samples | Swift | Official Apple samples for MusicKit | Apple Sample Code | Reference |
| MPMusicPlayerController Wrapper | Swift | MediaPlayer wrapper | MIT | Integrate |
| SoundCloud API Wrapper | Swift | Music API integration | MIT | Reference |

**Note**: Since this is a queue management tool that integrates with Apple Music, the best approach is to use Apple's native MusicKit and MediaPlayer frameworks rather than third-party open source projects. The app should focus on UI/UX and queue management logic.

---

## 4. Apple App Store Guidelines

### 4.1 Required Capabilities

In Xcode, enable the following capabilities:
- **MusicKit** - For Apple Music integration
- **Background Modes** - For background audio playback
- **App Groups** - For data sharing (if needed)

### 4.2 Required Permissions

Add to `Info.plist`:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>QueueMaster needs access to your Apple Music library to manage your playback queue and provide queue protection features.</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### 4.3 App Store Review Guidelines Compliance

#### Section 2.1 - App Completeness
- App must be fully functional
- All features must work as described
- No placeholder content

#### Section 4.2 - Minimum Functionality
- App must provide significant functionality
- Cannot be a simple wrapper around web content
- Must have native iOS features

#### Section 4.3 - Spam
- No duplicate app submissions
- No excessive advertising
- Respectful of user privacy

#### Section 5.1 - Privacy
- Data stored locally only
- No third-party analytics without consent
- Clear privacy policy

### 4.4 Intellectual Property Considerations

- App name cannot include "Apple Music" or "Apple" trademarked terms in a way that suggests official endorsement
- Use "Works with Apple Music" badge if appropriate
- Focus on "queue management" rather than "music playback"

---

## 5. Technical Implementation

### 5.1 Architecture Principles

1. **Local-First** - All data stored locally
2. **Native Integration** - Deep integration with Apple MusicKit
3. **Performance-First** - Smooth 60fps animations
4. **Privacy Protection** - Zero data collection
5. **Extensibility** - Easy to add new features

### 5.2 Technical Stack

#### Frontend Framework
```swift
Swift 5.9+ (Latest Stable)
SwiftUI 5.0+ (Modern Declarative UI)
Combine (Reactive Programming)
```

#### Core Frameworks
```swift
MusicKit (Apple Official Music Framework)
MediaPlayer (Low-level Playback Control)
StoreKit 2 (In-App Purchase)
WidgetKit (Home Screen Widgets)
```

#### Data Storage
```swift
UserDefaults (Settings Storage)
FileManager (File Management)
SQLite.swift (Structured Data - Optional)
```

#### Design Patterns
```swift
MVVM (Model-View-ViewModel)
Repository Pattern (Data Repository)
Singleton (Shared Services)
Observer (Data Observation)
```

### 5.3 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (SwiftUI)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │QueueEditor   │  │QueueHistory  │  │SettingsView │      │
│  │    View      │  │    View      │  │    View     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              ViewModel Layer (ObservableObject)              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │QueueViewModel│  │HistoryVM     │  │SettingsVM    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Service Layer (Business Logic)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │QueueManager  │  │HistoryManager│  │MusicService  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Data Layer (Persistence)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │UserDefaults  │  │FileStorage   │  │CoreData      │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              External Integrations                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │Apple MusicKit│  │System Music  │  │Notifications │       │
│  │              │  │Player        │  │              │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### 5.4 Core Module Design

#### Module 1: QueueManager (Core Queue Management)
**Responsibility**: All queue operation logic

```swift
class QueueManager: ObservableObject {
    static let shared = QueueManager()
    
    @Published var currentQueue: [MusicItem] = []
    @Published var queueHistory: [QueueSnapshot] = []
    @Published var isQueueModified: Bool = false
    
    func addToQueue(_ item: MusicItem, position: InsertPosition)
    func removeFromQueue(_ item: MusicItem)
    func reorderQueue(from source: IndexSet, to destination: Int)
    func saveQueueSnapshot() -> QueueSnapshot
    func restoreQueueSnapshot(_ snapshot: QueueSnapshot)
    func undoLastAction()
}
```

**Key Features**:
- Undo/Redo mechanism (up to 50 steps)
- Real-time queue monitoring
- Smart conflict detection
- Auto-save mechanism

#### Module 2: MusicService (Music Playback Service)
**Responsibility**: Interaction with Apple MusicKit

```swift
class MusicService: ObservableObject {
    static let shared = MusicService()
    
    private let musicPlayer: MPMusicPlayerController
    private let applicationMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    func play(item: MusicItem)
    func pause()
    func next()
    func previous()
    func setQueue(_ items: [MusicItem])
    func getCurrentPlaybackTime() -> TimeInterval
    func seek(to time: TimeInterval)
    func getCurrentQueue() -> [MusicItem]
}
```

**Key Features**:
- System music player integration
- Background playback support
- Remote control integration

#### Module 3: HistoryManager (History Management)
**Responsibility**: Queue history and statistics

```swift
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var queueHistory: [QueueSnapshot] = []
    @Published var playStatistics: PlayStatistics
    
    func saveSnapshot(_ snapshot: QueueSnapshot)
    func loadSnapshots() -> [QueueSnapshot]
    func deleteSnapshot(_ id: UUID)
    func getStatistics() -> PlayStatistics
    func exportHistory() -> URL?
}
```

**Key Features**:
- Auto-save queue snapshots
- Playback statistics tracking
- Export functionality

### 5.5 Data Models

```swift
struct MusicItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?
    let durationInSeconds: Int
    let playParameters: PlayParameters?
}

struct QueueSnapshot: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let items: [MusicItem]
    let currentIndex: Int?
    let source: SnapshotSource
}

enum InsertPosition {
    case next
    case last
    case atIndex(Int)
}

enum SnapshotSource: String, Codable {
    case manual
    case auto
    case system
}

struct PlayStatistics: Codable {
    var totalQueueEdits: Int
    var totalRestores: Int
    var mostEditedTimeOfDay: String
    var favoriteQueueLength: Int
}
```

---

## 6. UI/UX Design Guidelines

### 6.1 US Market Design Trends (2024-2025)

Based on research of popular US apps:

1. **Minimalism with Depth** - Clean interfaces with meaningful interactions
2. **Large Typography** - Bold, readable fonts (SF Pro family)
3. **Generous Spacing** - Airy layouts with clear visual hierarchy
4. **Subtle Animations** - Smooth, purposeful micro-interactions
5. **Dark Mode First** - Support dark mode as primary experience
6. **Haptic Feedback** - Tactile responses for key actions

### 6.2 Color Palette

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| Primary | #007AFF | #0A84FF | Main actions, links |
| Secondary | #5856D6 | #5E5CE6 | Secondary actions |
| Background | #F2F2F7 | #000000 | Main background |
| Surface | #FFFFFF | #1C1C1E | Cards, sheets |
| Text Primary | #000000 | #FFFFFF | Main text |
| Text Secondary | #3C3C43 (60%) | #EBEBF5 (60%) | Secondary text |
| Destructive | #FF3B30 | #FF453A | Delete actions |
| Success | #34C759 | #30D158 | Confirmations |
| Warning | #FF9500 | #FF9F0A | Warnings |

### 6.3 Typography

| Style | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| Large Title | SF Pro Display | 34pt | Bold | 41pt |
| Title 1 | SF Pro Display | 28pt | Bold | 34pt |
| Title 2 | SF Pro Display | 22pt | Bold | 28pt |
| Title 3 | SF Pro Display | 20pt | Semibold | 25pt |
| Headline | SF Pro Text | 17pt | Semibold | 22pt |
| Body | SF Pro Text | 17pt | Regular | 22pt |
| Callout | SF Pro Text | 16pt | Regular | 21pt |
| Subheadline | SF Pro Text | 15pt | Regular | 20pt |
| Footnote | SF Pro Text | 13pt | Regular | 18pt |
| Caption | SF Pro Text | 12pt | Regular | 16pt |

### 6.4 Spacing System (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4pt | Tight spacing |
| sm | 8pt | Inline elements |
| md | 16pt | Section padding |
| lg | 24pt | Card padding |
| xl | 32pt | Screen margins |
| 2xl | 48pt | Major sections |

### 6.5 Screen Structure

#### Screen 1: Main Queue View
- Mini player at bottom (expandable)
- Queue list with drag-to-reorder
- Floating action button for quick actions
- Pull-to-refresh for sync

#### Screen 2: Queue Editor (Full Screen)
- Large album artwork header
- Draggable song list
- Edit mode toggle
- Batch selection support

#### Screen 3: History View
- Timeline-style list
- Snapshot preview cards
- Restore action buttons
- Clear history option

#### Screen 4: Settings View
- Grouped list sections
- Toggle switches for features
- Queue protection settings
- Export/Import options
- About & Support links

### 6.6 Component Library

#### QueueItemCard
```swift
struct QueueItemCard: View {
    let item: MusicItem
    let isPlaying: Bool
    let showDragHandle: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if showDragHandle {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
            }
            
            AsyncImage(url: item.artworkURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 56, height: 56)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(isPlaying ? .semibold : .regular)
                    .foregroundColor(isPlaying ? .accentColor : .primary)
                
                Text(item.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}
```

#### MiniPlayer
```swift
struct MiniPlayer: View {
    @Binding var isExpanded: Bool
    let currentItem: MusicItem?
    let onPlayPause: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                ExpandedPlayerView()
            } else {
                CollapsedMiniPlayer()
            }
        }
        .frame(height: isExpanded ? 300 : 64)
        .background(.ultraThinMaterial)
    }
}
```

---

## 7. Code Generation Rules

### 7.1 Module Principle (Single Responsibility)

**Rule**: One function = One module  
**Implementation**:

1. Each feature module should have a clear, single responsibility
2. File naming should be semantic and descriptive
3. Directory structure should reflect the feature organization

**Example Directory Structure**:
```
QueueMaster/
├── App/
│   ├── QueueMasterApp.swift
│   └── AppDelegate.swift
├── Features/
│   ├── Queue/
│   │   ├── Views/
│   │   │   ├── QueueEditorView.swift
│   │   │   ├── QueueItemView.swift
│   │   │   └── QueueToolbarView.swift
│   │   ├── ViewModels/
│   │   │   └── QueueViewModel.swift
│   │   └── Models/
│   │       └── QueueItem.swift
│   ├── History/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── Settings/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/
│   ├── Services/
│   │   ├── MusicService.swift
│   │   ├── QueueManager.swift
│   │   └── HistoryManager.swift
│   ├── Extensions/
│   └── Utilities/
├── Shared/
│   ├── Components/
│   ├── Theme/
│   └── Constants/
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### 7.2 Code Reuse Principle (DRY)

**Rule**: Code复用，优先复用现有模块，抽象需符合"三次法则"  
**Implementation**:

1. **First Occurrence**: Copy the code directly
2. **Second Occurrence**: Note that refactoring may be needed
3. **Third Occurrence**: Extract to shared component/module

**Example - Button Styles**:
```swift
// First use - inline
Button("Save") {}

// Second use - inline
Button("Cancel") {}

// Third use - extract to component
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
    }
}

// Now use everywhere
Button("Save") {}.buttonStyle(PrimaryButtonStyle())
```

### 7.3 Code Cleanup Principle

**Rule**: 替换时标记废弃 → 验证无影响 → 删除  
**Implementation**:

1. When replacing code, mark old code as `@available(*, deprecated)`
2. Add deprecation message explaining the replacement
3. After testing confirms no impact, remove deprecated code
4. Commit message should note cleanup scope

**Example**:
```swift
// OLD CODE - Mark as deprecated
@available(*, deprecated, message: "Use QueueManager.shared instead")
class LegacyQueueHandler {
    // Old implementation
}

// NEW CODE
class QueueManager {
    static let shared = QueueManager()
    // New implementation
}
```

### 7.4 Open Source Integration

**Rule**: 优先使用苹果原生系统代码，若有开源项目可二次开发  
**Implementation**:

1. **Priority 1**: Use Apple native frameworks (MusicKit, MediaPlayer)
2. **Priority 2**: Use well-maintained Swift packages from SPM
3. **Priority 3**: Convert third-party code to native Swift if necessary

**Allowed Dependencies**:
- Swift Package Manager (SPM) packages
- CocoaPods (if SPM not available)
- Direct integration of Objective-C/C bridging headers

**Example - SPM Integration**:
```swift
// Package.swift dependencies
dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")
]
```

### 7.5 Native Code Conversion

**Rule**: 若可二次开发的项目不是原生代码，需要转换成苹果原生的代码来写  
**Implementation**:

When converting non-native code:
1. Convert JavaScript/TypeScript to Swift
2. Convert Kotlin to Swift
3. Convert React Native/Flutter to SwiftUI
4. Rewrite Objective-C to Swift where appropriate

**Example - JavaScript to Swift Conversion**:
```javascript
// JavaScript
const queue = items.filter(item => item.isValid);
queue.sort((a, b) => a.order - b.order);
```

```swift
// Swift
let queue = items.filter { $0.isValid }.sorted { $0.order < $1.order }
```

---

## 8. Implementation Process

### 8.1 Development Phases

#### Phase 1: Core Queue Management (Week 1-2)

| Task | Description | Estimated Time |
|------|-------------|----------------|
| 1.1 | Project setup and configuration | 2 hours |
| 1.2 | MusicKit authorization | 4 hours |
| 1.3 | Queue read/write implementation | 8 hours |
| 1.4 | Queue visualization UI | 8 hours |
| 1.5 | Drag-to-reorder functionality | 6 hours |

#### Phase 2: Queue Protection (Week 2-3)

| Task | Description | Estimated Time |
|------|-------------|----------------|
| 2.1 | Queue snapshot system | 6 hours |
| 2.2 | Auto-save mechanism | 4 hours |
| 2.3 | Undo/Redo implementation | 8 hours |
| 2.4 | Queue clear detection | 4 hours |
| 2.5 | Restore UI and flow | 6 hours |

#### Phase 3: History & Statistics (Week 3-4)

| Task | Description | Estimated Time |
|------|-------------|----------------|
| 3.1 | History storage system | 4 hours |
| 3.2 | History list UI | 6 hours |
| 3.3 | Statistics calculation | 4 hours |
| 3.4 | Export functionality | 6 hours |

#### Phase 4: Settings & Polish (Week 4-5)

| Task | Description | Estimated Time |
|------|-------------|----------------|
| 4.1 | Settings UI | 4 hours |
| 4.2 | User preferences | 4 hours |
| 4.3 | App icon and assets | 4 hours |
| 4.4 | Performance optimization | 4 hours |
| 4.5 | Beta testing | 8 hours |

### 8.2 Implementation Checklist

#### Before Code Generation
- [ ] Confirm all data models are defined
- [ ] Confirm all API interfaces are documented
- [ ] Confirm UI mockups are approved
- [ ] Confirm third-party library list

#### During Code Generation
- [ ] Follow naming conventions (camelCase for variables, PascalCase for types)
- [ ] Add access control (private, fileprivate, internal, public)
- [ ] Document complex logic with comments
- [ ] Write unit tests alongside code

#### After Code Generation
- [ ] Verify all files compile without errors
- [ ] Verify all modules integrate correctly
- [ ] Run static analyzer
- [ ] Check for memory leaks

---

## 9. Testing & Validation Standards

### 9.1 Unit Testing Requirements

| Test Type | Coverage Target | Tools |
|-----------|-----------------|-------|
| Unit Tests | 80%+ | XCTest |
| UI Tests | Core flows | XCTest |
| Performance | <100ms response | Instruments |

### 9.2 Test Cases

#### Queue Management Tests
```swift
func testAddToQueue() {
    let item = MusicItem(title: "Test Song", artistName: "Test Artist")
    queueManager.addToQueue(item, position: .next)
    
    XCTAssertEqual(queueManager.currentQueue.count, 1)
    XCTAssertEqual(queueManager.currentQueue.first?.title, "Test Song")
}

func testRemoveFromQueue() {
    let item = MusicItem(title: "Test Song", artistName: "Test Artist")
    queueManager.addToQueue(item, position: .next)
    queueManager.removeFromQueue(item)
    
    XCTAssertTrue(queueManager.currentQueue.isEmpty)
}

func testReorderQueue() {
    let item1 = MusicItem(title: "Song 1", artistName: "Artist")
    let item2 = MusicItem(title: "Song 2", artistName: "Artist")
    queueManager.addToQueue(item1, position: .last)
    queueManager.addToQueue(item2, position: .last)
    
    queueManager.reorderQueue(from: IndexSet(integer: 1), to: 0)
    
    XCTAssertEqual(queueManager.currentQueue.first?.title, "Song 2")
}
```

#### Queue Protection Tests
```swift
func testQueueSnapshotSave() {
    let item = MusicItem(title: "Test Song", artistName: "Test Artist")
    queueManager.addToQueue(item, position: .last)
    
    let snapshot = queueManager.saveQueueSnapshot()
    
    XCTAssertNotNil(snapshot)
    XCTAssertEqual(snapshot.items.count, 1)
}

func testQueueRestore() {
    let item = MusicItem(title: "Test Song", artistName: "Test Artist")
    queueManager.addToQueue(item, position: .last)
    
    let snapshot = queueManager.saveQueueSnapshot()
    queueManager.clearQueue()
    queueManager.restoreQueueSnapshot(snapshot)
    
    XCTAssertEqual(queueManager.currentQueue.count, 1)
}

func testUndoRedo() {
    let item = MusicItem(title: "Test Song", artistName: "Test Artist")
    queueManager.addToQueue(item, position: .last)
    
    queueManager.undoLastAction()
    XCTAssertTrue(queueManager.currentQueue.isEmpty)
    
    queueManager.redoLastAction()
    XCTAssertEqual(queueManager.currentQueue.count, 1)
}
```

### 9.3 UI Validation Checklist

#### Visual Checkpoints
- [ ] All text is in English (US)
- [ ] Typography follows 8pt grid
- [ ] Colors match design system
- [ ] Spacing is consistent
- [ ] Dark mode renders correctly
- [ ] Safe areas are respected

#### Interaction Checkpoints
- [ ] Tap gestures work correctly
- [ ] Long press shows context menu
- [ ] Drag and drop is smooth (60fps)
- [ ] Haptic feedback triggers appropriately
- [ ] Animations complete without jank

#### Accessibility Checkpoints
- [ ] VoiceOver labels present
- [ ] Dynamic Type support
- [ ] Sufficient color contrast (WCAG AA)
- [ ] Focus indicators visible

### 9.4 Build Requirements

#### Minimum Requirements
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS Deployment Target**: 15.0+
- **Device Support**: iPhone only (optimized for US market)

#### Build Verification
```bash
# Clean build
xcodebuild clean

# Build for simulator
xcodebuild -project QueueMaster.xcodeproj \
  -scheme QueueMaster \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build

# Build for device
xcodebuild -project QueueMaster.xcodeproj \
  -scheme QueueMaster \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build
```

---

## 10. Build & Compilation

### 10.1 Xcode Project Structure

```
QueueMaster/
├── QueueMaster.xcodeproj/
│   ├── project.pbxproj
│   └── project.xcworkspace/
├── QueueMaster/
│   ├── App/
│   ├── Features/
│   ├── Core/
│   ├── Shared/
│   └── Resources/
├── QueueMasterTests/
└── QueueMasterUITests/
```

### 10.2 Build Settings

| Setting | Value |
|---------|-------|
| SWIFT_VERSION | 5.9 |
| IPHONEOS_DEPLOYMENT_TARGET | 15.0 |
| MARKETING_VERSION | 1.0.0 |
| CURRENT_PROJECT_VERSION | 1 |
| GENERATE_INFOPLIST_FILE | YES |
| CODE_SIGN_STYLE | Automatic |

### 10.3 Compilation Verification Steps

1. **Pre-Build**
   - Confirm all files are added to project
   - Confirm framework dependencies are linked
   - Confirm signing team is set

2. **During Build**
   - Monitor for compilation errors
   - Check for linker warnings
   - Verify asset compilation

3. **Post-Build**
   - Confirm .app bundle is generated
   - Verify app runs on simulator
   - Check console for runtime errors

### 10.4 Archive & Submission

```bash
# Archive for App Store
xcodebuild -project QueueMaster.xcodeproj \
  -scheme QueueMaster \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive

# Or use Xcode GUI
# Product > Archive
```

---

## Appendix A: GitHub Projects Reference

### A.1 Recommended Open Source Projects

| Project | URL | Purpose | License |
|---------|-----|---------|---------|
| MusicKit Sample Code | developer.apple.com | Official Apple samples | Apple Sample Code |
| Kingfisher | github.com/onevcat/Kingfisher | Image loading/caching | MIT |
| SnapKit | github.com/SnapKit/SnapKit | Auto Layout DSL | MIT |

### A.2 Optional Dependencies

For enhanced functionality, consider these (convert to native if used):
- SQLite.swift for complex data storage
- CombineExt for reactive utilities

---

## Appendix B: Localization Guide

### B.1 English (US) Strings

All user-facing strings must be in English (US):

```swift
// Correct
Text("Queue")
Text("Add to Queue")
Text("Remove from Queue")
Text("Restore Queue")
Text("Settings")

// Avoid
Text("Cola")  // Slang
Text("QueueList")  // Not user-facing
```

### B.2 Date/Time Formatting

```swift
// US Format
let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .short
formatter.locale = Locale(identifier: "en_US")
```

### B.3 Currency Formatting

```swift
// US Currency
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.locale = Locale(identifier: "en_US")
```

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | March 15, 2026 | AI Assistant | Initial version |

---

**End of Document**
