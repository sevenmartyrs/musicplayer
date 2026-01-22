# GitHub Actions Workflows

本目录包含用于构建音乐播放器应用的 GitHub Actions workflows。

## Workflows

### 1. `ios.yml` - iOS 构建
单独构建 iOS 应用。

**触发条件**：
- 仅手动触发

**构建产物**：
- `ios-build.zip` - 未签名的 iOS 应用

**启用代码签名**：
在 workflow 中将 `if: false` 改为 `if: true`，并在 GitHub Secrets 中配置：
- `CERTIFICATE_BASE64` - Base64 编码的证书
- `CERTIFICATE_PASSWORD` - 证书密码
- `PROVISIONING_PROFILE_BASE64` - Base64 编码的 Provisioning Profile
- `KEYCHAIN_PASSWORD` - 钥匙串密码

### 2. `android.yml` - Android 构建
单独构建 Android 应用。

**触发条件**：
- 仅手动触发

**构建产物**：
- `android-apk` - APK 文件
- `android-appbundle` - App Bundle 文件

### 3. `build-all.yml` - 全平台构建
构建所有支持的平台（Android、iOS、Linux、Windows、macOS）。

**触发条件**：
- 仅手动触发

**构建产物**：
- Android APK 和 AAB
- iOS 应用（未签名）
- Linux 可执行文件
- Windows 可执行文件
- macOS 应用

## 使用方法

### 手动触发构建
1. 进入 GitHub 仓库的 Actions 页面
2. 选择对应的 workflow
3. 点击 "Run workflow" 按钮
4. 选择分支并运行

## 配置要求

### iOS 代码签名（可选）
如需构建可发布的 iOS 应用：

1. 导出证书和 Provisioning Profile：
   ```bash
   # 导出证书
   base64 -i certificate.p12 | pbcopy

   # 导出 Provisioning Profile
   base64 -i profile.mobileprovision | pbcopy
   ```

2. 在 GitHub 仓库设置中添加 Secrets：
   - Settings → Secrets and variables → Actions → New repository secret
   - 添加上述四个变量

### Android 签名（可选）
如需构建签名的 Android 应用，需要在 `android/app/build.gradle` 中配置签名信息，并在 GitHub Secrets 中添加：
- `KEYSTORE_FILE` - Base64 编码的 keystore 文件
- `KEYSTORE_PASSWORD` - Keystore 密码
- `KEY_ALIAS` - Key 别名
- `KEY_PASSWORD` - Key 密码

## 构建缓存
Workflows 使用了缓存功能来加速构建：
- Flutter SDK 缓存
- Gradle 依赖缓存（Android）

清理缓存：
1. 进入 GitHub 仓库的 Actions 页面
2. 点击 "Caches"
3. 选择并删除缓存

## 故障排查

### 构建失败
1. 查看 Actions 日志获取详细错误信息
2. 检查依赖版本是否兼容
3. 验证 GitHub Secrets 配置是否正确

### iOS 构建超时
- 使用 `--no-codesign` 跳过代码签名
- 检查 CocoaPods 依赖是否正确安装

### Android 构建失败
- 检查 Java 版本（需要 JDK 17）
- 验证 Gradle 配置
- 检查 Android SDK 版本

## 本地测试

在推送代码前，可以在本地测试构建：

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (需要 macOS)
flutter build ios --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## 相关链接
- [Flutter 文档](https://docs.flutter.dev/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)