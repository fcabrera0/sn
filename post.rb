require 'sinatra/base'
require 'sinatra/cookies'
require_relative 'models'

class PostController < Sinatra::Base
  helpers Sinatra::Cookies

  before do
    begin
      @session = Session.find(cookies['session'])
      @user = @session.user
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      @session = @user = nil
    end
  end

  post '/posts/new' do
    return {success: 0, code: 1}.to_json if @user.blank?
    return {success: 0, code: 2}.to_json unless params.include? :content

    @user.posts.build(content: params[:content])
    @user.save

    {success: 1}.to_json
  end

  get '/posts/latest' do
    posts = []
    users = [@user.id]
    query = Post.in(:user_id => users)
    query = query.where(:timestamp.gt => DateTime.iso8601(params[:since])) if params.include? :since
    query.each do |e|
      posts << {
          :id => e.id.to_s,
          :content => e.content,
          :timestamp => e.timestamp,
          :user_id => e.user_id.to_s
      }
    end
    posts = posts.take(params[:count].to_i) unless params[:count].blank?
    posts.sort! { |a, b| b[:timestamp].to_i <=> a[:timestamp].to_i }
    posts.to_json
  end
  
  get '/posts/from_user' do
    posts = []
    Post.where(:user_id => params[:id]).each do |e|
      posts << {
          :id => e.id.to_s,
          :content => e.content,
          :timestamp => e.timestamp,
          :user_id => e.user_id.to_s
      }
    end
    posts.to_json
  end
end