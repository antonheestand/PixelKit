//
//  Live.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics

public class Live {
    
    public static let now = Live()
    
    let start = Date()
    
    public var float: LiveFloat!
    
//    public var touch: LivePoint?
//    public var touchDown: LiveBool
//    public var multiTouch: LivePointArray
//    public var mouse: LivePoint
//    public var mouseLeft: LiveBool
//    public var mouseRight: LiveBool
//
//    public var darkMode: LiveBool
//
//    public var year: LiveInt!
//    public var years: LiveFloat!
//    public var month: LiveInt!
//    public var months: LiveFloat!
//    public var day: LiveInt!
//    public var days: LiveFloat!
//    public var hour: LiveInt!
//    public var hours: LiveFloat!
//    public var minute: LiveInt!
//    public var minutes: LiveFloat!
//    public var second: LiveInt!
//    public var seconds: LiveFloat!
//    public var secondsSinceLaunch: LiveFloat!
//    public var secondsSince1970: LiveFloat!
    
    init() {
        float = LiveFloat { () -> (CGFloat) in
            return CGFloat(-self.start.timeIntervalSinceNow)
        }
    }
    
    public func test() {
        let x: LiveFloat = 2
        print(x, float)
    }
    
}

extension CGFloat {
    
}

public class LiveFloat: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    let literal: Bool
    
    public var description: String {
        return literal ? "Float(\(native))" : "LiveFloat(\(native))"
    }
    //Equatable, Comparable { //}: ExpressibleByFloatLiteral {
    
    public typealias NativeType = CGFloat
    public var native: LiveFloat.NativeType
    
//    public var value: CGFloat {
//        return future()
//    }
//    let future: () -> (CGFloat)
    
    public init(_ futureValue: @escaping () -> (CGFloat)) {
        native = futureValue()
//        future = futureValue
        literal = false
    }
    
    init(_ futureValue: @escaping () -> (CGFloat), literal: Bool) {
        native = futureValue()
        //        future = futureValue
        self.literal = literal
    }
    
    required public convenience init(floatLiteral value: FloatLiteralType) {
        self.init({ () -> (CGFloat) in
            return CGFloat(value)
        }, literal: true)
    }
    
    required public convenience init(integerLiteral value: IntegerLiteralType) {
        self.init({ () -> (CGFloat) in
            return CGFloat(value)
        }, literal: true)
    }
    
}
