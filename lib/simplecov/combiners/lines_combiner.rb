# frozen_string_literal: true

module SimpleCov
  module Combiners
    #
    # Combine two different lines coverage results on same file
    #
    class LinesCombiner < BaseCombiner
      def combine
        return existing_coverage unless empty_coverage?

        combine_lines
      end

      # first_coverage = [nil, 1, 1, 1, nil, nil, 1, 0, nil, 1]
      # second_coverage = [nil, 1, 1, 1, nil, 1, 1, 0, nil, nil]
      # output ex: [nil, 2, 2, 2, nil, 1, 2, 0, nil, 1]
      def combine_lines
        merged_vals = []
        @first_coverage.zip(@second_coverage) do |first_val, second_val|
          merged_vals << merge_line_coverage(first_val, second_val)
        end
        merged_vals
      end

      #
      # Return depends on value
      #
      # @param [Integer || nil] first_val
      # @param [Integer || nil] second_val
      #
      # Logic:
      #
      # => nil + 0 = nil
      # => nil + nil = nil
      # => int + int = int
      # @return [Integer || nil]
      #
      def merge_line_coverage(first_val, second_val)
        sum = first_val.to_i + second_val.to_i

        if sum.zero? && (first_val.nil? || second_val.nil?)
          nil
        else
          sum
        end
      end
    end
  end
end
