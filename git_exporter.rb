#!/usr/bin/env ruby

require 'sinatra'
require 'octokit'

set :bind, '0.0.0.0'
set :port, 9105

def fetch_all_github_result(client, request)
  result = []
  result << request
  last_response = client.last_response
  until last_response.rels[:next].nil?
    last_response = last_response.rels[:next].get
    result << last_response.data
  end
  result.flatten
end

def fetch_pr_status
  result = []
  client = Octokit::Client.new(:access_token => ENV['GIT_ACCESS_TOKEN'])
  repos = fetch_all_github_result(client, client.repositories('mydrive'))

  repos.each do |repo|
    pulls = fetch_all_github_result(client, client.pull_requests(repo.id, :state => 'all'))
    result << {:name => repo.name, :open => pulls.count {|pull| pull.state == 'open'}, :closed => pulls.count {|pull| pull.state == 'closed'} }
  end

  result
end

get '/' do
  'Github prometheus exporter'
end

get '/metrics' do
  content_type 'text/plain'
  @prs = fetch_pr_status
  erb :response
end
