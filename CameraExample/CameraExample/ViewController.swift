//
//  ViewController.swift
//  CameraExample
//
//  Created by Geppy Parziale on 2/15/16.
//  Copyright © 2016 iNVASIVECODE, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var fuckenImage: UIImageView!
    private let context = CIContext()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupCameraSession()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		view.layer.addSublayer(previewLayer)

		cameraSession.startRunning()
	}

	lazy var cameraSession: AVCaptureSession = {
		let s = AVCaptureSession()
		s.sessionPreset = AVCaptureSessionPresetHigh
		return s
	}()

	lazy var previewLayer: AVCaptureVideoPreviewLayer = {
		let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
		preview?.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
		preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
		return preview!
	}()

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

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.fuckenImage.image = uiImage
        }
    }
	func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		// Here you can count how many frames are dopped
	}
	
}

