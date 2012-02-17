$stdout.write("Loading... ")
$stdout.flush()

require 'rubygems'

gem 'curb', '0.8.0'

require 'curb'
require 'highline'
require 'json'
require 'stringio'
require 'prawn'

puts "done."

highline = HighLine.new
username = highline.ask("What is your lds.org username? ")
password = highline.ask("What is your lds.org password? ") { |q| q.echo = "*" }

conn = Curl::Easy.new("https://www.lds.org/login.html")
conn.http_post(Curl::PostField.content("username", username),
               Curl::PostField.content("password", password))

if conn.response_code == 200
  conn.cookies = conn.header_str.scan(/Set-Cookie: ([^=]+)=([^;]+)/).map do |cookie|
    "#{cookie[0]}=#{cookie[1]}"
  end.join(";")
else
  puts "Failed to connect."
  exit(1)
end

start = Time.now
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
  all[key] = {:key => key}
  all
end

household_urls = households.keys.map do |key|
  "https://www.lds.org/directory/services/ludrs/mem/ward-family/#{key}"
end

conn.url = "https://www.lds.org/directory/services/ludrs/mem/wardDirectory/photos/#{ward_unit_no}"
conn.http_get
JSON(conn.body_str).each do |data|
  key = data["householdId"].to_s
  photo_path = data["photoUrl"]
  household = households[key]
  household[:photo_path] = photo_path
end

photo_urls = households.keys.map do |key|
  photo_path = households[key][:photo_path]
  if photo_path.length > 0
    "https://www.lds.org#{photo_path}&__key__=#{key}"
  else
    nil
  end
end.compact

all_urls = household_urls.concat(photo_urls)

Curl::Multi.get(all_urls, {:cookies => conn.cookies}, {:max_connects => 60}) do |easy|
  if easy.last_effective_url.match(/ward-family/)
    data = JSON(easy.body_str)
    key = data["head"]["individualId"].to_s
    household = households[key] || (households[key] = {:key => key})
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
  else
    key = easy.last_effective_url.match(/__key__=(.*)/)[1].to_s
    household = households[key]
    household[:photo] = StringIO.new(easy.body_str)
  end
end

puts "done."

households = households.keys.map do |key|
  households[key]
end.sort do |a, b|
  if a[:photo] && b[:photo]
    a[:sortName] <=> b[:sortName]
  else
    a[:photo] ? -1 : 1
  end
end

$stdout.write "Generating PDF... "
$stdout.flush
  
doc = Prawn::Document.new(:left_margin => 10, :right_margin => 10, :top_margin => 10, :bottom_margin => 10) do |pdf|
  header_height = 10
  footer_height = 10
  columns       = 6.0
  rows          = 5.0
  padding       = 2.0
  grid_width    = pdf.bounds.width / columns
  grid_height   = (pdf.bounds.height - header_height - footer_height) / rows
  box_width     = grid_width - (padding * 2)
  box_height    = grid_height - (padding * 2)
  pages         = (households.size.to_f / (columns * rows)).ceil()
  pdf.font_size = 8
  info_count    = 4
  info_height   = pdf.font.height*info_count
  date          = Time.new().strftime("%m/%d/%Y")
  title         = ward_and_stake["wardName"]
  
  (0...pages).each do |page|
    pdf.start_new_page unless page == 0
    pdf.draw_text(title, :at => [pdf.bounds.right/2 - pdf.width_of(title, :size => 12)/2, pdf.bounds.top - header_height + padding], :size => 12)
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
            info.push(household[:name])
            info.push(household[:address])
            info.push(household[:phone_number])
            info.push(household[:email])
            
            pdf.image(household[:photo] ? household[:photo] : File.join(File.dirname(__FILE__), 'extra', 'placeholder.jpg'), :position => :center, :fit => [box_width, box_height - (padding*2 + info_height)] )
            
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
puts "done."
puts "Finished in #{Time.now - start} seconds."

