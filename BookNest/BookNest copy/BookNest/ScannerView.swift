//
//  ScannerView.swift
//  BookNest
//
import SwiftUI
import VisionKit
import SwiftData

struct ScannerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
   
    @State private var scannedISBN: String?
    @State private var isScanning = true
    @State private var showManualEntry = false
   
    var body: some View {
        NavigationStack {
            ZStack {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    DataScannerRepresentable(scannedCode: $scannedISBN, isScanning: $isScanning)
                        .ignoresSafeArea()
                } else {
                    ContentUnavailableView("Scanner Not Available", systemImage: "camera.fill", description: Text("Camera scanning is not supported on this device."))
                }
               
                VStack {
                    Spacer()
                    if let isbn = scannedISBN {
                        VStack(spacing: 12) {
                            Text("ISBN Detected")
                                .font(.headline)
                            Text(isbn)
                                .font(.title2)
                                .fontWeight(.semibold)
                           
                            Button("Use This ISBN") {
                                showManualEntry = true
                            }
                            .buttonStyle(.borderedProminent)
                           
                            Button("Scan Again") {
                                scannedISBN = nil
                                isScanning = true
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding()
                    }
                }
            }
            .navigationTitle("Scan ISBN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Manual") { showManualEntry = true }
                }
            }
            .sheet(isPresented: $showManualEntry) {
                AddBookView(prefilledISBN: scannedISBN)
            }
            .onChange(of: scannedISBN) { _, newValue in
                if newValue != nil {
                    isScanning = false
                }
            }
        }
    }
}

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isScanning: Bool
   
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .code128, .qr])],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }
   
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if isScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
   
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
   
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerRepresentable
       
        init(_ parent: DataScannerRepresentable) {
            self.parent = parent
        }
       
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = addedItems.first else { return }
            switch item {
            case .barcode(let barcode):
                parent.scannedCode = barcode.payloadStringValue
            default:
                break
            }
        }
    }
}

