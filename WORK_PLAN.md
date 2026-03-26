# Work Plan

## Project

- Name: `Sigenerator`
- Path: `D:\road_creator`
- Focus:
  - 轨道交通导向牌编辑器继续对齐 `vi-tool`
  - 自定义线路 / 自定义 SVG / 颜色系统打通
  - 保持项目级保存、恢复、拖拽复用和静态分析稳定

## Goals

- 让自定义线路同时出现在“线路”和“经典线路”素材分组中。
- 让自定义线路的视觉风格分别贴合对应分组，而不是只在一个分组里做特例。
- 把颜色系统从“固定色块”升级为“预设色 + HEX 输入 + 取色器”。
- 在经典线路选项卡下增加“自定义元素”入口，形成完整的本地 SVG 上传、保存、复用、编辑联动。
- 明确并补完顶部“上海地铁”城市按钮的职责；若只是展示态，则改成真正可切换的样式入口。

## Constraints

- 不破坏现有 `MetroGuideProject` 文件兼容性。
- 自定义素材必须跟随项目保存并在重新打开后继续可用。
- 素材库拖拽插入、复制、编辑、删除逻辑必须保持正确。
- 维持 `flutter analyze --no-pub` 可通过。

## Implementation Strategy

### 1. 自定义线路双分组化

- 为自定义线路补充目标分组概念，支持 `GuideItemType.line` 和 `GuideItemType.clss`。
- 在工具栏中同时为“线路”和“经典线路”显示“自定义线路”入口。
- 自定义素材区按分组展示，避免所有自定义线路都堆到一个分组中。
- 编辑已有自定义线路时，保持原分组不丢失。

### 2. 自定义线路样式统一

- `line` 分组的自定义线路预览遵循普通线路徽标风格。
- `clss` 分组的自定义线路预览保持经典线路条带 / 徽标风格。
- 工具栏卡片、画布元素、拖拽反馈三处统一渲染逻辑。
- 避免把 `clss@custom.svg` 写死为唯一自定义线路类型，改为统一的自定义线路渲染分支。

### 3. 完整颜色系统

- 复用现有 `ColorPickerDialog`，接入轨交编辑器。
- 保留常用预设色，新增“更多颜色”入口。
- 支持 HEX 文本输入、实时预览、结果回填。
- 应用于：
  - 自定义线路
  - 线路 / 经典线路颜色编辑
  - 色带元素

### 4. 自定义 SVG 联动系统

- 在经典线路分组下增加“自定义元素”入口。
- 允许上传本地 SVG，并为其指定归属分组、名称和默认颜色策略。
- 自定义 SVG 进入素材库后可重复拖入。
- 画布中的实例编辑不应破坏素材库原型。
- 项目保存时写入 SVG 内容，避免仅依赖本地绝对路径。

### 5. 顶部城市按钮补完

- 明确当前“上海地铁”按钮是否仅展示城市名。
- 若按钮无实际功能，则改为可点击的“城市 / 风格”选择入口。
- 城市切换至少联动：
  - 顶部显示文案
  - 默认背景色
  - 自定义线路默认命名和默认配色
- 如果暂不做跨城市素材切换，需在代码和计划中明确范围。

## Task Board

| ID | Task | Status | Notes |
| --- | --- | --- | --- |
| M1 | 梳理轨交编辑器当前实现与缺口 | Completed | 已确认自定义线路仅在 `clss`、颜色系统仅预设色、城市按钮未形成完整联动。 |
| M2 | 建立 `WORK_PLAN.md` 并作为后续执行基线 | Completed | 当前文件即本轮执行基线。 |
| M3 | 自定义线路同时支持 `line` / `clss` | Completed | 工具栏双分组入口、对话框按分创建、渲染层区分样式。 |
| M4 | 统一自定义线路在工具栏 / 画布 / 拖拽中的风格 | Completed | line 分组用徽标风格、clss 用条带风格；新增自定义素材删除按钮和分割线。 |
| M5 | 接入完整取色器系统 | Completed | 已接入预设色、HEX 与取色器按钮，覆盖自定义线路、元素改色与色带编辑。 |
| M6 | 完成经典线路下的自定义 SVG 上传与复用联动 | Pending | 需要补元数据、导入流程、素材库映射。 |
| M7 | 补完顶部城市按钮作用 | Pending | 至少让按钮具备真实交互和样式联动。 |
| M8 | 跑静态分析并清理告警 | Completed | `flutter analyze --no-pub` 通过，No issues found!。 |
| M9 | 更新 `WORK_LOG.md` 记录本轮成果 | Pending | 在主要功能闭合后更新。 |

## Detailed Design Notes

### Data Model

- `MetroGuideItem`
  - 继续保留 `customSvgContent`
  - 补充自定义素材名称展示所需字段时优先复用 `customText`
  - 自定义线路通过 `type + fileName` 共同区分样式
- `MetroGuideProject`
  - `customAssets` 继续作为素材库原型列表
  - 画布中的实例继续保存在 `items`

### File Targets

- `lib/pages/metro_guide_editor_page.dart`
  - 对话框流程
  - 自定义线路 / SVG 导入逻辑
  - 顶部城市按钮联动
- `lib/widgets/metro_guide_toolbar.dart`
  - 双分组入口
  - 自定义素材分区
- `lib/widgets/metro_guide_toolbar_item.dart`
  - 工具栏预览风格统一
- `lib/widgets/metro_guide_item.dart`
  - 画布渲染统一
- `lib/widgets/metro_guide_canvas.dart`
  - 保证实例复制 / 插入时保留自定义字段
- `lib/models/metro_guide_models.dart`
  - 如有必要补充最小元数据字段

## Acceptance Criteria

- 可以在“线路”里创建自定义线路，并以普通线路风格显示。
- 可以在“经典线路”里创建自定义线路，并以经典线路风格显示。
- 两种自定义线路都能被拖入画布、复制、编辑、删除、保存、重新打开。
- 颜色既可从预设选择，也可通过取色器 / HEX 自定义。
- 经典线路分组下支持导入本地 SVG，并能进入素材库复用。
- 顶部城市按钮不再是疑似未完成状态。
- `flutter analyze --no-pub` 通过。

## Update Rules

- 每完成一个任务，立即更新本文件 `Task Board` 的 `Status`。
- 如果实现范围发生变化，在 `Notes` 中追加原因。
- 功能完成后再同步更新 `WORK_LOG.md`，避免日志先于代码。

## Current Execution

- Current focus: `M6 自定义 SVG 上传与复用联动`
- Last completed: `M4 自定义线路风格统一`
- Next after that: `M7 顶部城市按钮补完`
