# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/riksdagen/version'

Gem::Specification.new do |s|
  s.version = Decidim::Riksdagen.version
  s.authors = ['Pierre Mesure']
  s.email = ['pierre.mesure@gmail.com']
  s.license = 'AGPL-3.0'
  s.homepage = 'https://github.com/decidim/decidim-module-riksdagen'
  s.required_ruby_version = '>= 2.3.1'

  s.name = 'decidim-riksdagen'
  s.summary = 'A decidim module for Din Riksdag'
  s.description = 'A module to integrate some of the open data produced by the Swedish parliament'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE-AGPLv3.txt', 'Rakefile', 'README.md']

  s.add_dependency 'decidim-core', Decidim::Riksdagen.version
  s.add_dependency 'decidim-participatory_processes', Decidim::Riksdagen.version
  s.add_dependency 'decidim-admin', Decidim::Riksdagen.version

  s.add_development_dependency 'decidim-dev'
  s.add_development_dependency 'pry-byebug'
end
