//
//  Extensions.swift
//  Lawyer
//
//  Created by Admin on 11/6/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Foundation


// MARK: - UINavigationController extension

extension UINavigationController {
    func clear() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.clear
    }
}


// MARK: - UIViewController extension

extension UIViewController {
    
    func showAlert(title: String? = nil, msg: String? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        guard title != nil || msg != nil else {
            return
        }
        
        let alert = AppShared.getAlert(title: title, msg: msg, handler: handler)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInfoButton() {
        var needAdd = true
        if let rightBarButtonItems = navigationItem.rightBarButtonItems {
            for barButton in rightBarButtonItems {
                if barButton.action == #selector(didTapInfoButton){
                    needAdd = false
                }
            }
        }
        
        if needAdd == false {
            return
        }
        let infoButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapInfoButton))
        infoButtonItem.imageInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: -4.0, right: -4.0)

        if navigationItem.rightBarButtonItems?.count == nil {
            navigationItem.rightBarButtonItem = infoButtonItem
        } else {
            var rightBarButtonItems = navigationItem.rightBarButtonItems
            rightBarButtonItems?.append(infoButtonItem)
            navigationItem.rightBarButtonItems = rightBarButtonItems;
            
        }
    }
    
    @objc private func didTapInfoButton(sender: UIBarButtonItem) {
        let infoStoryboard =  UIStoryboard(name: "InfoScreen", bundle: nil)
        let infoController = infoStoryboard.instantiateViewController(withIdentifier: "InfoTableViewController")
        navigationController?.pushViewController(infoController, animated: true)
    }
    
    func showNoResultLabel(label: UILabel?, show: Bool, message: String?) {
        guard let label = label else {
            return
        }
        
        label.text = message == nil ? G.No_record_found : message
        label.alpha = show ? 1.0 : 0.0
    }
}


// MARK: - UIView extension

extension UIView {
    func shadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 8.0
    }
    
    func setRoundBorderEdgeView(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
}


// MARK: - UIImageView extension

extension UIImageView {
    func setRoundedView(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
}


// MARK: - UIImage extension

extension UIImage {
    func imageMasked(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        context.clip(to: rect, mask: cgImage)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func fixOrientation() -> UIImage {
        var transformOrientation: CGAffineTransform = .identity
        let width = size.width
        let height = size.height
        if imageOrientation == .up {
            return self
        }
        
        if imageOrientation == .down || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: height)
            transformOrientation = transformOrientation.rotated(by: .pi)
        } else if imageOrientation == .left || imageOrientation == .leftMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.rotated(by: .pi/2)
        } else if imageOrientation == .right || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: 0, y: height)
            transformOrientation = transformOrientation.rotated(by: -(.pi/2))
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        } else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: height, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        }
        
        guard let cgImage = self.cgImage, let space = cgImage.colorSpace,
            let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: cgImage.bitmapInfo.rawValue)  else {
                return UIImage()
        }
        context.concatenate(transformOrientation)
        
        if imageOrientation == .left ||
            imageOrientation == .leftMirrored ||
            imageOrientation == .right ||
            imageOrientation == .rightMirrored {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        } else {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        guard let newCGImage = context.makeImage() else {
            return UIImage()
        }
        let image = UIImage(cgImage: newCGImage)

        return image
    }
}


// MARK: - String extension

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func size(withConstrainedWidth width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let size = CGSize(width: ceil(boundingBox.width),
                          height: ceil(boundingBox.height))
        
        return size
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func stringByTrimingWhitespace() -> String {
        let squashed = replacingOccurrences(of: "[ ]+",
                                            with: " ",
                                            options: .regularExpression)
        return squashed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func getMessageHeight() -> CGFloat {
        let size: CGSize = getMessageSize()
        let height:CGFloat = size.height
        
        return height
    }
    
    func getMessageSize() -> CGSize {
        var size: CGSize = CGSize.zero
        
        let maxWidth: CGFloat = 240.0
        let font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        size = self.size(withConstrainedWidth: maxWidth, font: font)
        if (size.height < 30.0) {
            size = CGSize(width: size.width, height: 30.0)
        }
        
        return size
    }
}


// MARK: - NSAttributedString extension

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}


// MARK: - NSDate extension

extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self as Date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        else if calendar.isDateInYesterday(self as Date){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        }
        else if calendar.compare(Date(), to: self as Date, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self as Date).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        }
        else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self as Date)
    }
}


extension CGSize {
    func getFitSizeFotChatImage() -> CGSize {
        if (self.width < ChatImage.MaxWidth && self.height < ChatImage.MaxHeight) {
            return self
        }
        
        var newWidth: CGFloat = 0.0
        var newHeight: CGFloat = 0.0
        if (self.width >= self.height) { // Landscape
            newWidth = ChatImage.MaxWidth
            newHeight = self.height * newWidth / self.width
            if (newHeight > ChatImage.MaxHeight) {
                newHeight = ChatImage.MaxHeight
                newWidth = self.width * newHeight / self.height
            }
        }
        else { // Portrait
            newHeight = ChatImage.MaxHeight
            newWidth = self.width * newHeight / self.height
            if (newWidth > ChatImage.MaxWidth) {
                newWidth = ChatImage.MaxWidth
                newHeight = self.height * newWidth / self.width
            }
        }
        
        let fitSize = CGSize(width: newWidth, height: newHeight)
        return fitSize
    }
}
