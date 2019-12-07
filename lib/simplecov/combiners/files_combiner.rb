# frozen_string_literal: true

module SimpleCov
  module Combiners
    #
    # Handle combining two coverage results for same file
    #
    class FilesCombiner < BaseCombiner
      #
      #
      # @param [Hash] first_coverage
      # @param [Hash] second_coverage
      #
      def initialize(first_coverage, second_coverage)
        @combined_results ||= {}
        super
      end

      #
      # Handle combining results
      # => Check if any of the files coverage is empty or not
      # => Call lines combiner
      # => Call Branches combiner
      # Notice: this structure gives possibility to add in future methods coverage combiner
      #
      # @return [Hash]
      #
      def combine
        return existing_coverage unless empty_coverage?

        @combined_results[:lines] = LinesCombiner.combine(
          first_coverage[:lines],
          second_coverage[:lines]
        )

        @combined_results[:branches] = BranchesCombiner.combine(
          first_coverage[:branches],
          second_coverage[:branches]
        )

        @combined_results
      end
    end
  end
end
