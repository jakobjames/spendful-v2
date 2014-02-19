spec_types = [:controllers, :helpers, :integration, :lib, :mailers, :models, :routing, :views]

def toggle_coverage(state)
  ENV['COVERAGE'] = state.to_s
end

desc 'Run all specs, generating a coverage report afterward'
task :spendful do
  Rake::Task['spendful:all'].invoke
end

namespace :spendful do
  task :reset do
    require 'fileutils'
    FileUtils.rm_rf "coverage"
  end
  
  task :report do
    report = 'coverage/index.html'
    system("open #{report}") if File.exists?(report)
  end

  desc 'Run all specs, generating a coverage report afterward'
  task :all do
    toggle_coverage(:on)
    Rake::Task['spendful:reset'].invoke
    Rake::Task['spec'].invoke
    Rake::Task['spendful:report'].invoke
  end
  
  spec_types.each do |type|
    singular_form = type
    singular_form = singular_form[0...-1] unless [:integration, :lib, :routing].include?(type)

    desc "Run #{singular_form} specs, generating a coverage report afterward"
    task type do
      toggle_coverage(:on)
      Rake::Task['spendful:reset'].invoke
      Rake::Task["spec:#{type}"].invoke
      Rake::Task['spendful:report'].invoke
    end
  end

  desc 'Run all specs, without generating a coverage report'
  task :nocov do
    Rake::Task['spendful:nocov:all'].invoke
  end
  
  namespace :nocov do
    desc 'Run all specs, without generating a coverage report afterward'
    task :all do
      toggle_coverage(:off)
      Rake::Task['spec'].invoke
    end

    spec_types.each do |type|
      singular_form = type
      singular_form = singular_form[0...-1] unless [:integration, :lib, :routing].include?(type)

      desc "Run #{singular_form} specs, without generating a coverage report afterward"
      task type do
        toggle_coverage(:off)
        Rake::Task['spendful:reset'].invoke
        Rake::Task["spec:#{type}"].invoke
      end
    end
  end # namespace :nocov
end # namespace :spendful

# add integration type to spec
namespace :spec do
  desc "Run the code examples in spec/integration"
  if defined?(RSpec)
    RSpec::Core::RakeTask.new(:integration => :noop) do |t|
      t.pattern = "./spec/integration/**/*_spec.rb"
    end
  end
end
