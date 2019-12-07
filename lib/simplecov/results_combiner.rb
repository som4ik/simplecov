# frozen_string_literal: true

module SimpleCov
  # There might be reports from different kinds of tests,
  # e.g. RSpec and Cucumber. We need to combine their results
  # into unified one. This class does that.
  # To unite the results on file basis, it leverages
  # the combiners of lines and branches inside each file within given results.
  class ResultsCombiner
    class << self
      #
      # Combine process explanation
      # => ResultCombiner: define all present files between results and start combine on file level.
      # ==> FileCombiner: collect result of next combine levels lines and branches.
      # ===> LinesCombiner: combine lines results.
      # ===> BranchesCombiner: combine branches results.
      #
      # @return [Hash]
      #
      def combine(*results)
        results.reduce({}) do |result, next_result|
          combine_result_sets(result, next_result)
        end
      end

      #
      # Manage combining results on files level
      #
      # @param [Hash] first_result
      # @param [Hash] second_result
      #
      # @return [Hash]
      #
      def combine_result_sets(first_result, second_result)
        results_files = first_result.keys | second_result.keys

        results_files.each_with_object({}) do |file_name, combined_results|
          combined_results[file_name] = Combiners::FilesCombiner.combine(
            first_result[file_name],
            second_result[file_name]
          )
        end
      end
    end
  end
end
