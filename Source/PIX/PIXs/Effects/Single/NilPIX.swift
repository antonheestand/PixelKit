//
//  NilPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-15.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution

final public class NilPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "nilPIX" }
    
    let nilOverrideBits: Bits?
    public override var overrideBits: Bits? { nilOverrideBits }
    
    public required init(name: String = "Nil") {
        nilOverrideBits = nil
        super.init(name: name, typeName: "pix-effect-single-nil")
    }
    
    public required init() {
        nilOverrideBits = nil
        super.init(name: "Nil", typeName: "pix-effect-single-nil")
    }
    
    public init(overrideBits: Bits) {
        nilOverrideBits = overrideBits
        super.init(name: "Nil (\(overrideBits.rawValue)bit)", typeName: "pix-effect-single-nil")
    }
    
}

public extension NODEOut {
    
    /// bypass is `false` by *default*
    func pixNil(bypass: Bool = false) -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.input = self as? PIX & NODEOut
        nilPix.bypass = bypass
        return nilPix
    }
    
}
