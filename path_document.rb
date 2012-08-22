require 'yaml'
require 'fileutils'
require 'pathname'

module PathCenter
  class PathRecord # :nodoc:
    attr_accessor :score, :path
    # Test Needed
    def initialize(score = 1, path = '') # :nodoc:
      @score = score
      @path = path
    end
    
    # Test Needed
    def like(*path) # :nodoc:
      # not (/#{self.path}/ =~ path).nil?
      not self.path.match(path.join('.*')).nil?
    end
    
    # Test Needed
    include Comparable
    def <=>(record) # :nodoc:
      score <=> record.score
    end
    
    # Test Needed
    def to_doc_yaml(opts = {}) # :nodoc:
      to_yaml(opts).sub(/--/, '').gsub(/(\n)(.+)/, '\1  \2')
    end
  end
  
  class PathDocument
    attr_writer :file
    attr_accessor :records
    def initialize(path) # :nodoc:
      @path = path
    end
    
    def records # :nodoc:
      @records ||= YAML.load(file)
    end
    
    def file # :nodoc:
      @file ||= File.new(@path)
    end
    
    # Test Needed
    def append(path) # :nodoc:
      new_record = PathRecord.new(path)
      records << new_record
      new_record
    end
    
    def append!(path) # :nodoc:
      pr = append(path)
      file.open('a') do |f|
        f << new_record.to_doc_yaml
      end
      new_record
    end
    
    # Test Needed
    def find(path = '', &block) # :nodoc:
      selector = block_given? ? block : Proc.new { |record| record.like(path) }
      records.select &selector
    end
    
    # Test Needed
    def top(path) # :nodoc:
      find(path).inject do |record1, record2|
        record1 >= record2 ? record1 : record2
      end
    end
    
    # Test Needed
    def update(path, score, index = 0) # :nodoc:
      pr = find(path)[index]
      pr.score = score
      pr
    end
    
    def update!(path, score, index = 0) # :nodoc:
      pr = update path, score, index
      save
      pr
    end
    
    def empty # :nodoc:
      FileUtils.rm file
    end
    
    # Test Needed
    def remove(path, index = 0) # :nodoc:
      pr = find(path)[index]
      records.delete pr
    end
    
    def remove!(path, index = 0) # :nodoc:
      remove
      save
    end
    
    # Test Needed
    def remove_all # :nodoc:
      records = []
      file=[]
    end
    
    def remove_all! # :nodoc:
      remove_all
      save
    end
    
    def save # :nodoc:
      file.open('w') do |f|
        f << records.to_doc_yaml
      end
    end
  end
end
