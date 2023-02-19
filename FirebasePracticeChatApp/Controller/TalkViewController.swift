//
//  TalkViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit

class TalkViewController: UIViewController {

    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var talkTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        talkTable.delegate = self
        talkTable.dataSource = self
        talkTable.register(UINib(nibName: K.Xib.talkCell_1, bundle: nil), forCellReuseIdentifier: K.CellID.talkCell)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
    }
    
}

extension TalkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        talkTable.estimatedRowHeight = 40
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let talkCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.talkCell, for: indexPath)
//        talkCell.textLabel?.text =
        return talkCell
    }
    
    
}
