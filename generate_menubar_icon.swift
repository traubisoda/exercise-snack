#!/usr/bin/env swift

import AppKit
import CoreGraphics

// Generate a monochrome bitten-donut template icon for the menu bar
// Template images are drawn in black — macOS automatically adapts them for light/dark mode
func generateMenuBarIcon(pixelSize: Int) -> NSImage {
    let size = CGFloat(pixelSize)
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let scale = size / 36.0 // Design at 36px (18pt @2x base)

    // === Donut parameters ===
    let centerX = size * 0.46
    let centerY = size * 0.50
    let outerRadius = size * 0.40
    let innerRadius = size * 0.15

    // Bite parameters - upper right area
    let biteAngle = CGFloat.pi * 0.3
    let biteRadius = size * 0.20
    let biteCenterX = centerX + outerRadius * 0.78 * cos(biteAngle)
    let biteCenterY = centerY + outerRadius * 0.78 * sin(biteAngle)

    // === Draw donut shape: clip out bite first, then draw outer minus hole ===
    ctx.saveGState()

    // Clip OUT the bite area first (rect + bite ellipse with even-odd = everything except bite)
    let biteClipPath = CGMutablePath()
    biteClipPath.addRect(CGRect(x: 0, y: 0, width: size, height: size))
    biteClipPath.addEllipse(in: CGRect(x: biteCenterX - biteRadius, y: biteCenterY - biteRadius,
                                        width: biteRadius * 2, height: biteRadius * 2))
    ctx.addPath(biteClipPath)
    ctx.clip(using: .evenOdd) // Clips to everything EXCEPT the bite circle

    // Now draw the donut ring (outer minus hole) — bite is already clipped out
    let donutPath = CGMutablePath()
    donutPath.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                     width: outerRadius * 2, height: outerRadius * 2))
    donutPath.addEllipse(in: CGRect(x: centerX - innerRadius, y: centerY - innerRadius,
                                     width: innerRadius * 2, height: innerRadius * 2))

    ctx.addPath(donutPath)
    // Black fill — template rendering mode will handle light/dark adaptation
    ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1.0))
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()

    // === Draw glazing line on top half for recognizability ===
    // A thicker arc on the upper portion to suggest glazing
    let glazeLineWidth = 1.8 * scale
    let glazeRadius = (outerRadius + innerRadius) / 2.0 + size * 0.02

    ctx.saveGState()

    // Clip out the bite area first
    let glazeBiteClip = CGMutablePath()
    glazeBiteClip.addRect(CGRect(x: 0, y: 0, width: size, height: size))
    glazeBiteClip.addEllipse(in: CGRect(x: biteCenterX - biteRadius, y: biteCenterY - biteRadius,
                                         width: biteRadius * 2, height: biteRadius * 2))
    ctx.addPath(glazeBiteClip)
    ctx.clip(using: .evenOdd) // Clips to everything EXCEPT the bite circle

    // Then clip to the donut body (exclude hole)
    let clipPath = CGMutablePath()
    clipPath.addEllipse(in: CGRect(x: centerX - outerRadius, y: centerY - outerRadius,
                                    width: outerRadius * 2, height: outerRadius * 2))
    clipPath.addEllipse(in: CGRect(x: centerX - innerRadius, y: centerY - innerRadius,
                                    width: innerRadius * 2, height: innerRadius * 2))
    ctx.addPath(clipPath)
    ctx.clip(using: .evenOdd)

    // Draw a white arc line to create the glazing edge detail
    // This creates a subtle separation between glaze and body
    let glazeArcPath = CGMutablePath()
    // Arc from roughly left side, across top, to the bite area
    glazeArcPath.addArc(center: CGPoint(x: centerX, y: centerY),
                        radius: glazeRadius,
                        startAngle: CGFloat.pi * 0.7,
                        endAngle: CGFloat.pi * 0.05,
                        clockwise: true)

    ctx.addPath(glazeArcPath)
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    ctx.setLineWidth(glazeLineWidth)
    ctx.strokePath()

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

// Menu bar icon sizes: 18x18 (@1x) and 36x36 (@2x)
let iconSizes: [(name: String, pixels: Int)] = [
    ("menubar_icon.png", 18),
    ("menubar_icon@2x.png", 36),
]

let outputDir = "ExerciseSnack/Assets.xcassets/MenuBarIcon.imageset"

// Create output directory
let fm = FileManager.default
try! fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for iconSize in iconSizes {
    let image = generateMenuBarIcon(pixelSize: iconSize.pixels)
    let path = "\(outputDir)/\(iconSize.name)"
    savePNG(image: image, path: path, pixelSize: iconSize.pixels)
    print("Generated \(iconSize.name) (\(iconSize.pixels)x\(iconSize.pixels)px)")
}

print("\nMenu bar icons generated successfully!")
