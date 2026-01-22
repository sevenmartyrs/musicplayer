# AGENTS.md - 音乐播放器项目

## 项目概述

这是一个基于 Flutter 开发的跨平台音乐播放器应用，支持 Android、iOS、Linux、macOS 和 Windows 平台。

### 主要功能
- 本地音乐文件扫描和播放
- 音乐元数据解析（艺术家、专辑、时长、封面）
- 播放列表管理
- 播放历史记录
- 专辑封面显示
- 歌词显示
- 睡眠定时器
- 随机播放和循环模式
- 设置页面（扫描、自动更新、高品质音频、均衡器）

### 技术栈
- **框架**: Flutter (SDK ^3.10.4)
- **音频播放**: just_audio ^0.9.40
- **音频会话**: audio_session ^0.1.25
- **状态管理**: Provider ^6.1.2
- **数据持久化**: sqflite ^2.3.3, shared_preferences ^2.2.3
- **权限管理**: permission_handler ^11.3.1
- **文件路径**: path_provider ^2.1.4, path ^1.9.0
- **元数据解析**: metadata_god ^1.1.0 (Rust FFI)
- **目标平台**: Java 17, Kotlin JVM 17

### 项目架构
```
lib/
├── main.dart                 # 应用入口，主状态管理
├── models/                   # 数据模型
│   ├── song.dart            # 歌曲模型
│   ├── player_state.dart    # 播放器状态
│   ├── lyric.dart           # 歌词模型
│   ├── play_history.dart    # 播放历史
│   └── playlist.dart        # 播放列表
├── pages/                    # 页面组件
│   ├── library_page.dart    # 乐库页面
│   ├── playlist_page.dart   # 播放列表页面
│   ├── playlists_page.dart  # 播放列表管理
│   ├── history_page.dart    # 历史记录页面
│   ├── settings_page.dart   # 设置页面
│   ├── now_playing_page.dart # 正在播放页面
│   └── equalizer_page.dart  # 均衡器页面
├── providers/                # 状态管理
│   └── player_provider.dart # 播放器状态提供者
├── services/                 # 业务逻辑
│   ├── music_scanner.dart   # 音乐扫描服务
│   ├── music_scanner_isolate.dart # 音乐扫描 Isolate
│   ├── song_database.dart   # 歌曲数据库
│   ├── cover_cache.dart     # 封面缓存
│   ├── metadata_parser.dart # 元数据解析
│   ├── lyric_service.dart   # 歌词服务
│   ├── audio_service.dart   # 音频服务
│   └── persistence_service.dart # 持久化服务
└── widgets/                  # 通用组件
    ├── bottom_nav_bar.dart  # 底部导航栏
    └── player_bar.dart      # 播放器栏
```

## 构建和运行

### 环境要求
- Flutter SDK 3.10.4 或更高版本
- Dart SDK 3.10.4 或更高版本
- Android Studio / Xcode / VS Code
- 对于 Android：Java 17, Android SDK 33+
- 对于 iOS：Xcode 14.0+

### 常用命令

#### 安装依赖
```bash
flutter pub get
```

#### 运行应用
```bash
# 调试模式运行（连接设备）
flutter run

# 指定设备运行
flutter run -d <device_id>

# 查看可用设备
flutter devices
```

#### 构建应用
```bash
# Android APK
flutter build apk

# Android App Bundle (推荐用于发布)
flutter build appbundle

# iOS
flutter build ios

# Linux
flutter build linux

# macOS
flutter build macos

# Windows
flutter build windows
```

#### 安装到设备
```bash
# 安装到指定设备
flutter install -d <device_id>
```

#### 清理构建
```bash
flutter clean
```

#### 检查依赖更新
```bash
flutter pub outdated
```

#### 运行测试
```bash
flutter test
```

#### 代码分析
```bash
flutter analyze
```

### Android 构建配置
- Java 版本: 17
- Kotlin JVM 目标: 17
- 最小 SDK: 21 (Android 5.0)
- 目标 SDK: 34 (Android 14)

## 开发约定

### 代码风格
- 使用 `flutter_lints` 进行代码检查
- 遵循 Flutter 官方代码风格指南
- 使用 `const` 构造函数优化性能
- 使用 `UnmodifiableListView` 保护不可变数据

### 状态管理
- 使用 Provider 模式进行状态管理
- 状态变更通过 `setState` 或 Provider 的 `notifyListeners()`
- 避免在 `build()` 方法中执行耗时操作
- 使用 `addPostFrameCallback` 延迟执行初始化操作

### 性能优化
- 使用 Isolate 进行后台文件扫描
- 使用 `compute()` 执行 CPU 密集型任务
- 延迟初始化 MetadataGod（在扫描时才初始化）
- 使用缓存机制（封面缓存、数据库缓存）
- 减少不必要的 `setState` 调用

### 数据持久化
- 使用 SQLite (sqflite) 存储歌曲数据
- 使用 SharedPreferences 存储用户设置
- 封面图片缓存到本地文件系统

