require 'rubygems'
require 'sinatra'
require 'haml'
require 'coffee-script'
require 'csv_record'
require 'json'
require 'active_support/core_ext'

set :public_folder, 'public'

get '/' do
  haml :app
end

get '/app.js' do
  content_type 'text/javascript'
  coffee :app
end

get '/views/:name' do
  haml params[:name].to_sym
end

get '/todos' do
  content_type :json
  Todo.all.to_json
end

post '/todos' do
  Todo.create params
end

post '/todos/:id' do
  todo = Todo.find params[:id]
  todo.update_attributes params.slice('title', 'completed')
end

delete '/todos/:id' do
  Todo.find(params[:id]).destroy
end

delete '/todos' do
  Todo.all.map &:destroy
  ''
end

class Todo
  include CsvRecord::Document

  def initialize(args={})
    self.title = args[:title]
    self.completed = args[:completed] || false
  end

  attr_accessor :title, :completed

  def to_json(options)
    {
      id: self.id,
      title: self.title,
      completed: self.completed
    }.to_json
  end
end