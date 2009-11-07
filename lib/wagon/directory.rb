require 'wagon/photo_directory'
require 'prawn'
require 'stringio'

module Wagon
  class Directory < Page
    def photo_directory_path
      return @photo_directory_path unless @photo_directory_path.nil?
      
      self.at('a.linknoline[href^="javascript:confirm_photo"]')['href'].match(/^javascript:confirm_photo\('(.*)'\);$/)
      @photo_directory_path = $1
    end
    
    def photo_directory
      @photo_directory ||= PhotoDirectory.new(connection, photo_directory_path)
    end
    
    def households
      photo_directory.households
    end
    
    def members
      households.collect(&:members).flatten()
    end
    
    def to_pdf(options = {})
      options = {:columns => 7, :rows => 6, :padding => 2, :font_size => 8, :address => true, :phone_number => true, :email => true}.merge(options)
      
      Prawn::Document.new(:skip_page_creation => true, :left_margin => 10, :right_margin => 10, :top_margin => 20, :bottom_margin => 10) do |pdf|
        columns       = options[:columns]
        rows          = options[:rows]
        padding       = options[:padding]
        grid_width    = pdf.bounds.width / columns.to_f
        grid_height   = pdf.bounds.height / rows.to_f
        box_width     = grid_width - (padding * 2)
        box_height    = grid_height - (padding * 2)
        pages         = (households.size.to_f / (columns * rows)).ceil()
        info_lines    = 1 + [:address, :phone_number, :email].inject(0) { |sum, item| sum += item ? 1 : 0 }
        pdf.font_size = options[:font_size]
        
        (0...pages).each do |page|
          pdf.start_new_page
          (0...rows).each do |row|
            y = pdf.bounds.top - row*grid_height
            (0...columns).each do |column|
              break if (index = page*rows*columns+row*columns+column) >= households.size
              household = households[index]
              x         = pdf.bounds.left + column*grid_width
              pdf.bounding_box([x, y], :width => grid_width, :height => grid_height) do
                pdf.bounding_box([pdf.bounds.left + padding, pdf.bounds.top - padding], :width => box_width, :height => box_height) do
                  information = []
                  information.push(household.name)
                  information.push(*household.address.street) if options[:address]
                  information.push(household.phone_number) if options[:phone_number]
                  information.push(household.members.first.email) if options[:email]
                  
                  pdf.image(household.image_path ? StringIO.new(household.image_data) : './extra/placeholder.jpg',
                            :position => :center, :fit => [box_width, box_height - (padding*2 + pdf.font.height*info_lines)] )
                  
                  pdf.move_down(padding)
                  information.compact.each do |line|
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