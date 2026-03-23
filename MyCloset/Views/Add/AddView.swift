import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categorySettings: [CategorySettings]

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCameraPicker = false

    @State private var processedImage: UIImage?
    @State private var isProcessingImage = false

    @State private var selectedMainCategory = ""
    @State private var selectedSubCategory = ""
    @State private var selectedColor = ColorPalette.quickPickColors.first ?? "黑"
    @State private var priceText = ""

    @State private var alertMessage: String?
    @State private var showAlert = false

    private var categoryTree: [String: [String]] {
        categorySettings.first?.categoryTree ?? CategoryDefaults.tree
    }

    private var mainCategories: [String] {
        categoryTree.keys.sorted()
    }

    private var subCategories: [String] {
        categoryTree[selectedMainCategory] ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                imagePreviewSection
                sourceActionSection
                formSection
                saveButton
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("添加录入")
        .sheet(isPresented: $showCameraPicker) {
            CameraImagePicker { image in
                processImage(image)
            }
        }
        .onAppear {
            initializeCategorySelectionsIfNeeded()
        }
        .onChange(of: selectedMainCategory) { _, newValue in
            let availableSub = categoryTree[newValue] ?? []
            if !availableSub.contains(selectedSubCategory) {
                selectedSubCategory = availableSub.first ?? ""
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    processImage(image)
                } else {
                    showFailure("读取相册图片失败，请重试。")
                }
            }
        }
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "发生未知错误")
        }
    }
}

private extension AddView {
    var imagePreviewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 240)

            if let processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("请拍照或选择图片，自动抠图后会显示白底预览")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            if isProcessingImage {
                Color.black.opacity(0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                ProgressView("正在离线抠图…")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    var sourceActionSection: some View {
        HStack(spacing: 10) {
            Button {
                showCameraPicker = true
            } label: {
                Label("拍照", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("相册", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    var formSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("一级分类")
                    .font(.subheadline.bold())
                Picker("一级分类", selection: $selectedMainCategory) {
                    ForEach(mainCategories, id: \.self) { mainCategory in
                        Text(mainCategory).tag(mainCategory)
                    }
                }
                .pickerStyle(.menu)
            }

            Group {
                Text("二级分类")
                    .font(.subheadline.bold())
                Picker("二级分类", selection: $selectedSubCategory) {
                    ForEach(subCategories, id: \.self) { subCategory in
                        Text(subCategory).tag(subCategory)
                    }
                }
                .pickerStyle(.menu)
            }

            Group {
                Text("颜色（基础 8 色）")
                    .font(.subheadline.bold())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ColorPalette.quickPickColors, id: \.self) { colorName in
                            Button {
                                selectedColor = colorName
                            } label: {
                                VStack(spacing: 6) {
                                    ColorDot(colorName: colorName, isSelected: selectedColor == colorName)
                                    Text(colorName)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            Group {
                Text("价格")
                    .font(.subheadline.bold())
                TextField("输入价格", text: $priceText)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    var saveButton: some View {
        Button {
            saveClothingItem()
        } label: {
            Text("保存入库")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(.borderedProminent)
        .disabled(processedImage == nil || selectedMainCategory.isEmpty || selectedSubCategory.isEmpty || Double(priceText) == nil)
    }

    func initializeCategorySelectionsIfNeeded() {
        if selectedMainCategory.isEmpty {
            selectedMainCategory = mainCategories.first ?? ""
        }
        if selectedSubCategory.isEmpty {
            selectedSubCategory = categoryTree[selectedMainCategory]?.first ?? ""
        }
    }

    func processImage(_ image: UIImage) {
        isProcessingImage = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let output = try VisionBackgroundProcessor().makeWhiteBackgroundImage(from: image)
                DispatchQueue.main.async {
                    self.processedImage = output
                    self.isProcessingImage = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessingImage = false
                    self.showFailure(error.localizedDescription)
                }
            }
        }
    }

    func saveClothingItem() {
        guard let processedImage else {
            showFailure("请先选择并处理图片。")
            return
        }
        guard let price = Double(priceText) else {
            showFailure("价格格式不正确。")
            return
        }

        do {
            let relativePath = try ImageStorageService.saveProcessedImage(processedImage)
            let item = ClothingItem(
                imagePath: relativePath,
                mainCategory: selectedMainCategory,
                subCategory: selectedSubCategory,
                color: selectedColor,
                price: price,
                addDate: .now,
                isArchived: false
            )
            modelContext.insert(item)
            try modelContext.save()

            priceText = ""
            self.processedImage = nil
            showSuccess("已保存到衣橱。")
        } catch {
            showFailure(error.localizedDescription)
        }
    }

    func showSuccess(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    func showFailure(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
