require "salesforceintegration/version"

require 'active_support'
require 'yaml'
require 'databasedotcom'

module SalesforceIntegration
  class SalesforceIntegrationLead
    def initialize(options)
      raise "It's necessary to inform client_id, client_secret, url, username and password!" unless options.has_key?(:client_id) and options.has_key?(:client_secret) and options.has_key?(:url) and options.has_key?(:username) and options.has_key?(:password)

      client = Databasedotcom::Client.new(:client_id => options[:client_id], :client_secret => options[:client_secret], :host => options[:url])
      client.authenticate(:username => options[:username], :password => options[:password])

      client.materialize("Lead")
      client.materialize("User")
    end

    #TODO: Permitir associar a mais de uma conta
    def create_lead_on_salesforce(username_owner_lead,fields)
      raise "The fields last_name and company are required"    unless fields.has_key?(:last_name) and fields.has_key?(:company)
      raise "The fields last_name and company cannot be blank"     if fields[:last_name].blank?    or fields[:company].blank? 

      lead = Lead.new
      user = User.find_by_username(username_owner_lead)

      lead['OwnerId'] = user.Id
      lead['FirstName'] = fields[:first_name]
      lead['LastName'] = fields[:last_name]
      lead['Email'] = fields[:email]
      lead['Company'] = fields[:company]
      lead['Title'] = fields[:job_title]
      lead['Phone'] = fields[:phone]
      lead['Website'] = fields[:website]
      lead['IsConverted'] = false
      lead['IsUnreadByOwner'] = true
      lead.save
      lead.Id
    end
  end
end
