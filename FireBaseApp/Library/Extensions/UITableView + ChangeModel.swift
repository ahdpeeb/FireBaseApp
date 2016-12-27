//
//  UUTableVide + ChangeModel.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 29.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import UIKit

extension UITableView {
    
    // This function works only if your TableView containst one section
    public func updateWithChangeModel(_ model: ChangeModel, animation: UITableViewRowAnimation) {
        self.updateWithChangeModel(model, shift: 0, animation: animation)
    }
    
    public func updateWithChangeModel(_ model: ChangeModel, shift: Int, animation: UITableViewRowAnimation) {
        switch model {
        case .add(index: let index):
            self.update {
                self.insertRows(at: [IndexPath(row: index + shift, section: 0)], with: animation)
            }
        case .remove(index: let index):
            self.update {
                self.deleteRows(at: [IndexPath(row: index + shift, section: 0)], with: animation)
            }
            
        case .addInRange(range: let range):
            self.update {
                var paths = [IndexPath]()
                for value in range  {
                    let path = IndexPath(row: value + shift, section: 0)
                    paths.append(path)
                }
                
                self.insertRows(at: paths, with: animation)
            }
        }
    }
}
