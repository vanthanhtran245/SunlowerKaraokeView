//
//  VTKaraokeLyricLabel.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/19/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit

protocol VTXKaraokeLyricViewDelegate:class {
    func karaokeLyric(label: VTKaraokeLyricLabel, didStartAnimation: CAAnimation)
    func karaokeLyric(label: VTKaraokeLyricLabel, didStopAnimation: CAAnimation, finished: Bool)
}

extension VTKaraokeLyricLabel{
    var hasAnimation: Bool {
        return textLayer.animation(forKey: animationKey) != nil
    }
}
final class VTKaraokeLyricLabel: UILabel {
    
    weak var delegate:VTXKaraokeLyricViewDelegate?
    var duration:CGFloat                = 0.25
    
    private var textLayer:CATextLayer   = CATextLayer()
    private let animationKey            = "runLyric"
    
    var isAnimating:Bool {
        return textLayer.speed > 0
    }
    
    var fillTextColor:UIColor? {
        didSet {
            guard let fillTextColor = self.fillTextColor else { return }
            textLayer.foregroundColor = fillTextColor.cgColor
        }
    }
    
    var lyricSegment:Dictionary<CGFloat,String>? {
        didSet {
            
            guard let lyricSegment = self.lyricSegment else { return }
            let sortedKeys = Array(lyricSegment.keys).sorted(by: <)
            
            var fullText = ""
            for k in sortedKeys {
                
                if let segmentStr = lyricSegment[k] {
                    fullText = "\(fullText)\(segmentStr)"
                }
                
            }
            
            self.text = fullText
        }
    }
    
    override var text: String? {
        didSet {
            self.updateLayer()
        }
    }
    
    override var font: UIFont! {
        didSet {
            self.updateLayer()
        }
    }
    
    
    // MARK: Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareForLyricLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareForLyricLabel()
    }
    
    func prepareForLyricLabel() {
        textLayer.removeFromSuperlayer()
        textLayer = CATextLayer()
        textLayer.frame = self.bounds
        numberOfLines = 1
        clipsToBounds = true
        textAlignment = .left
        baselineAdjustment = .alignBaselines
        textLayer.foregroundColor = fillTextColor?.cgColor ?? UIColor.blue.cgColor
        let textFont = self.font
        textLayer.font      = textFont
        textLayer.fontSize  = textFont?.pointSize ?? 13
        textLayer.string    = self.text
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.masksToBounds = true
        textLayer.anchorPoint   = CGPoint(x: 0, y: 0.5)
        textLayer.frame         = self.bounds
        textLayer.isHidden        = true
        self.layer.addSublayer(textLayer)
    }

    // MARK: Animation
    func animationForTextLayer() -> CAKeyframeAnimation {
        textLayer.isHidden = false
        let textAnim = CAKeyframeAnimation(keyPath: "bounds.size.width")
        textAnim.duration   = CFTimeInterval(self.duration)
        textAnim.values     = valuesFromLyricSegment()
        textAnim.keyTimes   = keyTimesFromLyricSegment() as [NSNumber]
        textAnim.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
        textAnim.isRemovedOnCompletion   = true
        textAnim.delegate              = self
        return textAnim
    }
    
    // MARK: Help methods
    
    func updateLayer() {
        sizeToFit()
        setNeedsLayout()
        prepareForLyricLabel()
    }
    
    
    func valuesFromLyricSegment() -> Array<CGFloat> {
        let layerWidth = textLayer.bounds.size.width
        guard let lyricSegment = self.lyricSegment else {
            return [0.0,layerWidth]
        }
        var values:Array<CGFloat> = [0.0]
        let sortedKeys = Array(lyricSegment.keys).sorted(by: < )
        var val:CGFloat = 0
        sortedKeys.forEach({
            let str = lyricSegment[$0]!
            let strWidth = str.size(withAttributes: [NSAttributedString.Key.font:self.font]).width
            val += strWidth
            values.append(val)
        })
        return values
    }
    
    
    func keyTimesFromLyricSegment() -> Array<CGFloat> {
        guard let lyricSegment = self.lyricSegment else {
            return [0.0, 1.0]
        }
        let keyTimes:Array<CGFloat> = [0.0] + Array(lyricSegment.keys).sorted(by: < ) + [1.0]
        return keyTimes
    }
    
    func pauseLayer() {
        let pauseTime = textLayer.convertTime(CACurrentMediaTime(), from: nil)
        textLayer.speed = 0.0
        textLayer.timeOffset = pauseTime
    }
    
    func resumeLayer() {
        let pauseTime = textLayer.timeOffset
        textLayer.speed = 1.0;
        textLayer.timeOffset = 0.0;
        textLayer.beginTime = 0.0;
        textLayer.beginTime = textLayer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
    }
    
    // MARK: Main methods
    
    func startAnimation() {
        guard !hasAnimation else { return }
        let anim = animationForTextLayer()
        textLayer.add(anim, forKey: animationKey)
    }
    
    func pauseAnimation() {
        guard hasAnimation else { return }
        pauseLayer()
    }
    
    func resumeAnimation() {
        guard hasAnimation else { return }
        resumeLayer()
    }
    
    func reset() {
        textLayer.removeAnimation(forKey: animationKey)
        textLayer.isHidden = true
    }
}

extension VTKaraokeLyricLabel: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        delegate?.karaokeLyric(label: self, didStartAnimation: anim)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        delegate?.karaokeLyric(label: self, didStopAnimation: anim, finished: flag)
    }
}
