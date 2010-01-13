require 'nokogiri'

module Wagon
  class Page
    attr_reader :connection, :source
    
    def initialize(connection, url, parent = nil)
      @connection, @url, @parent = connection, url, parent
      @source = Future(@url) do |url|
        Nokogiri::HTML(get(url))
      end
    end
    
    def get(*args)
      connection.get(*args)
    end
    
    def post(*args)
      connection.post(*args)
    end
    
    def method_missing(method, *args, &block)
      unless source.respond_to?(method)
        super(method, *args, &block)
      else
        source.send(method, *args, &block)
      end
    end
  end
end
