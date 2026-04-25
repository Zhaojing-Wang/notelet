import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("默认样式") {
                LabeledContent("默认模板", value: TemplateStore.defaultTemplate.name)
                LabeledContent("默认字体", value: FontPresetStore.defaultPreset.name)
                LabeledContent("默认切图", value: "多图 · 4:5")
            }

            Section("隐私") {
                Text("留笺在本地解析和渲染内容，不上传用户的备忘录文本。最近生成记录保存在本机。")
                    .foregroundStyle(.secondary)
            }

            Section("关于") {
                LabeledContent("App", value: "留笺 Notelet")
                LabeledContent("版本", value: "1.0")
            }
        }
        .navigationTitle("设置")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") {
                    dismiss()
                }
            }
        }
    }
}

