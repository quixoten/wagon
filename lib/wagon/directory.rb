require 'wagon/household'
require 'prawn'
require 'stringio'

module Wagon
  class Directory < Page
    def ward
      @parent
    end
    
    def households
      @households ||= self.search('body > table > tr > td.eventsource[@width="25%"]').collect do |household_td|
        household = Household.create_from_td(connection, household_td)
      end.sort
    end
    
    def to_pdf(options = {})
      options = {
        :columns      => 7,
        :rows         => 6,
        :padding      => 2,
        :font_size    => 8,
        :address      => true,
        :phone_number => true,
        :email        => true,
        :title        => "#{ward.name}"
      }.merge(options.delete_if {|k,v| v.nil? })
      
      Prawn::Document.new(:left_margin => 10, :right_margin => 10, :top_margin => 10, :bottom_margin => 10) do |pdf|
        header_height = 10
        footer_height = 10
        columns       = options[:columns].to_f
        rows          = options[:rows].to_f
        padding       = options[:padding].to_f
        grid_width    = pdf.bounds.width / columns
        grid_height   = (pdf.bounds.height - header_height - footer_height) / rows
        box_width     = grid_width - (padding * 2)
        box_height    = grid_height - (padding * 2)
        pages         = (households.size.to_f / (columns * rows)).ceil()
        pdf.font_size = options[:font_size].to_i
        info_count    = 1 + [:address, :phone_number, :email].inject(0) { |sum, item| sum += options[item] ? 1 : 0 }
        info_height   = pdf.font.height*info_count
        date          = options[:include_date] ? Time.new().strftime("%m/%d/%Y") : ""
        
        (0...pages).each do |page|
          pdf.start_new_page unless page == 0
          pdf.draw_text(options[:title], :at => [pdf.bounds.right/2 - pdf.width_of(options[:title], :size => 12)/2, pdf.bounds.top - header_height + padding], :size => 12)
          pdf.draw_text("For Church Use Only", :at => [pdf.bounds.right/2 - pdf.width_of("For Church Use Only")/2, pdf.bounds.bottom])
          pdf.draw_text(date, :at => [pdf.bounds.right - pdf.width_of(date), pdf.bounds.bottom])
          (0...rows).each do |row|
            y = pdf.bounds.top - row*grid_height - header_height
            (0...columns).each do |column|
              break if (index = page*rows*columns+row*columns+column) >= households.size
              x         = pdf.bounds.left + column*grid_width
              household = households[index]
              
              pdf.bounding_box([x, y], :width => grid_width, :height => grid_height) do
                pdf.bounding_box([pdf.bounds.left + padding, pdf.bounds.top - padding], :width => box_width, :height => box_height) do
                  info = []
                  info.push(household.name)
                  info.push(*household.address.street) if options[:address]
                  info.push(household.phone_number.value) if options[:phone_number]
                  info.push(household.members.first.email) if options[:email]
                  
                  pdf.image(household.has_image? ? StringIO.new(household.image_data) : File.join('.', 'extra', 'placeholder.jpg'), :position => :center, :fit => [box_width, box_height - (padding*2 + info_height)] )
                  
                  pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + info_height], :height => info_height+1, :width => pdf.bounds.width) do
                    info.compact.each do |line|
                      pdf.text(line, :align => :center, :size => pdf.font_size.downto(1).detect() { |size| pdf.width_of(line.to_s, :size => size) <= box_width })
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
