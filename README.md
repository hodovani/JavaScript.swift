# JavaScriptSwift 

JavaScriptSwift library to run JavaScript in pure IOS Swift 

[![Build Status](https://travis-ci.com/hodovani/JavaScript.swift.svg?branch=master)](https://travis-ci.com/hodovani/JavaScript.swift)

## Example

Use `JavaScriptSwift.import` to import JavaScript context to your project. For example:

```swift
import JavaScriptSwift

try JavaScriptSwift.import("""
var conference = {
    name: "Swift Island",
    organizers: [
        {
            name: "Niels",
            twitter: "@nvh",
            email: "niels@swiftisland.nl"
        },
        {
            name: "Sidney de Koning",
            twitter: "@sidneydekoning ",
            email: "sidney@swiftisland.nl"
        }
    ]
};
""")
```

Now you can access conference fields. For example: 

```swift
let conference = JavaScriptSwift.context.conference
// conference.name -> "Swift Island"
```

## Requirements

* Xcode 10.1
* Swift 5.0
* iOS 7.0+ / macOS 10.5+ / tvOS 9.0+  

## Author

[Matvii Hodovaniuk](https://matvii.hodovani.uk)

## License

JavaScriptSwift is available under the Apache 2.0 license. See the 
[LICENSE](https://github.com/hodovani/JavaScript.swift/blob/master/LICENSE) file for 
more info.
