//
//  AutocompleteField.swift
//  AutocompleteTextField
//
//  Created by Jeffrey Kereakoglow on 12/22/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

import UIKit

protocol AutocompleteDataSource {
  func textfield(textfield: AutocompleteTextField, predictionForPrefix prefix: String) -> String
}

class AutocompleteTextField: UITextField {
  var dataSource: AutocompleteDataSource?
  var suggestionLabelPosition: CGPoint

  private let suggestionLabel: UILabel

  override init(frame: CGRect) {
    suggestionLabel = UILabel(frame: CGRectZero)
    suggestionLabelPosition = CGPointZero
    super.init(frame: frame)

    setUp(suggestionLabel: suggestionLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    suggestionLabel = UILabel(frame: CGRectZero)
    suggestionLabelPosition = CGPointZero

    super.init(coder: aDecoder)

    setUp(suggestionLabel: suggestionLabel)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override var font: UIFont? {
    didSet {
      suggestionLabel.font = font
    }
  }

  func setUp(suggestionLabel label: UILabel) {
    label.font = font
    label.backgroundColor = UIColor.clearColor()
    label.textColor = UIColor.grayColor()
    label.lineBreakMode = .ByClipping
    label.hidden = true

    addSubview(label)
    bringSubviewToFront(label)

    // Be aware each time the textfield changes
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: Selector("textDidChange"),
      name: UITextFieldTextDidChangeNotification,
      object: self
    )
  }

  func textDidChange() {
    guard let someText = text, let aDataSource = dataSource else {
      return
    }

    // Find a prediction for a given data source
    suggestionLabel(suggestionLabel, findPredictionWithText: someText, usingDataSource: aDataSource)
  }
}

extension AutocompleteTextField {
  private func suggestionLabel(label: UILabel, rectForBounds bounds: CGRect,
    withSuggestion suggestion: String, font: UIFont?, offset: CGPoint ) -> CGRect {
      let textContainer = textRectForBounds(bounds)

      guard let textRange = textRangeFromPosition(
        beginningOfDocument,
        toPosition: endOfDocument) else {
        return CGRectZero
      }

      let textRect = CGRectIntegral(firstRectForRange(textRange))

      let pStyle = NSMutableParagraphStyle()
      pStyle.lineBreakMode = label.lineBreakMode

      let prefixTextRect = text?.boundingRectWithSize(textContainer.size,
        options: [.UsesLineFragmentOrigin, .UsesFontLeading],
        attributes: [NSFontAttributeName: font ?? UIFont.systemFontOfSize(17.0), NSParagraphStyleAttributeName: pStyle],
        context: nil
      )

      let prefixTextSize = prefixTextRect?.size

      let suggestionTextRect = suggestion.boundingRectWithSize(
        CGSizeMake(textContainer.size.width - (prefixTextSize?.width ?? 0), textContainer.size.height),
        options: [.UsesLineFragmentOrigin, .UsesFontLeading],
        attributes: [NSFontAttributeName: label.font, NSParagraphStyleAttributeName: pStyle],
        context: nil
      )

      let suggestionTextSize = suggestionTextRect.size

      return CGRectMake(
        CGRectGetMinX(textContainer) + CGRectGetMaxX(textRect) + offset.x,
        CGRectGetMinY(textContainer) + offset.y,
        suggestionTextSize.width,
        textContainer.size.height
      )
  }

  private func suggestionLabel(label: UILabel, findPredictionWithText text: String,
    usingDataSource dataSource: AutocompleteDataSource) {

      let aSuggestion = dataSource.textfield(self, predictionForPrefix: text)

      suggestionLabel(suggestionLabel, updateWithSuggestion: aSuggestion)
  }

  private func suggestionLabel(label: UILabel, updateWithSuggestion suggestion: String) {
    label.text = suggestion
    label.sizeToFit()
    label.frame = suggestionLabel(label,
      rectForBounds: bounds,
      withSuggestion: suggestion,
      font: font,
      offset: suggestionLabelPosition
    )
  }

  private func suggestionLabel(label: UILabel, acceptSuggestion suggestion: String) {
    guard !suggestion.isEmpty else {
      return
    }

    text? += suggestion

    suggestionLabel(label, updateWithSuggestion: suggestion)

    // Programmatic changes to `text` are not automatically fired. Hence, we must do so manually.
    sendActionsForControlEvents(.EditingChanged)
    NSNotificationCenter.defaultCenter().postNotificationName(
      UITextFieldTextDidChangeNotification,
      object: self
    )
  }
}

extension AutocompleteTextField {
  override func becomeFirstResponder() -> Bool {
    if clearsOnBeginEditing {
      suggestionLabel.text = ""
    }

    suggestionLabel.hidden = false

    return super.becomeFirstResponder()
  }

  override func resignFirstResponder() -> Bool {
    suggestionLabel.hidden = true

    if let suggestion = suggestionLabel.text {
      suggestionLabel(suggestionLabel, acceptSuggestion: suggestion)
    }

    return super.resignFirstResponder()
  }
}
