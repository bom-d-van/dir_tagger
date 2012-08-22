require_relative 'path_center'
require_relative 'path_document'

module PathCenter
  HomePath = Pathname.new(Dir.home).join('.xcd')
  FilePath = HomePath.join('file')
  DirPath = HomePath.join('dir')
  ParentPaths = HomePath.join('parent_paths')
  HistoryPath = HomePath.join('history')
  CoreOpts = ARGV.dup
  HomePath.mkpath unless HomePath.exist?
  
  class XCd
    def run
      PathCenter::Opts.parse ARGV
      # puts 'something', opts
      register_current_path_as_parent_path if Options.register
      search_in_parent_path if CoreOpts.include?('in')
    end
    
    def register_current_path_as_parent_path
      ParentPaths.open('a') { |f| f << Dir.pwd << "\n" }
      exit
    end
    
    # ToDo
    def search_in_parent_path
      pwd = Dir.pwd
      file = CoreOpts[1]
      ParentPaths.each_line do |line|
        pwd.include?(line)
      end
    end
  end
  
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
PathCenter::XCd.new.run

