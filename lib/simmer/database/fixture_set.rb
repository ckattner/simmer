# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'fixture'

module Simmer
  module Database
    # Hydrate a collection of Fixture instances from configuration.
    class FixtureSet
      class FixtureMissingError < StandardError; end

      def initialize(config = {})
        @fixtures_by_name = config_to_fixures_by_name(config)

        freeze
      end

      def get!(name)
        key = name.to_s

        raise FixtureMissingError, "fixture missing: #{name}" unless fixtures_by_name.key?(key)

        fixtures_by_name[key]
      end

      private

      attr_reader :fixtures_by_name

      def config_to_fixures_by_name(config)
        (config || {}).each_with_object({}) do |(name, fixture_config), memo|
          full_config = (fixture_config || {}).merge(name: name)

          memo[name.to_s] = Fixture.make(full_config)
        end
      end
    end
  end
end
