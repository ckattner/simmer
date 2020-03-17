# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

class AwsS3Client
  extend Forwardable

  def_delegators :client,
                 :list_objects,
                 :delete_objects,
                 :put_object

  attr_reader :client, :store

  def initialize(store = {})
    @store  = store
    @client = make_client

    freeze
  end

  private

  # rubocop:disable Metrics/AbcSize
  def make_client
    Aws::S3::Client.new(stub_responses: true).tap do |client|
      client.stub_responses(:get_object, lambda { |context|
        obj = store[context.params[:key]]
        obj || 'NoSuchKey'
      })

      client.stub_responses(:put_object, lambda { |context|
        store[context.params[:key]] = { body: context.params[:body] }
        {}
      })

      client.stub_responses(:list_objects, lambda { |_context|
        contents = store.keys.map { |k| OpenStruct.new(key: k) }

        OpenStruct.new(contents: contents)
      })

      client.stub_responses(:delete_objects, lambda { |context|
        keys = context.params.dig(:delete, :objects).map { |k| k[:key] }

        keys.each { |key| store.delete(key) }
      })
    end
  end
  # rubocop:enable Metrics/AbcSize
end
