# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'spec_helper'

describe Simmer::Util::Evaluator do
  let(:template) do
    'The {traits.speed} {animal} jumps over the {thing}.'
  end

  describe '#evaluate' do
    context 'when input is hash with string keys' do
      let(:input) do
        {
          'animal' => :fox,
          'traits' => {
            'speed' => :quick
          },
          'thing' => :wall
        }
      end

      it 'renders template' do
        expected = 'The quick fox jumps over the wall.'

        expect(subject.evaluate(template, input)).to eq(expected)
      end
    end

    context 'when input is hash with symbol keys' do
      let(:input) do
        {
          animal: :fox,
          traits: {
            speed: :quick
          },
          thing: :wall
        }
      end

      it 'renders template' do
        expected = 'The quick fox jumps over the wall.'

        expect(subject.evaluate(template, input)).to eq(expected)
      end
    end

    context 'when input is OpenStruct' do
      let(:input) do
        OpenStruct.new(
          animal: :fox,
          traits: OpenStruct.new(
            speed: :quick
          ),
          thing: :wall
        )
      end

      it 'renders template' do
        expected = 'The quick fox jumps over the wall.'

        expect(subject.evaluate(template, input)).to eq(expected)
      end
    end

    context 'when input is nil' do
      let(:input) { nil }

      it 'renders against nil' do
        expected = 'The   jumps over the .'

        expect(subject.evaluate(template, input)).to eq(expected)
      end
    end
  end
end
