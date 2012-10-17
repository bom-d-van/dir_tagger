require 'optparse'
require 'ostruct'
require 'pathname'
require 'tempfile'

module DirTagger # :nodoc:
  Profile_Name = '.tag_dir_profile'
  class DirTagger
    include Comparable
    attr_accessor :tag, :dir, :children
    def initialize(tag, dir, children = DirTaggers.new)
      @tag = tag
      @dir = dir
      @children = children
    end
    
    def <=> (another_dir_tagger)
      tag.length <=> another_dir_tagger.tag.length
    end
    
    def length
      tag.length
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
    def initialize
      @empty = true
    end
    
    def take_in (dir_tagger, parent_tags = [])
      if parent_tags.empty?
        self << dir_tagger
      else
        searching_tag = parent_tags.shift
        each { |dt|
          if dt.tag == searching_tag
            dt.children.take_in dir_tagger, parent_tags
            break
          end
        }
      end
      @empty = false
      self
    end
    
    def max_tag_length
      @max_tag_length ||= sort.last.length
    end
    
    def empty?
      @empty
    end
  end
  
  class DirTaggerOperator
    attr_accessor :options, :profile, :dir_taggers
    def initialize(argv) # :nodoc:
      argv.push('-l') if argv.length.zero?
      @options = OpenStruct.new(:actions => [], :parent_tags => [])
      (OptionParser.new do |opts|
        opts.banner = 'Usage: tagdir tag[,directory] [options]'
        opts.separator ''
        opts.separator 'SPECIFIC OPTIONS:'

        opts.on('-a', '--add tag[,directory]', :REQUIRED, Array, 'Tag a directory, the defaualt directory is the current directory') do |tag, dir|
          options.actions.push :new_tag
          options.tag = tag
          options.dir = dir.nil? ? Dir.pwd : dir
        end

        opts.on('-u', '--under tag[,tag2, ..]', Array, 'Operate tag within parent tags') do |tags|
          options.parent_tags = tags # .split(',')
        end

        opts.on('-r', '--remove tag,[tag2, ..]', :REQUIRED, Array, 'Remove one or more tags') do |tags|
          options.actions.push :remove_tag
          options.tag_patterns = tags # .split(',')
        end

        # opts.on('-c', '--rename old_tag,new_tag', :REQUIRED, Array, 'Rename tag') do |old_tag, new_tag|
        #   options.actions.push :rename_tag
        #   options.old_tag = old_tag
        #   options.new_tag = new_tag
        # end

        opts.on('-l', '--list', 'List all the saved paths') do
          options.actions.push :list_tags_and_dirs
        end

        # ToDo => Support listing all saved keys
        # List all or specified tags
        opts.on('-t', '--tags [pattern1, ..]', Array, '') do |pattern|
          options.actions.push :list_tags
          pattern = pattern.nil? ? '' : pattern
          options.pattern = pattern
        end

        # List all or specified directories
        opts.on('-d', '--dir [pattern1, ..]', Array, '') do |pattern|
          options.actions.push :list_dirs
          pattern = pattern.nil? ? '' : pattern
          options.pattern = pattern
        end

        opts.on('-v', '--version', 'List current TagDir Version') do
          puts '2.0.0'
          exit
        end

        opts.on('-h', '--help', 'Display help message') do
          puts opts
          exit
        end
        
        # To Solve => Why options is empty when it is invoked in this block?
        # if options.actions.empty?
        #   options.actions << :get_dir
        #   options.tags = argv
        # end
      end).parse(argv)

      # Preparing for the running environment
      @profile = Pathname.new(Dir.home).join(Profile_Name) # profile path
      @dir_taggers = DirTaggers.new
      # Run actions
      if options.actions.empty?
        options.actions << :get_dir
        options.tags = argv
      end
      options.actions.each { |action| send action }
    end

    def new_tag
      mode = profile.exist? ? 'a' : 'w'
      profile.open(mode) do |f|
        f << (options.parent_tags.empty? ? '' : "#{options.parent_tags.join(',')},") \
          << "#{options.tag};#{options.dir}\n"
      end
      puts "\e[32m Add Success"
    end

    def remove_tag
      tmp_paths_profile = Tempfile.new(Profile_Name)
      removed_tag = ''
      profile.each_line do |l|
        tags = tags_and_dir(l)[0]
        if removed_tag.empty? && tag_match?(tags, options.tag_patterns, false)
          removed_tag = tags.join(',')
          next
        end
        next if !removed_tag.empty? && l.match(/^#{removed_tag}/)
        tmp_paths_profile << l
      end
      FileUtils.mv(tmp_paths_profile.to_path, profile.to_path)
      puts "\e[31m " + (removed_tag.empty? ? "Tagged Directory Not Existed" : "Remove Success")
    end

    # def rename_tag
    #   tmp_paths_profile = Tempfile.new(Profile_Name)
    #   profile.each_line do |line|
    #     if line.split(',').first.match(Regexp.new(options.old_key))
    #       tmp_paths_profile << "#{options.new_key},#{line.split(',')[1]}"
    #     else
    #       tmp_paths_profile << line
    #     end
    #   end
    #   FileUtils.mv(tmp_paths_profile.to_path, profile.to_path)
    #   puts "\e[32m Rename Success"
    # end

    def list_tags_and_dirs
      puts 'All the Tagged Directories:'
      tag_dir_printer saved_dir_taggers
    end
    
    # Get instance of DirTaggers, init
    def saved_dir_taggers
      unless profile.exist?
        puts "\e[031m Not Any Directory Tagged"
        exit
      end
      if dir_taggers.empty?
        profile.each_line do |l|
          tags, dir = tags_and_dir(l)
          dir_taggers.take_in DirTagger.new(tags.pop, dir.first), tags
        end
      end
      dir_taggers
    end

    def tag_dir_printer(dir_taggers, prefix = 0)
      dir_taggers.each do |dt|
        puts sprintf("\e[032m%#{dir_taggers.max_tag_length + prefix}s\e[0m  %s", dt.tag, dt.dir)
        tag_dir_printer dt.children, dir_taggers.max_tag_length + prefix
      end
    end

    # def list_tags
    #   
    # end

    # def list_dirs
    #   
    # end

    # def get_tag
    #   profile_parser(options.pattern, 0)
    # end

    def get_dir
      puts profile_parser(options.tags, 1)
    end

    private
      def profile_parser(tag_patterns, index)
        tags_or_dir = ''
        profile.each_line do |line|
          tags, dir = tags_and_dir(line)
          if tag_match?(tags, tag_patterns, tag_patterns.count == 1)
            tags_or_dir = [tags, dir][index]
            break
          end
        end
        tags_or_dir
      end
      
      # Check if the nested tags match the patterns of tag
      def tag_match?(tags, tag_patterns, last_only)
        if last_only
          tags.last.match(Regexp.new(tag_patterns.last))
        else
          return false if tags.count != tag_patterns.count
          all_match = true
          tags.each_with_index do |tag, i|
            unless tag.match(Regexp.new(tag_patterns[i]))
              all_match = false
              break
            end
          end
          all_match
        end
      end
      
      def tags_and_dir(line)
        line.split(';').map { |s| s.split(',') }
      end
  end
end
