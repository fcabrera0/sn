require 'sinatra'
require 'sinatra/cookies'
require_relative 'post'
require_relative 'auth'
require_relative 'profile'
require_relative 'models'

Mongoid.load!('mongoid.yml', :production)
set :port, 3000

use AuthController
use PostController
use ProfileController

before do
  @path = request.path_info
  @ip = request.ip
  begin
    @session = Session.find(cookies['session'])
    @user = @session.user
  rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
    @session = @user = nil
  end
end

get '/' do
  redirect '/login' if @user.blank?
  redirect '/profile/manage' if @user.profile.blank? or @user.profile.identity.blank?
  @title = 'Home'
  erb :home
end

get '/login' do
  @title = 'Login'
  erb :login
end

get '/signup' do
  @title = 'Signup'
  erb :signup
end