//
//  CountrySelectionTableViewController.swift
//  Paperboy
//
//  Created by Alvaro Serrano on 1/14/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit

class CountrySelectionTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    let country = Country()
    var searchResults: [(String, String)] = []
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController?.searchResultsTableView {
            return searchResults.count
        } else {
            return country.countries.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CountryCell", forIndexPath: indexPath) as UITableViewCell
        var countryName: String? = nil
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            countryName = searchResults[indexPath.row].0
        } else {
            countryName = country.countries[indexPath.row].0
        }
        
        cell.textLabel?.text = countryName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let viewControllerCount = navigationController?.viewControllers.count {
            var selectedCountry = ""
            var selectedCountryPrefix = ""
            if tableView == self.searchDisplayController?.searchResultsTableView {
                selectedCountry = searchResults[indexPath.row].0
                if let phonePrefix = country.countryPhonePrefix[searchResults[indexPath.row].1] {
                    selectedCountryPrefix = phonePrefix
                }
            } else {
                selectedCountry = country.countries[indexPath.row].0
                if let phonePrefix = country.countryPhonePrefix[country.countries[indexPath.row].1] {
                    selectedCountryPrefix = phonePrefix
                }
            }
            
            let previousView = navigationController?.viewControllers[viewControllerCount - 2] as NumberInputViewController
            
            previousView.country = selectedCountry
            previousView.countryPrefix = selectedCountryPrefix
            navigationController?.popToViewController(previousView, animated: true)
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterContentForSearchText(searchString)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        searchResults = country.countries.filter({ (countryName: String, _) -> Bool in
            let stringMatch = countryName.rangeOfString(searchText) != nil
            return stringMatch
        })
    }
}
