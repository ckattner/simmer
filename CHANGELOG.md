# 2.1.0 (May 12th, 2020)

Additions:

* Do not make missing fixtures short-circuit the rest of the test suite.
* Do not make PDI timeouts short-circuit the rest of the test suite.
* Report PDI's exit code and execution time to the console.

# 2.0.0 (May 11th, 2020)

Breaking Changes:

* Do not emit error file, standard error has been combined with the standard output within the underlying pdi library.

Additions:

* Enhanced Simmer configuration for `spoon_client` to account for `timeout_in_seconds` option.
