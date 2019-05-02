# JavaScriptSwift

JavaScriptSwift library to run JavaScript in pure IOS Swift

## Example

Use `JavaScriptSwift.import` to import JavaScript context to your project. For example:

````swift
import JavaScriptSwift

let context = JavaScriptSwift()
try context.importSafe("""
var swiftLib = {
    name: "JavaScript.swift",
    organizers: [
        {
            name: "Matvii",
            twitter: "@hodovani",
            email: "matvii@hodovani.uk"
        },
        {
            name: "Max",
            twitter: "@maxdesiatov",
            email: "max@desiatov.com"
        }
    ]
};
""")
````

Now you can access swiftLib fields. For example:

````swift
var conference = context.swiftLib.name
// conference will be "JavaScript.swift"
````

## Requirements

- Xcode 10.2
- Swift 5.0
- iOS 7.0+ / macOS 10.5+ / tvOS 9.0+

## Author

[Matvii Hodovaniuk](https://matvii.hodovani.uk)

## License

JavaScriptSwift is available under the Apache 2.0 license. See the
[LICENSE](https://github.com/hodovani/JavaScript.swift/blob/master/LICENSE) file for
more info.
