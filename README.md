# flutter_downloader_ohos

<p align="center">
  <h1 align="center"> <code>flutter_downloader_ohos</code> </h1>
</p>

本项目基于 [flutter_downloader](https://pub.dev/packages/flutter_downloader) 开发，提供了 OpenHarmony 平台的下载管理功能。

## 1. 安装与使用

### 1.1 安装方式

本项目为联合插件，需要与原版 [flutter_downloader](https://pub.dev/packages/flutter_downloader) 配合使用。

在 pubspec.yaml 中添加以下依赖：

```yaml
dependencies:
  flutter_downloader: ^1.12.0
  flutter_downloader_ohos: ^1.12.0
```

执行命令

```bash
flutter pub get
```

### 1.2 使用案例

使用案例详见 [example](example/lib/main.dart)。

## 2. API

> [!TIP] 使用方法与原版 `flutter_downloader` 一致，效果对标 iOS 或 Android。

### FlutterDownloader API

| Name                | Description                         | ohos Support |
|---------------------|-------------------------------------|--------------|
| initialize          | 初始化插件。必须在调用其他方法前调用 | ✅ |
| enqueue             | 创建新下载任务并返回其唯一标识符 | partially |
| loadTasks           | 从SQLite数据库加载所有下载任务 | ✅ |
| loadTasksWithRawQuery | 通过原始SQL查询加载任务 | ✅ |
| cancel              | 取消指定的下载任务 | ✅ |
| cancelAll           | 取消所有已排队/正在运行的任务 | ✅ |
| pause               | 暂停正在运行的下载任务 | ✅ |
| resume              | 使用新配置恢复已暂停的任务 | ✅ |
| retry               | 重试失败的下载任务 | ✅ |
| remove              | 从数据库删除任务并可选删除文件 | ✅ |
| open                | 打开下载的文件 | ✅ |
| registerCallback    | 注册下载状态更新回调 | ✅ |

## 3. 属性

### DownloadTaskStatus

| Name       | Description              | ohos Support |
|------------|--------------------------|--------------|
| undefined  | 任务状态未知或已损坏      | ✅ |
| enqueued   | 任务已排队但尚未运行      | ✅ |
| running    | 任务正在执行中            | ✅ |
| complete   | 任务已成功完成            | ✅ |
| failed     | 任务执行失败              | ✅ |
| canceled   | 任务已取消且无法恢复      | ✅ |
| paused     | 任务已暂停且可恢复        | ✅ |

### DownloadTask

| Name          | Description               | ohos Support |
|---------------|---------------------------|--------------|
| taskId        | 此任务的唯一标识符        | ✅ |
| status        | 任务当前状态              | ✅ |
| progress      | 下载进度（0-100）         | ✅ |
| url           | 文件下载的源地址          | ✅ |
| filename      | 下载文件的本地名称        | ✅ |
| savedDir      | 文件保存的绝对路径        | ✅ |
| timeCreated   | 任务创建时间戳            | ✅ |
| allowCellular | 是否允许使用蜂窝网络下载  | ✅ |

## 4.截图

![](./example/screenshot/1.jpg)
