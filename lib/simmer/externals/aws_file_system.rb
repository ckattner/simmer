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
    # Provides the implementation for using AWS S3 as a destination file store.
    class AwsFileSystem < FileSystem
      def initialize(aws_s3_client, bucket, encryption, files_dir)
        raise ArgumentError, 'aws_s3_client is required' unless aws_s3_client
        raise ArgumentError, 'bucket is required'        if bucket.to_s.empty?

        super(bucket)

        @aws_s3_client = aws_s3_client
        @encryption    = encryption
        @files_dir     = files_dir

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
        response    = aws_s3_client.list_objects(bucket: root)
        objects     = response.contents
        keys        = objects.map(&:key)
        delete_keys = keys.map { |key| { key: key } }

        return 0 if objects.length.zero?

        aws_s3_client.delete_objects(
          bucket: root,
          delete: {
            objects: delete_keys
          }
        )

        delete_keys.length
      end

      private

      attr_reader :aws_s3_client, :encryption, :files_dir

      def write_single(dest, src)
        src = File.expand_path(src)

        File.open(src, 'rb') do |file|
          aws_s3_client.put_object(
            body: file.read,
            bucket: root,
            key: dest,
            server_side_encryption: encryption
          )
        end

        nil
      end
    end
  end
end
