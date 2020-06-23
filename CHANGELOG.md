# Simmer Change Log

## 4.0.0 (TBD, 2020)

Additions:

* Support for custom test lifecycle hooks to be run before and after a every test or the entire suite.
* Simmer can now be configured to re-run tests which have failed due to a timeout a custom number of times.

Breaking Changes:

* The `callback_configuration` and `make_runner` methods have been removed from the `Simmer` module.
* `Simmer::Runner::Result#errors` now contains error/exception instances instead of strings.

## 3.0.0 (June 8th, 2020)

Breaking Changes:

* `Simmer::Runner` now accepts a `Simmer::Suite::OutputRouter` instead of an `IO` instance as its 'out' parameter.
* The `execution_output` and `execution_result` methods have been removed from `Simmer::Runner::Result`.

Additions:

* pdi_out.txt is written to throughout test execution instead of at the end.

Fixes:

* Fixtures now handle identifiers which are MySQL reserved words.

## 2.1.0 (May 13th, 2020)

Additions:

* Do not make missing fixtures short-circuit the rest of the test suite.
* Do not make PDI timeouts short-circuit the rest of the test suite.
* Report PDI's exit code and execution time to the console.

## 2.0.0 (May 11th, 2020)

Breaking Changes:

* Do not emit error file, standard error has been combined with the standard output within the underlying pdi library.

Additions:

* Enhanced Simmer configuration for `spoon_client` to account for `timeout_in_seconds` option.
