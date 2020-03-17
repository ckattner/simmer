# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'specification/act'
require_relative 'specification/assert'
require_relative 'specification/stage'

module Simmer
  # Describes a specification at the highest of levels.
  class Specification
    acts_as_hashable

    attr_reader :act, :assert, :name, :path, :stage

    def initialize(act: {}, assert: {}, name:, path:, stage: {})
      raise ArgumentError, 'name is required' if name.to_s.empty?
      raise ArgumentError, 'path is required' if path.to_s.empty?

      @act    = Act.make(act)
      @assert = Assert.make(assert)
      @name   = name.to_s
      @path   = path.to_s
      @stage  = Stage.make(stage)

      freeze
    end
  end
end
