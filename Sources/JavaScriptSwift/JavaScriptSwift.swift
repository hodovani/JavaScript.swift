import JavaScriptCore

@dynamicMemberLookup
public final class JavaScriptSwift {
    fileprivate var context = JSContext()!

    public enum Error: Swift.Error {
        case notAFunction
    }

    /// Initializes `self` with separete context.
    public init() {
        context = JSContext()!
    }

    var exception: JavaScriptException? {
        if let exception = self.context.exception {
            let object = JSValue(exception)
            return JavaScriptException(
                message: object.message.string!,
                line: object.line.int,
                column: object.column.int
            )
        } else {
            return nil
        }
    }

    @discardableResult
    public func `import`(_ script: String) throws -> JSValue {
        let value = JSValue(context.evaluateScript(script))
        // TODO: add error handler
        //        if let exception = context.exception { throw Error(exception) }
        return value
    }

    @discardableResult
    public func `import`(_ url: URL) throws -> JSValue {
        return try `import`(String(contentsOf: url))
    }
}

@dynamicCallable
@dynamicMemberLookup
public struct JSValue {
    internal let value: JavaScriptCore.JSValue

    fileprivate init(_ value: JavaScriptCore.JSValue) {
        self.value = value
    }
}

struct JavaScriptException: Error, CustomStringConvertible, CustomDebugStringConvertible {
    let message: String
    let line: Int?
    let column: Int?

    var description: String {
        let lineString = line.map(String.init(describing:)) ?? "?"
        let columnString = column.map(String.init(describing:)) ?? "?"
        return "\(message) (line: \(lineString), column: \(columnString)"
    }

    var debugDescription: String {
        return description
    }
}

public extension JSValue {
    var isUndefined: Bool {
        return value.isUndefined
    }

    var isNull: Bool {
        return value.isNull
    }

    var isBool: Bool {
        return value.isBoolean
    }

    var bool: Bool? {
        return value.isBoolean ? value.toBool() : nil
    }

    var isNumber: Bool {
        return value.isNumber
    }

    var int: Int? {
        return value.isNumber ? Int(value.toInt32()) : nil
    }

    var double: Double? {
        return value.isNumber ? value.toDouble() : nil
    }

    var isString: Bool {
        return value.isString
    }

    var string: String? {
        return value.isString ? value.toString() : nil
    }
}

extension JSValue: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self.init(.init(nullIn: JSContext()))
    }
}

extension JSValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(.init(bool: value, in: JSContext()))
    }
}

extension JSValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self.init(.init(int32: value, in: JSContext()))
    }
}

extension JSValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(.init(double: value, in: JSContext()))
    }
}

extension JSValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(.init(object: value, in: JSContext()))
    }
}

extension JSValue: Equatable {
    public static func == (lhs: JSValue, rhs: JSValue) -> Bool {
        return lhs.value.isEqualWithTypeCoercion(to: rhs.value)
    }
}

extension JSValue: CustomStringConvertible {
    public var description: String {
        return value.toString()
    }
}

public extension JavaScriptSwift {
    subscript(dynamicMember member: String) -> JSValue {
        get {
            return JSValue(context.objectForKeyedSubscript(member))
        }
        set {
            context.setObject(newValue.value, forKeyedSubscript: member as NSString)
        }
    }
}

public extension JSValue {
    subscript(index: Int) -> JSValue {
        get {
            return JSValue(value.atIndex(index))
        }
        set {
            value.setValue(newValue.value, at: index)
        }
    }

    subscript(dynamicMember member: String) -> JSValue {
        get {
            return JSValue(value.forProperty(member)!)
        }
        set {
            value.setValue(newValue.value, forProperty: member)
        }
    }
}

public extension JSValue {
    @discardableResult
    func dynamicallyCall(withArguments arguments: [JSValue]) throws -> JSValue {
        let values = arguments.map({ $0.value })

        guard let returnValue = value.call(withArguments: values) else {
            throw JavaScriptSwift.Error.notAFunction
        }
//        add exception catch
//        if let exception = JavaScriptSwift.context.exception {
//            throw exception
//        }

        return JSValue(returnValue)
    }
}
