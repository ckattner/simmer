# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  module Util
    # Understands how to read YAML.  You can utilize this tool to recursively read an entire
    # directory of YAML files and combine them into one YAML file, or simply read one YAML file.
    class YamlReader
      EXTENSIONS = %w[yml yaml].freeze

      private_constant :EXTENSIONS

      def smash(path)
        read(path).each_with_object({}) { |file, memo| memo.merge!(file.data || {}) }
      end

      def read(path)
        expand(path).map { |file| OpenStruct.new(path: file, data: raw(file)) }
      end

      private

      def raw(path)
        path     = File.expand_path(path)
        contents = File.read(path)

        YAML.safe_load(contents, [], [], true)
      end

      def wildcard_name
        "*.{#{EXTENSIONS.join(',')}}"
      end

      def full_path(path)
        File.join(path, '**', wildcard_name)
      end

      def expand(path)
        path = File.expand_path(path.to_s)

        # The sort will ensure it is deterministic (lexicographic by path)
        if File.directory?(path)
          glob = full_path(path)

          Dir[glob].to_a
        else
          Array(path)
        end.sort
      end
    end
  end
end
