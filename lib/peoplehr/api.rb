require "json"

module PeopleHR
  class API
    API_ROOT = Addressable::URI.parse("https://api.peoplehr.net/")

    class APIError < StandardError; end
    class BadResponse < APIError; end

    def initialize(api_key:, connection: nil)
      @api_key = api_key
      @connection = connection ||
        Faraday.new(url: API_ROOT) do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end
    end

    def request(action, params = {})
      request = {
        "APIKey" => api_key,
        "Action" => action,
      }

      payload = params.merge(request)
      payload = JSON.generate(payload)

      response = connection.post do |req|
        req.url "/"
        req.headers["Content-Type"] = "application/json"
        req.body = payload
      end

      JSON.parse(response.body)
    rescue JSON::ParserError
      fail BadResponse
    end

    private

    attr_reader :connection, :api_key
  end
end