## Unreleased

- 新增工作台、钴蓝、兰紫和石墨四套 `YeknomColorPreset` 颜色组合。
- 增加黑曜、午夜和紫黑三套近黑背景颜色组合。
- 增加一套避免纯白、纯黑表面的 `sage` 护眼颜色组合。
- `YeknomTheme` 支持独立组合颜色预设与浅色、深色模式，并保持原有默认配色兼容。
- Catalog 增加颜色组合切换和即时预览。
- Toast 未显式配置颜色时跟随当前语义色，并保留静态颜色覆盖能力。
- 改善低强调文字对比度及短窗口下的 Catalog 侧栏滚动。
- 新增统一风格的 `YeknomListCard`、`YeknomDropdown`、`YeknomDialog` 和
  `YeknomDialogAction`，覆盖交互状态、表单校验、响应式布局和危险操作。
- 重绘 `YeknomSegmentedTabs` 为紧凑轨道式 Tab，以单一选中填充强化层级，
  并补齐悬停、焦点、禁用和横向滚动状态。
- 重绘 `YeknomSwitch` 为紧凑状态灯式开关，并让 `YeknomSwitchTile` 复用同一
  控件，统一轨道、滑块、焦点和禁用状态。
- 补齐交互组件的样式透传、禁用态、拖动、键盘与读屏语义、窄窗口溢出回归
  覆盖，并保持 Flutter 3.32.1 兼容。
- Catalog 总览页交互示例改用 `YeknomTextField`、`YeknomSegmentedTabs` 和
  `YeknomButton`，与组件页保持一致。

## 0.3.0

- 将 `toast` 1.0.1 的 Overlay 通知能力迁入 UI Kit，新增 `YeknomToast`。
- 保留 `Toast` 兼容 API，现有调用方迁移依赖后无需改写调用代码。
- Catalog 增加普通、成功、警告和错误 Toast 的交互示例。

## 0.2.4

- `YeknomSearchField` 透传输入文本样式，便于紧凑工具栏保持现有字号。

## 0.2.3

- `YeknomButton` 同时支持 `label` 和 Material 风格的 `child` 参数，便于等价迁移现有按钮。

## 0.2.2

- `YeknomIconButton` 透传尺寸、密度、颜色和布局参数，并允许无 tooltip 的装饰性按钮。

## 0.2.1

- `YeknomSwitch` 透传 `materialTapTargetSize`，便于保持紧凑工具栏布局。

## 0.2.0

- 增加可在 macOS 与 Web 独立运行的组件 Catalog example。
- 增加输入框、搜索框、按钮、图标按钮、Switch、分段 Tab、Skeleton 和 loading 组件。
- 增加统一的 Switch 主题。

## 0.1.0

- 提供浅色与深色 `YeknomPalette`、完整 Material 3 `YeknomTheme`。
- 提供 surface、section header、status badge、state view、info row 和 icon frame。
- 增加主题映射、交互、语义和窄布局测试。
