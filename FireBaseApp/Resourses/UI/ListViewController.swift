//
//  ListViewController.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 12/29/16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    //MARK: Overrided functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
