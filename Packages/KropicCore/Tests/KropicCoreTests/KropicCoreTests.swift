import Testing
@testable import KropicCore

@Test func packageExposesVersion() {
    #expect(KropicCore.version == "0.1.0")
}
