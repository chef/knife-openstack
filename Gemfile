source "https://rubygems.org"

# Specify your gem's dependencies in knife-openstack.gemspec
gemspec

group :development do
  gem "guard-rspec"
  gem "mixlib-shellout"
  gem "rake", "~> 11.0"
  gem "rspec", "~> 3.0"
  gem "chefstyle"
  gem "rspec-expectations"
  gem "rspec-mocks"
  gem "rspec_junit_formatter"
end

# our use of the fork can go away if they merge https://github.com/skywinder/github-changelog-generator/pull/453
group(:changelog) do
  gem "github_changelog_generator", git: "https://github.com/tduffield/github-changelog-generator", branch: "adjust-tag-section-mapping"
end
