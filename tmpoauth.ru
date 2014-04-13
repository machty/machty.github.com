require 'bundler/setup'
require 'sinatra/base'
require 'uri'
require 'httparty'
require 'base64'

# The project root directory
$root = ::File.dirname(__FILE__)


class SinatraStaticServer < Sinatra::Base

  def creds
    @creds ||= File.read('./.cram').split(' ')
  end

  def cram_key
    creds[0]
  end

  def cram_secret
    creds[1]
  end

  def redirect_uri
    "http://localhost:9292/auth"
  end

  def encoded_redirect_uri
    URI.encode_www_form_component(redirect_uri)
  end

  def auth_url
    "http://Cram.com/oauth2/authorize/?client_id=#{cram_key}&scope=read_write_delete&redirect_uri=#{encoded_redirect_uri}&response_type=code"
  end


  get(/auth+/) do
    code = params[:code]
    url = "https://api.Cram.com/oauth2/token/"

    basic_auth_code = Base64.encode64("#{cram_key}:#{cram_secret}").strip.gsub("\n","")
    auth_header = "Basic #{basic_auth_code}"
    puts auth_header
    puts "LOL"

    result = HTTParty.post(url,
      body: {
        code: code,
        grant_type: 'authorization_code',
      },
      headers: {
        "Authorization" => auth_header
      }
    )

    result.body
  end

  get(/.+/) do
    redirect to(auth_url)
  end

  #def send_sinatra_file(path, &missing_file_block)
    #file_path = File.join(File.dirname(__FILE__), 'public',  path)
    #file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    #File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  #end

end

run SinatraStaticServer

