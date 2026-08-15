# Yeknom UI Kit

`yeknom_ui_kit` 是 Yeknom 桌面工具共用的 Flutter Material 视觉基础库，只包含主题、
语义色和纯展示控件。

## 边界

- 只依赖 Flutter Material。
- 不包含 Riverpod、网络、存储、toast、文件系统或平台插件。
- 不包含品牌图片、字体、员工信息、内部地址和业务配置。
- 文案、图标、资源、状态值与回调均由宿主应用传入。

## 安装

```yaml
dependencies:
  yeknom_ui_kit:
    git:
      url: git@github.com:yozoe/yeknom-ui-kit.git
      ref: v0.1.0
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
      TextField(),
    ],
  ),
);
```

该仓库当前没有附带开源许可证；请按仓库所有者授予的权限使用。
