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

    /// Builds the Core Image filter used for manual color adjustments.
    ///
    /// `ColorAdjusts` stores values as UI deltas: brightness is already centered
    /// around zero, while contrast and saturation are centered around zero in the
    /// UI but around one in `CIColorControls`. That is why contrast and saturation
    /// are shifted by `+1` before being sent to Core Image.
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

    /// Builds the Core Image filter that corresponds to a high-level editor filter.
    ///
    /// The public `VideoFilter` API stays intentionally small and stable. This
    /// method is the single translation point from that API to Core Image so the
    /// preview pipeline and export pipeline always render the same pixels.
    static func createVideoFilter(_ videoFilter: VideoFilter) -> CIFilter? {
        switch videoFilter {
        case .none:
            // Returning nil for the identity case lets callers compact the chain
            // and skip `AVVideoComposition` entirely when no other appearance work exists.
            nil
        case .vivid:
            // There is no single built-in "vivid" CIFilter that matches the editor
            // intent, so the look is expressed as a small color-control boost.
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

    /// Backward-compatible helper for code paths that only need manual adjustments.
    static func createColorAdjustsFilters(
        colorAdjusts: ColorAdjusts?
    ) -> [CIFilter] {
        guard let adjustsFilter = createColorAdjustsFilter(colorAdjusts) else {
            return []
        }

        return [adjustsFilter]
    }

    /// Creates the full appearance filter chain used by preview and export.
    ///
    /// The selected filter is applied before manual adjustments. This makes the
    /// adjustment sliders behave as a final tuning pass on top of the chosen look,
    /// which is easier to reason about for users and keeps export parity with the
    /// live preview.
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
        // `CITemperatureAndTint` expects Kelvin-like neutral vectors. The y value
        // represents tint; this editor only exposes warm/cool presets, so tint stays at zero.
        let filter = CIFilter(name: "CITemperatureAndTint")
        filter?.setValue(CIVector(x: neutral, y: 0), forKey: "inputNeutral")
        filter?.setValue(CIVector(x: targetNeutral, y: 0), forKey: "inputTargetNeutral")
        return filter
    }

}
