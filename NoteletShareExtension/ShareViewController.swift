import SwiftUI
import UIKit

final class ShareViewController: UIViewController {
    private let historyStore = HistoryStore()
    private var hostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        showLoading()

        Task {
            let document = await ItemProviderReader.document(
                from: extensionContext?.inputItems as? [NSExtensionItem] ?? []
            )

            await MainActor.run {
                if let document {
                    showEditor(document: document)
                } else {
                    showError()
                }
            }
        }
    }

    private func showLoading() {
        let root = AnyView(
            VStack(spacing: 14) {
                ProgressView()
                Text("正在读取分享内容")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        install(root)
    }

    private func showEditor(document: NoteDocument) {
        let route = EditorRoute(document: document)
        let root = AnyView(
            EditorView(route: route) { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil)
            }
            .environmentObject(historyStore)
        )
        install(root)
    }

    private func showError() {
        let root = AnyView(
            VStack(spacing: 18) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.noteletMutedInk)
                Text("未识别到可生成图片的文字")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.noteletInk)
                Text("请从 Apple Notes 分享文字内容，或先复制文字后在留笺 App 内生成。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.noteletMutedInk)
                    .padding(.horizontal, 28)
                Button("关闭") { [weak self] in
                    self?.extensionContext?.completeRequest(returningItems: nil)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.noteletInk)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.noteletCanvas)
        )
        install(root)
    }

    private func install(_ rootView: AnyView) {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        let controller = UIHostingController(rootView: rootView)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        controller.didMove(toParent: self)
        hostingController = controller
    }
}

