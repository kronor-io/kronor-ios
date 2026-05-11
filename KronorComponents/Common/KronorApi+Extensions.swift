import KronorApi

extension KronorApi.APIError {
    static let empty = KronorApi.APIError(errors: [], extensions: [:])
}
