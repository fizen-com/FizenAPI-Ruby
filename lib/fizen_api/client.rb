require 'net/http'
require 'json'
require 'uri'
require 'logger'

module FizenAPI
  class Client
    BASE_URL = 'https://docs.fizen.com/api/v1'

    def initialize(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
    end

    def get_bank_list
      headers = { "operationType" => "AIS" }
      response = get('/banks/list', headers)
      response
    end

    def create_domestic_transaction(amount:, transfer_title:, user_id:, callback_success:, callback_failure:, recipient_name: nil, recipient_address: nil, recipient_account_number: nil)
      url = '/fizenPay/createTransaction'
      payload = {
        transferTitle: transfer_title,
        amount: amount,
        userId: user_id,
        callbackSuccess: callback_success,
        callbackFailure: callback_failure
      }
      payload[:recipientName] = recipient_name if recipient_name
      payload[:recipientAddress] = recipient_address if recipient_address
      payload[:recipientAccountNumber] = recipient_account_number if recipient_account_number
      @logger.info("create_domestic_transaction payload: #{payload}")
      post(url, payload)
    end

    def create_payment_link(bank_id:, redirect_uri:, amount:, user_id:, title:, ip_address:, user_agent:, recipient_account_number: nil, recipient_name_address: nil, sender_account_number: nil)
      redirect_uri_encoded = URI.encode_www_form_component(redirect_uri)
      url = "/#{bank_id}/payment/initiate/#{redirect_uri_encoded}"
      headers = {
        "amount" => amount.to_s,
        "userId" => user_id,
        "title" => title,
        "ip" => ip_address,
        "agent" => user_agent
      }
      headers["recipientName"] = recipient_name_address if recipient_name_address
      headers["recipientAccountNumber"] = recipient_account_number if recipient_account_number
      headers["senderAccountNumber"] = sender_account_number if sender_account_number
      response = get(url, headers)
      response
    end

    def get_payment_status(state)
      headers = { "state" => state }
      get('/payment', headers)
    end

    private

    def get(endpoint, headers = {})
      uri = URI(BASE_URL + endpoint)
      request = Net::HTTP::Get.new(uri)
      request['apiKey'] = @api_key
      request['token'] = @api_secret
      headers.each { |key, value| request[key] = value }
      make_request(request)
    end

    def post(endpoint, payload = {})
      uri = URI(BASE_URL + endpoint)
      request = Net::HTTP::Post.new(uri)
      request['apiKey'] = @api_key
      request['token'] = @api_secret
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      make_request(request)
    end

    def make_request(request)
      response = Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        @logger.error("HTTP Error: #{response.code} - #{response.message}")
        raise "HTTP Error: #{response.code} - #{response.message}"
      end
    end
  end
end

# Example usage:
# client = FizenAPI::Client.new('your_api_key', 'your_api_secret')
# response = client.get_bank_list
# puts response

