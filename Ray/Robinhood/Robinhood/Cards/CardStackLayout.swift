/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

protocol CardStackLayoutProtocol: class {
    
    //移除数据源中的某个数据
    func cardShouldRemove(_ flowLayout: CardStackLayout, indexPath: IndexPath)
    
}

class CardStackLayout: UICollectionViewLayout {
    
    private var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    //最大的极限值
    private var maxOffsetThresholdPercentage: CGFloat = 0.3
    
    //动画时间
    private let animationDuration: TimeInterval = 0.15
    
    weak var delegate: CardStackLayoutProtocol?
    
    typealias CellWithIndexPath = (cell: UICollectionViewCell, indexPath: IndexPath)
    
    //最顶层的cell
    private var topCellWithIndexPath: CellWithIndexPath? {
        let lastItem = collectionView?.numberOfItems(inSection: 0) ?? 0
        let indexPath = IndexPath(item: lastItem - 1, section: 0)
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else {
            return nil
        }
        
        return (cell: cell, indexPath: indexPath)
        
    }
    
    //最顶层底部的cell
    private var bottomCellWithIndexPath: CellWithIndexPath? {
        
        guard let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 1 else {
            return nil
        }
        
        let indexPath = IndexPath(item: numItems - 2, section: 0)
        
        guard  let cell = collectionView?.cellForItem(at: indexPath) else {
            return nil
        }
        
        return (cell: cell, indexPath: indexPath)
        
    }
    
    override func prepare() {
        super.prepare()
        
        panGestureRecognizer.addTarget(self, action: #selector(handlePan(gestrueRecognizer:)))
        collectionView?.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    fileprivate func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        if let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 0 {
            for i in 0...numItems-1 {
                indexPaths.append(IndexPath(item: i, section: 0))
            }
        }
        
        return indexPaths
    }
    
    //事件
    @objc func handlePan(gestrueRecognizer: UIPanGestureRecognizer) {
        print("paning......")
        
        let translation = gestrueRecognizer.translation(in: collectionView)
        
        let xOffset = translation.x
        //x最大偏移
        let xMaxOffset = (collectionView?.frame.width ?? 0) * maxOffsetThresholdPercentage
        
        switch gestrueRecognizer.state {
        case .changed:
            if let topCard = topCellWithIndexPath {
                topCard.cell.transform = CGAffineTransform(translationX: xOffset, y: 0)
            }
            
            if let bottomCard = bottomCellWithIndexPath {
                
                let draggingScale = 0.5 + (abs(xOffset) / (collectionView?.frame.width ?? 1) * 0.7)
                let scale = draggingScale > 1 ? 1 : draggingScale
                
                bottomCard.cell.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                bottomCard.cell.alpha = scale / 2
            }
        case .ended:
            if abs(xOffset) > xMaxOffset {
                if let topCard = topCellWithIndexPath {
                    aniamtionAndMove(left: xOffset < 0, cell: topCard.cell, completion: {
                        [weak self] in
                        guard let `self` = self else { return }
                        self.delegate?.cardShouldRemove(self, indexPath: topCard.indexPath)
                    })
                }
                if let bottomCard = bottomCellWithIndexPath {
                    animateIntoPosition(cell: bottomCard.cell)
                }
            } else {
                if let topCard = topCellWithIndexPath {
                    //返回原来的位置
                    animateIntoPosition(cell: topCard.cell)
                }
            }
        default:
            break
        }
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        //修改frame
        attributes.frame = collectionView?.bounds ?? .zero
        
        //不是顶部的cell
        var isNotTop = false
        if let numItems = collectionView?.numberOfItems(inSection: 0), numItems > 0 {
            isNotTop = indexPath.row != numItems - 1
        }
        attributes.alpha = isNotTop ? 0 : 1
        
        return attributes
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let indexPaths = indexPathsForElementsInRect(rect)
        let layoutAttributes = indexPaths.map{ layoutAttributesForItem(at: $0) }
            .filter { $0 != nil }.map { $0! }
        
        return layoutAttributes
        
    }
   
    //动画
    
    private func animateIntoPosition(cell: UICollectionViewCell) {
        
        UIView.animate(withDuration: animationDuration) {
            
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1
            
        }
        
    }
    
    
    private func aniamtionAndMove(left: Bool, cell: UICollectionViewCell, completion: (() -> ())?) {
        
        let screenWidth = UIScreen.main.bounds.width
        
        UIView.animate(withDuration: animationDuration, animations: {
            
            let xTranslateOffscreen = CGAffineTransform(translationX: left ? -screenWidth : screenWidth, y: 0)
            cell.transform = xTranslateOffscreen
            
            
        }) { (_) in
            
            //需解包
            completion?()
            
        }
        
    }
    
}
