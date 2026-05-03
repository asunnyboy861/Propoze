import SwiftUI
import PencilKit

struct SignatureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var isSigned = false
    let onSign: (Data) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign Here")
                    .font(.headline)

                SignatureCanvasRepresentable(canvasView: $canvasView, isSigned: $isSigned)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                if isSigned {
                    Text("Signature captured")
                        .font(.caption)
                        .foregroundStyle(AppConstants.Colors.secondary)
                }

                Spacer()

                HStack(spacing: 16) {
                    Button("Clear") {
                        canvasView.drawing = PKDrawing()
                        isSigned = false
                    }
                    .foregroundStyle(.secondary)

                    Button("Confirm Signature") {
                        confirmSignature()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isSigned)
                }
                .padding()
            }
            .navigationTitle("E-Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func confirmSignature() {
        let drawing = canvasView.drawing
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        if let data = image.pngData() {
            onSign(data)
        }
        dismiss()
    }
}

struct SignatureCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isSigned: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isSigned: $isSigned)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var isSigned: Bool

        init(isSigned: Binding<Bool>) {
            _isSigned = isSigned
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            isSigned = !canvasView.drawing.strokes.isEmpty
        }
    }
}
