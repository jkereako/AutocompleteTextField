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

protocol AutocompleteDelegate: class {
  func textfield(textfield: AutocompleteTextField, didAcceptSuggestion suggestion: String)
}

@IBDesignable
class AutocompleteTextField: UITextField {

  // MARK: - IBInspectable
  @IBInspectable var suggestionColor: UIColor = UIColor.grayColor()
  @IBInspectable var suggestionBackgroundColor: UIColor = UIColor.clearColor()

  var suggestionLabelPosition = CGPointZero
  private let suggestionLabel = UILabel(frame: CGRectZero)

  var autoCompleteDataSource: AutocompleteDataSource?
  weak var autoCompleteDelegate: AutocompleteDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: Selector("textDidChange"),
      name: UITextFieldTextDidChangeNotification,
      object: self
    )
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: Selector("textDidChange"),
      name: UITextFieldTextDidChangeNotification,
      object: self
    )
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func drawRect(rect: CGRect) {
    suggestionLabel.font = font
    suggestionLabel.backgroundColor = suggestionBackgroundColor
    suggestionLabel.textColor = suggestionColor
    suggestionLabel.lineBreakMode = .ByClipping
    suggestionLabel.hidden = true

    addSubview(suggestionLabel)
    bringSubviewToFront(suggestionLabel)
  }

  func textDidChange() {
    guard let someText = text, let aDataSource = autoCompleteDataSource else {
      return
    }

    // Find a prediction for a given data source
    suggestionLabel(suggestionLabel, findPredictionWithText: someText, usingDataSource: aDataSource)
  }
}

// MARK: - Private methods
extension AutocompleteTextField {
  private func suggestionLabel(label: UILabel, rectForBounds bounds: CGRect,
    withSuggestion suggestion: String, font: UIFont?, offset: CGPoint ) -> CGRect {
      let textContainer = textRectForBounds(bounds)

      guard let textRange = textRangeFromPosition(beginningOfDocument, toPosition: endOfDocument)
        else {
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
        CGSize(
          width: textContainer.size.width - (prefixTextSize?.width ?? 0),
          height: textContainer.size.height
        ),
        options: [.UsesLineFragmentOrigin, .UsesFontLeading],
        attributes: [NSFontAttributeName: label.font, NSParagraphStyleAttributeName: pStyle],
        context: nil
      )

      let suggestionTextSize = suggestionTextRect.size

      return CGRect(
        x: CGRectGetMinX(textContainer) + CGRectGetMaxX(textRect) + offset.x,
        y: CGRectGetMinY(textContainer) + offset.y,
        width: suggestionTextSize.width,
        height: textContainer.size.height
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

    autoCompleteDelegate?.textfield(self, didAcceptSuggestion: text!)

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
