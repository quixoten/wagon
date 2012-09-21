$stdout.write("Loading... ")
$stdout.flush()

require 'rubygems'
require 'curb'
require 'highline'
require 'json'
require 'stringio'
require 'prawn'
require 'pp'

$stdout.write("done.\n")
$stdout.flush()

module Curl
  class Easy
    @@cookies = ""
    
    class << self
      alias _new new
      def new(*args, &block)
        _new(*args, &block).instance_eval do
          self.ssl_verify_host = false
          self.ssl_verify_peer = false
          self.cookies = @@cookies
          
          self
        end
      end
    end
    
    alias _http_post http_post
    def http_post(*args)
      response = _http_post(*args)
      
      @@cookies = self.header_str.scan(/Set-Cookie: ([^=]+)=([^;]+)/).map do |cookie|
        "#{cookie[0]}=#{cookie[1]}"
      end.join(";")
      
      self.cookies = @@cookies
      
      response
    end
  end
end

highline = HighLine.new
username = highline.ask("What is your lds.org username? ")
password = highline.ask("What is your lds.org password? ") { |q| q.echo = "*" }

conn = Curl::Easy.new("https://www.lds.org/login.html")

begin
  credentials = [ Curl::PostField.content("username", username) \
                , Curl::PostField.content("password", password) \
                ]
                 
  conn.http_post(*credentials) do |easy|
    if easy.response_code != 200
      abort "Unable to connect. Please check your username and password and try again."      
    end
  end
rescue
  abort "Unable to connect. Please verify your internet connection is working and try again."
end

start = Time.now
multi = Curl::Multi.new
multi.max_connects = 20

conn.url = "https://www.lds.org/directory/services/ludrs/unit/current-user-ward-stake/"
conn.http_get
ward_and_stake = JSON(conn.body_str)
ward_unit_no = ward_and_stake["wardUnitNo"]

$stdout.write %Q<Gathering information for "#{ward_and_stake["wardName"]}"... >
$stdout.flush

conn.url = "https://www.lds.org/directory/services/ludrs/mem/member-list/#{ward_unit_no}"
conn.http_get
households = JSON(conn.body_str).inject({}) do |all, current|
  key = current["headOfHouseIndividualId"].to_s
  all[key] = household = {:key => key}
  
  c = Curl::Easy.new("https://www.lds.org/directory/services/ludrs/mem/ward-family/#{key}") do |curl|
    curl.on_complete do |curl|
      data = JSON(curl.body_str)
      members = [data["head"]]
      members << data["spouse"] if data["spouse"]
      members.concat(data["children"])
  
      household.merge!({
        :address => "#{data["address"]["addr1"]}",
        :email => data["email"],
        :phone_number => data["phone"]
      })
  
      if members.size == 1
        household[:name] = "#{data["head"]["directoryName"]} #{data["head"]["surname"]}"
        household[:sortName] = data["head"]["preferredName"]
      else
        household[:name] = \
        household[:sortName] = "#{data["familyName"]} Familiy" 
      end
    end
  end
  
  multi.add(c)

  c = Curl::Easy.new("https://www.lds.org/directory/services/ludrs/photo/url/#{key}/household") do |curl|
    curl.on_complete do |curl|
      if curl.response_code == 200
        data = JSON(curl.body_str)
        photo_path = data["largeUri"]
        if photo_path.length > 0
          c = Curl::Easy.new("https://www.lds.org#{photo_path}") do |curl|
            curl.on_complete do |curl|
              if curl.response_code == 200
                household[:photo] = StringIO.new(curl.body_str)
              end
            end
          end
        
          multi.add(c)
        end
      end
    end
  end

  multi.add(c)
  
  all
end

multi.perform

households = households.keys.map do |key|
  households[key]
end.sort do |a, b|
  if !a[:photo] === !b[:photo]
    a[:sortName] <=> b[:sortName]
  else
    a[:photo] ? -1 : 1
  end
end

$stdout.write "done.\nGenerating PDF... "
$stdout.flush
  
doc = Prawn::Document.new(:left_margin => 10, :right_margin => 10, :top_margin => 10, :bottom_margin => 10) do |pdf|
  header_height = 10
  footer_height = 10
  columns       = 1.0
  rows          = 1.0
  padding       = 2.0
  grid_width    = 100
  grid_height   = 200
  box_width     = grid_width - (padding * 2)
  box_height    = grid_height - (padding * 2)
  pages         = (households.size.to_f / (columns * rows)).ceil()
  pdf.font_size = 12
  info_count    = 4
  info_height   = pdf.font.height*info_count
  date          = Time.new().strftime("%m/%d/%Y")
  title         = ward_and_stake["wardName"]
  placeholder   = File.join(File.dirname(__FILE__), 'extra', 'placeholder.jpg')
  
  (0...pages).each do |page|
    pdf.start_new_page unless page == 0

    (0...rows).each do |row|
      y = pdf.bounds.top - row*grid_height - header_height
      (0...columns).each do |column|
        break if (index = page*rows*columns+row*columns+column) >= households.size
        x         = pdf.bounds.left + column*grid_width
        household = households[index]
        
        pdf.bounding_box([x, y], :width => grid_width, :height => grid_height) do
          pdf.bounding_box([pdf.bounds.left + padding, pdf.bounds.top - padding], :width => box_width, :height => box_height) do
            info = []
            info.push(household[:name])
            info.push(household[:address])
            info.push(household[:phone_number])
            info.push(household[:email])

            photo = household[:photo] || placeholder
            pdf.image(photo, :position => :center, :fit => [box_width, box_height - (padding*2 + info_height)] )
            
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

doc.render_file("#{ward_and_stake["wardName"]}.pdf")
$stdout.write "done.\nFinished in #{Time.now - start} seconds."

