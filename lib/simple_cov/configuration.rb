#
# Bundles the configuration options used for SimpleCov. All methods
# defined here are usable from SimpleCov directly. Please check out
# SimpleCov documentation for further info.
#
module SimpleCov::Configuration
  attr_writer :filters, :groups, :formatter
  
  #
  # The root for the project. This defaults to the
  # current working directory.
  #
  # Configure with SimpleCov.root('/my/project/path')
  #
  def root(root=nil)
    return @root if @root and root.nil?
    @root = File.expand_path(root || Dir.getwd)
  end
  
  #
  # The name of the output and cache directory. Defaults to 'coverage'
  #
  # Configure with SimpleCov.coverage_dir('cov')
  #
  def coverage_dir(dir=nil)
    return @coverage_dir if @coverage_dir and dir.nil?
    @coverage_dir = (dir || 'coverage')
  end
  
  #
  # Returns the full path to the output directory using SimpleCov.root
  # and SimpleCov.coverage_dir, so you can adjust this by configuring those
  # values. Will create the directory if it's missing
  #
  def coverage_path
    coverage_path = File.join(root, coverage_dir)
    system "mkdir -p '#{coverage_path}'"
    coverage_path
  end
  
  # 
  # Returns the list of configured filters. Add filters using SimpleCov.add_filter.
  #
  def filters
    @filters ||= []
  end
  
  #
  # Gets or sets the configured formatter.
  #
  # Configure with: SimpleCov.formatter(SimpleCov::Formatter::SimpleFormatter)
  #
  def formatter(formatter=nil)
    return @formatter if @formatter and formatter.nil?
    @formatter = formatter
    raise "No formatter configured. Please specify a formatter using SimpleCov.formatter = SimpleCov::Formatter::SimpleFormatter" unless @formatter
    @formatter
  end
  
  #
  # Returns the configured groups. Add groups using SimpleCov.add_group
  #
  def groups
    @groups ||= {}
  end
  
  #
  # Returns the hash of available adapters
  #
  def adapters
    @adapters ||= SimpleCov::Adapters.new
  end
  
  #
  # Configure SimpleCov using a block:
  #
  # SimpleCov.configure do
  #   add_filter 'foobar'
  # end
  #
  # This is equivalent to SimpleCov.add_filter 'foobar' and thus makes it easier to set a lot of configure
  # options.
  #
  def configure(&block)
    instance_exec(&block)
  end
  
  #
  # Gets or sets the behavior to process coverage results.
  #
  # By default, it will call SimpleCov.result.format!
  #
  # Configure with:
  #   SimpleCov.at_exit do
  #     puts "Coverage done"
  #     SimpleCov.result.format!
  #   end
  #
  def at_exit(&block)
    return Proc.new {} unless running
    @at_exit = block if block_given?
    @at_exit ||= Proc.new { SimpleCov.result.format! }
  end
  
  #
  # Add a filter to the processing chain.
  # There are three ways to define a filter:
  # 
  # * as a String that will then be matched against all source files' file paths,
  #   SimpleCov.add_filter 'app/models' # will reject all your models
  # * as a block which will be passed the source file in question and should either
  #   return a true or false value, depending on whether the file should be removed
  #   SimpleCov.add_filter do |src_file|
  #     File.basename(src_file.filename) == 'environment.rb'
  #   end # Will exclude environment.rb files from the results
  # * as an instance of a subclass of SimpleCov::Filter. See the documentation there
  #   on how to define your own filter classes
  #
  def add_filter(filter_argument=nil, &filter_proc)
    filters << parse_filter(filter_argument, &filter_proc)
  end
  
  def add_group(group_name, filter_argument=nil, &filter_proc)
    groups[group_name] = parse_filter(filter_argument, &filter_proc)
  end
  
  #
  # The actal filter processor. Not meant for direct use
  #
  def parse_filter(filter_argument=nil, &filter_proc)
    if filter_argument.kind_of?(SimpleCov::Filter)
      filter_argument
    elsif filter_argument.kind_of?(String)
      SimpleCov::StringFilter.new(filter_argument)
    elsif filter_proc
      SimpleCov::BlockFilter.new(filter_proc)
    else
      raise ArgumentError, "Please specify either a string or a block to filter with"
    end      
  end
end