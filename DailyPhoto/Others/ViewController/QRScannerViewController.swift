//
//  QRScannerViewController.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/13.
//

import SwiftUI
import AVFoundation

class QRScannerViewController: UIViewController {
    var completion: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        addOverlay()

        session.startRunning()
    }

    private func addOverlay() {
        let overlayView = UIView()
        overlayView.layer.borderColor = UIColor.white.cgColor
        overlayView.layer.borderWidth = 4
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            overlayView.heightAnchor.constraint(equalTo: overlayView.widthAnchor)
        ])

        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.isUserInteractionEnabled = false
        view.addSubview(dimView)
        view.bringSubviewToFront(overlayView)

        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: view.bounds)
        let transparentRect = overlayView.frame.insetBy(dx: -2, dy: -2)
        path.append(UIBezierPath(rect: transparentRect).reversing())
        maskLayer.path = path.cgPath
        dimView.layer.mask = maskLayer

        let label = UILabel()
        label.text = "QRコードを枠内に収めてください"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let stringValue = metadataObject.stringValue {
            dismiss(animated: true) {
                self.completion?(stringValue)
            }
        }
    }
}
