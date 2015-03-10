require 'nokogiri'
require 'openssl'
require 'rest_client'
require 'net/https'
require 'rubygems'
require "sinatra"
require "erb"


set :port, 9494
set :bind, '0.0.0.0'

def get_data(credentials)
end

get '/' do
    cert = OpenSSL::X509::Certificate.new(File.read './cert/wakeupbitch.bcn.abiquo.com.pem')
    key = OpenSSL::PKey::RSA.new(File.read './cert/wakeupbitch.bcn.abiquo.com.key')
    cli = RestClient::Resource.new('https://ruido.bcn.abiquo.com:8443/dhcp/10.60.1.0', 
                                    :ssl_client_cert => cert, 
                                    :ssl_client_key => key, 
                                    :verify_ssl => OpenSSL::SSL::VERIFY_NONE )
    page = Nokogiri::HTML.parse(cli.get)

    leases = []
    records = page.css("table").first
    records.css("tr").each do |lease|
        ip = lease.css("td")[0].text
        if ip.split(".")[3].to_i >= 220
            mac = lease.css("td")[1].text
            owner = lease.css("td")[4].text
            leases << [ip, mac, owner]
        end
    end 
    erb :index, :locals => {'leases' => leases}
end

post '/wake_up/:mac' do
    mac = params[:mac]
    puts `wakeonlan #{mac}` 
    redirect '/'
end
