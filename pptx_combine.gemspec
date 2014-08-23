# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "pptx_combine"
  spec.authors       = ["dotxy"]
  spec.email         = ["dotxzx@gmail.com"]
  spec.description   = %q{A Ruby gem that can combine PowerPoint presentations.}
  spec.summary       = %q{pptx_combine is a Ruby gem that can combine multi-pptx to one.}
  spec.homepage      = "https://github.com/dotxy/pptx_combine"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2.13.0'

  spec.add_dependency 'rubyzip', '~> 1.1.3'
  spec.add_dependency 'nokogiri', '~> 1.6.1'
end
