//
//  RangePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//
import CoreGraphics//x

public class RangePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleRangePIX" }
    
    // MARK: - Public Properties
    
    public var inLow: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var inHigh: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var outLow: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var outHigh: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var inLowColor: LiveColor = .clear { didSet { setNeedsRender() } }
    public var inHighColor: LiveColor = .white { didSet { setNeedsRender() } }
    public var outLowColor: LiveColor = .clear { didSet { setNeedsRender() } }
    public var outHighColor: LiveColor = .white { didSet { setNeedsRender() } }
    public var ignoreAlpha: Bool = true { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case inLow; case inHigh; case outLow; case outHigh; case inLowColor; case inHighColor; case outLowColor; case outHighColor; case ignoreAlpha
//    }
    
    open override var uniforms: [CGFloat] {
        var vals = [inLow, inHigh, outLow, outHigh]
        vals.append(contentsOf: inLowColor.list)
        vals.append(contentsOf: inHighColor.list)
        vals.append(contentsOf: outLowColor.list)
        vals.append(contentsOf: outHighColor.list)
        vals.append(ignoreAlpha ? 1 : 0)
        return vals
    }
    
    public override required init() {
        super.init()
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        inLow = try container.decode(CGFloat.self, forKey: .inLow)
//        inHigh = try container.decode(CGFloat.self, forKey: .inHigh)
//        outLow = try container.decode(CGFloat.self, forKey: .outLow)
//        outHigh = try container.decode(CGFloat.self, forKey: .outHigh)
//        inLowLiveColor = try container.decode(Color.self, forKey: .inLowColor)
//        inHighLiveColor = try container.decode(Color.self, forKey: .inHighColor)
//        outLowLiveColor = try container.decode(Color.self, forKey: .outLowColor)
//        outHighLiveColor = try container.decode(Color.self, forKey: .outHighColor)
//        ignoreAlpha = try container.decode(Bool.self, forKey: .ignoreAlpha)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(inLow, forKey: .inLow)
//        try container.encode(inHigh, forKey: .inHigh)
//        try container.encode(outLow, forKey: .outLow)
//        try container.encode(outHigh, forKey: .outHigh)
//        try container.encode(inLowColor, forKey: .inLowColor)
//        try container.encode(inHighColor, forKey: .inHighColor)
//        try container.encode(outLowColor, forKey: .outLowColor)
//        try container.encode(outHighColor, forKey: .outHighColor)
//        try container.encode(ignoreAlpha, forKey: .ignoreAlpha)
//    }
    
}

public extension PIXOut {
    
    func _range(inLow: CGFloat = 0.0, inHigh: CGFloat = 1.0, outLow: CGFloat = 0.0, outHigh: CGFloat = 1.0) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLow = inLow
        rangePix.inHigh = inHigh
        rangePix.outLow = outLow
        rangePix.outHigh = outHigh
        return rangePix
    }
    
    func _range(inLow: LiveColor = .clear, inHigh: LiveColor = .white, outLow: LiveColor = .clear, outHigh: LiveColor = .white) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.name = ":range:"
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLowColor = inLow
        rangePix.inHighColor = inHigh
        rangePix.outLowColor = outLow
        rangePix.outHighColor = outHigh
        return rangePix
    }
    
}
