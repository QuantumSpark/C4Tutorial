//
//  VideoCam.swift
//  c4Test
//
//  Created by Geyi Liu on 2017-09-01.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit
import AVFoundation


class VideoCam: View, AVCaptureVideoDataOutputSampleBufferDelegate {
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
        get {
            return self.cameraView.cameraPreviewLayer
        }
    }

    var cameraView: CameraView {
        return self.view as! CameraView // swiftlint:disable:this force_cast
    }


    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetLow
        return s
    }()


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
        setupPreviewLayer()
        setupCameraSession()
        self.addTapGestureRecognizer { (_, _, _) in
            if self.tapCounter == 0 {
                self.cameraSession.startRunning()
                self.tapCounter+=1
            } else if self.tapCounter == 1 {
                self.cameraSession.stopRunning()
                self.tapCounter = 0
            }
        }

    }

    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice

        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)

            cameraSession.beginConfiguration()

            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }

            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true

            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }

            cameraSession.commitConfiguration()

            let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }


    func setupPreviewLayer() {
        self.cameraView.setUpPreviewLayer(with: cameraSession)
        self.cameraView.getPreviewLayer().frame = self.cameraView.bounds
        (self.cameraView.getPreviewLayer() as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("Video frame has been dropped")
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("Video frame has been created")

        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        let src_buff = CVPixelBufferGetBaseAddress(imageBuffer!)
        let data = NSData(bytes: src_buff, length: bytesPerRow * height)
        print(data)
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    }
}
