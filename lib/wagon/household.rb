
require 'wagon/member'

module Wagon
  class Household
    attr_reader :ward, :conn, :id, :image_data
    
    def initialize(ward, id)
      @id = id
      @ward = ward
      @conn = ward.conn
      @photo_path = ward.photos[id]

      path = "#{Connection::MAP[:household]}#{id}"
      @household = JSON(conn.get(path).body)

      if has_image?
        #@image_data = Future(image_path) do |image_path|
        #  @connection.get(image_path)
        #end
      end
    end

    def name
      unless @name
        if self.individual?
          @name = @household["head"]["directoryName"]
        else
          @name = "#{@household["familyName"]} Household"
        end
      end
      @name
    end

    def address
      unless @address
        @address = [
          @household["address"]["addr1"],
          @household["address"]["addr2"],
          @household["address"]["addr3"],
          @household["address"]["addr4"],
          @household["address"]["addr5"]
        ].flatten.join("\n")
      end
      @address
    end

    def phone_number
      @household["phone"]
    end

    def individual?
      members.count == 1
    end

    def members
      unless @members
        @members = [@household["head"]]
        @members.concat(@household["spouse"] || [])
        @members.concat(@household["children"])
      end
      @members
    end
    
    def has_image?
      !@image_path.to_s.empty?
    end
    
    def <=>(other)
      if has_image? == other.has_image?
        reversed_name <=> other.reversed_name
      else
        has_image? ? -1 : 1
      end
    end
  end
end

