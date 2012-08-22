require 'optparse'
require 'ostruct'
require 'pathname'

class Rcd # :nodoc:
  attr_accessor :options, :profile
  def initialize(argv) # :nodoc:
    # profile path
    @profile = Pathname.new(Dir.home).join('.rcd_profile')
    
    @options = OpenStruct.new
    (OptionParser.new do |opts|
      opts.banner = 'Usage: rcd path/key [options]'
      opts.separator ''
      opts.separator 'SPECIFIC OPTIONS:'

      opts.on('-a [key,new_path]', :REQUIRED, Array, 'Add a new target file or direcotry') do |key, path|
        options.key = key
        options.path = path
        options.add_new_path = true
        argv.delete('-a')
        argv.delete("#{key},#{path}")
      end
      
      opts.on('--add-pwd key', :REQUIRED, String, 'Add $(pwd) and a key in rcd_profile') do |key|
        options.key = key
        options.path = Dir.pwd
        options.add_new_path = true
        agv.delete('--add-pwd')
        agv.delete(key)
      end
      
      opts.on('-l', 'List all the saved paths') do
        options.list_all = true
        argv.delete('-l')
      end
      
      opts.on('-h', 'Display help message') do
        p opts
        exit
      end
    end).parse(argv)
    
    list_all_saved_paths if options.list_all
    add_new_target_path if options.add_new_path
    puts(get_path(argv[0])) unless argv.length.zero?
  end
  
  def list_all_saved_paths
    unless profile.exist?
      puts "\e[031m Not Paths Saved"
      exit
    end
    puts ' All the saved paths:'
    profile.each_line do |l|
      puts(sprintf(" \e[032m%10s\e[0m    %s", *l.split(','))) unless l.match(/\^n/)
    end
  end
  
  def add_new_target_path
    mode = profile.exist? ? 'a' : 'w'
    profile.open(mode) do |f|
      f << "#{options.key},#{options.path}\n"
    end
    puts "\e[32m Add Success"
  end
  
  def get_path(key)
    path = ''
    profile.each_line do |line|
      path_pair = line.split(',')
      if path_pair[0].match(Regexp.new(key))
        path = path_pair[1]
        break
      end
    end
    path
  end
end
