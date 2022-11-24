lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cache_store_redis/version'

Gem::Specification.new do |spec|
  spec.name          = 'cache_store_redis'
  spec.version       = CacheStoreRedis::VERSION
  spec.authors       = ['vaughanbrittonsage']
  spec.email         = ['vaughan.britton@sage.com']

  spec.summary       = 'This is the redis cache_store implementation.'
  spec.description   = 'This is the redis cache_store implementation.'
  spec.homepage      = 'https://github.com/sage/cache_store'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{bin,lib}/**/**/**")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'

  spec.add_dependency 'oj'
  spec.add_dependency 'redis'
end
