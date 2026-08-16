# Yeknom UI Kit

`yeknom_ui_kit` 是 Yeknom 桌面工具共用的 Flutter Material 视觉基础库，只包含主题、
语义色、展示控件和轻量 Overlay 通知组件。

## 边界

- 只依赖 Flutter Material。
- 不包含 Riverpod、网络、存储、文件系统或平台插件。
- 不包含品牌图片、字体、员工信息、内部地址和业务配置。
- 文案、图标、资源、状态值与回调均由宿主应用传入。

## 安装

```yaml
dependencies:
  yeknom_ui_kit:
    git:
      url: git@github.com:yozoe/yeknom-ui-kit.git
      ref: v0.3.0
```

## 主题

```dart
import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

MaterialApp(
  theme: YeknomTheme.light(),
  darkTheme: YeknomTheme.dark(),
  themeMode: ThemeMode.system,
  home: const MyHomePage(),
);
```

## 独立运行 Catalog

仓库包含一个可独立运行的组件 Catalog，支持 macOS 与 Web：

```bash
cd example
flutter pub get
flutter run -d macos
```

Web 预览可改用 `flutter run -d chrome`。Catalog 可以切换系统、浅色和深色主题，
并展示语义色、间距、圆角、表单、状态与全部公开控件。

通过语义色而不是硬编码颜色表达界面状态：

```dart
final palette = YeknomPalette.of(context);

YeknomStatusBadge(
  label: '构建完成',
  color: palette.ack,
  semanticsLabel: '构建状态：构建完成',
  liveRegion: true,
);
```

## 通用控件

- `YeknomSurface`：有边框的工作台面板。
- `YeknomSectionHeader`：图标、标题、描述和尾部操作。
- `YeknomStatusBadge`：带语义支持的状态徽标。
- `YeknomStateView`：可参数化的 empty/error 状态。
- `YeknomInfoRow`：详情对话框中的 label/value 行。
- `YeknomIconFrame`：统一尺寸和底色的图标容器。
- `YeknomTextField` / `YeknomSearchField`：通用输入和自带清空行为的搜索输入。
- `YeknomButton` / `YeknomIconButton`：支持 filled、outlined、text 及 loading 状态。
- `YeknomSwitch` / `YeknomSwitchTile`：通用开关与列表开关。
- `YeknomSegmentedTabs`：基于 Material `SegmentedButton` 的分段 Tab。
- `YeknomSkeleton` / `YeknomLoadingView`：局部骨架占位和整体加载状态。
- `YeknomToast`：支持普通、成功、警告、错误、堆叠和独立退场动画的 Overlay 通知。

```dart
YeknomSurface(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: const [
      YeknomSectionHeader(
        icon: Icons.source_outlined,
        title: 'Git 分支',
        description: '选择需要构建的来源分支',
      ),
      SizedBox(height: YeknomSpacing.lg),
      YeknomTextField(),
    ],
  ),
);
```

## Toast 通知

优先通过 `navigatorKey` 提供全局 Overlay：

```dart
MaterialApp(
  navigatorKey: YeknomToast.navigatorKey,
  home: const MyHomePage(),
);

YeknomToast.show('普通消息');
YeknomToast.showSuccess('保存成功');
YeknomToast.showWarning('请检查输入');
YeknomToast.showError('保存失败');
```

如果宿主应用已经使用自己的 `navigatorKey`，也可以在 Navigator 的 Overlay 下方初始化：

```dart
YeknomToast.init(context);
```

`displayDuration`、`maxWidth` 和各状态默认颜色均可全局配置，单次调用也可以覆盖背景色和文字色。
调用时找不到 Overlay 会直接返回，不会抛出异常。

从 `package:toast` 迁移时，移除原依赖并改为导入 UI Kit 即可继续使用兼容入口：

```dart
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

Toast.showSuccess('保存成功');
```

该仓库当前没有附带开源许可证；请按仓库所有者授予的权限使用。
