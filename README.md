# Yeknom UI Kit

`yeknom_ui_kit` 是 Yeknom 共用的 Flutter Material 视觉基础库，提供共享
Foundation，以及两套结构和密度不同的体验：面向管理后台与桌面工具的
Workbench、面向用户端应用的 App。

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
      ref: main
```

Workbench/App 双体验 API 尚未包含在 `v0.3.0` 中，因此未正式发布前使用
`main`。正式发布后，请将 `ref` 固定为首个包含双体验 API 的 release tag，
以获得可复现的依赖版本。

## 体验与入口

- `yeknom_foundation.dart`：只导出共享语义色、颜色组合、间距、圆角与 Tone。
- `yeknom_workbench.dart`：导出紧凑、信息密集的 Workbench 主题和现有管理后台控件。
- `yeknom_app.dart`：导出触控优先、内容导向的 App 主题与 App 页面组件。
- `yeknom_ui_kit.dart`：保留原有 API 和 `YeknomTheme` 行为，已有项目无需立即迁移。

新代码应按目标体验选择明确入口。管理后台或桌面工具：

```dart
import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_workbench.dart';

MaterialApp(
  theme: YeknomWorkbenchTheme.light(),
  darkTheme: YeknomWorkbenchTheme.dark(),
  themeMode: ThemeMode.system,
  home: const MyHomePage(),
);
```

用户端应用：

```dart
import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart';

MaterialApp(
  theme: YeknomAppTheme.light(),
  darkTheme: YeknomAppTheme.dark(),
  themeMode: ThemeMode.system,
  home: const MyHomePage(),
);
```

只使用共享 Foundation 时：

```dart
import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_foundation.dart';

final palette = YeknomPalette.fromPreset(
  YeknomColorPreset.sage,
  Brightness.light,
);
```

## 主题与颜色

明暗模式与颜色组合相互独立。内置 `workbench`、`cobalt`、`orchid`、
`graphite`、`obsidian`、`midnight`、`blackberry` 和 `sage` 八套组合，
原有工作台配色仍是默认值。三套近黑方案使用更接近纯黑的深色表面；护眼方案
使用暖灰绿表面，避免纯白和纯黑：

```dart
const preset = YeknomColorPreset.cobalt;

MaterialApp(
  theme: YeknomAppTheme.light(preset: preset),
  darkTheme: YeknomAppTheme.dark(preset: preset),
  themeMode: ThemeMode.system,
);
```

`YeknomWorkbenchTheme`、`YeknomAppTheme` 和兼容入口 `YeknomTheme` 都接受
相同的 `preset` 与 `palette` 参数。需要品牌定制时可传入完整的
`YeknomPalette`；同时指定两者时，以 `palette` 为准。

## 独立运行 Catalog

仓库包含一个可独立运行的组件 Catalog，支持 macOS 与 Web：

```bash
cd example
flutter pub get
flutter run -d macos
```

Web 预览可改用 `flutter run -d chrome`。Catalog 可以切换 Workbench/App
体验、系统/浅色/深色主题及颜色组合，并分别展示两套页面结构和公开控件。

在 macOS 上构建 release、安装到 `/Applications` 并启动 Catalog：

```bash
./install_macos.sh
```

脚本只会替换 Bundle ID 匹配的
`/Applications/Yeknom UI Kit Catalog.app`，并会拒绝同路径下的符号链接、
非目录或其他应用；代码签名和 Bundle ID 校验通过后才会启动新版本。

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

## Workbench 控件

- `YeknomSurface`：有边框的工作台面板。
- `YeknomSectionHeader`：图标、标题、描述和尾部操作。
- `YeknomStatusBadge`：带语义支持的状态徽标。
- `YeknomStateView`：可参数化的 empty/error 状态。
- `YeknomInfoRow`：详情对话框中的 label/value 行。
- `YeknomListCard`：统一选中、悬停、焦点、禁用和导航状态的列表卡片。
- `YeknomIconFrame`：统一尺寸和底色的图标容器。
- `YeknomTextField` / `YeknomSearchField`：通用输入和自带清空行为的搜索输入。
- `YeknomDropdown`：带统一字段轮廓、菜单密度和选项布局的表单下拉框。
- `YeknomButton` / `YeknomIconButton`：支持 filled、outlined、text 及 loading 状态。
- `YeknomDialog` / `YeknomDialogAction`：分区式响应对话框与危险操作样式。
- `YeknomSwitch` / `YeknomSwitchTile`：状态灯式紧凑开关与统一列表开关。
- `YeknomSegmentedTabs`：带轨道、选中填充和完整桌面交互状态的分段 Tab。
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

## App 组件

- `YeknomAppPage`：居中、可滚动且自适应页面宽度的用户端页面骨架。
- `YeknomAppHero`：用于页面首屏的品牌化 Hero 区域。
- `YeknomAppCard`：弱描边、柔和层级的内容卡片。
- `YeknomAppSection`：带标题、描述和操作的宽松内容分区。
- `YeknomAppActionTile`：用于设置、快捷入口和下一步操作的触控行。
- `YeknomAppSheet`：键盘感知、内容可滚动的 App Bottom Sheet。
- `YeknomButton` 与 `YeknomTextField`：由 App Theme 调整为更大的触控尺寸。
- `YeknomToast`：与 Workbench 共享通知行为，并跟随当前语义色。

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

未显式配置颜色时，Toast 会使用当前 `YeknomPalette` 的普通、成功、警告和错误
语义色，并自动选择高对比度文字色。`displayDuration`、`maxWidth` 和各状态颜色
仍可全局配置，单次调用也可以覆盖背景色和文字色；显式配置始终优先。调用时
找不到 Overlay 会直接返回，不会抛出异常。

从 `package:toast` 迁移时，移除原依赖并改为导入 UI Kit 即可继续使用兼容入口：

```dart
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

Toast.showSuccess('保存成功');
```

该仓库当前没有附带开源许可证；请按仓库所有者授予的权限使用。
