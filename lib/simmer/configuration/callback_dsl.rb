# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Simmer
  class Configuration
    # Defines lifecycle hooks which can be run before and after the entire
    # suite or just a single test. Very similar to Rspec
    # (https://relishapp.com/rspec/rspec-core/v/3-9/docs/hooks/before-and-after-hooks).
    class CallbackDsl
      def initialize
        @before_suite = []
        @after_suite = []
        @before_each = []
        @after_each = []

        freeze
      end

      # Used to create a before callback. This accepts and optional level
      # parameter which can either be :suite or :each. ":each" is implied if no
      # level is provided.
      def before(level = LEVEL_EACH, &block)
        verify_level!(level)

        level == LEVEL_SUITE ? before_suite.push(block) : before_each.push(block)
      end

      # Used to create an after callback. This accepts and optional level
      # parameter which can either be :suite or :each. ":each" is implied if no
      # level is provided.
      def after(level = LEVEL_EACH, &block)
        verify_level!(level)

        level == LEVEL_SUITE ? after_suite.push(block) : after_each.push(block)
      end

      # :nodoc:
      def run_single_test_with_callbacks
        before_each.each(&:call)

        result = yield

        after_each.each { |block| block.call(result) }

        result
      end

      # :nodoc:
      def run_suite_with_callbacks
        before_suite.each(&:call)

        result = yield

        after_suite.each { |block| block.call(result) }

        result
      end

      private

      def verify_level!(level)
        raise ArgumentError, "unknown test level: #{level}" unless CALLBACK_LEVELS.include?(level)
      end

      attr_reader :after_each, :before_each, :after_suite, :before_suite

      LEVEL_EACH = :each
      LEVEL_SUITE = :suite
      CALLBACK_LEVELS = Set.new([LEVEL_EACH, LEVEL_SUITE])
      private_constant :LEVEL_EACH, :LEVEL_SUITE, :CALLBACK_LEVELS
    end
  end
end
