//
//  ChatCellLayoutAttributes.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct ChatCellLayoutAttributesConstant {
    static let invalidParameter = "Invalid parameter not satisfying: containerSize.width >= 0.0 && containerSize.height >= 0.0"
}

class ChatCellLayoutAttributes: UICollectionViewLayoutAttributes {
    
    //MARK: - Properties
    private var _containerSize: CGSize = .zero
    var containerSize: CGSize {
        get {
            return _containerSize
        }
        set {
            var width = newValue.width
            var height = newValue.height
            width.round(.up)
            height.round(.up)
            let newSize = CGSize(width: width, height: height)
            _containerSize = newSize
        }
    }
    
    private var _avatarSize: CGSize = .zero
    var avatarSize: CGSize {
        get {
            return _avatarSize
        }
        set {
            var width = newValue.width
            var height = newValue.height
            width.round(.up)
            height.round(.up)
            let newSize = CGSize(width: width, height: height)
            _avatarSize = newSize
        }
    }
    
    
    //MARK: - Lifecycle
    override init() {
        super.init()
        commonInit()
    }
    
    func commonInit() {
        self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    deinit {
    }
    
    //MARK: - Utilities
    
    override var hash: Int {
        return indexPath.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let layoutAttributes = object as? ChatCellLayoutAttributes else {
            return false
        }
        
        if self === layoutAttributes {
            return true
        }
        
        if representedElementCategory == .cell {
            
            if !(layoutAttributes.containerSize.equalTo(containerSize)) ||
                !layoutAttributes.avatarSize.equalTo(avatarSize) {
                
                return false
            }
        }
        return super.isEqual(object)
    }
    
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone)
        
        guard let cellLayout = copy as? ChatCellLayoutAttributes else {
            return copy
        }
        
        if cellLayout.representedElementCategory != .cell {
            return cellLayout
        }
        
        cellLayout.avatarSize = avatarSize
        cellLayout.containerSize = containerSize
        
        return cellLayout
    }
    
}