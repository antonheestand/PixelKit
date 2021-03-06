//
//  ReducePIX.swift
//
//
//  Created by Anton Heestand on 2020-07-03.
//


import RenderKit
import Resolution
import MetalPerformanceShaders

@available(tvOS 11.3, *)
@available(iOS 11.3, *)
@available(OSX 10.13.4, *)
final public class ReducePIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }

    override var customResolution: Resolution? {
        guard let inputResolution: Resolution = (input as! PIX?)?.derivedResolution else { return nil }
        return getCustomResolution(from: inputResolution)
    }

    // MARK: - Public Properties
    
    public enum CellList {
        case column
        case row
    }
    
    /// the cell list that will be sampled
    ///
    /// one pixel row is *default*
    public var cellList: CellList = .row { didSet { applyResolution { [weak self] in self?.render() } } }
    
    public enum Method {
        /// average
        case avg
        /// minumum
        case min
        /// maximum
        case max
        /// sum of all pixels the cell list
        case sum
    }
    
    public var method: Method = .avg { didSet { render() } }

    public required init() {
        super.init(name: "Reduce", typeName: "pix-effect-single-reduce")
        customRenderActive = true
        customRenderDelegate = self
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: - Custom Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let resolution: Resolution = getCustomResolution(from: texture.resolution)
        guard let destinationTexture: MTLTexture = try? Texture.emptyTexture(size: resolution.size,
                                                                             bits: pixelKit.render.bits,
                                                                             on: pixelKit.render.metalDevice,
                                                                             write: true) else {
            pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let reduceKernel: MPSImageReduceUnary = getKernel(with: pixelKit.render.metalDevice)
        #if !os(tvOS) && !targetEnvironment(simulator)
        reduceKernel.edgeMode = extend.mps!
        #endif
        reduceKernel.encode(commandBuffer: commandBuffer,
                            sourceTexture: texture,
                            destinationTexture: destinationTexture)
        return destinationTexture
    }
    
    // MARK: - Resolution
    
    func getCustomResolution(from resolution: Resolution) -> Resolution {
        switch cellList {
        case .column:
            return .custom(w: 1, h: resolution.h)
        case .row:
            return .custom(w: resolution.w, h: 1)
        }
    }
    
    // MARK: - Kernel
    
    func getKernel(with device: MTLDevice) -> MPSImageReduceUnary {
        switch cellList {
        case .row:
            switch method {
            case .avg:
                return MPSImageReduceColumnMean(device: device)
            case .min:
                return MPSImageReduceColumnMin(device: device)
            case .max:
                return MPSImageReduceColumnMax(device: device)
            case .sum:
                return MPSImageReduceColumnSum(device: device)
            }
        case .column:
            switch method {
            case .avg:
                return MPSImageReduceRowMean(device: device)
            case .min:
                return MPSImageReduceRowMin(device: device)
            case .max:
                return MPSImageReduceRowMax(device: device)
            case .sum:
                return MPSImageReduceRowSum(device: device)
            }
        }
    }
    
}
