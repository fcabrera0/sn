require 'sinatra'
require 'sinatra/cookies'
require_relative 'post'
require_relative 'auth'
require_relative 'models'

Mongoid.load!('mongoid.yml', :production)
set :port, 3000

use AuthController
use PostController

before do
  begin
    @session = Session.find(cookies['session'])
    @user = @session.user
  rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
    @session = @user = nil
  end
end

get '/' do
  @title = 'Home'
  redirect '/login' if @user.blank?
  redirect '/profile/edit' if @user.profile.blank? or @user.profile.identity.blank?
  erb :home
end

get '/profile/edit' do
  @title = 'Edit my profile'
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

get '/login' do
  @title = 'Login'
  erb :login
end

get '/signup' do
  @title = 'Signup'
  erb :signup
end