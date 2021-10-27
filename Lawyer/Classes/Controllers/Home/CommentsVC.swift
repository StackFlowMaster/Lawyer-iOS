//
//  CommentsVC.swift
//  Lawyer
//
//  Created by Admin on 11/7/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController {

    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        
        loadComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        (self.tabBarController as! LawyerTabVC).showTabView(show: false)
        AppManager.shared.mainTabVC.showTabView(show: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func initUI() {
        self.title = "Comments"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
    }
    
    func updateWrapper() {
        
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadComments() {
        getLawyerRating()
    }
    
    func loadTestComments() {
        self.comments = Comment.testComments()
        self.commentsTableView.reloadData()
    }
    
    
    // MARK: - API functions
    
    func getLawyerRating() {
        SVProgressHUD.show()
        AppWebClient.GetLawyerRating() { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyerRating api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
//                self.showAlert(msg: response[G.error].string)
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.error].string)
                return;
            }
            
            guard let jsonComments = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.comments = [Comment]()
            for info in jsonComments {
                let comment = Mapper<Comment>().map(JSONString: info.rawString()!)
                self.comments.append(comment!)
            }
            self.commentsTableView.reloadData()
            
            self.showNoResultLabel(label: self.noResultLabel, show: self.comments.count < 1, message: G.No_record_found)
        }
    }
}


extension CommentsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = self.comments[indexPath.row]
        let commentHeight = comment.comment!.size(withConstrainedWidth: self.view.frame.width - 100.0, font: UIFont.systemFont(ofSize: 15.0)).height
        
        var cellHeight: CGFloat = commentHeight + 85.0
        if (cellHeight < 110.0) {
            cellHeight = 110.0
        }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        // Configure the cell...
        
        let comment = self.comments[indexPath.row]
        cell.userImageView.image = UIImage(named: comment.user!.imageUrl!)
        cell.nameLabel.text = comment.user!.full_name
        cell.addressLabel.text = comment.user!.address
        cell.commentLabel.text = comment.comment
        cell.ratingView.rating = comment.rating!
        cell.timeLabel.text = comment.time!
        
        return cell
    }
}


extension CommentsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
