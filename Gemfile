source 'https://rubygems.org'

gem "pact-provider-verifier"
gem "pry"

if ENV['X_PACT_DEVELOPMENT']
  gem "pact-support", path: '../pact-support'
  gem "pact", path: '../pact'
else
  gem "pact-support", git: "git@github.com:pact-foundation/pact-support.git", ref: "93839cf5584406b99e52544040b475fc262afb32"
  gem "pact", git: "git@github.com:pact-foundation/pact-ruby.git", ref: "fa98102843666fd5d334d548ecab9f48257a3ede"
end
