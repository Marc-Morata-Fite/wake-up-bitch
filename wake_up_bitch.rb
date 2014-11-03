require 'nokogiri'
require 'open-uri'
require 'net/https'
require 'rubygems'
require "sinatra"
require "erb"


set :port, 9494
set :bind, '0.0.0.0'

def get_data(credentials)
end

get '/' do
    page  = Nokogiri::HTML(open("https://10.60.1.4:8443/dhcp/10.60.1.0", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
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
