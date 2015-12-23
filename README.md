# Autocomplete text field
A Swift version of HotelTonight's (RIP) [HTAutocompleteTextField](https://github.com/hoteltonight/HTAutocompleteTextField)

This is *not a framework*.
# Usage
Copy `AutocompleteTextField` into your project. Change the class type of your textfield from `UITextField` to `AutocompleteTextField` in In Storyboard Builder or programatically. Define a data source struct and have it implement the protocol `AutocompleteDataSource`. Finally, wire everything together in your view controller's `viewDidLoad()` method:

```swift
import UIKit

class TableViewController: UITableViewController {

  @IBOutlet weak var nameField: AutocompleteTextField?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let name = nameField else {
      assertionFailure("Name field is nil. Did you forget to wire it up in Storyboard Builder?")
      return
    }
    
    // Set the datasource
    name.dataSource = DataSource()
    name.suggestionLabelPosition = CGPointMake(0, -0.5)
  }
}

```
