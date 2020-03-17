# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Specification
    class Act
      # Understands how to compile a list of files and key value pairs for Pdi::Spoon
      # consumption.
      class Params
        acts_as_hashable

        attr_reader :files, :keys

        def initialize(files: {}, keys: {})
          @files     = files || {}
          @keys      = keys || {}
          @evaluator = Util::Evaluator.new

          freeze
        end

        def compile(files_path, config = {})
          compiled_file_params(files_path, config).merge(compiled_key_params(config))
        end

        private

        attr_reader :evaluator

        def compiled_file_params(files_path, config)
          files.map do |key, value|
            evaluated_value = evaluator.evaluate(value, config)
            expanded_value  = File.expand_path(File.join(files_path, evaluated_value))

            [key, expanded_value]
          end.to_h
        end

        def compiled_key_params(config)
          keys.map do |key, value|
            evaluated_value = evaluator.evaluate(value, config)

            [key, evaluated_value]
          end.to_h
        end
      end
    end
  end
end
