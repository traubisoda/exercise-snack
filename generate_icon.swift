#!/usr/bin/env swift

import AppKit
import CoreGraphics

// Generate a bitten-donut icon at a given pixel size
func generateIcon(pixelSize: Int) -> NSImage {
    let size = CGFloat(pixelSize)
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let scale = size / 512.0 // Design at 512, scale everything

    // === Background: Green gradient rounded rectangle ===
    let cornerRadius = 100.0 * scale // macOS-style rounded rect
    let bgPath = CGPath(roundedRect: rect.insetBy(dx: 2 * scale, dy: 2 * scale),
                        cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                        transform: nil)

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradientColors = [
        CGColor(red: 0.45, green: 0.82, blue: 0.35, alpha: 1.0), // Light green (top-left)
        CGColor(red: 0.18, green: 0.55, blue: 0.22, alpha: 1.0)  // Darker green (bottom-right)
    ] as CFArray
    let gradientLocations: [CGFloat] = [0.0, 1.0]

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: gradientLocations) {
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: size),
                               end: CGPoint(x: size, y: 0),
                               options: [])
    }
    ctx.restoreGState()

    // === Donut parameters ===
    let centerX = size * 0.48
    let centerY = size * 0.46
    let outerRadius = size * 0.32
    let innerRadius = size * 0.12
    let glazeThickness = size * 0.06 // How thick the purple glaze appears on top

    // Bite parameters - upper right area
    let biteAngle = CGFloat.pi * 0.3 // Center angle of bite (upper-right)
    let biteRadius = size * 0.18
    let biteCenterX = centerX + outerRadius * 0.78 * cos(biteAngle)
    let biteCenterY = centerY + outerRadius * 0.78 * sin(biteAngle)

    // === Helper: Create donut path with bite ===
    func donutOuterPath() -> CGMutablePath {
        let path = CGMutablePath()
        // Outer circle
        path.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                    width: outerRadius * 2, height: outerRadius * 2))
        return path
    }

    func holePath() -> CGMutablePath {
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: centerX - innerRadius, y: centerY - innerRadius,
                                    width: innerRadius * 2, height: innerRadius * 2))
        return path
    }

    func bitePath() -> CGMutablePath {
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: biteCenterX - biteRadius, y: biteCenterY - biteRadius,
                                    width: biteRadius * 2, height: biteRadius * 2))
        return path
    }

    // === Draw donut shadow ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    ctx.setShadow(offset: CGSize(width: 3 * scale, height: -5 * scale),
                  blur: 12 * scale,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.35))

    // Draw donut body shape for shadow (without hole/bite cut)
    let shadowPath = CGMutablePath()
    shadowPath.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                      width: outerRadius * 2, height: outerRadius * 2))
    ctx.addPath(shadowPath)
    ctx.setFillColor(CGColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0))
    ctx.fillPath()
    ctx.restoreGState()

    // === Draw donut body (warm tan) ===
    ctx.saveGState()
    // Clip to background shape
    ctx.addPath(bgPath)
    ctx.clip()

    // First clip OUT the bite area, then draw donut ring with even-odd for the hole only
    // This prevents the even-odd bug where the bite ellipse extending beyond the outer circle gets filled
    let biteClipPath = CGMutablePath()
    biteClipPath.addRect(CGRect(x: 0, y: 0, width: size, height: size))
    biteClipPath.addEllipse(in: CGRect(x: biteCenterX - biteRadius, y: biteCenterY - biteRadius,
                                        width: biteRadius * 2, height: biteRadius * 2))
    ctx.addPath(biteClipPath)
    ctx.clip(using: .evenOdd) // Clips to everything EXCEPT the bite circle

    // Now draw the donut ring (outer minus hole) — bite is already clipped out
    let donutBodyPath = CGMutablePath()
    donutBodyPath.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                         width: outerRadius * 2, height: outerRadius * 2))
    donutBodyPath.addEllipse(in: CGRect(x: centerX - innerRadius, y: centerY - innerRadius,
                                         width: innerRadius * 2, height: innerRadius * 2))

    ctx.addPath(donutBodyPath)
    ctx.setFillColor(CGColor(red: 0.82, green: 0.62, blue: 0.38, alpha: 1.0)) // Warm tan
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()

    // === Draw bite cross-section (slightly darker tan for depth) ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // The bite cross-section is the area where the bite circle intersects the donut
    // Draw a crescent/arc to show the inner "cake" of the donut
    let crossSectionWidth = size * 0.025

    // Draw a ring at the bite edge within the donut body
    let biteEdgePath = CGMutablePath()
    biteEdgePath.addEllipse(in: CGRect(x: biteCenterX - biteRadius - crossSectionWidth,
                                        y: biteCenterY - biteRadius - crossSectionWidth,
                                        width: (biteRadius + crossSectionWidth) * 2,
                                        height: (biteRadius + crossSectionWidth) * 2))
    biteEdgePath.addEllipse(in: CGRect(x: biteCenterX - biteRadius,
                                        y: biteCenterY - biteRadius,
                                        width: biteRadius * 2,
                                        height: biteRadius * 2))

    // Clip to donut outer minus inner
    let donutMask = CGMutablePath()
    donutMask.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                     width: outerRadius * 2, height: outerRadius * 2))
    ctx.addPath(donutMask)
    ctx.clip()

    // Exclude the donut hole
    ctx.addPath(biteEdgePath)
    ctx.setFillColor(CGColor(red: 0.72, green: 0.52, blue: 0.30, alpha: 1.0)) // Slightly darker tan
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()

    // === Draw purple glazing on top half of donut ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // Clip out the bite area first to prevent even-odd fill bug
    let glazeBiteClip = CGMutablePath()
    glazeBiteClip.addRect(CGRect(x: 0, y: 0, width: size, height: size))
    glazeBiteClip.addEllipse(in: CGRect(x: biteCenterX - biteRadius, y: biteCenterY - biteRadius,
                                         width: biteRadius * 2, height: biteRadius * 2))
    ctx.addPath(glazeBiteClip)
    ctx.clip(using: .evenOdd) // Clips to everything EXCEPT the bite circle

    // Glaze covers the top portion of the donut
    // Create glaze path: a slightly smaller ellipse on the top half
    let glazeOuterRadius = outerRadius - size * 0.008
    let glazeInnerRadius = innerRadius + size * 0.008

    // Glaze as the top part of the donut - use a clipping rect for top portion
    let glazeClipRect = CGRect(x: 0, y: centerY - glazeThickness * 0.3, width: size, height: size)

    let glazePath = CGMutablePath()
    glazePath.addEllipse(in: CGRect(x: centerX - glazeOuterRadius, y: centerY - glazeOuterRadius + glazeThickness * 0.5,
                                     width: glazeOuterRadius * 2, height: glazeOuterRadius * 2))
    glazePath.addEllipse(in: CGRect(x: centerX - glazeInnerRadius, y: centerY - glazeInnerRadius + glazeThickness * 0.3,
                                     width: glazeInnerRadius * 2, height: glazeInnerRadius * 2))

    ctx.clip(to: glazeClipRect)
    ctx.addPath(glazePath)

    // Purple/violet gradient for glazing
    let glazeGradientColors = [
        CGColor(red: 0.58, green: 0.28, blue: 0.72, alpha: 1.0), // Lighter purple
        CGColor(red: 0.42, green: 0.18, blue: 0.58, alpha: 1.0)  // Darker purple
    ] as CFArray

    ctx.clip(using: .evenOdd)

    if let glazeGradient = CGGradient(colorsSpace: colorSpace, colors: glazeGradientColors, locations: gradientLocations) {
        ctx.drawLinearGradient(glazeGradient,
                               start: CGPoint(x: centerX - outerRadius, y: centerY + outerRadius),
                               end: CGPoint(x: centerX + outerRadius, y: centerY - outerRadius),
                               options: [])
    }
    ctx.restoreGState()

    // === Draw sprinkles on the glazing ===
    if size >= 64 { // Only draw sprinkles at larger sizes where they're visible
        let sprinkleColors: [CGColor] = [
            CGColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),  // Red
            CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0), // Yellow
            CGColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0),  // Blue
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9),  // White
            CGColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 1.0), // Orange
        ]

        // Sprinkle positions (in 512-unit space, relative to center)
        struct Sprinkle {
            let dx: CGFloat   // offset from center X (in 512 units)
            let dy: CGFloat   // offset from center Y
            let angle: CGFloat // rotation angle in radians
            let colorIndex: Int
        }

        let sprinkles: [Sprinkle] = [
            Sprinkle(dx: -0.18, dy: 0.14, angle: 0.3, colorIndex: 0),
            Sprinkle(dx: -0.08, dy: 0.22, angle: -0.5, colorIndex: 1),
            Sprinkle(dx: 0.05, dy: 0.20, angle: 0.8, colorIndex: 2),
            Sprinkle(dx: -0.22, dy: 0.02, angle: -0.2, colorIndex: 3),
            Sprinkle(dx: -0.14, dy: -0.18, angle: 0.6, colorIndex: 4),
            Sprinkle(dx: 0.02, dy: -0.24, angle: -0.4, colorIndex: 0),
            Sprinkle(dx: 0.16, dy: -0.16, angle: 0.1, colorIndex: 1),
            Sprinkle(dx: -0.24, dy: -0.10, angle: -0.7, colorIndex: 2),
            Sprinkle(dx: 0.14, dy: 0.12, angle: 0.5, colorIndex: 3),
            Sprinkle(dx: -0.04, dy: 0.06, angle: -0.3, colorIndex: 4),
        ]

        let sprinkleLength = 14.0 * scale
        let sprinkleWidth = 3.5 * scale

        for s in sprinkles {
            let sx = centerX + s.dx * size
            let sy = centerY + s.dy * size

            // Check if sprinkle is within the donut body (between inner and outer radius)
            // and not in the bite area
            let distFromCenter = sqrt(pow(sx - centerX, 2) + pow(sy - centerY, 2))
            let distFromBite = sqrt(pow(sx - biteCenterX, 2) + pow(sy - biteCenterY, 2))

            if distFromCenter > innerRadius + size * 0.04 &&
               distFromCenter < outerRadius - size * 0.04 &&
               distFromBite > biteRadius + size * 0.02 {

                ctx.saveGState()
                ctx.translateBy(x: sx, y: sy)
                ctx.rotate(by: s.angle)

                let sprinkleRect = CGRect(x: -sprinkleLength / 2, y: -sprinkleWidth / 2,
                                          width: sprinkleLength, height: sprinkleWidth)
                let sprinklePath = CGPath(roundedRect: sprinkleRect,
                                          cornerWidth: sprinkleWidth / 2,
                                          cornerHeight: sprinkleWidth / 2,
                                          transform: nil)
                ctx.addPath(sprinklePath)
                ctx.setFillColor(sprinkleColors[s.colorIndex])
                ctx.fillPath()
                ctx.restoreGState()
            }
        }
    }

    // === Subtle highlight on the donut for 3D effect ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // Add a subtle light reflection on the upper-left of the donut
    let highlightCenter = CGPoint(x: centerX - outerRadius * 0.35, y: centerY + outerRadius * 0.35)
    let highlightRadius = outerRadius * 0.6

    let highlightColors = [
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.18),
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    ] as CFArray

    if let highlightGradient = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: gradientLocations) {
        // Clip to donut shape first
        let donutClip = CGMutablePath()
        donutClip.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                         width: outerRadius * 2, height: outerRadius * 2))
        ctx.addPath(donutClip)
        ctx.clip()

        ctx.drawRadialGradient(highlightGradient,
                                startCenter: highlightCenter, startRadius: 0,
                                endCenter: highlightCenter, endRadius: highlightRadius,
                                options: [])
    }
    ctx.restoreGState()

    image.unlockFocus()
    return image
}

// Save NSImage as PNG at the given path
func savePNG(image: NSImage, path: String, pixelSize: Int) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                pixelsWide: pixelSize,
                                pixelsHigh: pixelSize,
                                bitsPerSample: 8,
                                samplesPerPixel: 4,
                                hasAlpha: true,
                                isPlanar: false,
                                colorSpaceName: .deviceRGB,
                                bytesPerRow: 0,
                                bitsPerPixel: 0)!

    rep.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
               from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
               operation: .copy,
               fraction: 1.0)

    NSGraphicsContext.restoreGraphicsState()

    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
}

// Icon sizes required for macOS
let iconSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

let outputDir = "ExerciseSnack/Assets.xcassets/AppIcon.appiconset"

for iconSize in iconSizes {
    let image = generateIcon(pixelSize: iconSize.pixels)
    let path = "\(outputDir)/\(iconSize.name)"
    savePNG(image: image, path: path, pixelSize: iconSize.pixels)
    print("Generated \(iconSize.name) (\(iconSize.pixels)x\(iconSize.pixels)px)")
}

print("\nAll icons generated successfully!")
