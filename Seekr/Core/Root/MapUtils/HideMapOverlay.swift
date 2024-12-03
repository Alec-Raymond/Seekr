//
//  HideMapOverlay.swift
//  Seekr
//
//  Created by Alec Raymond on 12/2/24.
//

import MapKit

class HideMapOverlay: MKTileOverlay {
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let tileSize = CGSize(width: 256, height: 256)
        UIGraphicsBeginImageContext(tileSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            result(nil, nil)
            return
        }
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: tileSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let imageData = image?.pngData() {
            result(imageData, nil)
        } else {
            result(nil, nil)
        }
    }
}
