source "https://rubygems.org"

gemspec

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.7")
  gem "chef-zero", "~> 15"
  gem "chef", "~> 15"
end

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

group :test do
  gem "chefstyle", "1.6.2"
  gem "guard-rspec"
  gem "mixlib-shellout"
  gem "rake"
  gem "rspec", "~> 3.0"
  gem "rspec-expectations"
  gem "rspec-mocks"
  gem "rspec_junit_formatter"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end
