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
import CocoaAsyncSocket

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


class Camera: View, AVCapturePhotoCaptureDelegate, GCDAsyncSocketDelegate {

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
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }


        self.addTapGestureRecognizer { (_, _, _) in
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            self.cameraOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }

        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
           let data=UIImageJPEGRepresentation(image, 0) as Data?
//            
           print(data!)
            
//            let data = "fuck this bullshit. I talked to Josh about math 3209dakfja;ldkfja;kdljfa;dkjf;akdjf;akdfjkdjieqpiefjpeifjpeifjadkfadkfa;dkf;adkfj;adkfjipqeJFDEIJFAKDFA;DKFADKFMJPQAEIJFIAPEFJDAK;FAKDJkdjfiapid".data(using: .utf8)
//            
//            let packet=Packet(type: PacketType(rawValue: 100000), id: 3, payload: data)
            //SocketManager.sharedManager.broadcastPacket(data!)
            
            
            print("Image broadcasted")
            
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        } else {
            print("some error here")
        }
           }

   }
