require 'sinatra'
require 'faker'
require 'json'
require 'pry'

books = 20.times.map do |i|
  { title: Faker::Lorem.sentence,
    author: Faker::Name.name,
    published: (1920..2017).to_a.sample,
    id: i+1,
  }
end

def json_api_book(book)
  { type: 'book',
    id: book[:id].to_s,
    attributes: {
      title: book[:title],
      author: book[:author],
      published: book[:published],
    },
  }
end

before do
  headers 'Access-Control-Allow-Origin' => '*'
end

get '/books' do
  limit = (params.dig "page", "size").to_i
  limit = 50 if limit.zero?
  { data: books.first(limit).map { |book| json_api_book(book) } }.to_json
end

get '/books/:id' do
  book = books.select{|a| a[:id] = params[:id]}.first
  if book
    { data: json_api_book(book) }.to_json
  else
    404
  end
end
