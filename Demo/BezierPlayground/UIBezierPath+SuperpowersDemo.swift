//
//  UIBezierPath+SuperpowersDemo.swift
//  BezierPlayground
//
//  Created by Maximilian Kraus on 13.07.17.
//  Copyright © 2017 Maximilian Kraus. All rights reserved.
//

import UIKit


/// -- -- -- -- -- IMPORTANT -- -- -- -- --

/*
 *  This file is an adjusted version of the UIBezierPath+Superpowers.
 *
 *  It makes several internal structs and properties publicly available for demo purposes.
 *  You should not use this file in your production code. Use UIBezierPath+Superpowers.
 */



//MARK: - Settings. Public for demo app.

/// The precision with which to calculate the length of the path.
/// Higher precision is naturally more expensive to compute.
enum LengthCalculationPrecision: Int {
  case low = 50
  case normal = 100
  case high = 150
}

var lengthCalculationPrecision: LengthCalculationPrecision = .normal

/// The precision with which to calculate the perpendicular points and distances.
/// Higher precision is naturally more expensive to compute.
enum PerpendicularCalculationPrecision: CGFloat {
  case low = 15
  case normal = 5
  case high = 2
}

var perpendicularCalculationPrecision: PerpendicularCalculationPrecision = .normal
//  -


//MARK: - Public API
extension UIBezierPath {
  
  //  Public for demo app.
  
  var mx_lookupTable: [CGPoint] {
    calculatePointLookupTable()
    
    return extractPathElements().flatMap { return $0.pointsLookupTable! }
  }
  
  func invalidatePathCalculations() {
    mx_pathElements = nil
    mx_pathLength = nil
    mx_lengthRangesCalculated = false
    mx_pointLookupTableCalculated = false
  }
  
  //  -
  
