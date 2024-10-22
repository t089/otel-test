### Error

```
swift-driver version: 1.115 Apple Swift version 6.0 (swiftlang-6.0.0.9.10 clang-1600.0.26.2)
Target: arm64-apple-macosx15.0
```

```
error: link command failed with exit code 1 (use -v to see invocation)
Undefined symbols for architecture arm64:
  "protocol witness table for OTel.OTelTracer<A, B, C, D, E> : Instrumentation.Instrument in OTel", referenced from:
      (3) suspend resume partial function for otel_test.otel_test.run() async throws -> () in otel_test.swift.o
  "protocol witness table for OTel.OTelTracer<A, B, C, D, E> : ServiceLifecycle.Service in OTel", referenced from:
      (3) suspend resume partial function for otel_test.otel_test.run() async throws -> () in otel_test.swift.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
[5/7] Linking otel-test
```