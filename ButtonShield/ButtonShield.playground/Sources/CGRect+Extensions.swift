import QuartzCore

public extension CGRect {
    public init(centre: CGPoint, size: CGSize) {
        //applying应用仿射变化
        self.init(origin: centre.applying(CGAffineTransform(translationX: size.width / -2, y: size.height / -2)), size: size)
    }
    
    public var centre: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    //最大内嵌矩形
    public var largestContainedSquare: CGRect {
        let side = min(width, height)
        return CGRect(centre: centre, size: CGSize(width: side, height: side))
    }
    
    //最小外包矩形
    public var smallestContainingSquare: CGRect {
        let side = max(width, height)
        return CGRect(centre: centre, size: CGSize(width: side, height: side))
    }
}
