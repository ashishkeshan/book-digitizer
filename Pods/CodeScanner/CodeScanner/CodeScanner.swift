//
//  CodeScanner.swift
//  CodeScanner
//
//  Created by 須藤 将史 on 2017/02/15.
//  Copyright © 2017年 masashi_sutou. All rights reserved.
//

import UIKit
import AVFoundation

public class CodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDevice: AVCaptureDevice?

    private var types: [AVMetadataObject.ObjectType]!
    private var preview: UIView!
    private var resultOutputs: (([String]) -> Void)?
    
    // scan area（0 ~ 1.0）
    private let originX: CGFloat = 0.1
    private let originY: CGFloat = 0.3
    private let width: CGFloat = 0.8
    private let height: CGFloat = 0.4

    public init(metadataObjectTypes: [AVMetadataObject.ObjectType], preview: UIView) {

        super.init()
        self.types = metadataObjectTypes
        self.preview = preview
    }

    public class func requestCameraPermission(success: @escaping (Bool) -> Void) {
        
        // Determine whether camera is available
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            success(true)
        case .denied, .restricted:
            success(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    success(granted)
                }
            })
        }
    }
    
    public func scan(resultOutputs: @escaping ([String]) -> Void) {
        
        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let inputDevice: AVCaptureInput = try AVCaptureDeviceInput(device: captureDevice!)
            
            // avoid error that Multiple audio/video AVCaptureInputs are not currently supported
            if !captureSession.canAddInput(inputDevice) {
                if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                    for input in inputs {
                        captureSession.removeInput(input)
                    }
                }
            }
            
            captureSession.addInput(inputDevice)
            
            // AVCaptureSessionPresetHigh is the default sessionPreset value
            captureSession.sessionPreset = AVCaptureSession.Preset.high
            
            // setting output metadata
            let metaOutput = AVCaptureMetadataOutput()
            metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // avoid error that because more than one output of the same type is unsupported
            if !captureSession.canAddOutput(metaOutput) {
                if let outputs = captureSession.outputs as? [AVCaptureMetadataOutput] {
                    for output in outputs {
                        captureSession.removeOutput(output)
                    }
                }
            }
            captureSession.addOutput(metaOutput)
            
            // set metadataType setting property in initialize
            metaOutput.metadataObjectTypes = self.types
            
            // capture full screen from camera
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = .resizeAspectFill
            self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.preview.frame.width, height: self.preview.frame.height)
            self.preview.layer.insertSublayer(self.previewLayer!, at: 0)
            
            self.setupVideoOrientation()

            if let type: AVMetadataObject.ObjectType = self.types.first {
                switch type {
                case .ean8, .ean13, .code128:

                    // scan area
                    metaOutput.rectOfInterest = CGRect(x: originY, y: 1 - originX - width, width: height, height: width)

                    // attributed scan area
                    let pFrame: CGRect = self.preview.frame
                    let bFrame: CGRect = CGRect(x: originX * pFrame.width, y: originY * pFrame.height, width: width * pFrame.width, height: height * pFrame.height)
                    let borderView = UIView(frame: bFrame)
                    borderView.layer.borderWidth = 2
                    borderView.layer.borderColor = UIColor.red.cgColor
                    self.preview.addSubview(borderView)
                    
                case .qr:
                    break
                default:
                    break
                }
            }
            
            // callBack
            self.resultOutputs = resultOutputs

            captureSession.startRunning()
            
        } catch {
            print(error)
        }
    }

    // MARK: - Start and Stop
    
    public func start() {
        captureSession.startRunning()
    }
    
    public func stop() {
        captureSession.stopRunning()
    }
    
    // MARK: - VideoOrientation
    
    private func setupVideoOrientation() {
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        guard let previewLayer = self.previewLayer else { return }
        if (previewLayer.connection?.isVideoOrientationSupported)! {
            self.previewLayer?.connection?.videoOrientation = self.videoOrientationForInterfaceOrientation(interfaceOrientation: orientation)
        }
    }
    
    private func videoOrientationForInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        
        switch interfaceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return .portrait
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        var detectionStrings: [String] = []
        
        for metadataObject in metadataObjects {
            loop: for type in self.types {
                guard metadataObject.type == type else { continue }
                guard self.previewLayer?.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject else { continue }
                if let object = metadataObject as? AVMetadataMachineReadableCodeObject {

                    #if DEBUG
                        var text = "Scan Value: "
                        text += "\(String(describing: object.stringValue))"
                        text += "\n"
                        print(text)
                    #endif

                    detectionStrings.append(object.stringValue!)
                    break loop
                }
            }
        }
        
        // callBack
        if let _ = self.resultOutputs {
            self.resultOutputs!(detectionStrings)
        }
    }
}
