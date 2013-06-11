require "rest-client"

module Wagon
  module Request
    module DSL
      def self.included(base)
        base.send(:extend, ClassMethods)
        base.send(:include, InstanceMethods)
      end

      module ClassMethods
        def uri(value = nil)
          unless value.nil?
            @uri = value
          end

          @uri
        end

        def method(value = nil)
          unless value.nil?
            @method = value.to_sym
          end

          @method || :get
        end
      end

      module InstanceMethods
        def data
          respond_to?(:to_h) ? to_h : {}
        end

        def headers
          {}
        end

        def method
          self.class.method
        end

        def send(headers = self.headers)
          case method
          when :post
            RestClient.post(uri, data, headers)
          when :get
            RestClient.get(uri, headers)
          end
        end

        def send_with_cookies(cookies)
          send(headers.merge(cookies))
        end

        def send_with_cookies!(cookies)
          cookies ||= {}

          send(headers.merge(cookies)).tap do |response|
            cookies = response.cookies
          end
        end

        def uri
          self.class.uri
        end
      end
    end
  end
end
