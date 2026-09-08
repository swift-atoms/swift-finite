#if os(macOS)
import Darwin
import Finite
import Foundation
import Testing

extension Finite::Finite {
    @Suite(.serialized)
    struct `Compiler emission preserves bounded ordinal construction contracts` {
        struct Compilation {
            let status: Int32
            let diagnostic: String
            let emittedObject: Bool
            let terminationReason: Process.TerminationReason
        }

        enum Failure: Swift.Error {
            case timedOut(String)
        }
    }
}

extension Finite::Finite.`Compiler emission preserves bounded ordinal construction contracts` {
    @Test
    func `Unrestricted tags coexist with checked nominal enumeration`() throws {
        let compilation = try Self.emit(named: "Valid Construction And Enumeration.swift")
        #expect(compilation.status == 0, Comment(rawValue: compilation.diagnostic))
        #expect(compilation.emittedObject)
    }

    @Test
    func `Capacity metadata does not confer finite enumeration on a tagged ordinal`() throws {
        let diagnostic = try Self.rejection(named: "Capacity Tagged Enumerable.swift")
        #expect(diagnostic.contains("'Tagged<CapacityThree, Ordinal>' conform to 'Finite.Enumerable'"))
    }

    @Test
    func `Capacity metadata does not make tagged ordinals CaseIterable`() throws {
        let diagnostic = try Self.rejection(named: "Capacity Tagged CaseIterable.swift")
        #expect(diagnostic.contains("'Tagged<CapacityThree, Ordinal>' conform to 'CaseIterable'"))
    }

    @Test
    func `The old bound tag does not restore the removed enumeration conformance`() throws {
        let diagnostic = try Self.rejection(named: "Old Bound Tagged Enumerable.swift")
        #expect(diagnostic.contains("'Tagged<Finite.Bound<3>, Ordinal>' conform to 'Finite.Enumerable'"))
    }

    @Test(arguments: ["Carrier Conformance.swift", "Ordinal Conformance.swift"])
    func `Bounded ordinals reject protocols requiring unrestricted construction`(_ fixture: String) throws {
        let diagnostic = try Self.rejection(named: fixture)
        #expect(diagnostic.contains("requires that 'Ordinal.Finite<3>' conform to"))
    }

    @Test(arguments: ["Unchecked Mapping.swift", "Unchecked Retagging.swift"])
    func `A nominal bounded ordinal cannot change its bound through generic tagged transforms`(
        _ fixture: String
    ) throws {
        let diagnostic = try Self.rejection(named: fixture)
        let member = fixture == "Unchecked Mapping.swift" ? "map" : "retag"
        #expect(diagnostic.contains("has no member '\(member)'"))
    }

    @Test
    func `Ordinary ordinal construction cannot bypass the failable result`() throws {
        let diagnostic = try Self.rejection(named: "Nonfailable Ordinal Construction.swift")
        #expect(diagnostic.contains("missing argument label '_unchecked:' in call"))
    }

    @Test
    func `Unrestricted ordinal addition is unavailable on bounded values`() throws {
        let diagnostic = try Self.rejection(named: "Unrestricted Addition.swift")
        #expect(diagnostic.contains("cannot convert value of type 'Ordinal.Finite<3>' to expected argument type 'Int'"))
    }

    @Test
    func `The stored ordinal cannot be replaced through a writable property`() throws {
        let diagnostic = try Self.rejection(named: "Mutable Underlying Ordinal.swift")
        #expect(diagnostic.contains("cannot assign to property: 'underlying' is a 'let' constant"))
    }

    @Test
    func `Checked construction at the largest integer bound can be emitted`() throws {
        let compilation = try Self.emit(named: "Largest Integer Bound.swift")
        #if DEBUG
        withKnownIssue("Swift integer generic specialization mangling: https://github.com/swiftlang/swift/issues/90739") {
            #expect(
                compilation.status == 0 && compilation.emittedObject,
                Comment(rawValue: compilation.diagnostic)
            )
        } matching: { issue in
            guard case .expectationFailed = issue.kind else { return false }
            return compilation.terminationReason == .uncaughtSignal
                && compilation.status == SIGABRT
                && compilation.diagnostic.contains(
                    "Abort: function demangleAndAddAsChildren at GenericSpecializationMangler.cpp:47"
                )
                && compilation.diagnostic.contains("Can't demangle: $4294967294__Tg5")
        }
        #else
        #expect(compilation.status == 0, Comment(rawValue: compilation.diagnostic))
        #expect(compilation.emittedObject)
        #endif
    }

    private static func rejection(named name: String) throws -> String {
        let compilation = try emit(named: name)
        try #require(compilation.terminationReason == .exit, Comment(rawValue: compilation.diagnostic))
        try #require(compilation.status != 0, "Fixture unexpectedly emitted successfully")
        return compilation.diagnostic
    }

    private static func emit(named name: String) throws -> Compilation {
        let manager = FileManager.default
        var products = Bundle.module.bundleURL
        while !manager.fileExists(atPath: products.appendingPathComponent("Finite.swiftmodule").path) {
            let parent = products.deletingLastPathComponent()
            products = try #require(parent != products ? parent : nil)
        }
        let resource = try #require(Bundle.module.resourceURL)
        let fixtures = resource.appendingPathComponent("Fixtures")
        let fixture = fixtures.appendingPathComponent(name)
        let support = fixtures.appendingPathComponent("Support.swift")
        try #require(manager.fileExists(atPath: fixture.path))
        try #require(manager.fileExists(atPath: support.path))

        let directory = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: directory) }
        let diagnosticURL = directory.appendingPathComponent("diagnostic.txt")
        try #require(manager.createFile(atPath: diagnosticURL.path, contents: nil))
        let diagnosticFile = try FileHandle(forWritingTo: diagnosticURL)
        defer { try? diagnosticFile.close() }
        let object = directory.appendingPathComponent("Proof.o")

        #if DEBUG
        let optimization = "-Onone"
        #else
        let optimization = "-O"
        #endif

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc", "-c", "-whole-module-optimization", "-parse-as-library", optimization,
            "-swift-version", "6",
            "-enable-experimental-feature", "Lifetimes",
            "-module-name", "Proof",
            "-I", products.path,
            support.path, fixture.path,
            "-o", object.path,
        ]
        process.standardOutput = diagnosticFile
        process.standardError = diagnosticFile
        try process.run()
        defer {
            if process.isRunning {
                _ = Darwin.kill(process.processIdentifier, SIGKILL)
            }
        }

        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(30))
        while process.isRunning && clock.now < deadline {
            Thread.sleep(forTimeInterval: 0.01)
        }
        guard !process.isRunning else {
            process.interrupt()
            let cancellationDeadline = clock.now.advanced(by: .seconds(1))
            while process.isRunning && clock.now < cancellationDeadline {
                Thread.sleep(forTimeInterval: 0.01)
            }
            throw Failure.timedOut(name)
        }
        process.waitUntilExit()
        let diagnostic = try String(contentsOf: diagnosticURL, encoding: .utf8)
        for failure in ["no such module", "missing required module", "could not build module", "compiled module was created by a different version"] {
            try #require(!diagnostic.contains(failure), Comment(rawValue: diagnostic))
        }
        return Compilation(
            status: process.terminationStatus,
            diagnostic: diagnostic,
            emittedObject: manager.fileExists(atPath: object.path),
            terminationReason: process.terminationReason
        )
    }
}
#endif
