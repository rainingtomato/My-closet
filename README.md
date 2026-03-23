# My Closet (iOS)

一个中文的「我的衣橱」iOS App 源码骨架，技术栈如下：

- 界面：SwiftUI
- 本地数据库：SwiftData
- 图像处理：Vision (`VNGenerateForegroundInstanceMaskRequest`) 离线抠图 + 白底合成

## 当前实现

### 1) 数据模型（SwiftData）

- `ClothingItem`
  - `id: UUID`
  - `imagePath: String`（仅存本地沙盒相对路径）
  - `mainCategory: String`
  - `subCategory: String`
  - `color: String`
  - `price: Double`
  - `addDate: Date`
  - `isArchived: Bool`（默认 `false`）

- `CategorySettings`
  - 存储一级/二级分类树（以 JSON Data 落库）
  - 内置默认分类

### 2) 页面架构（TabView）

- `HomeView`：一级分类聚合网格 + 件数统计 + 进入二级分类网格
- `AddView`：拍照/相册 -> Vision 离线抠图白底 -> 表单录入 -> 保存入库
- `StatsView`：有效衣物总件数/总价值 + 归档件数/沉没成本统计

### 3) 图像处理流程

1. 选择图片（拍照或相册）
2. Vision 前景实例分割（`VNGenerateForegroundInstanceMaskRequest`）
3. 用 mask 将背景合成为纯白色 `#FFFFFF`
4. 以 JPEG 写入沙盒 `Documents/ClosetImages/*.jpg`
5. `ClothingItem.imagePath` 仅保存相对路径（不存 Data）

## 代码目录

```text
MyCloset/
  MyClosetApp.swift
  Models/
  Services/
  Views/
```

## 运行说明

当前仓库仅包含源码结构，需在 Xcode 中新建 iOS App 工程（iOS 17+），再将 `MyCloset/` 下文件加入目标 Target。

> `VNGenerateForegroundInstanceMaskRequest` 需要 iOS 17+；真机体验更佳。
