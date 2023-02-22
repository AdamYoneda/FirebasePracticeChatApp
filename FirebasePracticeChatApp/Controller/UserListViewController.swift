//
//  UserListViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/22.
//

import UIKit

class UserListViewController: UIViewController {
    
    var users: [User] = []

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        userListTableView.register(UINib(nibName: K.Xib.userListCell, bundle: nil), forCellReuseIdentifier: K.CellID.userListCell)
    }
    

}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userListCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.userListCell, for: indexPath) as! UserListCell

        return userListCell
    }
    
    
}
