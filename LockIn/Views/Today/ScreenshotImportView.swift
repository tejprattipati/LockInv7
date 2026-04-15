import SwiftUI
import PhotosUI

struct ScreenshotImportView: View {
    @Binding var isPresented: Bool
    let onConfirm: (Int, Int, Int, Int) -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var result: GeminiService.NutritionResult?
    @State private var calories = ""
    @State private var protein  = ""
    @State private var carbs    = ""
    @State private var fat      = ""
    @State private var showRaw  = false

    var body: some View {
        NavigationStack {
            ZStack {
                LockInTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // Image picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable().scaledToFit()
                                    .frame(maxHeight: 220)
                                    .cornerRadius(12)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LockInTheme.surface)
                                    .frame(height: 140)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 32))
                                                .foregroundColor(LockInTheme.accent)
                                            Text("Select your MND food report screenshot")
                                                .font(.system(size: 13))
                                                .foregroundColor(LockInTheme.textSecondary)
                                                .multilineTextAlignment(.center)
                                        }
                                    )
                            }
                        }
                        .onChange(of: selectedItem) { analyzeIfReady() }

                        if isAnalyzing {
                            HStack(spacing: 10) {
                                ProgressView().tint(LockInTheme.accent)
                                Text("Claude AI is reading your screenshot...")
                                    .font(.system(size: 14))
                                    .foregroundColor(LockInTheme.textSecondary)
                            }
                            .padding(16).cardStyle()
                        }

                        if let r = result {
                            // Status
                            HStack {
                                Image(systemName: r.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(r.success ? LockInTheme.success : LockInTheme.warning)
                                Text(r.success ? "Parsed successfully \u2014 review and confirm" : "Partial parse \u2014 check values")
                                    .font(.system(size: 13))
                                    .foregroundColor(LockInTheme.textSecondary)
                            }
                            .padding(12).cardStyle()

                            // Editable fields
                            VStack(spacing: 12) {
                                editRow("Calories", text: $calories)
                                editRow("Protein (g)", text: $protein)
                                editRow("Carbs (g)", text: $carbs)
                                editRow("Fat (g)", text: $fat)
                            }
                            .padding(16).cardStyle()

                            // Raw response toggle
                            DisclosureGroup("Raw AI Response", isExpanded: $showRaw) {
                                Text(r.rawResponse)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(LockInTheme.textMuted)
                                    .padding(.top, 8)
                            }
                            .font(.system(size: 12))
                            .foregroundColor(LockInTheme.textMuted)
                            .padding(12).cardStyle()

                            PrimaryButton("Confirm & Save") {
                                onConfirm(
                                    Int(calories) ?? 0,
                                    Int(protein)  ?? 0,
                                    Int(carbs)    ?? 0,
                                    Int(fat)      ?? 0
                                )
                                isPresented = false
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("IMPORT SCREENSHOT")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(LockInTheme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { isPresented = false }.foregroundColor(LockInTheme.textMuted)
                }
            }
        }
    }

    private func analyzeIfReady() {
        guard let item = selectedItem else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data) else { return }
            selectedImage = img
            isAnalyzing = true
            let r = await GeminiService.shared.parseNutritionScreenshot(img)
            result = r
            calories = r.calories > 0 ? String(r.calories) : ""
            protein  = r.protein  > 0 ? String(r.protein)  : ""
            carbs    = r.carbs    > 0 ? String(r.carbs)    : ""
            fat      = r.fat      > 0 ? String(r.fat)      : ""
            isAnalyzing = false
        }
    }

    @ViewBuilder
    private func editRow(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(LockInTheme.textSecondary).frame(width: 100, alignment: .leading)
            TextField("0", text: text).keyboardType(.numberPad)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}
