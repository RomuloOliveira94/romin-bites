source "https://rubygems.org"

gem "bootsnap", require: false
gem "ffaker"
gem "jsonapi-serializer"
gem "kamal", require: false
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.2"
gem "solid_cache"
gem "solid_cable"
gem "solid_queue"
gem "sqlite3", ">= 2.1"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "bullet"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
end
