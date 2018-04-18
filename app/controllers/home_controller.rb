class HomeController < ApplicationController
require 'base64'
require 'openssl'
  def index

  end

  def check_signature
  	
    header_signature = request.headers["X-Request-Signature"]
    # Sort all POST parameters
    array_of_prams = []
    # params.each do |parm|
    #     if parm != "controller" 
    #         array_of_prams << parm
    #     end
    # end
    array_of_prams.sort!

    # Creates the string to convert
    server_url = "https://my-server.com/messages_envaya_sms" 
    string = "<#{server_url}>"
    array_of_prams.each do |parm|
        # Uses this because EnvayaSMS sends an action parameter that is over overwritten by rails
        if parm == "action"
            action = request.request_parameters['action']
            string += ",<#{parm}>=<#{action}>"
        else
            string += ",<#{parm}>=<#{params[parm]}>" 
        end
    end

    # Add password to the string
    string += ",testpassword"

    puts "string = #{string}"

    # Generate the SHA-1 hash of the input string
    string = Base64.encode64(Digest::SHA1.hexdigest(string))

    # Checks if header signature matches the string
    if header_signature == string
        success = "The test was a success"
        error = ""
    else
        success = "The test was not a success"
        error = "The header signature does not match"
    end

    render :json => {:payload => {:success => success, :error => error ,:hs => header_signature ,:str => string  }}  	
  end
end


# secret = "xyz"
# request = "https://my-server.com/messages_envaya_sms"
 
# digest = OpenSSL::Digest::Digest.new('sha256')
# signature = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, request)).chomp 
# puts signature # => "ohGcFIHF3vg75A8Kpg42LNxuQpQZJsTBKv8xnZASzu0="