//
//  Helpers.swift
//  VideoEditorKit
//
//  Created by Adriano Souza Costa on 23.03.2026.
//

import CoreImage
import Foundation

enum Helpers {

    // MARK: - Public Methods

    static func createColorAdjustsFilter(_ colorAdjusts: ColorAdjusts?) -> CIFilter? {
        guard let colorAdjusts else { return nil }
        guard colorAdjusts.isIdentity == false else { return nil }

        let colorAdjustsFilter = CIFilter(name: "CIColorControls")

        colorAdjustsFilter?.setValue(
            colorAdjusts.brightness,
            forKey: ColorAdjustType.brightness.key
        )

        colorAdjustsFilter?.setValue(
            colorAdjusts.contrast + 1,
            forKey: ColorAdjustType.contrast.key
        )

        colorAdjustsFilter?.setValue(
            colorAdjusts.saturation + 1,
            forKey: ColorAdjustType.saturation.key
        )

        return colorAdjustsFilter
    }

    static func createVideoFilter(_ videoFilter: VideoFilter) -> CIFilter? {
        switch videoFilter {
        case .none:
            nil
        case .vivid:
            colorControlsFilter(saturation: 1.28, contrast: 1.12, brightness: 0.02)
        case .warm:
            temperatureFilter(neutral: 6500, targetNeutral: 5200)
        case .cool:
            temperatureFilter(neutral: 6500, targetNeutral: 8200)
        case .chrome:
            CIFilter(name: "CIPhotoEffectChrome")
        case .fade:
            CIFilter(name: "CIPhotoEffectFade")
        case .mono:
            CIFilter(name: "CIPhotoEffectMono")
        case .noir:
            CIFilter(name: "CIPhotoEffectNoir")
        }
    }

    static func createColorAdjustsFilters(
        colorAdjusts: ColorAdjusts?
    ) -> [CIFilter] {
        guard let adjustsFilter = createColorAdjustsFilter(colorAdjusts) else {
            return []
        }

        return [adjustsFilter]
    }

    static func createVideoAppearanceFilters(
        filter: VideoFilter,
        colorAdjusts: ColorAdjusts?
    ) -> [CIFilter] {
        [
            createVideoFilter(filter),
            createColorAdjustsFilter(colorAdjusts),
        ].compactMap { $0 }
    }

    // MARK: - Private Methods

    private static func colorControlsFilter(
        saturation: Double,
        contrast: Double,
        brightness: Double
    ) -> CIFilter? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(saturation, forKey: kCIInputSaturationKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        filter?.setValue(brightness, forKey: kCIInputBrightnessKey)
        return filter
    }

    private static func temperatureFilter(
        neutral: CGFloat,
        targetNeutral: CGFloat
    ) -> CIFilter? {
        let filter = CIFilter(name: "CITemperatureAndTint")
        filter?.setValue(CIVector(x: neutral, y: 0), forKey: "inputNeutral")
        filter?.setValue(CIVector(x: targetNeutral, y: 0), forKey: "inputTargetNeutral")
        return filter
    }

}
