//
//  VideoCam.swift
//  c4Test
//
//  Created by Geyi Liu on 2017-09-01.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit
import AVFoundation


class VideoCam: View, AVCaptureFileOutputRecordingDelegate {
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

    var outputURL: URL!

    var tapCounter = 0
    
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

        self.addTapGestureRecognizer { (_, _, _) in
            if self.tapCounter == 0 {
                self.startCapture()
                self.tapCounter+=1
            } else if self.tapCounter == 1 {
                self.stopRecording()
                self.tapCounter = 0
            }
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


    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }

    func startCapture() {

        startRecording()
        
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func tempURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


        let path = paths.appendingPathComponent(NSUUID().uuidString + "fuckyou.mp4")
        return path

    }
    func startRecording() {
        print("yes we are recording")
        if movieOutput.isRecording == false {

            let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }

            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }

            let device = activeInput.device
            if (device?.isSmoothAutoFocusSupported)! {
                do {
                    try device?.lockForConfiguration()
                    device?.isSmoothAutoFocusEnabled = false
                    device?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }

            }

            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)

        }
        else {
            stopRecording()
        }

    }

    func stopRecording() {
        if movieOutput.isRecording == true {
            print("stopped reccording")
            movieOutput.stopRecording()
        }
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {

    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            print("save video to Album")
             UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            _ = outputURL as URL
            
        }
        outputURL = nil
    }


}
