Gem::Specification.new do |s|
  s.name        = 'macrodeck-platform'
  s.version     = '1.0.0'
  s.date        = '2012-12-27'
  s.summary     = "The MacroDeck Platform"
  s.description = "The MacroDeck Platform for Ruby utilizes CouchDB to dynamically generate models from CouchDB"
  s.authors     = ["Keith Gable"]
  s.email       = 'ziggy@ignition-project.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/ziggythehamster/macrodeck-platform'

  # Required RubyGems version
  s.required_rubygems_version = ">= 1.3.6"

  # Dependencies.
  s.add_development_dependency "rake"
  s.add_runtime_dependency "couchrest",                     "~> 1.0.1"
  s.add_runtime_dependency "couchrest_extended_document",   "~> 1.0.0"
  s.add_runtime_dependency "jnunemaker-validatable",        "~> 1.8.4"
  s.add_runtime_dependency "validatable-validates_list_items_in_list"
  s.add_runtime_dependency "uuidtools"

  # Set require path.
  s.require_path = "lib"
end