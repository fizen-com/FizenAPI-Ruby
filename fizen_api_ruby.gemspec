Gem::Specification.new do |spec|
  spec.name          = "fizen_api_ruby"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  spec.summary       = "A Ruby SDK for the Fizen API."
  spec.description   = "This gem provides a Ruby wrapper for the Fizen API, enabling seamless integration."
  spec.homepage      = "https://github.com/yourusername/fizen_api_ruby"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json", "~> 2.0"
  spec.add_runtime_dependency "net-http", "~> 0.1.1"
end
