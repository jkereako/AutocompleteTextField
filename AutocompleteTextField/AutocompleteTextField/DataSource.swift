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
    "Beth",
    "Carlos",
    "Daniel",
    "Ethan",
    "Fred",
    "George",
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

  func textfield(textfield: AutocompleteTextField, completionForPrefix prefix: String) -> String {
    let components = prefix.componentsSeparatedByString(",")
    if let actualPrefix = components.last?.stringByTrimmingCharactersInSet(
      NSCharacterSet.whitespaceAndNewlineCharacterSet()
      ) {

        for string in dataSource {
          if string.hasPrefix(actualPrefix), let range = string.rangeOfString(actualPrefix) {
            return string.stringByReplacingCharactersInRange(range, withString: "")
          }
        }
    }

    return "TEST"
  }
}