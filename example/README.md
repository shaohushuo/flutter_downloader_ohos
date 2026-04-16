# flutter_downloader_ohos_example 📱

演示如何使用 `flutter_downloader_ohos` 插件。

## 🚀 运行示例

```bash
cd example
flutter pub get
flutter run
```

## 📋 功能说明

本示例展示了 `flutter_downloader_ohos` 的核心功能：

- **🔌 初始化插件** — 在应用启动时调用 `FlutterDownloader.initialize()`
- **📥 创建下载任务** — 通过 URL 创建新的下载任务
- **⏯️ 管理下载任务** — 暂停、恢复、重试、取消下载
- **📊 查看下载进度** — 实时监听下载状态和进度更新
- **📂 打开已下载文件** — 下载完成后打开文件

## 🗂️ 项目结构

```
example/
├── lib/
│   ├── main.dart       # 应用入口，初始化插件
│   └── home_page.dart  # 主页面，下载管理功能
├── pubspec.yaml        # 项目依赖
└── README.md           # 本文件
```
