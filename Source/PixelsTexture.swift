//
//  PixelsTexture.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

extension Pixels {
    
    enum TextureError: Error {
        case pixelBuffer
        case empty
        case copy(String)
        case multi(String)
    }
    
    func buffer(from image: CGImage, at size: CGSize?) -> CVPixelBuffer? {
        #if os(iOS)
        return buffer(from: UIImage(cgImage: image))
        #elseif os(macOS)
        guard size != nil else { return nil }
        return buffer(from: NSImage(cgImage: image, size: size!))
        #endif
    }
    
    #if os(iOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    func buffer(from image: _Image) -> CVPixelBuffer? {
        
        #if os(iOS)
        let scale: CGFloat = image.scale
        #elseif os(macOS)
        let scale: CGFloat = 1.0
        #endif
        
        let width = image.size.width * scale
        let height = image.size.height * scale
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
//            String(kCVPixelBufferIOSurfacePropertiesKey): [
//                "IOSurfaceOpenGLESFBOCompatibility": true,
//                "IOSurfaceOpenGLESTextureCompatibility": true,
//                "IOSurfaceCoreAnimationCompatibility": true,
//                ]
            ] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         colorBits.os,
                                         attrs,
                                         &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8, // FIXME: colorBits.rawValue,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return nil
        }
        
        #if os(iOS)
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        #elseif os(macOS)
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        #endif
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func makeTexture(from pixelBuffer: CVPixelBuffer) throws -> MTLTexture {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        // MARK: No Sim
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, PIX.Color.Bits._8.mtl, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            throw TextureError.pixelBuffer
        }
        return inputTexture
    }
    
    func emptyTexture(size: CGSize) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: colorBits.mtl, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let t = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.empty
        }
        return t
    }
    
    func copyTexture(from pix: PIX) throws -> MTLTexture {
        guard let texture = pix.texture else {
            throw TextureError.copy("PIX Texture is nil.")
        }
        let textureCopy = try emptyTexture(size: CGSize(width: pix.texture!.width, height: pix.texture!.height))
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw TextureError.copy("Command Buffer make failed.")
        }
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.copy("Blit Command Encoder make failed.")
        }
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1), to: textureCopy, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    func makeMultiTexture(from textures: [MTLTexture], with commandBuffer: MTLCommandBuffer) throws -> MTLTexture {
        
        guard !textures.isEmpty else {
            throw TextureError.multi("Passed Textures array is empty.")
        }
        
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = colorBits.mtl
        descriptor.textureType = .type2DArray
        descriptor.width = textures.first!.width
        descriptor.height = textures.first!.height
        descriptor.arrayLength = textures.count
        
        guard let multiTexture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw TextureError.multi("Texture creation failed.")
        }

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw TextureError.multi("Blit Encoder creation failed.")
        }
        
        for (i, texture) in textures.enumerated() {
            blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: texture.width, height: texture.height, depth: 1), to: multiTexture, destinationSlice: i, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        }
        blitEncoder.endEncoding()
        
        return multiTexture
    }
    
    func textures(from pix: PIX, with commandBuffer: MTLCommandBuffer) throws -> (MTLTexture?, MTLTexture?) {

        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else {
                    throw RenderError.texture("Pixel Buffer is nil.")
                }
                inputTexture = try makeTexture(from: pixelBuffer)
            } else if pixContent is PIXGenerator {
                generator = true
            } else if let pixSprite = pixContent as? PIXSprite {
                guard let spriteTexture = pixSprite.sceneView.texture(from: pixSprite.scene) else {
                    throw RenderError.texture("Sprite Texture fail.")
                }
                let spriteImage: CGImage = spriteTexture.cgImage()
                guard let spriteBuffer = buffer(from: spriteImage, at: pixSprite.res.size) else {
                    throw RenderError.texture("Sprite Buffer fail.")
                }
                inputTexture = try makeTexture(from: spriteBuffer)
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            if let pixInMulti = pixIn as? PIXInMulti {
                var inTextures: [MTLTexture] = []
                for (i, pixOut) in pixInMulti.inPixs.enumerated() {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture \(i) not found for: \(pixOut)")
                    }
                    inTextures.append(pixOutTexture)
                }
                inputTexture = try makeMultiTexture(from: inTextures, with: commandBuffer)
            } else {
                guard let pixOut = pixIn.pixInList.first else {
                    throw RenderError.texture("inPix not connected.")
                }
                var feed = false
                if let feedbackPix = pixIn as? FeedbackPIX {
                    if feedbackPix.readyToFeed && feedbackPix.feedActive {
                        guard let feedTexture = feedbackPix.feedTexture else {
                            throw RenderError.texture("Feed Texture not avalible.")
                        }
                        inputTexture = feedTexture
                        feed = true
                    }
                }
                if !feed {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture not found for: \(pixOut)")
                    }
                    inputTexture = pixOutTexture // CHECK copy?
                    if pix is PIXInMerger {
                        let pixOutB = pixIn.pixInList[1]
                        guard let pixOutTextureB = pixOutB.texture else {
                            throw RenderError.texture("IO Texture B not found for: \(pixOutB)")
                        }
                        secondInputTexture = pixOutTextureB // CHECK copy?
                    }
                }
            }
        }
        
        guard generator || inputTexture != nil else {
            throw RenderError.texture("Input Texture missing.")
        }
        
        // MARK: Custom Render
        
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                throw RenderError.custom("PixelsCustomRenderDelegate not implemented.")
            }
            guard let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) else {
                throw RenderError.custom("Custom Render faild.")
            }
            inputTexture = customRenderedTexture
        }
        
        return (inputTexture, secondInputTexture)
        
    }
    
}
