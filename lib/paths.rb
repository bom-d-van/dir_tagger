require 'optparse'
require 'ostruct'
require 'pathname'
require 'tempfile'

class Paths # :nodoc:
  Profile_Name = '.paths_profile'
  attr_accessor :options, :profile
  def initialize(argv) # :nodoc:
    argv.push('-l') if argv.length.zero?
    @options = OpenStruct.new
    (OptionParser.new do |opts|
      opts.banner = 'Usage: paths key [options]'
      opts.separator ''
      opts.separator 'SPECIFIC OPTIONS:'

      opts.on('-a', '--add key,new_path', :REQUIRED, Array, 'Add a new target file or direcotry, the default new paths is $(pwd)') do |key, path|
        options.key = key
        options.path = path.nil? ? Dir.pwd : path
        options.add_new_path = true
      end
      
      opts.on('-r', '--remove key', :REQUIRED, String, 'Remove Key') do |key|
        options.remove_path = true
        options.key = key
      end
      
      opts.on('--rename old_key,new_key', :REQUIRED, Array, 'Rename key') do |old_key, new_key|
        options.rename_key = true
        options.old_key = old_key
        options.new_key = new_key
      end
      
      opts.on('-l', '--list', 'List all the saved paths') do
        options.list_all = true
      end
      
      # ToDo => Support listing all saved keys
      opts.on('-k', '--keys [pattern]', String, '') do |pattern|
        options.get_key = true
        options.pattern = pattern
      end
      
      opts.on('-h', '--help', 'Display help message') do
        p opts
        exit
      end
      
      # opts.on('-v', '--version', 'Display help message') do
      #   p opts
      #   exit
      # end
    end).parse(argv)
    
    # profile path
    @profile = Pathname.new(Dir.home).join(Profile_Name)
    list_all_saved_paths if options.list_all
    add_new_target_path if options.add_new_path
    remove_path if options.remove_path
    rename_key if options.rename_key
    puts(get_key) if options.get_key
    puts(get_path(argv[0])) if argv.length == 1 && !argv[0].include?('-')
  end
  
  def list_all_saved_paths
    unless profile.exist?
      puts "\e[031m Not Paths Saved"
      exit
    end
    puts 'All the saved paths:'
    profile.each_line do |l|
      puts(sprintf("\e[032m%10s\e[0m    %s", *l.split(','))) unless l.match(/\^n/)
    end
  end
  
  def add_new_target_path
    mode = profile.exist? ? 'a' : 'w'
    profile.open(mode) do |f|
      f << "#{options.key},#{options.path}\n"
    end
    puts "\e[32m Add Success"
  end
  
  def remove_path
    tmp_paths_profile = Tempfile.new(Profile_Name)
    profile.each_line do |line|
      next if line.split(',').first.match(Regexp.new(options.key))
      tmp_paths_profile << line
    end
    FileUtils.mv(tmp_paths_profile.to_path, profile.to_path)
    puts "\e[31m Remove Success"
  end
  
  def rename_key
    tmp_paths_profile = Tempfile.new(Profile_Name)
    profile.each_line do |line|
      if line.split(',').first.match(Regexp.new(options.old_key))
        tmp_paths_profile << "#{options.new_key},#{line.split(',')[1]}"
      else
        tmp_paths_profile << line
      end
    end
    FileUtils.mv(tmp_paths_profile.to_path, profile.to_path)
    puts "\e[32m Rename Success"
  end
  
  def get_key
    getter(options.pattern, 0)
    # completed_key = ''
    # pattern = Regexp.new(options.pattern)
    # profile.each_line do |line|
    #   key = line.split(',')[0]
    #   if key.match(pattern)
    #     completed_key = key
    #     break
    #   end
    # end
    # completed_key
  end
  
  def get_path(key)
    getter(key, 1)
  end
  
  private
    def getter(key, index)
      target = ''
      pattern = Regexp.new(key)
      profile.each_line do |line|
        key, path = line.split(',')
        if key.match(pattern)
          # path = path_pair[1]
          target = (index == 0 ? key : path)
          break
        end
      end
      target
    end
end
