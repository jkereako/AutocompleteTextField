//
//  AutocompleteDataSource.swift
//  AutocompleteTextField
//
//  Created by Jeffrey Kereakoglow on 12/22/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

import Foundation

struct DataSource: AutocompleteDataSource {
  private let dataSource = [
    "Alfred",
    "Bertha",
    "Beth",
    "Carlos",
    "Charlie",
    "Daniel",
    "Donald",
    "Edward",
    "Ethan",
    "Fred",
    "George",
    "Gregory",
    "Helen",
    "Inis",
    "Jennifer",
    "Kylie",
    "Liam",
    "Melissa",
    "Noah",
    "Omar",
    "Penelope",
    "Quan",
    "Rachel",
    "Seth",
    "Timothy",
    "Ulga",
    "Vanessa",
    "William",
    "Xao",
    "Yilton",
    "Zander"]

  func textfield(textfield: AutocompleteTextField, predictionForPrefix prefix: String) -> String {
    // Add support for CSV
    let components = prefix.componentsSeparatedByString(",")

    // Always add a suggestion for the right-most component
    if let aPrefix = components.last?.stringByTrimmingCharactersInSet(
      NSCharacterSet.whitespaceAndNewlineCharacterSet()
      ) {
        for string in dataSource {
          // Make autocompletion case insensitive
          if string.lowercaseString.hasPrefix(aPrefix.lowercaseString),
            let range = string.lowercaseString.rangeOfString(aPrefix.lowercaseString) {
            return string.stringByReplacingCharactersInRange(range, withString: "")
          }
        }
    }

    return ""
  }
}