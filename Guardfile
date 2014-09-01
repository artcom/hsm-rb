require 'chromatic'
require 'command'

rubocop_files = %w(
  **/*.rb
  *.ru
  **/*.rake
  Guardfile
  Gemfile
  **/Capfile
  Rakefile
  *.gemspec
)
guard :rubocop, all_on_start: true, cli: %w(-D).concat(rubocop_files) do
  ignore(/^vendor\/.*/)
  ignore(/^node_modules\/.*/)
  watch(/.*\.rb/)
  watch(/.*\.ru/)
  watch(/.+\.rake$/)
  watch(/.*Guardfile$/)
  watch(/.*Gemfile$/)
  watch(/.*Capfile$/)
  watch(/.*Rakefile$/)
  watch(/.*gemspec$/)
  watch(/(?:.+\/)?\.rubocop\.yml$/) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec', all_on_start: true do
  # watch('Guardfile') { 'spec' }
  # watch('Gemfile')  { 'spec' }
  # watch('Gemfile.lock')  { 'spec' }

  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/([a-zA-Z_])\.rb$/) { |m|
    Dir["spec/**/#{m[1]}*_spec.rb"]
  }
  watch(%r{^lib\/hsm\/(.+).rb$}) { |m|
    Dir["spec/**/#{m[1]}*_spec.rb"]
  }
  watch('spec/spec_helper.rb')  { 'spec' }
end

guard :bundler do
  watch('Gemfile')
  # Uncomment next line if your Gemfile contains the `gemspec' command.
  watch(/^.+\.gemspec/)
end

guard :shell do
  watch(/.+\.rake$/) do |m|
    puts "#{m[0]} changed:".bold.cyan
    command = Command.run 'rake -T'
    if command.success?
      puts "* 'rake -T' (still) works! Good!".green
    else
      puts "* 'rake -T' does not work anymore! =>".red
      puts command.stderr.red
    end
  end
end
