@testable import JavaScriptSwift
import XCTest

final class JavaScriptSwiftTests: XCTestCase {
    func testHelpers() throws {
        var value: Value = nil
        XCTAssertTrue(value.isNull)
        XCTAssertFalse(value.isBool)
        XCTAssertFalse(value.isNumber)
        XCTAssertFalse(value.isString)
        XCTAssertNil(value.bool)
        XCTAssertNil(value.int)
        XCTAssertNil(value.double)
        XCTAssertNil(value.string)

        value = true
        XCTAssertFalse(value.isNull)
        XCTAssertTrue(value.isBool)
        XCTAssertFalse(value.isNumber)
        XCTAssertFalse(value.isString)
        XCTAssertEqual(value.bool, true)
        XCTAssertNil(value.int)
        XCTAssertNil(value.double)
        XCTAssertNil(value.string)

        value = 14
        XCTAssertFalse(value.isNull)
        XCTAssertFalse(value.isBool)
        XCTAssertTrue(value.isNumber)
        XCTAssertFalse(value.isString)
        XCTAssertNil(value.bool)
        XCTAssertEqual(value.int, 14)
        XCTAssertEqual(value.double, 14.0)
        XCTAssertNil(value.string)

        value = 5.67
        XCTAssertFalse(value.isNull)
        XCTAssertFalse(value.isBool)
        XCTAssertTrue(value.isNumber)
        XCTAssertFalse(value.isString)
        XCTAssertNil(value.bool)
        XCTAssertEqual(value.int, 5)
        XCTAssertEqual(value.double!, 5.67, accuracy: 0.001)
        XCTAssertNil(value.string)

        value = "Hello World"
        XCTAssertFalse(value.isNull)
        XCTAssertFalse(value.isBool)
        XCTAssertFalse(value.isNumber)
        XCTAssertTrue(value.isString)
        XCTAssertNil(value.bool)
        XCTAssertNil(value.int)
        XCTAssertNil(value.double)
        XCTAssertEqual(value.string, "Hello World")
    }

    func testArrayAccessAndDynamicMemberLookup() throws {
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

        var swiftLib = context.swiftLib
        XCTAssertEqual(swiftLib.name, "JavaScript.swift")
        XCTAssertEqual(swiftLib.organizers[0].name, "Matvii")
        swiftLib.organizers[0].name = "Max"
        XCTAssertEqual(swiftLib.organizers[0].name, "Max")

        context.swiftLib = "Overriding global scope object!"
        XCTAssertEqual(context.swiftLib, "Overriding global scope object!")
    }

    func testDynamicCallable() throws {
        let context = JavaScriptSwift()
        try context.importSafe("""
        var adder = function () {
            var total = 0;
            return {
                getTotal: function () {
                    return total;
                },
                add: function (value) {
                    total += value;
                }
            };
        }();
        """)

        let adder = context.adder
        XCTAssertEqual(try adder.getTotal(), 0)
        try adder.add(40)
        XCTAssertEqual(try adder.getTotal(), 40)
        try adder.add(2)
        XCTAssertEqual(try adder.getTotal(), 42)

        XCTAssertThrowsError(try adder(), "should throw that adder is not a function")
    }

    func testPassSwiftValueToJavaScriptFunction() throws {
        let context = JavaScriptSwift()
        context.import("""
        var adder = function () {
            var total = 0;
            return {
                getTotal: function () {
                    return total;
                },
                add: function (value) {
                    total += value;
                }
            };
        }();
        """)

        let adder = context.adder
        XCTAssertEqual(try adder.getTotal(), 0)
        try adder.add(40)
        XCTAssertEqual(try adder.getTotal(), 40)
        try adder.add(2)
        XCTAssertEqual(try adder.getTotal(), 42)

        XCTAssertThrowsError(try adder(), "should throw that adder is not a function")
    }

    func testPassSwiftClosureToJavaScript() throws {
        let context = JavaScriptSwift()

        let lowerCaseString: @convention(block) (String) -> String = { input in
            let result = input.lowercased()
            return result
        }
        context.lowerCaseString = Value(object: lowerCaseString)
        XCTAssertEqual(context.import("lowerCaseString('lowerCaseString')"), "lowercasestring")
    }

    static var allTests = [
        ("testHelpers", testHelpers),
        ("testArrayAccessAndDynamicMemberLookup", testArrayAccessAndDynamicMemberLookup),
        ("testDynamicCallable", testDynamicCallable),
        ("testPassSwiftValueToJavaScriptFunction", testPassSwiftValueToJavaScriptFunction),
        ("testPassSwiftClosureToJavaScript", testPassSwiftClosureToJavaScript)
    ]
}
