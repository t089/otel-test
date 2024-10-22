// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import OTel
import OTLPGRPC
import Instrumentation
import Logging
import ServiceLifecycle

@main
struct otel_test: AsyncParsableCommand {
    mutating func run() async throws {
        let environment = OTelEnvironment.detected()
        let resourceDetection = OTelResourceDetection(detectors: [
            OTelProcessResourceDetector(),
            OTelEnvironmentResourceDetector(environment: environment),
        ])
        let resource = await resourceDetection.resource(environment: environment, logLevel: .trace)

        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            
            handler.metadataProvider = .otel(
                traceIDKey: "trace.id", spanIDKey: "transaction.id", traceFlagsKey: "trace.flags",
                parentSpanIDKey: nil)
            handler.logLevel = .info

            switch label {
            case "OTLPGRPCSpanExporter":
                handler.logLevel = .debug
            default: break
            }

            return handler
        }

        let exporter = try OTLPGRPCSpanExporter(
            configuration: .init(environment: environment),
            requestLogger: Logger(label: "otel_grpc"),
            backgroundActivityLogger: Logger(label: "otel_grpc"))

        let tracer = OTelTracer(
            idGenerator: OTelRandomIDGenerator(),
            sampler: OTelParentBasedSampler(
                rootSampler: OTelConstantSampler(decision: .recordAndSample)
            ),
            propagator: OTelW3CPropagator(),
            processor: OTelBatchSpanProcessor(
                exporter: exporter, configuration: .init(environment: environment)),
            environment: environment,
            resource: resource
        )

        InstrumentationSystem.bootstrap(tracer)

        let serviceGroup = ServiceGroup(services: [tracer], gracefulShutdownSignals: [], cancellationSignals: [.sigint, .sigterm], logger: Logger(label: "service_group"))
        print("Hello, world!")
        try await serviceGroup.run()
    }
}
