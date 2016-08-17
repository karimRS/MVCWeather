//
//  ForecastView.swift
//  testProject
//
//  Created by Karim on 15/08/16.
//  Copyright © 2016 Karim. All rights reserved.
//

import UIKit

enum ForecastViewTableViewNib: String {
    case Normal = "ForecastTableViewCell"
}

enum ForecastViewTableViewCellIdentifier: String {
    case Normal = "ForecastTableViewCellIdentifier"
}

class ForecastView: UIView {

    @IBOutlet weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.registerNib(UINib.init(nibName: ForecastViewTableViewNib.Normal.rawValue, bundle: nil), forCellReuseIdentifier: ForecastViewTableViewCellIdentifier.Normal.rawValue)
            }
}
