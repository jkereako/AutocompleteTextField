//
//  AutocompleteDataSource.swift
//  AutocompleteTextField
//
//  Created by Jeffrey Kereakoglow on 12/22/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

import Foundation

struct DataSource {
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
    "Hermés",
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
}

// MARK: - AutocompleteDataSource
extension DataSource: AutocompleteDataSource {
  func textfield(textfield: AutocompleteTextField, predictionForPrefix prefix: String) -> String {


    // Remove all whitespace around and within the text. Normalize the whitespace to a single space
    // see: http://nshipster.com/nscharacterset/#squashing-whitespace
    let whiteSpaceComponents = prefix.componentsSeparatedByCharactersInSet(
      NSCharacterSet.whitespaceAndNewlineCharacterSet()
      ).filter { !$0.isEmpty }

    // Add support for CSV
    let csvComponents = whiteSpaceComponents.joinWithSeparator(" ").componentsSeparatedByString(",")

    // Always add a suggestion for the right-most component
    if let aPrefix = csvComponents.last {

      if aPrefix.isEmpty {
        return ""
      }

      /*

      NOTE: I decided not to use this

      // Remove accents and such without deleting the character itself. For example, Hermés becomes
      // Hermes. Next, the string is converted to lowercase to offer a case insensitive search.
      // see: http://stackoverflow.com/questions/1231764/nsstring-convert-to-pure-alphabet-only-i-e-remove-accentspunctuation#1234095
      let filteredPrefix = aPrefix.stringByFoldingWithOptions(
        .DiacriticInsensitiveSearch, locale: NSLocale.currentLocale()
        ).lowercaseString
      */

      let filteredPrefix = aPrefix.lowercaseString

      for string in dataSource {
        let filteredDataSourceString = string.lowercaseString

        // Make autocompletion case insensitive
        if filteredDataSourceString.hasPrefix(filteredPrefix),
          let range = filteredDataSourceString.rangeOfString(filteredPrefix) {

            // Return the unfiltered string
            return string.stringByReplacingCharactersInRange(range, withString: "")
        }
      }
    }

    return ""
  }
}