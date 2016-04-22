require "rspec/matchers"

require "base64"
require "openssl"
require "addressable/uri"

RSpec::Matchers.define :carry_token_data do |input_data|
  option_to_token_key = {
    :api_key => :partner_id,
    :data => :connection_data,
    :initial_layout_classes => :initial_layout_class_list
  }
  match do |token|
    decoded_token = Base64.decode64(token[4..token.length])
    token_data_array = decoded_token.split(':').collect do |token_part|
      token_part_array_array = Addressable::URI.form_unencode(token_part)
      token_part_array = token_part_array_array.map do |array|
        { array[0].to_sym => array[1] }
      end
      token_part_array.reduce Hash.new, :merge
    end
    token_data = token_data_array.reduce Hash.new, :merge
    check_token_data = lambda { |key, value|
      key = option_to_token_key[key] if option_to_token_key.has_key? key
      if token_data.has_key? key
        unless value.nil?
          return token_data[key] == value.to_s
        end
        return true
      end
      false
    }
    unless input_data.respond_to? :all?
      return check_token_data.call(input_data, nil)
    end
    input_data.all? { |k, v| check_token_data.call(k, v) }
  end
end

RSpec::Matchers.define :carry_valid_token_signature do |api_secret|
  match do |token|
    decoded_token = Base64.decode64(token[4..token.length])
    metadata, data_string = decoded_token.split(':')
    digest = OpenSSL::Digest.new('sha1')
    # form_unencode returns an array of arrays, annoying so hardcoded lookup
    # expected format: [["partner_id", "..."], ["sig", "..."]]
    signature = Addressable::URI.form_unencode(metadata)[1][1]
    signature == OpenSSL::HMAC.hexdigest(digest, api_secret, data_string)
  end
end
