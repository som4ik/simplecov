# frozen_string_literal: true

require "digest/sha1"
require "forwardable"

module SimpleCov
  #
  # A simplecov code coverage result, initialized from the Hash Ruby's built-in coverage
  # library generates (Coverage.result).
  #
  class Result
    extend Forwardable
    # Returns the original Coverage.result used for this instance of SimpleCov::Result
    attr_reader :original_result
    # Returns all files that are applicable to this result (sans filters!) as instances of SimpleCov::SourceFile. Aliased as :source_files
    attr_reader :files
    alias source_files files
    # Explicitly set the Time this result has been created
    attr_writer :created_at
    # Explicitly set the command name that was used for this coverage result. Defaults to SimpleCov.command_name
    attr_writer :command_name

    def_delegators :files, :covered_percent, :covered_percentages, :least_covered_file, :covered_strength, :covered_lines, :missed_lines, :total_branches, :covered_branches, :missed_branches
    def_delegator :files, :lines_of_code, :total_lines

    # Initialize a new SimpleCov::Result from given Coverage.result (a Hash of filenames each containing an array of
    # coverage data)
    def initialize(original_result)
      @original_result = original_result.freeze
      @files = SimpleCov::FileList.new(original_result.map do |filename, coverage|
        SimpleCov::SourceFile.new(filename, JSON.parse(JSON.dump(coverage), :symbolize_names => true)) if File.file?(filename.to_s)
      end.compact.sort_by(&:filename))
      filter!
    end

    # Returns all filenames for source files contained in this result
    def filenames
      files.map(&:filename)
    end

    # Returns a Hash of groups for this result. Define groups using SimpleCov.add_group 'Models', 'app/models'
    def groups
      @groups ||= SimpleCov.grouped(files)
    end

    # Applies the configured SimpleCov.formatter on this result
    def format!
      SimpleCov.formatter.new.format(self)
    end

    # Defines when this result has been created. Defaults to Time.now
    def created_at
      @created_at ||= Time.now
    end

    # The command name that launched this result.
    # Delegated to SimpleCov.command_name if not set manually
    def command_name
      @command_name ||= SimpleCov.command_name
    end

    # Returns a hash representation of this Result that can be used for marshalling it into JSON
    def to_hash
      {command_name => {"coverage" => coverage, "timestamp" => created_at.to_i}}
    end

    # Loads a SimpleCov::Result#to_hash dump
    def self.from_hash(hash)
      command_name, data = hash.first

      result = SimpleCov::Result.new(
        symbolize_names_of_coverage_results(data["coverage"])
      )

      result.command_name = command_name
      result.created_at = Time.at(data["timestamp"])
      result
    end

    # Manage symbolize the keys of coverage hash.
    # JSON.parse gives coverage hash with stringified keys what breaks some logics
    # inside the process that expects them as symboles.
    #
    # @return [Hash]
    def self.symbolize_names_of_coverage_results(coverage_data)
      coverage_data.each_with_object({}) do |(file_name, file_coverage_result), coverage_results|
        coverage_results[file_name] = file_coverage_result.each_with_object({}) do |(k, v), cov_elem|
          cov_elem[k.to_sym] = v
        end
      end
    end

  private

    def coverage
      keys = original_result.keys & filenames
      Hash[keys.zip(original_result.values_at(*keys))]
    end

    # Applies all configured SimpleCov filters on this result's source files
    def filter!
      @files = SimpleCov.filtered(files)
    end
  end
end
