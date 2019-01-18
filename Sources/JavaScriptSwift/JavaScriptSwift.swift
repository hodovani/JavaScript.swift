import JavaScriptCore

@dynamicMemberLookup
public final class JavaScriptSwift {
    fileprivate var context = JSContext()!

    public enum Error: Swift.Error {
        case notAFunction
        case exception(String)
    }

    /// Initializes `self` with separete context.
    public init() {
        context = JSContext()!
    }

    var exception: JavaScriptException? {
        if let exception = self.context.exception {
            let object = Value(exception)
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
    public func importSafe(_ script: String) throws -> Value {
        let value = Value(context.evaluateScript(script))
        
        if let exception = context.exception {
            throw Error.exception(exception.toString())
        }
        
        return value
    }
    
    @discardableResult
    public func `import`(_ script: String) -> Value {
        let value = Value(context.evaluateScript(script))
        
        if let exception = context.exception {
            fatalError(exception.toString())
        }
        
        return value
    }
    
    @discardableResult
    public func importSafe(_ url: URL) throws -> Value {
        return try `import`(String(contentsOf: url))
    }
    
    public func setObject(_ object: Any!, forKeyedSubscript key: (NSCopying & NSObjectProtocol)!)  {
        self.context.setObject(object, forKeyedSubscript: key)
    }
}

@dynamicCallable
@dynamicMemberLookup
public struct Value {
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

public extension Value {
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

extension Value: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self.init(.init(nullIn: JSContext()))
    }
}

extension Value: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(.init(bool: value, in: JSContext()))
    }
}

extension Value: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self.init(.init(int32: value, in: JSContext()))
    }
}

extension Value: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(.init(double: value, in: JSContext()))
    }
}

extension Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(.init(object: value, in: JSContext()))
    }
}

extension Value: Equatable {
    public static func == (lhs: Value, rhs: Value) -> Bool {
        return lhs.value.isEqualWithTypeCoercion(to: rhs.value)
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        return value.toString()
    }
}

extension Value {
    public init(object: Any) {
        self.init(.init(object: object, in: JSContext()))
    }
}

public extension JavaScriptSwift {
    subscript(dynamicMember member: String) -> Value {
        get {
            return Value(context.objectForKeyedSubscript(member))
        }
        set {
            context.setObject(newValue.value, forKeyedSubscript: member as NSString)
        }
    }
}

public extension Value {
    subscript(index: Int) -> Value {
        get {
            return Value(value.atIndex(index))
        }
        set {
            value.setValue(newValue.value, at: index)
        }
    }

    subscript(dynamicMember member: String) -> Value {
        get {
            return Value(value.forProperty(member)!)
        }
        set {
            value.setValue(newValue.value, forProperty: member)
        }
    }
}

public extension Value {
    @discardableResult
    func dynamicallyCall(withArguments arguments: [Value]) throws -> Value {
        let values = arguments.map({ $0.value })

        guard let returnValue = value.call(withArguments: values) else {
            throw JavaScriptSwift.Error.notAFunction
        }
//        add exception catch
//        if let exception = JavaScriptSwift.context.exception {
//            throw exception
//        }

        return Value(returnValue)
    }
}
