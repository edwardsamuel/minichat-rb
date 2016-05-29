# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minichat/version'

Gem::Specification.new do |spec|
  spec.name          = 'minichat'
  spec.version       = Minichat::VERSION
  spec.authors       = ['Edward Samuel Pasaribu']
  spec.email         = ['edwardsamuel92@gmail.com']

  spec.summary       = 'Simple chat client-server for demonstrating Ruby TCP '\
                       'sockets.'
  spec.homepage      = 'https://github.com/edwardsamuel/minichat-rb'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.0.0'

  spec.files = `git ls-files -z`.split("\x0")
                                .reject do |f|
                                  f.match(%r{^(test|spec|features)/})
                                end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'colorize', '~> 0.7'
end
