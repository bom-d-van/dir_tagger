require_relative 'path_center'
require 'pathname'
require 'optparse'

module PathCenter
  HomePath = Pathname.new(Dir.home).join('.xto')
  FilePath = HomePath.join('file')
  DirPath = HomePath.join('dir')
  HistoryPath = HomePath.join('history')
  HomePath.mkpath unless HomePath.exist?
  
  # class Xto
  #   def initialize 
  # 
  #     @xto_home.mkpath unless @xto_home.exist?
  #   end
  # 
  #   def find_file(file)
  #     @files.each do |line|
  #       line
  #     end
  #   end
  # 
  #   def find_dir(dir)
  # 
  #   end
  # 
  #   def add_file(file)
  #     @files.open('w') do |f|
  #       f << file
  #     end
  #   end
  # 
  #   def add_dir(dir)
  #     @dirs.open('w') do |d|
  #       d << dir
  #     end
  #   end
  # end
end

# XTo.new