### 数据库操作
- 使用单例模式的 `SongDatabase`
- 所有数据库操作都是异步的
- 支持增量扫描（通过 `lastModified` 时间戳）

### 权限处理
- Android 13+ 使用 `READ_MEDIA_AUDIO`
- Android 12 及以下使用 `READ_EXTERNAL_STORAGE`
- 使用 `permission_handler` 统一处理权限请求

### 错误处理
- 使用 try-catch 捕获异常
- 使用 `debugPrint` 输出调试信息
- UI 层显示用户友好的错误提示

### 文件命名
- Dart 文件使用小写加下划线: `music_scanner.dart`
- 类名使用大驼峰: `MusicScanner`
- 私有成员使用下划线前缀: `_localSongs`
- 常量使用小写加下划线: `_supportedFormats`

### 目录结构约定
- `models/`: 数据模型类
- `pages/`: 页面级组件
- `providers/`: Provider 状态管理
- `services/`: 业务逻辑服务
- `widgets/`: 可复用组件

### Git 提交约定
- 使用清晰的提交信息
- 提交前运行 `flutter analyze` 检查代码
- 提交前运行 `flutter test` 确保测试通过

## 已知问题和限制

### 均衡器功能
- 当前均衡器页面只有 UI，没有实际功能实现
- `just_audio` 不支持均衡器，需要通过原生平台实现
- Android 需要使用 `android.media.audiofx.Equalizer`
- iOS 需要使用 `AVAudioEngine` 的 EQ 节点

### Web 平台
- `metadata_god` 使用 Rust FFI，不支持 Web 平台
- 如需支持 Web，需要替换为纯 Dart 实现的元数据解析库

### 高品质音频
- 当前只有设置开关，未实际应用到音频播放
- 需要在 `PlayerProvider` 中配置音频质量参数

## 开发注意事项

### 启动性能优化
- 应用启动时立即显示主界面（空状态）
- 后台并行初始化数据库和加载歌曲
- 延迟 MetadataGod 初始化到扫描时
- 避免在 `build()` 方法中执行耗时操作

### 内存管理
- 使用 `UnmodifiableListView` 防止意外修改
- 及时释放不再使用的资源
- 注意 Isolate 的生命周期管理

### 跨平台兼容性
- 使用条件编译处理平台特定代码
- 测试所有支持的平台
- 注意不同平台的权限模型差异

### 调试技巧
- 使用 `flutter run --verbose` 查看详细日志
- 使用 `flutter doctor` 检查开发环境
- 使用 `flutter logs` 查看设备日志
- 使用 DevTools 进行性能分析

## 依赖说明

### 核心依赖
- **just_audio**: 音频播放核心库
- **audio_session**: 音频会话管理（处理音频焦点、中断等）
- **provider**: 状态管理
- **sqflite**: SQLite 数据库
- **shared_preferences**: 简单键值对存储
- **permission_handler**: 权限请求
- **path_provider**: 获取系统路径
- **metadata_god**: 音频元数据解析（Rust FFI）

### 开发依赖
- **flutter_test**: Flutter 测试框架
- **flutter_lints**: Dart 代码检查规则

## 平台特定配置

### Android
- 最低 SDK: 21
- 目标 SDK: 34
- Java 版本: 17
- Kotlin 版本: 1.9+
- 权限: `READ_MEDIA_AUDIO` (Android 13+) 或 `READ_EXTERNAL_STORAGE` (Android 12-)

### iOS
- 最低版本: iOS 12.0
- 使用 Xcode 14.0+ 构建
- 权限: `NSAppleMusicUsageDescription` 和 `NSPhotoLibraryUsageDescription`

### Linux
- 需要 libmpv 或 libsox 作为音频后端
- 需要安装必要的系统库

### macOS
- 最低版本: macOS 10.14
- 需要 Xcode 14.0+ 构建
- 需要沙盒权限配置

### Windows
- 需要 Visual Studio 2019 或更高版本
- 需要 Windows 10 SDK

## 测试策略

### 单元测试
- 测试数据模型
- 测试服务层逻辑
- 测试工具函数

### 集成测试
- 测试页面交互
- 测试状态管理
- 测试数据库操作

### Widget 测试
- 测试 UI 组件
- 测试用户交互
- 测试布局渲染

## 发布流程

### Android
1. 配置签名密钥
2. 更新 `version` 和 `buildNumber`
3. 运行 `flutter build appbundle`
4. 上传到 Google Play Console

### iOS
1. 配置签名证书和 Provisioning Profile
2. 更新 `version` 和 `buildNumber`
3. 运行 `flutter build ios`
4. 使用 Xcode 上传到 App Store Connect

## 资源链接

- [Flutter 官方文档](https://docs.flutter.dev/)
- [just_audio 文档](https://pub.dev/packages/just_audio)
- [Provider 文档](https://pub.dev/packages/provider)
- [metadata_god 文档](https://pub.dev/packages/metadata_god)