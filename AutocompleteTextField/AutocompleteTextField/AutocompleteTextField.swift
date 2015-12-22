//
//  AutocompleteField.swift
//  AutocompleteTextField
//
//  Created by Jeffrey Kereakoglow on 12/22/15.
//  Copyright © 2015 Alexis Digital. All rights reserved.
//

import UIKit

protocol AutocompleteDataSource {
  func textfield(textfield: AutocompleteTextField, completionForPrefix prefix: String) -> String
}

class AutocompleteTextField: UITextField {
  var dataSource: AutocompleteDataSource?
  var suggestionLabelOffsetPosition: CGPoint

  private var suggestion: String
  private let suggestionLabel: UILabel

  override init(frame: CGRect) {
    suggestion = ""
    suggestionLabel = UILabel(frame: CGRectZero)
    suggestionLabelOffsetPosition = CGPointZero
    super.init(frame: frame)

    initializeSuggestionLabel()
  }

  required init?(coder aDecoder: NSCoder) {
    suggestion = ""
    suggestionLabel = UILabel(frame: CGRectZero)
    suggestionLabelOffsetPosition = CGPointZero

    super.init(coder: aDecoder)

    initializeSuggestionLabel()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override var font: UIFont? {
    didSet {
      suggestionLabel.font = font
    }
  }

  func initializeSuggestionLabel() {
    suggestionLabel.font = font
    suggestionLabel.backgroundColor = UIColor.clearColor()
    suggestionLabel.textColor = UIColor.grayColor()
    suggestionLabel.lineBreakMode = .ByClipping
    suggestionLabel.hidden = true

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: Selector("textDidChange"),
      name: UITextFieldTextDidChangeNotification,
      object: self
    )
  }

  func textDidChange() {
    refreshSuggestionText()
  }

  func suggestionLabelRectForBounds(bounds: CGRect) -> CGRect {
    let textContainer = textRectForBounds(bounds)

    guard let textRange = textRangeFromPosition(beginningOfDocument, toPosition: endOfDocument) else {
      return CGRectZero
    }

    let textRect = CGRectIntegral(firstRectForRange(textRange))

    let pStyle = NSMutableParagraphStyle()
    pStyle.lineBreakMode = suggestionLabel.lineBreakMode

    let prefixTextRect = text?.boundingRectWithSize(textContainer.size,
      options: [.UsesLineFragmentOrigin, .UsesFontLeading],
      attributes: [NSFontAttributeName: font ?? UIFont.systemFontOfSize(17.0), NSParagraphStyleAttributeName: pStyle],
      context: nil
    )

    let prefixTextSize = prefixTextRect?.size

    let suggestionTextRect = suggestion.boundingRectWithSize(
      CGSizeMake(textContainer.size.width - (prefixTextSize?.width ?? 0), textContainer.size.height),
      options: [.UsesLineFragmentOrigin, .UsesFontLeading],
      attributes: [NSFontAttributeName: suggestionLabel.font, NSParagraphStyleAttributeName: pStyle],
      context: nil
    )

    let suggestionTextSize = suggestionTextRect.size

    return CGRectMake(
      CGRectGetMinX(textContainer) + CGRectGetMaxX(textRect) + suggestionLabelOffsetPosition.x,
      CGRectGetMinY(textContainer) + suggestionLabelOffsetPosition.y,
      suggestionTextSize.width,
      textContainer.size.height
    )
  }

  func acceptSuggestion() {
    guard !suggestion.isEmpty else {
      return
    }

    text? += suggestion
    suggestion = ""

    updateSuggestionLabel()
  }

  func refreshSuggestionText() {
    guard let aDataSource = dataSource else {
      return
    }

    suggestion = aDataSource.textfield(self, completionForPrefix: text ?? "")

    updateSuggestionLabel()
  }

  func updateSuggestionLabel() {
    suggestionLabel.text = suggestion
    suggestionLabel.sizeToFit()
    suggestionLabel.frame = suggestionLabelRectForBounds(bounds)
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
    
    return super.resignFirstResponder()
  }
}
