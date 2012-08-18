require 'optparse'
# require 'optparse/time'
require 'ostruct'

module PathCenter
  Options = OpenStruct.new
  # options.
  Opts = OptionParser.new do |opts|
    opts.banner = 'Usage: xto file/path [options]'
    
    opts.separator ''
    opts.separator 'SPECIFIC OPTIONS:'
    
    opts.on('-t', '--type=type', :REQUIRED, String, 'Type of searching is File') do |type|
      Options.type = type
    end
    
    opts.on('-e', '--execute commands', Array, 'Execute some command after searching') do |cli|
      Options.exec_cli = cli
    end
    
    opts.on('-l', '--list', 'Display all the matching results') do
      Options.list = true
    end
    
    # opts.on('-s', '--setting', 'Some environment setting') do
    #   
    # end
    
    opts.on('--top', 'Move path to the head of record') do
      Options.head = true
    end
    
    opts.on('--tail', 'Move path to the tail of record') do
      Options.tail = true
    end
    
    opts.on('-r', '--remove', 'Remove matching path from path document') do
      Options.remove = true
    end
    
    opts.on('--scope', Array, 'Searching scope') do |scope|
      Options.scope = scope
    end
    
    opts.on('-u', '--use', 'Searching scope') do |use|
      Options.use = use
    end
    
    opts.separator ''
    opts.separator 'COMMON OPTIONS:'
    
    opts.on('-h', '--help', 'Display the help message') do
      puts opts
      exit
    end
    
    opts.on('--version', 'Display version') do
      puts 'Version is something'
    end
  end
end

PathCenter::Opts.parse!(ARGV)
