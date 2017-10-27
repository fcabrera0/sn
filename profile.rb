require 'sinatra/base'
require 'sinatra/cookies'

class ProfileController < Sinatra::Base
  helpers Sinatra::Cookies

  before do
    begin
      @session = Session.find(cookies['session'])
      @user = @session.user
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      @session = @user = nil
    end
  end

  get '/user/profile' do
    begin
      identity = User.find(params[:id]).profile[:identity]
      {
          firstname: identity[:firstname],
          lastname: identity[:lastname],
          gender: identity[:gender]
      }.to_json
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      ''
    end
  end

  get '/profile/manage' do
    redirect '/login' if @user.blank?
    @title = 'Manage my profile'
    @user.profile.build(
        identity: {},
        about: {},
        privacy: {}
    ) if @user.profile.blank?
    erb :edit_profile
  end

  post '/profile/identity' do
    [:firstname, :lastname, :gender].each do |param|
      return {success: 0, code: 1}.to_json unless params.include? param
    end

    profile = @user.profile
    profile.identity = {
        firstname: params[:firstname],
        lastname: params[:lastname],
        gender: params[:gender]
    }
    profile.save

    {success: 1}.to_json
  end

  post '/profile/about' do
    [].each do |param|
      return {success: 0, code: 1}.to_json unless params.include? param
    end

    profile = @user.profile
    profile.about = {

    }
    profile.save

    {success: 1}.to_json
  end
end