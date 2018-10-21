require "mangabey/version"
require 'oauth2'
require 'pathname'

module Mangabey
  API_ROOT = Pathname.new('/v3')

  class Client
    def initialize(token, opts = {})
      @oauth_token = Mangabey.oauth_access_token(token, opts)
    end

    attr_reader :oauth_token

    def surveys
      wrap_resource(Survey)
    end

    def survey(id)
      oauth_token.get(Mangabey::API_ROOT.join('surveys', id.to_s).to_s)
    end

    def survey_details(id)
      oauth_token.get(Mangabey::API_ROOT.join('surveys', id.to_s, 'details').to_s)
    end

    def wrap_resource(resource)
      ClientResource.new(self, resource)
    end

    def get(url, *args)
      oauth_token.get(url.to_s, *args).tap do |resp|
        raise Error.new unless resp.status == 200
      end
    end
  end

  class Error < StandardError
  end

  class << self
    def oauth_client
      OAuth2::Client.new(
        ENV['MANGABEY_CLIENT_ID'],
        ENV['MANGABEY_CLIENT_SECRET'],
        site: 'https://api.surveymonkey.com/oauth/authorize'
      )
    end

    def oauth_access_token(token = ENV['MANGABEY_ACCESS_TOKEN'], opts = {})
      OAuth2::AccessToken.new(oauth_client, token, opts)
    end
  end

  ClientResource = Struct.new(:client, :resource_class) do
    def all
      resource_class.all(client)
    end
  end

  class ClientPage
    attr_reader :response, :resource_class, :client

    def initialize(response, resource_class, client)
      @response = response
      @resource_class = resource_class
      @client = client
    end

    def data
      @data ||= JSON.parse(response.body)
    end

    def elements
      data['data'].map do |elem|
        resource_class.new(from_list: elem, client: client)
      end
    end

    def next_url
      data.dig('links', 'next')
    end
  end

  module HasData
    def method_missing(name, *args, &block)
      return fetch_attribute(name) if data.key?(name.to_s)
      return fetch_attribute(name) if self.class::ATTRIBUTES.include?(name)
      super
    end

    def fetch_attribute(name)
      data.fetch(name.to_s)
    rescue KeyError
      raise if details_loaded?
      load_details!
      retry
    end

    def load_details!
      # no-op
    end

    def details_loaded?
      true
    end
  end

  class Resource
    include HasData

    def self.all(client)
      Enumerator.new do |yielder|
        page_url = Mangabey::API_ROOT.join(path)
        yield_page(client, yielder, page_url)
      end
    end

    def self.yield_page(client, yielder, page_url)
      loop do
        page = ClientPage.new(client.get(page_url), self, client)
        page.elements.each do |elem|
          yielder << elem
        end

        page_url = page.next_url or return
      end
    end

    attr_reader :data, :client

    def initialize(from_list: {}, from_details: {}, client:)
      @data = from_list.merge(from_details)
      @details_loaded = !from_details.empty?
      @client = client
    end

    def details_loaded?
      !!@details_loaded
    end

    def load_details!
      body = JSON.parse(client.get(details_url).body)
      @data.merge!(body)
      @details_loaded = true
    end

    def href
      fetch_attribute('href')
    end

    private

    def details_url
      Pathname.new(href).join('details')
    end
  end

  class Survey < Resource
    # {
    #   "title": "My Survey",
    #   "nickname": "",
    #   "custom_variables": {
    #     "name": "label"
    #   },
    #   "language": "en",
    #   "question_count": 10,
    #   "page_count": 10,
    #   "date_created": "2015-10-06T12:56:55+00:00",
    #   "date_modified": "2015-10-06T12:56:55+00:00",
    #   "id": "1234",
    #   "folder_id":"1234",
    #   "pages":[
    #     {
    #       //Page Object
    #       "questions": [
    #         {
    #           //Question Object
    #         }
    #       ]
    #     }
    #   ],
    #   "buttons_text": {
    #     "done_button": "Done",
    #     "prev_button": "Prev",
    #     "exit_button": "Exit",
    #     "next_button": "Next"
    #   },
    #   "footer": true,
    #   "preview": "https://www.surveymonkey.com/r/Preview/",
    #   "edit_url": "https://www.surveymonkey.com/create/",
    #   "collect_url": "https://www.surveymonkey.com/collect/list",
    #   "analyze_url": "https://www.surveymonkey.com/analyze/",
    #   "summary_url": "https://www.surveymonkey.com/summary/"
    # }
    #
    ATTRIBUTES = %i[
      title
      nickname
      custom_variables
      language
      question_count
      page_count
      date_created
      date_modified
      id
      folder_id
      pages
      buttons_text
      footer
      preview
      edit_url
      collect_url
      analyze_url
      summary_url
    ]

    def self.path
      'surveys'
    end

    def questions
      pages.lazy.flat_map do |page|
        page['questions'].map do |q|
          Question.new(from_details: q, client: client)
        end
      end
    end
  end

  class SideloadedResource
    include HasData

    def initialize(data)
      @data = data
    end
  end

  class Question < Resource
    # {
    # "headings": [
    #     {
    #         "heading": "Which monkey would you rather have as a pet?"
    #     }
    # ],
    # "position": 1,
    # "family": "single_choice",
    # "subtype": "vertical",
    # "answers": {
    #     "choices":[
    #         {
    #             "text": "Capuchin"
    #         },
    #         {
    #             "text": "Mandrill"
    #         },
    #     ],
    #     "other":[
    #             {
    #                 "text": "Other",
    #                 "num_chars": 100,
    #                 "num_lines": 3
    #             }
    #     ]
    # }
  end
end
