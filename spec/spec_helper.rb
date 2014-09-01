require 'rubygems'
require 'bundler/setup'
require 'chromatic'

# COVERAGE env variable controls if coverage data is collected and the output
# format at the same time.
# COVERAGE values:
#  * html -> uses default html formatter
#  * rcov -> uses rcov-formatter (mainly useful for jenkins)

if ENV['COVERAGE']
  puts ' * Performing coverage via simplecov'.yellow
  require 'simplecov'
  require 'simplecov-rcov'
  SIMPLECOV_FORMATTERS = {
    html: SimpleCov::Formatter::HTMLFormatter,
    rcov: SimpleCov::Formatter::RcovFormatter
  }

  SimpleCov.formatter = SIMPLECOV_FORMATTERS.fetch(
                          ENV['COVERAGE'].to_sym,
                          SIMPLECOV_FORMATTERS[:html])
  puts "    * using formatter #{SimpleCov.formatter}".yellow
  SimpleCov.start do
    add_filter '/spec/'
    # add_group "App", "lib"
  end
else
  puts ' * NOT Performing coverage via simplecov'.yellow
end

# our app/gem (simply require it - will work because of bundler/setup)
require 'hsm'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.before(:suite) do
    # ...
  end
end
