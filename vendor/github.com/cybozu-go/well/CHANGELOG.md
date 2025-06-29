# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.11.2] - 2023-02-01

### Changed
- Update dependencies in [#43](https://github.com/cybozu-go/well/pull/43)
    - Upgrade direct dependencies in go.mod
    - Update Golang used for testing from 1.18 to 1.19
    - Update GitHub Actions
- Fix for deprecated "io/ioutil" in [#43](https://github.com/cybozu-go/well/pull/43)

## [1.11.1] - 2022-08-30

### Changed
- Update dependencies ([#40](https://github.com/cybozu-go/well/pull/40)).

## [1.11.0] - 2021-12-15

### Changed
- Update dependencies ([#39](https://github.com/cybozu-go/well/pull/39)).

### Removed
- The wrapped `http.ResponseWriter` no longer implements `http.CloseNotifier` ([#39](https://github.com/cybozu-go/well/pull/39)).

## [1.10.0] - 2020-01-24
### Added
- Getter for requestIDHeader ([#35](https://github.com/cybozu-go/well/pull/35)).

### Changed
- Sleep for some seconds after signal handler receives a signal ([#37](https://github.com/cybozu-go/well/pull/37)).

## [1.9.0] - 2019-09-24
### Added
- HTTPServer: add support for HTTP/2 request handling ([#27](https://github.com/cybozu-go/well/pull/27), [#32](https://github.com/cybozu-go/well/pull/32)).

### Changed
- HTTPServer: fix remote IP access logging ([#31](https://github.com/cybozu-go/well/pull/31)).

## [1.8.1] - 2018-10-21
### Changed
- Remove dependency on `github.com/spf13/cobra`.

## [1.8.0] - 2018-10-21
### Added
- Support for users of [github.com/spf13/cobra](https://github.com/spf13/cobra) and its friends ([#24](https://github.com/cybozu-go/well/pull/24)).

## [1.7.0] - 2018-10-20
### Changed
- Use http.Server.Shutdown for Go 1.8+ ([#23](https://github.com/cybozu-go/well/pull/23)).
- Rename the project from `cmd` to `well`.
- Remove dependency on `github.com/pkg/errors`.

## [1.6.0] - 2018-09-14
### Added
- Opt in to [Go modules](https://github.com/golang/go/wiki/Modules).

## [1.5.0] - 2017-04-28
### Added
- `IsSystemdService` to detect if running as a systemd service.

### Changed
- Ignore SIGPIPE for systemd, reverts [#15](https://github.com/cybozu-go/well/pull/15) ([#17](https://github.com/cybozu-go/well/pull/17)).

## [1.4.2] - 2017-04-26
### Changed
- Exit abnormally upon SIGPIPE ([#15](https://github.com/cybozu-go/well/pull/15)).

## [1.4.1] - 2017-03-01
### Changed
- Fix `NewEnvironment` documentation.
- Ignore SIGPIPE for systemd ([#13](https://github.com/cybozu-go/well/pull/13)).

## [1.4.0] - 2016-09-10
### Added
- `BackgroundWithID` creates a new context inheriting the request ID.
- `Graceful` for Windows to make porting easy, though it does not restart.

### Changed
- Fix Windows support by [@mattn](https://github.com/mattn).
- Fix a subtle data race in `Graceful`.

## [1.3.0] - 2016-09-02
### Added
- `GoWithID` starts a goroutine with a new request tracking ID.

### Changed
- `Go` no longer issues new ID automatically.  Use `GoWithID` instead.

## [1.2.0] - 2016-08-31
### Added
- `Graceful` for network servers to implement graceful restart.
- `SystemdListeners` returns `[]net.Listener` for [systemd socket activation][activation].

### Changed
- Optimize `IDGenerator` performance.
- `Server.Handler` closes connection.
- Lower `Environment.Wait` log to debug level.

## [1.1.0] - 2016-08-24
### Added
- `IDGenerator` generates UUID-like ID string for request tracking.
- `Go` issues new request tracking ID and store it in the derived context.
- `HTTPClient`, a wrapper for `http.Client` that exports request tracking ID and logs results.
- `LogCmd`, a wrapper for `exec.Cmd` that records command execution results together with request tracking ID.

### Changed
- `HTTPServer` adds or imports request tracking ID for every request.
- `Server` adds request tracking ID for each new connection.
- Install signal handler only for the global environment.

### Removed
- `Context` method of `Environment` is removed.  It was a design flaw.

## [1.0.1] - 2016-08-22
### Changed
- Update docs.
- Use [cybozu-go/netutil](https://github.com/cybozu-go/netutil).
- Conform to cybozu-go/log v1.1.0 spec.

[activation]: http://0pointer.de/blog/projects/socket-activation.html
[Unreleased]: https://github.com/cybozu-go/cmd/compare/v1.11.2...HEAD
[1.11.2]: https://github.com/cybozu-go/cmd/compare/v1.11.1...v1.11.2
[1.11.1]: https://github.com/cybozu-go/cmd/compare/v1.11.0...v1.11.1
[1.11.0]: https://github.com/cybozu-go/cmd/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/cybozu-go/cmd/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/cybozu-go/cmd/compare/v1.8.1...v1.9.0
[1.8.1]: https://github.com/cybozu-go/cmd/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/cybozu-go/cmd/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/cybozu-go/cmd/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/cybozu-go/cmd/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/cybozu-go/cmd/compare/v1.4.2...v1.5.0
[1.4.2]: https://github.com/cybozu-go/cmd/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/cybozu-go/cmd/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/cybozu-go/cmd/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/cybozu-go/cmd/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/cybozu-go/cmd/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/cybozu-go/cmd/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/cybozu-go/cmd/compare/v1.0.0...v1.0.1
