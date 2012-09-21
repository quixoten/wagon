$stdout.write("Loading... ")
$stdout.flush()

require 'rubygems'
require 'curb'
require 'highline'
require 'json'
require 'stringio'
require 'prawn'
require 'pp'
require 'base64'

puts "done."

module Wagon
  @cookies = ""

  def self.req(*args, &block)
    c = Curl::Easy.new(*args, &block)
    c.ssl_verify_host = false
    c.ssl_verify_peer = false
    c.cookies = @cookies
    c
  end

  def self.post(req, *args, &block)
    resp = req.http_post(*args, &block)
    
    @cookies = req.header_str.scan(/Set-Cookie: ([^=]+)=([^;]+)/).map do |cookie|
      "#{cookie[0]}=#{cookie[1]}"
    end.join(";")
    
    req.cookies = @cookies
    
    resp
  end
end

highline = HighLine.new
username = highline.ask("What is your lds.org username? ")
password = highline.ask("What is your lds.org password? ") { |q| q.echo = "*" }

conn = Wagon.req("https://www.lds.org/login.html")

begin
  credentials = [ Curl::PostField.content("username", username) \
                , Curl::PostField.content("password", password) \
                ]
                 
  Wagon.post(conn, *credentials) do |easy|
    if easy.response_code != 200
      abort "Unable to connect. Please check your username and password and try again."      
    end
  end
rescue
  puts $!
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
  
  c = Wagon.req("https://www.lds.org/directory/services/ludrs/mem/ward-family/#{key}") do |curl|
    curl.on_complete do |curl|
      data = JSON(curl.body_str)
      household.merge!(data)
    end
  end
  
  multi.add(c)
  
  c = Wagon.req("https://www.lds.org/directory/services/ludrs/photo/url/#{key}/household") do |curl|
    curl.on_complete do |curl|
      if curl.response_code == 200
        data = JSON(curl.body_str)
        photo_path = data["largeUri"]
        if photo_path.length > 0
          c = Wagon.req("https://www.lds.org#{photo_path}") do |curl|
            curl.on_complete do |curl|
              if curl.response_code == 200
                household[:photo] = Base64.encode64(curl.body_str).gsub("\n", "")
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

$stdout.write "done.\nGenerating vCard... "
$stdout.flush
  
open("#{ward_and_stake["wardName"]}.vcd", "w") do |file|
  households.each do |key, h|
    head = h["head"]
    addr = h["address"]

    file.write("BEGIN:VCARD\n")
    file.write("VERSION:4.0\n")
    file.write("N:#{h["familyName"]};")
    file.write(head["formattedName"])
    file.write(";;;\n")
    file.write("FN:#{head["formattedName"]} #{h["familyName"]}\n")
    file.write("ADR;TYPE=home:;;#{addr["addr1"]}")
    file.write(";#{addr["addr3"].gsub(/,?\s/, ";")};\n")
    file.write("EMAIL:#{head["email"]}\n")
    file.write("TEL;TYPE=cell;VALUE=uri:tel:#{h["phone"]}\n")
    if h[:photo]
      file.write("PHOTO:data:image/jpeg;base64,")
      file.write(h[:photo])
      file.write("\n")
    end
    file.write("END:VCARD\n")
  end
end

$stdout.write "done.\nFinished in #{Time.now - start} seconds."

