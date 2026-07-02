// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension KronorCdeApi {
  /// See https://developer.apple.com/documentation/applepayontheweb/applepaypaymentcontact
  nonisolated struct ApplePayPaymentContactInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      addressLines: GraphQLNullable<[String]> = nil,
      administrativeArea: GraphQLNullable<String> = nil,
      country: GraphQLNullable<String> = nil,
      countryCode: GraphQLNullable<String> = nil,
      emailAddress: GraphQLNullable<String> = nil,
      familyName: GraphQLNullable<String> = nil,
      givenName: GraphQLNullable<String> = nil,
      locality: GraphQLNullable<String> = nil,
      phoneNumber: GraphQLNullable<String> = nil,
      phoneticFamilyName: GraphQLNullable<String> = nil,
      phoneticGivenName: GraphQLNullable<String> = nil,
      postalCode: GraphQLNullable<String> = nil,
      subAdministrativeArea: GraphQLNullable<String> = nil,
      subLocality: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "addressLines": addressLines,
        "administrativeArea": administrativeArea,
        "country": country,
        "countryCode": countryCode,
        "emailAddress": emailAddress,
        "familyName": familyName,
        "givenName": givenName,
        "locality": locality,
        "phoneNumber": phoneNumber,
        "phoneticFamilyName": phoneticFamilyName,
        "phoneticGivenName": phoneticGivenName,
        "postalCode": postalCode,
        "subAdministrativeArea": subAdministrativeArea,
        "subLocality": subLocality
      ])
    }

    /// The street portion of the address for the contact.
    public var addressLines: GraphQLNullable<[String]> {
      get { __data["addressLines"] }
      set { __data["addressLines"] = newValue }
    }

    /// The state for the contact.
    public var administrativeArea: GraphQLNullable<String> {
      get { __data["administrativeArea"] }
      set { __data["administrativeArea"] = newValue }
    }

    /// The name of the country or region for the contact.
    public var country: GraphQLNullable<String> {
      get { __data["country"] }
      set { __data["country"] = newValue }
    }

    /// The contact’s two-letter ISO 3166 country code.
    public var countryCode: GraphQLNullable<String> {
      get { __data["countryCode"] }
      set { __data["countryCode"] = newValue }
    }

    /// An email address for the contact.
    public var emailAddress: GraphQLNullable<String> {
      get { __data["emailAddress"] }
      set { __data["emailAddress"] = newValue }
    }

    /// The contact’s family name.
    public var familyName: GraphQLNullable<String> {
      get { __data["familyName"] }
      set { __data["familyName"] = newValue }
    }

    /// The contact’s given name.
    public var givenName: GraphQLNullable<String> {
      get { __data["givenName"] }
      set { __data["givenName"] = newValue }
    }

    /// The city for the contact.
    public var locality: GraphQLNullable<String> {
      get { __data["locality"] }
      set { __data["locality"] = newValue }
    }

    /// A phone number for the contact.
    public var phoneNumber: GraphQLNullable<String> {
      get { __data["phoneNumber"] }
      set { __data["phoneNumber"] = newValue }
    }

    /// The phonetic spelling of the contact’s family name.
    public var phoneticFamilyName: GraphQLNullable<String> {
      get { __data["phoneticFamilyName"] }
      set { __data["phoneticFamilyName"] = newValue }
    }

    /// The phonetic spelling of the contact’s given name.
    public var phoneticGivenName: GraphQLNullable<String> {
      get { __data["phoneticGivenName"] }
      set { __data["phoneticGivenName"] = newValue }
    }

    /// The zip code or postal code, where applicable, for the contact.
    public var postalCode: GraphQLNullable<String> {
      get { __data["postalCode"] }
      set { __data["postalCode"] = newValue }
    }

    /// The subadministrative area (such as a county or other region) in a postal address.
    public var subAdministrativeArea: GraphQLNullable<String> {
      get { __data["subAdministrativeArea"] }
      set { __data["subAdministrativeArea"] = newValue }
    }

    /// Additional information associated with the location, typically defined at the city or town level (such as district or neighborhood), in a postal address.
    public var subLocality: GraphQLNullable<String> {
      get { __data["subLocality"] }
      set { __data["subLocality"] = newValue }
    }
  }

}