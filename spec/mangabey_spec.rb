RSpec.describe Mangabey do
  let(:token) do
    ENV['MANGABEY_ACCESS_TOKEN']
  end

  it 'is lazy by default', :vcr do
    surveys = Mangabey::Client.new('faketoken').surveys.all
    # error not raised until data access
    expect { surveys.first }.to raise_error(OAuth2::Error)
  end

  specify 'detail loading', :vcr do
    client = Mangabey::Client.new(token)
    survey, * = client.surveys.all.to_a
    expect(survey.details_loaded?).to eq(false)
    expect(survey.title).to eq('Post-Event Feedback Survey')
    expect(survey.details_loaded?).to eq(false)
    expect(survey.questions.count).to eq(8)
    expect(survey.details_loaded?).to eq(true)
  end

  specify '.find', :vcr do
    client = Mangabey::Client.new(token)
    survey = client.surveys.find(160281378)
    expect(survey.details_loaded?).to eq(false)
    survey.title
    expect(survey.details_loaded?).to eq(true)
  end

  specify 'survey#respondents', :vcr do
    client = Mangabey::Client.new(token)
    survey = client.surveys.find(160281378)
    expect(survey.details_loaded?).to eq(false)
    responses = survey.responses.all.to_a
    expect(survey.details_loaded?).to eq(false)

    expect(responses.count).to eq(2)
    responses.each do |r|
      expect(r).not_to be_details_loaded
      r.ip_address
      expect(r).to be_details_loaded
    end
  end

  specify 'surveys#search', :vcr do
    client = Mangabey::Client.new
    surveys = client.surveys.all(title: 'test')
  end

  context 'test survey' do
    let(:client) { Mangabey::Client.new }
    let(:survey) { client.surveys.find(43502721) }
    specify '.find', :vcr do
      expect(survey.details_loaded?).to eq(false)
      survey.load_details!
    end

    specify 'respondents', :vcr do
      responses = survey.responses.all.to_a
      responses.each(&:load_details!)
    end

    specify 'bulk respondents', :vcr do
      responses = survey.responses(bulk: true).all.to_a # bulk includes all answers)
      expect(responses.count).to eq(4)
      responses.each do |r|
        expect(r).to be_details_loaded
      end
    end

    let(:timestamp) { Time.new(2014, 1, 1, 0, 0, 0, 0) }

    specify 'bulk respondents with start_modified_at', :vcr do
      responses = survey.responses(bulk: true, after: timestamp).all.to_a
      expect(responses.count).to eq(2)
      responses.each do |r|
        expect(r).to be_details_loaded
        expect(Time.parse(r.data['date_modified'])).to be > timestamp
      end
    end
  end
end
