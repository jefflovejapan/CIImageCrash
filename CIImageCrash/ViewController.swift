//
//  ViewController.swift
//  CIImageCrash
//
//  Created by Jeffrey Blagdon on 2020-05-18.
//  Copyright © 2020 polyergy. All rights reserved.
//

import UIKit
import AVFoundation

extension AVAssetImageGenerator.Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .succeeded:
            return "succeeded"
        case .failed:
            return "failed"
        case .cancelled:
            return "cancelled"
        @unknown default:
            return "unknown: \(self.rawValue)"
        }
    }
}

class ViewController: UIViewController {
    var imageGenerator: AVAssetImageGenerator!
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        let url = Bundle.main.url(forResource: "computerTime", withExtension: "MOV")!
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        imageGenerator = AVAssetImageGenerator.init(asset: asset)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self = self else { return }
            let midPoint = CMTime(value: asset.duration.value / 2, timescale: asset.duration.timescale)
            self.imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: midPoint)]) { [weak self] (_, maybeImage, _, result, err) in
                guard let self = self, let image = maybeImage else { return }
                print("result: \(result), error: \(err as Optional)")
                let ciImage = CIImage(cgImage: image)
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = UIImage(ciImage: ciImage)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        imageView.frame = view.bounds
    }
}

