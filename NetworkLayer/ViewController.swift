//
//  ViewController.swift
//  NetworkLayer
//
//  Created by Aseem Aggarwal on 10/04/23.
//

import UIKit

class ViewController: UIViewController, GroupsDetailsAPIRepositoryInjection {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    private var queryParams: [CVarArg] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let param: [String: Any] = ["message": "asdsda"]
        groupsDetailsAPIRepository.createPost(groupId: "id", parameter: param) { response in
            print("response")
        }
    }
}

