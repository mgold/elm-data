require 'sinatra'
require 'faker'
require 'json'
require 'pry'

articles = Array.new(20) do
  { title: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraphs(2),
    id: Faker::Crypto.md5 }
end

authors = Array.new(5) do
  { first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    id: Faker::Crypto.md5,
    articles: [] }
end

articles.each do |article|
  article_authors = authors.sample([1, 1, 1, 2, 3].sample)
  article[:authors] = article_authors.map do |author|
    author[:articles] << article[:id]
    author[:id]
  end
end

def json_api_article(article)
  { type: 'article',
    id: article[:id],
    attributes: {
      title: article[:title],
      body: article[:body]
    }, relationships:
    { authors:
       article[:authors].map do |author_id|
         { data: { type: 'author', id: author_id },
           links: { related: "#{request.host}:#{request.port}/authors/#{author_id}"}
         }
       end
    }
  }
end

def json_api_author(author)
  { type: 'author',
    id: author[:id],
    attributes: {
      firstName: author[:first_name],
      lastName: author[:last_name]
    }, relationships:
    { articles:
       author[:articles].map do |article_id|
         { data: { type: 'article', id: article_id },
           links: { related: "#{request.host}:#{request.port}/articles/#{article_id}"}
         }
       end
    }
  }
end

get '/articles' do
  { data: articles.map { |article| json_api_article(article) } }.to_json
end

get '/authors' do
  { data: authors.map { |author| json_api_author(author) } }.to_json
end

get '/articles/:id' do
  article = articles.select{|a| a[:id] = params[:id]}.first
  if article
    { data: json_api_article(article) }.to_json
  else
    404
  end
end

get '/authors/:id' do
  author = authors.select{|a| a[:id] = params[:id]}.first
  if author
    { data: json_api_author(author) }.to_json
  else
    404
  end
end
