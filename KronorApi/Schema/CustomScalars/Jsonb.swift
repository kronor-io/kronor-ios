// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

public extension KronorApi {
    struct Jsonb: CustomScalarType, Hashable {
        public var value: [String: AnyHashable]

        public init(_jsonValue value: JSONValue) throws {
            if let dict = value as? [String: AnyHashable] {
                self.value = dict
            } else {
                throw JSONDecodingError.couldNotConvert(value: value, to: Jsonb.self)
            }
        }

        public var _jsonValue: JSONValue {
            return value as AnyHashable
        }

        public static func == (lhs: Jsonb, rhs: Jsonb) -> Bool {
            lhs._jsonValue == rhs._jsonValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(_jsonValue)
        }
    }

}
