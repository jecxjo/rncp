lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rncp/version'

Gem::Specification.new do |gem|
  gem.name = "rncp"
  gem.version = RNCP::VERSION
  gem.author = ["Jeff Parent"]
  gem.email = ["jecxjo@sdf.lonestar.org"]
  gem.summary = "a fast file copy tool for LANs"
  gem.description = "A port of NCP written in Ruby"
  gem.homepage = "http://github.com/jecxjo/rncp"
  gem.files = Dir['lib/**/*.rb', '.yardopts', 'README.md']
  gem.executables = Dir['bin/*'].each.map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "minitar", ">= 0.5.4"
  gem.add_runtime_dependency "clamp", '~> 0.3'
end
