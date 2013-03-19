lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rncp/version'

Gem::Specification.new do |gem|
  gem.name = "rncp"
  gem.version = RNCP::VERSION
  gem.author = ["Jeff Parent"]
  gem.email = ["jecxjo@sdf.lonestar.org"]
  gem.description = "a fast file copy tool for LANs"
  gem.homepage = "http://github.com/jecxjo/rncp"
  gem.files = Dir['lib/**/*.rb']

  gem.add_Development_dependency 'rspec', '~> 2.5'
end
