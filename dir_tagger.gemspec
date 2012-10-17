Gem::Specification.new do |s|
  s.name        = 'DirTagger'
  s.version     = '2.0.1'
  s.executables << 'dir_tagger'
  s.date        = '2012-08-22'
  s.summary     = '*nix system file system helper'
  s.description = "A gem saving some frequent used paths and keeping them at hand, both in a very ease and comportable way. The concept is to give your directory a tag, and then store it in '~/.tag_dir_profile'. After that, you can retrieve the path of the directory by a shell command with the tag as parameter.\nUsage is here: https://github.com/bom-d-van/dir_tagger"
  s.authors     = ["Van Hu"]
  s.homepage     = 'https://github.com/bom-d-van/dir_tagger'
  s.email       = 'bom.d.van@gmail.com'
  s.files       = ["lib/dir_tagger.rb"]
end
