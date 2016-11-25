require 'rubygems'
require 'bundler/setup'

require 'sinatra'
#require 'sinatra/reloader' if development?

require 'shopify_api'
require 'httparty'
require 'dotenv'

Dotenv.load

module Customers

  def GetCustomerByEMail(email)
	# Get a specific customer
	#customer = ShopifyAPI::Customer.all( from: :search, params: {q: "#{email}"})
	customer = ShopifyAPI::Customer.search(query: "email:#{email}")
	customer_count = customer.count
	
	if(customer_count != 1)
	  puts "ERROR! Customers::GetCustomerByEMail - The number of customers is not equal to 1"
	  return nil
	end
	
	return customer
  end
  
end

class Marketplace < Sinatra::Base
  configure :development do
    #register Sinatra::Reloader
  end

  include Customers

  API_KEY = ENV['API_KEY']
  PASSWORD = ENV['PASSWORD']
  APP_URL = "goestrie.pagekite.me"

  if (API_KEY == nil or PASSWORD == nil)
    puts "ERROR! API_KEY and/or PASSWORD are undefined (make sure startup path contains .env file"
  end
  
  Shop_url = "https://#{API_KEY}:#{PASSWORD}@goestrie.myshopify.com/admin"
  
  puts Shop_url
  ShopifyAPI::Base.site = Shop_url	
  Shop = ShopifyAPI::Shop.current
  
  #Marketplace_Customers = Customers.new;

  def initialize
    super
  end

  # Customer Endpoints
  get '/customers/:email/?:key1?/?:key2?' do
	email = params[:email]
	key1 = params[:key1]
	key2 = params[:key2]

    customer = GetCustomerByEMail(email)
	
	if (customer != nil)
		customer_json = customer.to_json
		customer_json_parsed = JSON.parse(customer_json)
		
		if (key1)
		  if (key2)
			value = customer_json_parsed[0]["#{key1}"]["#{key2}"]
		  else
			value = customer_json_parsed[0]["#{key1}"]
		  end
		else
		  value = customer_json
		end

		value = value.to_s
		
		return value.to_s
	else
	  return nil
	end

  end
end

run Marketplace.run!
