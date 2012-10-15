#!/usr/bin/env ruby

require 'wagon'
require 'ostruct'
require 'optparse' 
require 'highline/import'

module Wagon
  class CLI
    def self.run        
      CLI.new(ARGV).run
    end
    
    def initialize(arguments)
      @arguments = arguments
      @options = OpenStruct.new()
      
      # Set defaults
      @options.verbose      = false
      @options.title        = nil
      @options.rows         = 6
      @options.columns      = 7
      @options.padding      = 2
      @options.font_size    = 8
      @options.page_numbers = false
      @options.include_date = true
      @options.picture      = true
      @options.address      = true
      @options.phone_number = true
      @options.email        = true
      @options.output_file  = "./photo_directory.pdf"

      @parser = OptionParser.new 
      @parser.banner = "wagon [options] [output_file]"

      @parser.on('-h', '--help', 'Display this help message') do
        output_help
        exit
      end
      @parser.on('-v', '--version', 'Display the version') do
        output_version
        exit
      end
      @parser.on('-V', '--verbose', 'Verbose output')  do
        @options.verbose = true
      end
      @parser.on('-t', '--title=TITLE', 'The title displayed on each page (default is the ward name)') do |title|
        @options.title = title
      end
      @parser.on('-r', '--rows=ROWS', 'Number of rows per page (default is 6)') do |rows|
        @options.rows = rows
      end
      @parser.on('-c', '--columns=COLUMNS', 'Number of columns per page (default is 7)') do |columns|
        @options.columns = columns
      end
      @parser.on('-p', '--padding=PADDING', 'Padding between households (default is 2)') do |padding|
        @options.padding = padding
      end
      @parser.on('-f', '--font-size=SIZE', 'Primary font size (default is 8)') do |size|
        @options.font_size = size
      end
      @parser.on('--page-numbers', 'Include page numbers in the footer, e.g. (1 of 3)') do
        @options.page_numbering = true
      end
      @parser.on('--no--date', 'Do not include the current date in the footer') do
        @options.include_date = false
      end
      @parser.on('--no-picture', 'Do not include pictures') do
        @options.picture = false
      end
      @parser.on('--no-address', 'Do not include street addresses') do
        @options.address = false
      end
      @parser.on('--no-phone', 'Do not include phone numbers') do
        @options.phone_number = false
      end
      @parser.on('--no-email', 'Do not include email addresses') do
        @options.email = false
      end
    end

    def run
      begin
        @parser.parse!(@arguments)
        @options.output_file = @arguments.last unless @arguments.empty?

        puts "Start at #{DateTime.now}\n\n" if @options.verbose
        
        output_options if @options.verbose
              
        username = ask("What is your lds.org username? ")
        password = ask("What is your lds.org password? ") { |q| q.echo = "*" }
        
        user = Wagon::connect(username, password)
        
        puts "\nAlright, we're in!"
        puts "I'm gonna go ahead and create that PDF for ya now."
        puts "It might take a few minutes to gather all the info"
        puts "so grab a crisp cool beverage, sit back and relax."
        puts "I'll take it from here."
        
        directory = user.ward.to_pdf( @options.marshal_dump )
        directory.render_file(@options.output_file)
            
        puts "\nFinished. Enjoy.\n"
        puts "\nFinished at #{DateTime.now}" if @options.verbose
      rescue OptionParser::InvalidOption
        output_help
        exit
      rescue Wagon::AuthenticationFailure
        puts "\nThe username and password combination you entered is invalid."
      rescue
        if @options.verbose
          raise 
        else
          puts "\nI encountered an unexpected problem, and I don't know what to do. :("
        end
      end
    end

    private
    def output_options
      puts "Options:\n"
      
      @options.marshal_dump.each do |name, val|        
        puts "  #{name} = #{val}"
      end
    end
    
    def output_help
      puts @parser
    end
    
    def output_version
      puts "wagon v#{Wagon::VERSION}"
    end
  end
end
