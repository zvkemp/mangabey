module Mangabey
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
end
