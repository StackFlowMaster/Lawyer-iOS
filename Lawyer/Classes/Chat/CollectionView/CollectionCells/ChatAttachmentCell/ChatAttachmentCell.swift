//
//  ChatAttachmentCell.swift
//  Lawyer
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatAttachmentCell: ChatCell {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var progressLabel: UILabel!
    /**
     *  Attachment image view.
     */
    @IBOutlet weak var attachmentImageView: UIImageView!
    
    //MARK: - Properties
    private var attachmentID: String = ""
    private var attachmentDownloadManager = AttachmentDownloadManager()
    
    //MARK: - Overrides
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero;
        return defaultLayoutModel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        attachmentImageView.image = nil
    }
    
    //MARK: - Actions
    func setupAttachmentWithID(_ ID: String) {
        attachmentID = ID
        
        attachmentDownloadManager.downloadAttachment(attachmentID, progressHandler: { [weak self] (progress, ID) in
            if self?.attachmentID != ID {
                return
            }
            self?.updateLoadingProgress(progress)
        }, successHandler: { [weak self] (image, ID) in
            if self?.attachmentID != ID {
                return
            }
            self?.setupAttachmentImage(image)
        }, errorHandler: { [weak self] (error, ID) in
            if self?.attachmentID != ID {
                return
            }
            let errorImage = UIImage(named: "ic_error")!
            self?.setupAttachmentImage(errorImage)
        })
    }
    
    //MARK: - Internal Methods
    private func setupAttachmentImage(_ attachmentImage: UIImage) {
        progressLabel.isHidden = true
        attachmentImageView.image = attachmentImage
        attachmentImageView.setRoundedView(cornerRadius: 3.0)
    }
    
    private func updateLoadingProgress(_ progress: CGFloat) {
        if progress > 0.0 {
            DispatchQueue.main.async {
                self.progressLabel.isHidden = false
                self.progressLabel.text = String(format: "%2.0f %%", progress * 100.0)
                if progress > 0.99 {
                    self.progressLabel.isHidden = true
                }
            }
        }
    }
}
