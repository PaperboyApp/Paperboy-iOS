//
//  CountrySelectionTableViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class CountrySelectionTableViewController: UITableViewController {
    let countries = NSLocale.ISOCountryCodes()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryCell", forIndexPath: indexPath) as UITableViewCell

        if let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countries[indexPath.row]) {
            cell.textLabel?.text = countryName
        }

        println(countries[indexPath.row])

        return cell
    }
}
