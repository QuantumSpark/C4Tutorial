//
//  Camera.swift
//  c4Test
//
//  Created by James Park on 2017-08-28.
//  Copyright © 2017 James Park. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraView: UIView {
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    func setUpPreviewLayer(with session: AVCaptureSession) {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.layer.addSublayer(cameraPreviewLayer)
    }

    func getPreviewLayer() -> CALayer {
        return cameraPreviewLayer// swiftlint:disable:this force_cast
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}


class Camera: View, AVCapturePhotoCaptureDelegate {

    var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
        get {
            return self.cameraView.cameraPreviewLayer
        }
    }

    var cameraView: CameraView {
        return self.view as! CameraView // swiftlint:disable:this force_cast
    }


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
    var captureSesssion : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!

    public override init(frame: Rect) {
        super.init()
        self.view = CameraView(frame: CGRect(frame))
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()

        //        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            .map { $0 as! AVCaptureDevice }
            .filter { $0.position == .front}
            .first!

        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                if (captureSesssion.canAddOutput(cameraOutput)) {
                    captureSesssion.addOutput(cameraOutput)
                    self.cameraView.setUpPreviewLayer(with: captureSesssion)
                    self.cameraView.getPreviewLayer().frame = self.cameraView.bounds
//                    previewView.layer.addSublayer(previewLayer)
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
}
