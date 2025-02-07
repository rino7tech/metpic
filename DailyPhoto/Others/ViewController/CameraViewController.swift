//
//  CameraViewController.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/18.
//

import SwiftUI
import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var coordinator: Camera.Coordinator?
    var flashEnabled = false
    var isUsingFrontCamera = false
    let previewView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera(isFrontCamera: isUsingFrontCamera)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = previewView.layer.bounds
    }

    func setupCamera(isFrontCamera: Bool) {
        captureSession?.stopRunning()
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        captureSession.sessionPreset = .photo

        let cameraPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        photoOutput = AVCapturePhotoOutput()

        if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput!) {
            captureSession.addInput(input)
            captureSession.addOutput(photoOutput!)

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = previewView.layer.bounds
            videoPreviewLayer?.connection?.videoOrientation = .portrait

            previewView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            previewView.layer.addSublayer(videoPreviewLayer!)

            view.addSubview(previewView)
            previewView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                previewView.topAnchor.constraint(equalTo: view.topAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            captureSession.startRunning()
        }
    }

    func switchCamera() {
        isUsingFrontCamera.toggle()
        setupCamera(isFrontCamera: isUsingFrontCamera)
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashEnabled ? .on : .off

        if let connection = photoOutput?.connection(with: .video) {
            connection.videoOrientation = .portrait
        }

        photoOutput?.capturePhoto(with: settings, delegate: coordinator!)
    }
}
