#!/usr/bin/env ruby
require 'securerandom'
require 'net/http'
require 'json'
require 'rest_client'
require 'yaml'
require 'deep_merge'
require 'trollop'

opts = Trollop::options do
        banner <<-EOS
  This script will create test users for testing
  Usage:
  create-test-users.rb [options]
        EOS
        opt :user_count, "How many users to create", :default => 3
  opt :user_env, "Environment to create users(beta, staging, production)", :type => :string
end

# change this based on the environment running against
case opts.user_env
  when 'dev'
    base_url = 'https://service-dev'
    superadmin_email = 'admin@example.com'
    superadmin_passwd = ''
    superadmin_userAccountId = '44fb2716-102e-11e3-b0f2-001eecc02ec5'
  when 'staging'
    base_url = 'https://service-staging'
    superadmin_email = 'admin@example.com'
    superadmin_passwd = ''
    superadmin_userAccountId = '44fb2716-102e-11e3-b0f2-001eecc02ec5'
  when 'production'
    base_url = 'https://service'
    superadmin_email = 'superadmin@example.com'
    superadmin_passwd = ''
end

$app_version = '1000'
$email_domain = 'example.com'
org_user_data = Hash.new
org_user_data_temp = Hash.new
count = 1

def get_superadmin_token(base_url,superadmin_email,superadmin_passwd)
        puts "Getting superadmin credentials"
        superadmin_data = {
          :email => superadmin_email,
          :password => superadmin_passwd
        }
        admin_login_resp = RestClient.post("#{base_url}/login?&api_key=special_key&app_platform=ios&app_vers=#{$app_version}&", superadmin_data.to_json, {:content_type => 'application/json', :accept => 'application/json'})
        superadmin_login_json =  JSON.parse(admin_login_resp.body)
        superadmin_token = superadmin_login_json['token']
        return superadmin_token
end
