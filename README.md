# Simmer

---

[![Gem Version](https://badge.fury.io/rb/simmer.svg)](https://badge.fury.io/rb/simmer) [![Build Status](https://travis-ci.org/bluemarblepayroll/simmer.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/simmer) [![Maintainability](https://api.codeclimate.com/v1/badges/61996dff817d44efc408/maintainability)](https://codeclimate.com/github/bluemarblepayroll/simmer/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/61996dff817d44efc408/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/simmer/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Note: This is not officially supported by Hitachi Vantara.*

This library provides is a Ruby-based testing suite for [Pentaho Data Integration](https://www.hitachivantara.com/en-us/products/data-management-analytics/pentaho-platform/pentaho-data-integration.html).  You can create specifications for Pentaho transformations and jobs then ensure they always run correctly.

## Compatibility & Limitations

This library was tested against:

* Kettle version 6.1.0.1-196
* MacOS and Linux

Note that it also is currently limited to:

* MySQL
* Amazon Simple Storage Service

Future enhancements potentially could include breaking these out and making them plug-ins in order to support other database and cloud storage vendors/systems.

## Installation

To install through Rubygems:

````bash
gem install simmer
````

You can also add this to your Gemfile:

````bash
bundle add simmer
````

After installation, you will need do to two things:

1. Add simmer configuration file
2. Add simmer directory

### Simmer Configuration File

The configuration file contains information about external systems, such as:

* Amazon Simple Storage Service
* Local File System
* Pentaho Data Integration
* MySQL Database

Copy this configuration template into your project's root to: `config/simmer.yaml`:

````yaml
mysql_database:
  database:
  username:
  host:
  port:
  flags: MULTI_STATEMENTS

spoon_client:
  dir: spec/mocks/spoon
  args: 0

# local_file_system:
#  dir: tmp/store_test

# aws_file_system:
#   access_key_id:
#   bucket:
#   default_expires_in_seconds: 3600
#   encryption: AES256
#   region:
#   secret_access_key:
````

Note: You can configure any options for `mysql_database` listed in the [mysql2 gem configuration options](https://github.com/brianmario/mysql2#connection-options).

Fill out the missing configuration values required for each section.  If you would like to use your local file system then un-comment the `local_file_system` key.  If you would like to use AWS S3 then un-comment out the `aws_file_system` key.

Note: There is a naming-convention-based protection to help ensure non-test database and file systems do not get accidentally wiped that you must follow:

1. Database names must end in `_test'
2. local file system dir must end in `-test`
3. AWS file system bucket must end in `-test`

### Simmer Directory

You will also need to create the following folder structure in your project's root folder:

* **simmer/files**: Place any files necessary to stage in this directory.
* **simmer/fixtures**: Place YAML files, that describe database records, necessary to stage the database.
* **simmer/specs**: Place specification YAML files here.

It does not matter how each of these directories are internally structured, they can contain folder structure in any arbitrary way.  These directories should be version controlled as they contain the necessary information to execute your tests.  But you may want to ignore the `simmer/results` directory as that will store the results after execution.

## Getting Started

### What is a Specification?

A specification is a blueprint for how to run a transformation or job and contains configuration for:

* File system state before execution
* Database state before execution
* Execution command
* Expected database state after execution
* Expected execution output

#### Specification Example

The following is an example specification for a transformation:

````yaml
name: Declassify Users
stage:
  files:
    src: noc_list.csv
    dest: input/noc_list.csv
  fixtures:
    - iron_man
    - hulk
act:
  name: load_noc_list
  repository: top_secret
  type: transformation
  params:
    files:
      input_file: noc_list.csv
    keys:
      code: 'The secret code is: {codes.the_secret_one}'
assert:
  assertions:
    - type: table
      name: agents
      records:
        - call_sign: iron_man
          first: tony
          last: stark
        - call_sign: hulk
          first: bruce
          last: banner
    - type: table
      name: agents
      logic: includes
      records:
        - last: stark
    - type: output
      value: output to stdout
````

##### Stage Section

The stage section defines the pre-execution state that needs to exist before PDI execution.  There are two options:

1. Files
2. Fixtures

###### Files

Each file entry specifies two things:

* **src**: the location of the file (relative to the `simmer/files`)
* **dest**: where to copy it to (within the configured file system: local or S3)

###### Fixtures

Fixtures will populate the database specified in the `mysql_database` section of `simmer.yaml`.  In order to do this you need to:

1. Add the fixture to a YAML file in the `simmer/fixtures` directory.
2. Add the name of the fixture you wish to use in the `stage/fixtures` section as illustrated above

**Adding Fixtures**

Fixtures live in YAML files within the `simmer/fixtures` directory.  They can be placed in any arbitrary file, the only restriction is their top-level keys that uniquely identify a fixture.  Here is an example of a fixture file:

````yaml
hulk:
  table: agents
  fields:
    call_sign: hulk
    first: CLASSIFIED
    last: CLASSIFIED

iron_man:
  table: agents
  fields:
    call_sign: iron_man
    first: CLASSIFIED
    last: CLASSIFIED
````

This example specifies two fixtures: `hulk` and `iron_man`.  Each will end up creating a record in the `agents` table with their respective attributes (columns).

##### Act Section

The act configuration contains the necessary information for invoking Pentaho through its Spoon script.  The options are:

* **name**: The name of the transformation or job
* **repository**: The name of the Kettle repository
* **type**: transformation or job
* **file params**: key-value pairs to send through to Spoon as params.  The values will be joined with and are relative to the `simmer/files` directory.
* **key params**: key-value pairs to send through to Spoon as params.

##### Assert Section

The assert section contains the expected state of:

* Database table contents
* Pentaho output contents

Take the assert block from the example above:

````yaml
assert:
  assertions:
    - type: table
      name: agents
      records:
        - call_sign: iron_man
          first: tony
          last: stark
        - call_sign: hulk
          first: bruce
          last: banner
    - type: table
      name: agents
      logic: includes
      records:
        - last: stark
    - type: output
      value: output to stdout
````

This contains two table and one output assertion.  It explicitly states that:

* The table `agents` should exactly contain two records with the column values as described (iron_man and hulk)
* The table `agents` should include a record where the last name is `stark`
* The standard output should contain the string described in the value somewhere in the log

**Note**: Output does not currently test the standard error, just the standard output.

###### Table Assertion Rules

Currently table assertions operate under a very rudimentary set of rules:

* Record order does not matter
* Each record being asserted should have the same keys compared
* All values are asserted against their string coerced value
* There is no concept of relationships or associations (yet)

### Running Tests

After you have configured simmer and written a specification, you can run it by executing:

````bash
bundle exec simmer ./simmer/specs/name_of_the_spec.yaml
````

The passed in path can also be a directory and all specs in the directory (recursively) will be executed:

````bash
bundle exec simmer ./simmer/specs/some_directory
````

You can also omit the path altogether to execute all specs:

````bash
bundle exec simmer
````

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check simmer.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/simmer.git)
4. Navigate to the root folder (cd simmer)
5. Install dependencies (bundle)
6. Create the 'simmer_test' MySQL database as defined in `spec/db/tables.sql`.
7. Add the tables from `spec/db/tables.sql` to this database.
8. Configure your test simmer.yaml:

````bash
cp spec/config/simmer.yaml.ci spec/config/simmer.yaml
```

9. Edit `spec/config/simmer.yaml` so that it can connect to the database created in step seven.

### Running Tests

To execute the test suite and code-coverage tool, run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

or run all three in one command:

````bash
bundle exec rake
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/simmer/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/simmer/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
