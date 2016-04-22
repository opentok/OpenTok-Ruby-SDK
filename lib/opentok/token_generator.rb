require "opentok/constants"
require "opentok/session"

require "base64"
require "addressable/uri"
require "openssl"
require "active_support/time"

module OpenTok
  # @private
  module TokenGenerator
    # this works when using include TokenGenerator
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods

      # @private arguments the method we should generate will need (in order):
      # *  api_key (required - if no lambda assigned, part of method sig)
      # *  api_secret (required - if no lambda assigned, part of method sig)
      # *  session_id (required - if no lambda assigned, part of method sig)
      # *  token_opts (optional - part of method sig)
      #
      # arg_lambdas is a hash of keys which are the above args and values are lambdas that all have the
      # signature ->(instance)
      def generates_tokens(arg_lambdas={})
        @arg_lambdas = arg_lambdas
        define_method(:generate_token) do |*args|
          # puts "generate_something is being called on #{self}. set up with #{method_opts.inspect}"
          dynamic_args = [ :api_key, :api_secret, :session_id, :token_opts ].map do |arg|
            self.class.arg_lambdas[arg].call(self) if self.class.arg_lambdas[arg]
          end
          dynamic_args.compact!
          args = args.first(4-dynamic_args.length)
          self.class.generate_token.call(*dynamic_args, *args)
        end
      end

      # @private For internal use by the SDK.
      def arg_lambdas
        @arg_lambdas
      end

      # Generates a token
      def generate_token
        TokenGenerator::GENERATE_TOKEN_LAMBDA
      end

    end

    # @private TODO: this probably doesn't need to be a constant anyone can read
    GENERATE_TOKEN_LAMBDA = ->(api_key, api_secret, session_id, opts = {}) do
      # normalize required data params
      role = opts.fetch(:role, :publisher)
      unless ROLES.has_key? role
        raise "'#{role}' is not a recognized role"
      end
      unless Session.belongs_to_api_key? session_id.to_s, api_key
        raise "Cannot generate token for a session_id that doesn't belong to api_key: #{api_key}"
      end

      # minimum data params
      data_params = {
        :role => role,
        :session_id => session_id,
        :create_time => Time.now.to_i,
        :nonce => Random.rand
      }

      # normalize and add additional data params
      unless (expire_time = opts[:expire_time].to_i) == 0
        unless expire_time.between?(Time.now.to_i, (Time.now + 30.days).to_i)
          raise "Expire time must be within the next 30 days"
        end
        data_params[:expire_time] = expire_time.to_i
      end

      unless opts[:data].nil?
        unless (data = opts[:data].to_s).length < 1000
          raise "Connection data must be less than 1000 characters"
        end
        data_params[:connection_data] = data
      end

      if opts[:initial_layout_classes]
        if opts[:initial_layout_classes].is_a?(Array)
          data_params[:initial_layout_class_list] = opts[:initial_layout_classes].join(' ')
        else
          data_params[:initial_layout_class_list] = opts[:initial_layout_classes].to_s
        end
      end

      digest = OpenSSL::Digest.new('sha1')
      data_string = Addressable::URI.form_encode data_params
      meta_string = Addressable::URI.form_encode({
        :partner_id => api_key,
        :sig => OpenSSL::HMAC.hexdigest(digest, api_secret, data_string)
      })

      TOKEN_SENTINEL + Base64.strict_encode64(meta_string + ":" + data_string)
    end


    # this works when using extend TokenGenerator
    # def generates_tokens(method_opts)
    #   puts "I'm being called on #{self} with argument #{method_opts.inspect}"
    #
    # end
  end
end
