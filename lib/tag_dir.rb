require 'optparse'
require 'ostruct'
require 'pathname'
require 'tempfile'

module DirTagger # :nodoc:
  Profile_Name = '.tag_dir_profile'
  class DirTagger
    include Comparable
    attr_accessor :name, :dir, :children
    def initialize(name, dir, children = DirTaggers.new)
      @name = name
      @dir = dir
      @children = children
    end
    
    def <=> (another_dir_tagger)
      name.length <=> another_dir_tagger.name.length
    end
  end
  
  # == Test Data ==
  # dts = DirTaggers.new
  # dts.take_in DirTagger.new('first', 'Dir1')
  # dts.take_in DirTagger.new('second', 'Dir2')
  # dts.take_in DirTagger.new('third', 'Dir3')
  # dts.take_in DirTagger.new('forth', 'Dir4'), ['first']
  # dts.take_in DirTagger.new('fifth', 'Dir5'), %w(first forth)
  class DirTaggers < Array
    # Push a new TaggedDirs
    # alias :push, :<<
    def take_in (dir_tagger, parent_tags = [])
      if parent_tags.empty?
        self << dir_tagger
      else
        searching_tag = parent_tags.shift
        each { |dt|
          if dt.name == searching_tag
            dt.children.take_in dir_tagger, parent_tags
            break
          end
        }
      end
    end
    self
  end
  
  attr_accessor :options, :profile
  def initialize(argv) # :nodoc:
    argv.push('-l') if argv.length.zero?
    @options = OpenStruct.new(:actions => [])
    (OptionParser.new do |opts|
      opts.banner = 'Usage: tagdir tag[,directory] [options]'
      opts.separator ''
      opts.separator 'SPECIFIC OPTIONS:'

      opts.on('-a', '--add tag[,directory]', :REQUIRED, Array, 'Tag a directory, the defaualt directory is the current directory') do |key, dir|
        options.actions.push :new_tag
        options.key = key
        options.dir = dir.nil? ? Dir.pwd : dir
      end
      
      opts.on('-u', '--under tag[,tag2, ..]', Array, 'Operate tag within parent tags') do |tags|
        options.parent_tags = tags.split(',')
      end

      opts.on('-r', '--remove tag,[tag2, ..]', :REQUIRED, String, 'Remove one or more tags') do |tags|
        options.actions.push :remove_tags
        options.tags = tags.split(',')
      end

      opts.on('-c', '--rename old_tag,new_tag', :REQUIRED, Array, 'Rename tag') do |old_tag, new_tag|
        options.actions.push :rename_tag
        options.old_tag = old_tag
        options.new_tag = new_tag
      end

      opts.on('-l', '--list', 'List all the saved paths') do
        options.actions.push :list_tags_and_dirs
      end

      # ToDo => Support listing all saved keys
      # List all or specified tags
      opts.on('-t', '--tags [pattern]', String, '') do |pattern|
        options.actions.push :list_tags
        pattern = pattern.nil? ? '' : pattern
        options.pattern = pattern
      end
      
      # List all or specified directories
      opts.on('-d', '--dir [pattern]', String, '') do |pattern|
        options.actions.push :list_dirs
        pattern = pattern.nil? ? '' : pattern
        options.pattern = pattern
      end

      opts.on('-v', '--version', 'List current TagDir Version') do
        puts '1.0.0'
        exit
      end

      opts.on('-h', '--help', 'Display help message') do
        p opts
        exit
      end
    end).parse(argv)

    # profile path
    @profile = Pathname.new(Dir.home).join(Profile_Name)
    options.actions.each { |action| send :action }
  end
  
  def new_tag
    mode = profile.exist? ? 'a' : 'w'
    profile.open(mode) do |f|
      f << options.parent_tags.empty? ? '' : "#{options.parent_tags.join(',')}," \
        << "#{options.tag};#{options.dir}\n"
    end
    puts "\e[32m Add Success"
  end

  def remove_tags
    
  end

  def rename_tag
    
  end

  def list_tags_and_dirs
    unless profile.exist?
      puts "\e[031m Not Any Directory Tagged"
      exit
    end
    puts 'All the Tagged Directories:'
    tagged_dirs = TaggedDirs.new
    profile.each_line do |l|
      tagged_dirs << l.split(';').map {|s| s.split(',') }
    end
    max_top_tag_length = tagged_dirs.sort.last.length
    tagged_dirs.each do |td|
      sprintf "%#{max_top_tag_length}s", td.name
    end
  end

  def list_tags
    
  end

  def list_dirs
    
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
    line_parser(options.pattern, 0)
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
    line_parser(key, 1)
  end

  private
    def profile_parser(*tags, index)
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
