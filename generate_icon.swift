#!/usr/bin/env swift

import AppKit
import CoreGraphics
import Foundation

// Generate a bitten-donut icon at a given pixel size
// The donut is a 3/4 circle (~270°) with the missing quarter in the upper-right,
// featuring realistic scalloped bite edges and a narrower glazing band.
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

    // === Bite geometry ===
    // The bite removes the upper-right quarter (~90° arc) of the donut.
    // We define the arc gap and create scalloped edges at the bite boundaries.
    // Angles in CG are measured counter-clockwise from the positive X axis.
    // In CG's coordinate system (y-up), upper-right is roughly 15°..105° range.
    let biteStartAngle = CGFloat.pi * 0.08   // ~14° - where the bite starts (right side)
    let biteEndAngle = CGFloat.pi * 0.58     // ~104° - where the bite ends (top side)

    // === Helper: Create 3/4 donut arc path ===
    // Returns a closed path for an arc-shaped ring (outer arc - inner arc) with scalloped bite edges
    func donutArcPath(outerR: CGFloat, innerR: CGFloat, addScallops: Bool) -> CGMutablePath {
        let path = CGMutablePath()

        // The donut arc covers ~270° — everything EXCEPT the bite gap in the upper-right.
        // The bite gap spans from biteStartAngle to biteEndAngle (the short arc in upper-right).
        // We want the outer arc to go the LONG way from biteEndAngle around to biteStartAngle.
        //
        // In CoreGraphics (y-up, non-flipped CTM), addArc clockwise:false goes
        // counter-clockwise in math convention (increasing angles).
        // From biteEndAngle (~104°) going counter-clockwise INCREASES the angle,
        // wrapping through 180°, 270°, 360°/0°, back to biteStartAngle (~14°).
        // That's the long 270° arc we want.
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: outerR,
                    startAngle: biteEndAngle,
                    endAngle: biteStartAngle,
                    clockwise: false) // Counter-clockwise = long way around

        if addScallops {
            // Scalloped edge at the bite start (right side of bite)
            // Go from outer radius inward to inner radius along biteStartAngle
            let numScallops = max(3, Int(outerR / (20.0 * scale)))
            let scDepth = 4.0 * scale

            // Scallop from outer to inner at biteStartAngle
            let outerPtStart = CGPoint(x: centerX + outerR * cos(biteStartAngle),
                                        y: centerY + outerR * sin(biteStartAngle))
            let innerPtStart = CGPoint(x: centerX + innerR * cos(biteStartAngle),
                                        y: centerY + innerR * sin(biteStartAngle))

            // Generate scallop points from outer to inner
            let perpXStart = -sin(biteStartAngle)
            let perpYStart = cos(biteStartAngle)

            for i in 0..<numScallops {
                let t_mid = (CGFloat(i) + 0.5) / CGFloat(numScallops)
                let t_end = CGFloat(i + 1) / CGFloat(numScallops)

                let midX = outerPtStart.x + (innerPtStart.x - outerPtStart.x) * t_mid
                let midY = outerPtStart.y + (innerPtStart.y - outerPtStart.y) * t_mid
                let endX = outerPtStart.x + (innerPtStart.x - outerPtStart.x) * t_end
                let endY = outerPtStart.y + (innerPtStart.y - outerPtStart.y) * t_end

                let side: CGFloat = (i % 2 == 0) ? 1.0 : -1.0
                let cpX = midX + perpXStart * scDepth * side
                let cpY = midY + perpYStart * scDepth * side

                path.addQuadCurve(to: CGPoint(x: endX, y: endY),
                                  control: CGPoint(x: cpX, y: cpY))
            }
        } else {
            // Straight line from outer to inner at biteStartAngle
            path.addLine(to: CGPoint(x: centerX + innerR * cos(biteStartAngle),
                                     y: centerY + innerR * sin(biteStartAngle)))
        }

        // Inner arc: from biteStartAngle going the LONG way back to biteEndAngle
        // This traces the inner edge of the donut in the OPPOSITE direction (clockwise in math)
        // to close the ring shape properly.
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: innerR,
                    startAngle: biteStartAngle,
                    endAngle: biteEndAngle,
                    clockwise: true) // Clockwise = long way back (opposite direction of outer arc)

        if addScallops {
            // Scalloped edge at the bite end (top side of bite)
            // Go from inner radius outward to outer radius along biteEndAngle
            let numScallops = max(3, Int(outerR / (20.0 * scale)))
            let scDepth = 4.0 * scale

            let innerPtEnd = CGPoint(x: centerX + innerR * cos(biteEndAngle),
                                      y: centerY + innerR * sin(biteEndAngle))
            let outerPtEnd = CGPoint(x: centerX + outerR * cos(biteEndAngle),
                                      y: centerY + outerR * sin(biteEndAngle))

            let perpXEnd = -sin(biteEndAngle)
            let perpYEnd = cos(biteEndAngle)

            for i in 0..<numScallops {
                let t_mid = (CGFloat(i) + 0.5) / CGFloat(numScallops)
                let t_end = CGFloat(i + 1) / CGFloat(numScallops)

                let midX = innerPtEnd.x + (outerPtEnd.x - innerPtEnd.x) * t_mid
                let midY = innerPtEnd.y + (outerPtEnd.y - innerPtEnd.y) * t_mid
                let endX = innerPtEnd.x + (outerPtEnd.x - innerPtEnd.x) * t_end
                let endY = innerPtEnd.y + (outerPtEnd.y - innerPtEnd.y) * t_end

                let side: CGFloat = (i % 2 == 0) ? -1.0 : 1.0
                let cpX = midX + perpXEnd * scDepth * side
                let cpY = midY + perpYEnd * scDepth * side

                path.addQuadCurve(to: CGPoint(x: endX, y: endY),
                                  control: CGPoint(x: cpX, y: cpY))
            }
        } else {
            // Straight line from inner to outer at biteEndAngle
            path.addLine(to: CGPoint(x: centerX + outerR * cos(biteEndAngle),
                                     y: centerY + outerR * sin(biteEndAngle)))
        }

        path.closeSubpath()
        return path
    }

    // === Draw donut shadow ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    ctx.setShadow(offset: CGSize(width: 3 * scale, height: -5 * scale),
                  blur: 12 * scale,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.35))

    // Draw the 3/4 arc donut shape for shadow (no scallops needed, just the silhouette)
    let shadowPath = donutArcPath(outerR: outerRadius, innerR: innerRadius, addScallops: false)
    ctx.addPath(shadowPath)
    ctx.setFillColor(CGColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0))
    ctx.fillPath()
    ctx.restoreGState()

    // === Draw donut body (warm tan) with scalloped bite edges ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let donutBodyPath = donutArcPath(outerR: outerRadius, innerR: innerRadius, addScallops: true)
    ctx.addPath(donutBodyPath)
    ctx.setFillColor(CGColor(red: 0.82, green: 0.62, blue: 0.38, alpha: 1.0)) // Warm tan
    ctx.fillPath()
    ctx.restoreGState()

    // === Draw bite cross-section (slightly darker tan for depth) at bite edges ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    let crossSectionWidth = size * 0.02

    // Draw a thin darker strip along each bite edge to show the "cake interior"
    // We do this by drawing a slightly larger donut arc and clipping to a narrow strip near the bite edges
    for edgeAngle in [biteStartAngle, biteEndAngle] {
        ctx.saveGState()

        // Create a narrow wedge clip around this bite edge
        let wedgeHalfAngle = CGFloat.pi * 0.025
        let clipPath = CGMutablePath()
        clipPath.move(to: CGPoint(x: centerX, y: centerY))
        clipPath.addArc(center: CGPoint(x: centerX, y: centerY),
                        radius: outerRadius * 1.5,
                        startAngle: edgeAngle - wedgeHalfAngle,
                        endAngle: edgeAngle + wedgeHalfAngle,
                        clockwise: false)
        clipPath.closeSubpath()
        ctx.addPath(clipPath)
        ctx.clip()

        // Draw a slightly expanded donut body in darker tan
        let expandedPath = donutArcPath(outerR: outerRadius + crossSectionWidth, innerR: max(innerRadius - crossSectionWidth, 0), addScallops: true)
        ctx.addPath(expandedPath)
        ctx.setFillColor(CGColor(red: 0.72, green: 0.52, blue: 0.30, alpha: 1.0)) // Slightly darker tan
        ctx.fillPath()

        ctx.restoreGState()
    }

    ctx.restoreGState()

    // === Draw purple glazing as a narrower band on the 3/4 arc ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // Glazing is narrower than the donut body, leaving tan margins on both sides
    let glazeInset = size * 0.035 // How much narrower the glaze is on each side
    let glazeOuterRadius = outerRadius - glazeInset
    let glazeInnerRadius = innerRadius + glazeInset

    // The glazing follows the same 3/4 arc shape but with adjusted radii and NO scallops
    // (glaze has a clean break at the bite)
    let glazePath = donutArcPath(outerR: glazeOuterRadius, innerR: glazeInnerRadius, addScallops: false)

    ctx.addPath(glazePath)

    // Purple/violet gradient for glazing
    let glazeGradientColors = [
        CGColor(red: 0.58, green: 0.28, blue: 0.72, alpha: 1.0), // Lighter purple
        CGColor(red: 0.42, green: 0.18, blue: 0.58, alpha: 1.0)  // Darker purple
    ] as CFArray

    ctx.clip()

    if let glazeGradient = CGGradient(colorsSpace: colorSpace, colors: glazeGradientColors, locations: gradientLocations) {
        ctx.drawLinearGradient(glazeGradient,
                               start: CGPoint(x: centerX - outerRadius, y: centerY + outerRadius),
                               end: CGPoint(x: centerX + outerRadius, y: centerY - outerRadius),
                               options: [])
    }
    ctx.restoreGState()

    // === Draw sprinkles on the narrower glazing band ===
    if size >= 64 { // Only draw sprinkles at larger sizes where they're visible
        let sprinkleColors: [CGColor] = [
            CGColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),  // Red
            CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0), // Yellow
            CGColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0),  // Blue
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9),  // White
            CGColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 1.0), // Orange
        ]

        struct Sprinkle {
            let angle: CGFloat   // angle on the donut (radians from positive X)
            let radiusFrac: CGFloat // 0.0 = inner glaze edge, 1.0 = outer glaze edge
            let rotation: CGFloat // visual rotation angle
            let colorIndex: Int
        }

        // Place sprinkles at specific angles along the 3/4 arc, within the glazing band
        // The safe arc range is from biteStartAngle going clockwise (through negative angles) to biteEndAngle
        // i.e., from ~14° down through 0°, -90°, -180°, up to ~284° (=biteEndAngle going the long way)
        let sprinkles: [Sprinkle] = [
            Sprinkle(angle: -0.3, radiusFrac: 0.35, rotation: 0.3, colorIndex: 0),
            Sprinkle(angle: -0.8, radiusFrac: 0.65, rotation: -0.5, colorIndex: 1),
            Sprinkle(angle: -1.3, radiusFrac: 0.4, rotation: 0.8, colorIndex: 2),
            Sprinkle(angle: -1.8, radiusFrac: 0.7, rotation: -0.2, colorIndex: 3),
            Sprinkle(angle: -2.3, radiusFrac: 0.3, rotation: 0.6, colorIndex: 4),
            Sprinkle(angle: -2.8, radiusFrac: 0.55, rotation: -0.4, colorIndex: 0),
            Sprinkle(angle: CGFloat.pi * 0.75, radiusFrac: 0.45, rotation: 0.1, colorIndex: 1),
            Sprinkle(angle: CGFloat.pi * 0.9, radiusFrac: 0.6, rotation: -0.7, colorIndex: 2),
            Sprinkle(angle: CGFloat.pi * 1.1, radiusFrac: 0.5, rotation: 0.5, colorIndex: 3),
            Sprinkle(angle: CGFloat.pi * 1.3, radiusFrac: 0.35, rotation: -0.3, colorIndex: 4),
        ]

        let sprinkleLength = 14.0 * scale
        let sprinkleWidth = 3.5 * scale

        for s in sprinkles {
            // Compute sprinkle position along the glazing band
            let r = glazeInnerRadius + s.radiusFrac * (glazeOuterRadius - glazeInnerRadius)
            let sx = centerX + r * cos(s.angle)
            let sy = centerY + r * sin(s.angle)

            // Verify the sprinkle angle is within the 3/4 arc (not in the bite gap)
            // Normalize angle to [0, 2*pi)
            var normalizedAngle = s.angle.truncatingRemainder(dividingBy: CGFloat.pi * 2)
            if normalizedAngle < 0 { normalizedAngle += CGFloat.pi * 2 }

            // The bite gap is from biteStartAngle to biteEndAngle (the short arc in upper-right)
            // Skip sprinkles that fall in this gap
            let normStart = biteStartAngle
            let normEnd = biteEndAngle
            if normalizedAngle >= normStart && normalizedAngle <= normEnd {
                continue
            }

            ctx.saveGState()
            ctx.translateBy(x: sx, y: sy)
            ctx.rotate(by: s.rotation)

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

    // === Subtle highlight on the donut for 3D effect ===
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()

    // Clip to the donut arc shape so highlight doesn't appear in the bite gap
    let highlightDonutClip = donutArcPath(outerR: outerRadius, innerR: innerRadius, addScallops: false)
    ctx.addPath(highlightDonutClip)
    ctx.clip()

    // Add a subtle light reflection on the upper-left of the donut
    let highlightCenter = CGPoint(x: centerX - outerRadius * 0.35, y: centerY + outerRadius * 0.35)
    let highlightRadius = outerRadius * 0.6

    let highlightColors = [
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.18),
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    ] as CFArray

    if let highlightGradient = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: gradientLocations) {
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
