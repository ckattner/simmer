# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'resolver'

module Simmer
  module Util
    # Provides convenience methods for working with the file system.
    class FileSystem # :nodoc:
      class << self
        def setup_directory(dir_path)
          File.expand_path(dir_path).tap do |expanded_dir|
            FileUtils.mkdir_p(expanded_dir)
          end
        end
      end
    end
  end
end
