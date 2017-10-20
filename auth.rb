require 'sinatra/base'
require 'digest'
require 'base64'
require_relative 'models'

class AuthController < Sinatra::Base
  post '/auth/new' do
    [:email, :password].each do |param|
      return { success: 0, code: 1 }.to_json unless params.include? param
    end

    return { success: 0, code: 2 }.to_json if User.where(email: params[:email]).exists?

    salt = SecureRandom.base64
    value = Digest::SHA2.new(512).hexdigest(params[:password] + salt)

    user = User.create(email: params[:email], password: { salt: salt, value: value })

    { success: 1, id: user.id.to_s }.to_json
  end

  post '/auth/open' do
    [:email, :password].each do |param|
      return { success: 0, code: 1 }.to_json unless params.include? param
    end

    return { success: 0, code: 2 }.to_json unless User.where(email: params[:email]).exists?

    user = User.where(email: params[:email]).first
    salt = user.password[:salt]
    value = Digest::SHA2.new(512).hexdigest(params[:password] + salt)

    return { success: 0, code: 3}.to_json unless value == user.password[:value]

    session = user.sessions.build(ip: request.ip)
    user.save

    { success: 1, id: session.id.to_s }.to_json
  end

  get '/verify' do
    return { success: 0, code: 1}.to_json unless params.include? :id

    found = User.where(verification: params[:id], status: 0)
    return { success: 0, code: 2}.to_json unless found.exists?

    user = found.first
    user.status = 1
    user.save

    redirect '/login'
  end
end