  /// Call this method once to enable this library to automatically handle path mutations.
  /// Sadly, Swift does not allow us to utilize the `load` or `initialize` methods anymore, which
  /// could do this automatically for you, so you have to do it manually. Sorry.
  ///
  /// - Important:
  /// Invoking this method will perform runtime method swizzling to enable the extension to
  /// be notified when the path object is mutated. You should preferably call this method in
  /// your AppDelegate class or another piece of code that runs when your process is started:
  ///
  /// ```
  /// 
  ///  @UIApplicationMain
  ///  class AppDelegate: UIResponder, UIApplicationDelegate {
  ///    var window: UIWindow?
  ///
  ///    override init() {
  ///      super.init()
  ///
  ///      UIBezierPath.mx_prepare()
  ///    }
  ///  }
  ///
  /// ```
  ///
  /// You **do not have to** call this method in order for this library to work.
  /// However, opting out will result in the internal caching to be deactivated, which
  /// may cause a major performance impact, depending on your use case and how complex your path objects are.
  ///
  /// If you can guarantee that your path objects won't be mutated after the first time you call
  /// any of the mx_* methods or properties, you can set the internal variable `swizzled` to `true` without calling
  /// this method. This will result in the caching to be re-activated. Note however, that if you go down
  /// that road and mutate your path objects anyway, the library will base its calculations on the intercal cache
  /// which may not be in sync with the actual path object.
  static func mx_prepare() {
    if swizzled { return }
    
    let swizzlingPairs: [(Selector, Selector)] = [
      (#selector(UIBezierPath.addLine), #selector(UIBezierPath.mx_addLine)),
      (#selector(UIBezierPath.addCurve), #selector(UIBezierPath.mx_addCurve)),
      (#selector(UIBezierPath.addQuadCurve ), #selector(UIBezierPath.mx_addQuadCurve)),
      (#selector(UIBezierPath.addArc), #selector(UIBezierPath.mx_addArc)),
      (#selector(UIBezierPath.close), #selector(UIBezierPath.mx_close)),
      (#selector(UIBezierPath.removeAllPoints), #selector(UIBezierPath.mx_removeAllPoints)),
      (#selector(UIBezierPath.append), #selector(UIBezierPath.mx_append)),
      (#selector(UIBezierPath.apply), #selector(UIBezierPath.mx_apply))
    ]
    
    swizzlingPairs.forEach {
      swizzle(self, $0.0, $0.1)
    }
    
    swizzled = true
  }
  
  
  /// Returns the total length of the receiver.
  ///
  /// Note that if you did not call `mx_prepare`, the internal calculations of this operation
  /// are not cached. In this case, it is not safe to access this property frequently without creating any overhead.
  var mx_length: CGFloat {
    let length = calculateLength()
    
    if !swizzled { invalidatePathCalculations() }
    
    return length
  }
  
  
  /// Returns the point on the path at `t * length` in to the path.
  /// If the receiver is empty, `CGPoint.zero` is returned.
  ///
  /// - Parameters:
  ///   - t: The fraction of the total path length for which to return the point on the path.
  func mx_point(atFractionOfLength t: CGFloat) -> CGPoint {
    if isEmpty {
      return .zero
    }
    
    var point: CGPoint = .zero
    
    findPathElement(at: t) { element, t in
      point = element.point(at: t)
    }
    
    if !swizzled { invalidatePathCalculations() }
    
    return point
  }
  
  
  /// For a given t, returns the slope of the path at the point
  /// `t * length` in to the path.
  /// If the receiver is empty, `0` is returned.
  ///
  /// - Note:
  ///   The slope is expressed in context of the positiv cartesian x-axis.
  ///   i.e. for a path starting at `{0,100}` and ending at `{100,0}`, this method
  ///   will return a slope of `1.0` for any `t`.
  ///   Keep in mind that the y-axis of the iOS coordinate system is inversed.
  ///
  /// - Parameter t: The
  /// - Returns: a
  func mx_slope(atFractionOfLength t: CGFloat) -> CGFloat {
    if isEmpty {
      return 0
    }
    
    var slope: CGFloat = 0
    
    findPathElement(at: t) { element, t in
      slope = element.slope(at: t)
    }
    
    if !swizzled { invalidatePathCalculations() }
    
    //  Returning -slope, because the y-axis of the iOS coordinate system is inverse.
    //  By default, positive slopes would go down, negative go up. This is counter intuitive.
    return -slope
  }
  
  
  /// For a given t, returns the tangent angle of the path at the point
  /// `t * length` in to the path.
  /// If the receiver is empty, `0` is returned.
  ///
  /// - Note:
  ///   The angle is expressed in radian unit and in context of the positiv cartesian x-axis.
  ///   i.e. rotating (mathematically = counter clockwise) a horizontal line that starts in the point on the path
  ///   which corresponds to fraction `t`, around said point by the return value of this method,
  ///   results in the line being the tangent of the path in that point.
  ///
  /// - Parameter t: The fraction
  /// - Returns: The tangent angle
  func mx_tangentAngle(atFractionOfLength t: CGFloat) -> CGFloat {
    if isEmpty {
      return 0
    }
    
    var angle: CGFloat = 0
    
    findPathElement(at: t) { element, t in
      angle = element.tangentAngle(at: t)
    }
    
    if !swizzled { invalidatePathCalculations() }
    
    //  Rotating by .pi / 2, because the y-axis of the iOS coordinate system is inversed.
    //  Smaller values are at the top, increasing to the bottom. This is invers to the
    //  cartesian coordinate system.
    return angle - .pi / 2
  }
  
  
  /// Returns the closest point on the path to a given `CGPoint`,
  /// effectively letting fall a perpendicular on the path from `point`
  /// and returning the point of intersection.
  ///
  /// - Parameters:
  ///   - point: The point from which to letting fall the perpendicular.
  func mx_perpendicularPoint(for point: CGPoint) -> CGPoint {
    
    calculatePointLookupTable()
    
    var closestPoint: (p: CGPoint, distance: CGFloat) = (.zero, .greatestFiniteMagnitude)
    
    for element in extractPathElements() {
      if let lookupTable = element.pointsLookupTable {
        for p in lookupTable {
          let distance = p.linearLineLength(to: point)
          
          if distance < closestPoint.distance {
            closestPoint = (p, distance)
          }
        }
      }
    }
    
    if !swizzled { invalidatePathCalculations() }
    
    return closestPoint.p
  }
  
  
  /// Convenience method to calculate the perpendicular distance from a
  /// given `CGPoint` to the receiver. See `mx_perpendicularPoint(for:)`.
  ///
  /// - Parameters:
  ///   - point: The point for which to calculate the distance.
  func mx_perpendicularDistance(from point: CGPoint) -> CGFloat {
    let closestPathPoint = mx_perpendicularPoint(for: point)
    return closestPathPoint.linearLineLength(to: point)
  }
}
//  -


//MARK: - Internal
fileprivate struct BezierPathElement {
  let type: CGPathElementType
  
  var startPoint: CGPoint
  var endPoint: CGPoint
  var controlPoints: [CGPoint]
  
  var pointsLookupTable: [CGPoint]?
  
  var lengthRange: ClosedRange<CGFloat>?
  
  private let calculatedLength: CGFloat
  var length: CGFloat {
    return calculatedLength == 0 ? 1 : calculatedLength
  }
  
  
  init(type: CGPathElementType, startPoint: CGPoint, endPoint: CGPoint, controlPoints: [CGPoint] = []) {
    self.type = type
    self.startPoint = startPoint
    self.endPoint = endPoint
    self.controlPoints = controlPoints
    
    calculatedLength = type.calculateLength(from: startPoint, to: endPoint, controlPoints: controlPoints)
  }
  
  
  func point(at t: CGFloat) -> CGPoint {
    switch type {
    case .addLineToPoint:
      return startPoint.linearBezierPoint(to: endPoint, t: t)
    case .addQuadCurveToPoint:
      return startPoint.quadBezierPoint(to: endPoint, controlPoint: controlPoints[0], t: t)
    case .addCurveToPoint:
      return startPoint.cubicBezierPoint(to: endPoint, controlPoint1: controlPoints[0], controlPoint2: controlPoints[1], t: t)
    default:
      return .zero
    }
  }
  
  func slope(at t: CGFloat) -> CGFloat {
    switch type {
    case .addLineToPoint:
      return startPoint.linearSlope(to: endPoint, t: t)
    case .addQuadCurveToPoint:
      return startPoint.quadSlope(to: endPoint, controlPoint: controlPoints[0], t: t)
    case .addCurveToPoint:
      return startPoint.cubicSlope(to: endPoint, controlPoint1: controlPoints[0], controlPoint2: controlPoints[1], t: t)
    default:
      return 0
    }
  }
  
  func tangentAngle(at t: CGFloat) -> CGFloat {
    switch type {
    case .addLineToPoint:
      return startPoint.linearTangentAngle(to: endPoint, t: t)
    case .addQuadCurveToPoint:
      return startPoint.quadTangentAngle(to: endPoint, controlPoint: controlPoints[0], t: t)
    case .addCurveToPoint:
      return startPoint.cubicTangentAngle(to: endPoint, controlPoint1: controlPoints[0], controlPoint2: controlPoints[1], t: t)
    default:
      return 0
    }
  }
  
  mutating func apply(transform t: CGAffineTransform) {
    guard t.isTranslationOnly else { return }
    
    startPoint = startPoint.applying(t)
    endPoint = endPoint.applying(t)
    controlPoints = controlPoints.map { $0.applying(t) }
  }
}


fileprivate typealias CGPathApplierClosure = @convention(block) (CGPathElement) -> Void

fileprivate extension CGPath {
  func apply(closure: @escaping CGPathApplierClosure) {
    self.apply(info: unsafeBitCast(closure, to: UnsafeMutableRawPointer.self)) { (info, element) in
      let block = unsafeBitCast(info, to: CGPathApplierClosure.self)
      block(element.pointee)
    }
  }
}


fileprivate extension CGAffineTransform {
  /// Whether or not this transform solely consists of a translation.
  /// Note that the value of this property is `false`, when the receiver is `.identity`.
  var isTranslationOnly: Bool {
    for x in [a, b, c, d] {
      if x != 0 {
        return false
      }
    }
    
    return tx != 0 || ty != 0
  }
}

fileprivate extension CGPathElement {
  var mx_points: [CGPoint] {
    return Array(UnsafeBufferPointer(start: points, count: type.numberOfPoints))
  }
}

fileprivate extension CGPathElementType {
  var numberOfPoints: Int {
    switch self {
    case .moveToPoint, .addLineToPoint:
      return 1
    case .addQuadCurveToPoint:
      return 2
    case .addCurveToPoint:
      return 3
    case .closeSubpath:
      return 0
    }
  }
  
  func calculateLength(from: CGPoint, to: CGPoint, controlPoints: [CGPoint]) -> CGFloat {
    switch self {
    case .moveToPoint:
      return 0
    case .addLineToPoint, .closeSubpath:
      return from.linearLineLength(to: to)
    case .addQuadCurveToPoint:
      return from.quadCurveLength(to: to, controlPoint: controlPoints[0])
    case .addCurveToPoint:
      return from.cubicCurveLength(to: to, controlPoint1: controlPoints[0], controlPoint2: controlPoints[1])
    }
  }
}


fileprivate extension UIBezierPath {
  func extractPathElements() -> [BezierPathElement] {
    if let pathElements = self.mx_pathElements {
      return pathElements
    }
    
    var pathElements: [BezierPathElement] = []
    
    var currentPoint: CGPoint = .zero
    
    cgPath.apply { element in
      
      let type = element.type
      let points = element.mx_points
      
      var endPoint: CGPoint = .zero
      var controlPoints: [CGPoint] = []
      
      //  Every UIBezierPath - no matter how complex - is created through a combination of these path elements.
      switch type {
      case .moveToPoint, .addLineToPoint:
        endPoint = points[0]
      case .addQuadCurveToPoint:
        endPoint = points[1]
        controlPoints.append(points[0])
      case .addCurveToPoint:
        endPoint = points[2]
        controlPoints.append(contentsOf: points[0...1])
      case .closeSubpath:
        break
      }
      
      if type != .closeSubpath && type != .moveToPoint {
        let pathElement = BezierPathElement(type: type, startPoint: currentPoint, endPoint: endPoint, controlPoints: controlPoints)
        
        pathElements.append(pathElement)
      }
      
      currentPoint = endPoint
    }
    
    
    self.mx_pathElements = pathElements
    
    return pathElements
  }
  
  func findPathElement(at t: CGFloat, callback: (_ e: BezierPathElement, _ t: CGFloat) -> Void) {
    //  Clamp between 0 and 1.0
    let t = min(max(0, t), 1)
    
    calculateLengthRanges()
    
    for element in extractPathElements() {
      if let lengthRange = element.lengthRange, lengthRange.contains(t) {
        let tInElement = (t - lengthRange.lowerBound) / (lengthRange.upperBound - lengthRange.lowerBound)
        callback(element, tInElement)
        break
      }
    }
  }
  
  func calculateLength() -> CGFloat {
    if let length = self.mx_pathLength {
      return length
    }
    
    let pathElements = extractPathElements()
    let length = pathElements.reduce(0) { $0 + $1.length }
    
    self.mx_pathLength = length
    
    return length
  }
  
  func calculateLengthRanges() {
    if mx_lengthRangesCalculated {
      return
    }
    
    var pathElements = extractPathElements()
    
    let totalPathLength = calculateLength()
    
    var lengthRangeStart: CGFloat = 0
    
    for idx in pathElements.indices {
      let elementLength = pathElements[idx].length
      var lengthRangeEnd = lengthRangeStart + elementLength / totalPathLength
      
      if idx == pathElements.count - 1 {
        lengthRangeEnd = 1
      }
      
      pathElements[idx].lengthRange = lengthRangeStart...lengthRangeEnd
      
      lengthRangeStart = lengthRangeEnd
    }
    
    mx_pathElements = pathElements
    mx_lengthRangesCalculated = true
  }
  
  func calculatePointLookupTable() {
    if mx_pointLookupTableCalculated {
      return
    }
    
    var pathElements = extractPathElements()
    
    //  Step through all path elements and calculate points.
    //  The start and end point of the whole path are always included.
    let step = perpendicularCalculationPrecision.rawValue
    var offset: CGFloat = 0
    
    for idx in pathElements.indices {
      var element = pathElements[idx]
      
      var points: [CGPoint] = []
      
      while offset < element.length {
        points.append(element.point(at: offset / element.length))
        offset += step
      }
      
      if idx == pathElements.count - 1 && (offset - step) < element.length {
        points.append(element.point(at: 1))
      }
      
      offset -= element.length
      
      if points.isEmpty {
        points.append(element.point(at: 0.5))
      }
      
      element.pointsLookupTable = points
      
      pathElements[idx] = element
    }
    
    mx_pathElements = pathElements
    mx_pointLookupTableCalculated = true
  }
}
//  -


//MARK: - Black magic
fileprivate var pathElementsKey = "mx_pathElements_key"
fileprivate var pathLengthKey = "mx_pathLength_key"
fileprivate var pathElementsLengthRangesCalculated = "mx_pathElementsLengthRangesCalculated_key"
fileprivate var pathElementsPointLookupTableCalculated = "mx_pathElementsPointLookupTableCalculated_key"

fileprivate extension UIBezierPath {
  var mx_pathElements: [BezierPathElement]? {
    get {
      return objc_getAssociatedObject(self, &pathElementsKey) as? [BezierPathElement]
    }
    set {
      objc_setAssociatedObject(self, &pathElementsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var mx_pathLength: CGFloat? {
    get {
      return objc_getAssociatedObject(self, &pathLengthKey) as? CGFloat
    }
    set {
      objc_setAssociatedObject(self, &pathLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var mx_lengthRangesCalculated: Bool {
    get {
      return objc_getAssociatedObject(self, &pathElementsLengthRangesCalculated) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &pathElementsLengthRangesCalculated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var mx_pointLookupTableCalculated: Bool {
    get {
      return objc_getAssociatedObject(self, &pathElementsPointLookupTableCalculated) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &pathElementsPointLookupTableCalculated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
//  -


//MARK: - Swizzled selectors
//  dispatch_once is no longer available in Swift -.-
private var swizzled = false

fileprivate func swizzle(_ c: AnyClass, _ originalSelector: Selector, _ swizzledSelector: Selector) {
  guard
    let originalMethod = class_getInstanceMethod(c, originalSelector),
    let swizzledMethod = class_getInstanceMethod(c, swizzledSelector)
    else { return }
  
  method_exchangeImplementations(originalMethod, swizzledMethod)
}

fileprivate extension UIBezierPath {
  @objc func mx_addLine(to point: CGPoint) {
    print(#function)
    
    mx_addLine(to: point)
    
    invalidatePathCalculations()
  }
  
  @objc func mx_addCurve(to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
    print(#function)
    
    mx_addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    
    invalidatePathCalculations()
  }
  
  @objc func mx_addQuadCurve(to endPoint: CGPoint, controlPoint: CGPoint) {
    print(#function)
    
    mx_addQuadCurve(to: endPoint, controlPoint: controlPoint)
    
    invalidatePathCalculations()
  }
  
  @objc func mx_addArc(withCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
    print(#function)
    
    mx_addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    
    invalidatePathCalculations()
  }
  
  @objc func mx_close() {
    print(#function)
    
    mx_close()
    
    invalidatePathCalculations()
  }
  
  @objc func mx_removeAllPoints() {
    print(#function)
    
    mx_removeAllPoints()
    
    invalidatePathCalculations()
  }
  
  @objc func mx_append(path: UIBezierPath) {
    print(#function)
    
    mx_append(path: path)
    
    invalidatePathCalculations()
  }
  
  @objc func mx_apply(t: CGAffineTransform) {
    print(#function)
    
    mx_apply(t: t)
    
    if t.isTranslationOnly {
      mx_pathElements?.indices.forEach { mx_pathElements?[$0].apply(transform: t) }
    } else {
      invalidatePathCalculations()
    }
  }
}
//  -


//MARK: - Math helpers
fileprivate extension CGPoint {
  func linearLineLength(to: CGPoint) -> CGFloat {
    return sqrt(pow(to.x - x, 2) + pow(to.y - y, 2))
  }
  
  func linearBezierPoint(to: CGPoint, t: CGFloat) -> CGPoint {
    let dx = to.x - x;
    let dy = to.y - y;
    
    let px = x + (t * dx);
    let py = y + (t * dy);
    
    return CGPoint(x: px, y: py)
  }
  
  func linearSlope(to: CGPoint, t: CGFloat) -> CGFloat {
    let dx = to.x - x;
    let dy = to.y - y;
    
    return dy / dx
  }
  
  func linearTangentAngle(to: CGPoint, t: CGFloat) -> CGFloat {
    let dx = to.x - x;
    let dy = to.y - y;
    
    return atan2(dx, dy)
  }
  
  func quadCurveLength(to: CGPoint, controlPoint c: CGPoint) -> CGFloat {
    let iterations = lengthCalculationPrecision.rawValue;
    var length: CGFloat = 0;
    
    for idx in 0..<iterations {
      let t = CGFloat(idx) * (1 / CGFloat(iterations))
      let tt = t + (1 / CGFloat(iterations))
      
      let p = self.quadBezierPoint(to: to, controlPoint: c, t: t)
      let pp = self.quadBezierPoint(to: to, controlPoint: c, t: tt)
      
      length += p.linearLineLength(to: pp)
    }
    
    return length
  }
  
  func quadBezierPoint(to: CGPoint, controlPoint: CGPoint, t: CGFloat) -> CGPoint {
    let x = _quadBezier(t, self.x, controlPoint.x, to.x);
    let y = _quadBezier(t, self.y, controlPoint.y, to.y);
    
    return CGPoint(x: x, y: y);
  }
  
  func quadSlope(to: CGPoint, controlPoint: CGPoint, t: CGFloat) -> CGFloat {
    let dx = _quadSlope(t, self.x, controlPoint.x, to.x);
    let dy = _quadSlope(t, self.y, controlPoint.y, to.y);
    
    return dy / dx
  }
  
  func quadTangentAngle(to: CGPoint, controlPoint: CGPoint, t: CGFloat) -> CGFloat {
    let dx = _quadSlope(t, self.x, controlPoint.x, to.x);
    let dy = _quadSlope(t, self.y, controlPoint.y, to.y);
    
    return atan2(dx, dy)
  }
  
  func cubicCurveLength(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint) -> CGFloat {
    let iterations = lengthCalculationPrecision.rawValue;
    var length: CGFloat = 0;
    
    for idx in 0..<iterations {
      let t = CGFloat(idx) * (1 / CGFloat(iterations))
      let tt = t + (1 / CGFloat(iterations))
      
      let p = self.cubicBezierPoint(to: to, controlPoint1: c1, controlPoint2: c2, t: t)
      let pp = self.cubicBezierPoint(to: to, controlPoint1: c1, controlPoint2: c2, t: tt)
      
      length += p.linearLineLength(to: pp)
    }
    
    return length
  }
  
  func cubicBezierPoint(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint, t: CGFloat) -> CGPoint {
    let x = _cubicBezier(t, self.x, c1.x, c2.x, to.x);
    let y = _cubicBezier(t, self.y, c1.y, c2.y, to.y);
    
    return CGPoint(x: x, y: y);
  }
  
  func cubicSlope(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint, t: CGFloat) -> CGFloat {
    let dx = _cubicSlope(t, self.x, c1.x, c2.x, to.x);
    let dy = _cubicSlope(t, self.y, c1.y, c2.y, to.y);
    
    return dy / dx
  }
  
  func cubicTangentAngle(to: CGPoint, controlPoint1 c1: CGPoint, controlPoint2 c2: CGPoint, t: CGFloat) -> CGFloat {
    let dx = _cubicSlope(t, self.x, c1.x, c2.x, to.x);
    let dy = _cubicSlope(t, self.y, c1.y, c2.y, to.y);
  
    return atan2(dx, dy)
  }
}


/// See https://en.wikipedia.org/wiki/Bézier_curve
///
/// [Quad equation](https://wikimedia.org/api/rest_v1/media/math/render/svg/05aa724a6da0e00bcce53ec6510c8ae479aea5c3)
fileprivate func _quadBezier(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ end: CGFloat) -> CGFloat {
  let _t = 1 - t;
  let _t² = _t * _t;
  let t² = t * t;
  
  return  _t² * start +
          2 * _t * t * c1 +
          t² * end;
}


/// See https://en.wikipedia.org/wiki/Bézier_curve
///
/// [Quad equation dt](https://wikimedia.org/api/rest_v1/media/math/render/svg/698bc1454fe7abf7c01ff47ef9b26665446eb67c)
fileprivate func _quadSlope(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ end: CGFloat) -> CGFloat {
  let _t = 1 - t
  
  return  2 * _t * (c1 - start) +
          2 * t * (end - c1)
}


/// See https://en.wikipedia.org/wiki/Bézier_curve
///
/// [Cubic equation](https://wikimedia.org/api/rest_v1/media/math/render/svg/504c44ca5c5f1da2b6cb1702ad9d1afa27cc1ee0)
fileprivate func _cubicBezier(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ end: CGFloat) -> CGFloat {
  let _t = 1 - t;
  let _t² = _t * _t;
  let _t³ = _t * _t * _t ;
  let t² = t * t;
  let t³ = t * t * t;
  
  return  _t³ * start +
          3.0 * _t² * t * c1 +
          3.0 * _t * t² * c2 +
          t³ * end;
}

/// See https://en.wikipedia.org/wiki/Bézier_curve
///
/// [Cubic equation dt](https://wikimedia.org/api/rest_v1/media/math/render/svg/bda9197c2e77c17d90839b951cb0035d79c8d417)
fileprivate func _cubicSlope(_ t: CGFloat, _ start: CGFloat, _ c1: CGFloat, _ c2: CGFloat, _ end: CGFloat) -> CGFloat {
  let _t = 1 - t
  let _t² = _t * _t
  let t² = t * t
  
  return  3 * _t² * (c1 - start) +
          6 * _t * t * (c2 - c1) +
          3 * t² * (end - c2)
}
//  -

