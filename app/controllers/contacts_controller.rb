class ContactsController < ApplicationController
  def index
    token = session[:azure_access_token]
    email = session[:user_email]
    if token
      # If a token is present in the session, get messages from the inbox
      conn = Faraday.new(:url => 'https://outlook.office.com') do |faraday|
        # Outputs to the console
        faraday.response :logger
        # Uses the default Net::HTTP adapter
        faraday.adapter  Faraday.default_adapter
      end

      response = conn.get do |request|
        # Get contacts from the default contacts folder
        # Sort by GivenName in ascending orderby
        request.url '/api/v2.0/me/contactfolders/Contacts/contacts?$orderby=GivenName asc&$select=GivenName,Surname,EmailAddresses&$top=1000'
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['Accept'] = "application/json"
        request.headers['X-AnchorMailbox'] = email.to_s
      end

      @contacts = JSON.parse(response.body)['value']
    else
      # If no token, redirect to the root url so user
      # can sign in.
      redirect_to root_url
    end
  end
end
