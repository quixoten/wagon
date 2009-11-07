require 'wagon/page'

module Wagon
  class PhotoDirectory < Page
    def households
      @households ||= _parse_households
    end
    
    def members
      households.collect(&:members).flatten()
    end
    
    def to_pdf(options)
      Prawn::Document.new() do |pdf|
        households.each do |household|
          pdf.text household.name
        end
      end
    end
    
    private
    def _parse_households
      self.each('body > table > tr > td.eventsource[@width="25%"]') do |household|
        puts household.inner_text
      end
    end
  end
end