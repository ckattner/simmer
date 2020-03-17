# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'file_system'

module Simmer
  module Externals
    # Provides the implementation for using a local directory
    class LocalFileSystem < FileSystem
      def initialize(root, files_dir)
        root = File.expand_path(root.to_s)

        super(root)

        @files_dir = files_dir.to_s

        freeze
      end

      def write!(input_files)
        input_files.each do |input_file|
          src = File.join(files_dir, input_file.src)

          write_single(input_file.dest, src)
        end

        input_files.length
      end

      def clean!
        glob      = File.join(root, '**', '*')
        all_files = Dir[glob].reject { |p| File.directory?(p) }

        all_files.each { |path| FileUtils.rm(path) }
        all_files.length
      end

      private

      attr_reader :files_dir

      def write_single(dest, src)
        full_dest = File.join(root, dest)
        dest_dir  = File.dirname(full_dest)
        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp(src, full_dest)
      end
    end
  end
end
