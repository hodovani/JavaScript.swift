@testable import JavaScriptSwift
import XCTest

final class JavaScriptSwiftTests: XCTestCase {
    func testHelpers() throws {
        var value: JSValue = nil
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

        let conference = JavaScriptSwift.context.conference
        XCTAssertEqual(conference.name, "Swift Island")
        XCTAssertEqual(conference.organizers[0].name, "Niels")
        conference.organizers[0].name = "Niels van Hoorn"
        XCTAssertEqual(conference.organizers[0].name, "Niels van Hoorn")

        JavaScriptSwift.context.conference = "Overriding global scope object!"
        XCTAssertEqual(JavaScriptSwift.context.conference, "Overriding global scope object!")
    }

    func testDynamicCallable() throws {
        try JavaScriptSwift.import("""
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

        let adder = JavaScriptSwift.context.adder
        XCTAssertEqual(try adder.getTotal(), 0)
        try adder.add(40)
        XCTAssertEqual(try adder.getTotal(), 40)
        try adder.add(2)
        XCTAssertEqual(try adder.getTotal(), 42)

        XCTAssertThrowsError(try adder(), "should throw that adder is not a function")
    }

    static var allTests = [
        ("testHelpers", testHelpers),
        ("testArrayAccessAndDynamicMemberLookup", testArrayAccessAndDynamicMemberLookup),
        ("testDynamicCallable", testDynamicCallable)
    ]
}
