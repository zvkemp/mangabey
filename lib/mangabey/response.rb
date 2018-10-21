module Mangabey
  class Response < Resource
    ATTRIBUTES = %i[
      href
      id
      total_time
      custom_variables
      ip_address
      logic_path
      date_modified
      response_status
      custom_value
      analyze_url
      pages
      page_path
      recipient_id
      collector_id
      date_created
      survey_id
      collection_mode
      edit_url
      metadata
    ]

    def self.path
      'responses'
    end
  end
end
