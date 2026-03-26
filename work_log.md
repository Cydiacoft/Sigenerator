# Work Log

## Project

- Name: `Sigenerate`
- Path: `D:\road_creator`
- Stack: Flutter Windows desktop
- Focus:
  - 轨道交通导向牌编辑
  - 道路导向牌 / 路标元素编辑

## 2026-03-22

### 轨道交通编辑器整理

- 完成轨道交通编辑器主流程整合。
- 将首页入口拆分为轨道交通与道路编辑两个入口。
- 补齐轨交模板、导向牌编辑和项目文件管理的基础能力。

### 项目文件能力

- 增加项目保存、另存为、打开等基础文件流程。
- 补充项目元数据结构和 JSON 序列化支持。

## 2026-03-26

### 轨道交通部分重构

- 参考 `vi-tool` 重构轨道交通导向牌编辑流程。
- 接入 `vi-tool` 风格的 SVG 素材与横向拼接画布。
- 重写轨交素材库、画布、元素项与间距逻辑。
- 修正入口逻辑，避免旧模板页影响实际使用流程。

### README 与仓库整理

- README 按更简洁的仓库风格重写并精简。
- 已将阶段性成果提交并推送到 GitHub。

### 静态分析清理

- 清理未使用 import、未使用方法、冗余变量和废弃 API。
- 移除临时参考目录对分析结果的污染。
- `dart analyze` 已清到无报错状态。

### 道路编辑器重构

- 参考 `https://k.guc1010.top/Sig/lupai/` 重构道路编辑器。
- 将旧的模板式流程改为：
  - 路口配置
  - 四向预览
  - 路标元素库
- 重写 `lib/pages/road_editor_page.dart`，统一页面结构。
- 重写 `lib/models/intersection_scene.dart`，统一四方向数据结构，并新增 `signIds` 挂接能力。
- 重写 `lib/models/traffic_sign.dart` 与 `lib/signs/gb5768_signs.dart`，按 `GB 5768.2-2022` 整理常用禁令、警告、指示、指路、信息类元素。
- 重写 `lib/painters/road_sign_painter.dart` 与 `lib/painters/traffic_sign_painter.dart`，让预览根据方向、道路类型、地点类型、路口形状和已挂接路标动态绘制。
- 删除旧的 `lib/widgets/home_page.dart`，避免旧道路逻辑继续干扰当前结构。

### 道路编辑器规则约束

- 普通道路导向牌：蓝底白字。
- 高速道路导向牌：绿底白字。
- 景区导向牌：棕底白字。
- 路标元素按 `GB 5768.2-2022` 的常用颜色与形状约束整理。

### 道路编辑器 SVG 素材优先改造

- 为道路端新增 `assets/road_signs/` 本地 SVG 素材目录。
- 常用禁令、警告、指示、信息类路标开始切换为本地 SVG 资产渲染。
- `TrafficSign` 模型新增 `assetPath`，支持素材优先显示 SVG。
- 新增 `lib/widgets/road_sign_glyph.dart`，统一道路路标在素材库和预览中的显示组件。
- 道路端素材库不再默认依赖手绘近似图标，优先走 `flutter_svg`。
- 保留手绘 painter 作为 fallback，便于后续逐步补齐标准图版。

### 道路牌面比例与布局校正

- 重做 `lib/painters/road_sign_painter.dart` 的牌面分区比例。
- 顶部信息带压缩为更薄的标题带，减少 UI 卡片感。
- 主信息区扩大，通往地点提升为第一视觉层级。
- 道路名称下沉为第二层级，并增加分隔线增强层次。
- 方向箭头区独立成块，比例更接近真实道路导向牌。
- 底部辅助信息带改为更克制的说明区，弱化对主体信息的干扰。

### 轨道交通编辑器自定义能力扩展

- 为轨道交通编辑器新增“自定义线路”能力。
- 在 `clss` 分类下增加自定义经典线路入口，支持：
  - 自定义线路编号
  - 自定义线路颜色
  - 自定义线路名称
- 自定义线路会作为可重复使用的素材进入轨交素材库，并可继续拖入画布。

- 为 `oth` 分类新增“导入本地 SVG”能力。
- 支持从本地选择 `.svg` 文件导入素材库。
- 导入后的 SVG 可直接加入当前画布，并可从素材库重复拖入。

- 扩展轨交数据模型：
  - `MetroGuideItem` 新增 `customSvgContent`
  - `MetroGuideProject` 新增 `customAssets`
- 自定义线路和导入的本地 SVG 均可随项目保存，并在重新打开项目后继续使用。

### 验证

- 用户本地执行：`flutter analyze`
- 结果：`No issues found! (ran in 3.9s)`
- 后续用户本地再次执行：`flutter analyze --no-pub`
- 结果：`No issues found! (ran in 2.7s)`

### 追加记录

- 已再次确认本轮道路编辑器重构后的静态分析结果为全绿。
- 当前可作为下一步 Windows 端编译与界面联调的基线版本。

## Current Status

- 轨道交通编辑器已切换到参考 `vi-tool` 的素材与画布逻辑。
- 道路编辑器已切换到新的配置驱动结构。
- 当前静态分析通过。
- 下一步可以继续：
  - 编译 Windows 应用
  - 校正道路编辑器界面细节
  - 做一次完整的功能联调

## 2026-03-26 (续)

### 自定义线路双分组化 (M3)

- 工具栏“线路”和“经典线路”分类均显示“自定义线路”入口。
- 对话框创建时按目标分类生成对应文件名：`line@custom.svg` 或 `clss@custom.svg`。
- 编辑已有自定义线路时保持原分类不丢失。
- 渲染层区分普通线路徽标风格（圆形-badge）与经典线路条带风格。

### 自定义素材删除与分区 (M4)

- 自定义素材卡片右上角增加删除按钮，支持从素材库移除。
- 自定义素材与自带素材之间增加分割线 + “自带素材”文字说明。
- 删除时弹出确认对话框，避免误操作。

### 颜色系统升级 (M5)

- 复用 `ColorPickerDialog`，在自定义线路、元素改色、色带编辑处接入完整取色器。
- 支持预设色、HEX 文本输入、取色器按钮三种方式。

### 静态分析与编译

- `flutter analyze --no-pub` 通过，No issues found!
- Windows 编译成功，输出 `build\windows\x64\runner\Release\traffic_sign_generator.exe`
