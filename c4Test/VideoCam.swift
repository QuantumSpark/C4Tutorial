//
//  VideoCam.swift
//  c4Test
//
//  Created by Geyi Liu on 2017-09-01.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit
import AVFoundation


class VideoCam: View {
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
        get {
            return self.cameraView.cameraPreviewLayer
        }
    }
    
    var cameraView: CameraView {
        return self.view as! CameraView // swiftlint:disable:this force_cast
    }
    
    let captureSession = AVCaptureSession()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var activeInput: AVCaptureDeviceInput!

    
    
    public var constrainsProportions: Bool = true
    
    public override var width: Double {
        get {
            return Double(view.frame.size.width)
        } set(val) {
            var newSize = Size(val, height)
            if constrainsProportions {
                newSize.height = val * height / width
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }
    
    public override var height: Double {
        get {
            return Double(view.frame.size.height)
        } set(val) {
            var newSize = Size(Double(view.frame.size.width), val)
            if constrainsProportions {
                let ratio = Double(self.size.width / self.size.height)
                newSize.width = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }
   
    public override init(frame: Rect) {
        super.init()
        self.view = CameraView(frame: CGRect(frame))
        
        
        if setupSession() {
            setupPreview()
            startSession()
        }
    }
    
    public func  setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Camera
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
     func setupPreview() {
        self.cameraView.setUpPreviewLayer(with: captureSession)
        self.cameraView.getPreviewLayer().frame = self.cameraView.bounds
        (self.cameraView.getPreviewLayer() as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
     func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
}
