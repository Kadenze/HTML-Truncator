Gem::Specification.new do |s|
  s.name             = "html_truncator"
  s.version          = "0.1.2"
  s.date             = "2011-01-14"
  s.homepage         = "http://github.com/nono/HTML-Truncator"
  s.authors          = "Bruno Michel"
  s.email            = "bmichel@menfin.info"
  s.description      = "Wants to truncate an HTML string properly? This gem is for you."
  s.summary          = "Wants to truncate an HTML string properly? This gem is for you."
  s.extra_rdoc_files = %w(README.md)
  s.files            = Dir["MIT-LICENSE", "README.md", "Gemfile", "lib/**/*.rb"]
  s.require_paths    = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.add_dependency "nokogiri", "~>1.4"
  s.add_development_dependency "rspec", "~>2.4"
end
