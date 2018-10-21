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
      expect(r.details_loaded?).to eq(false)
      r.ip_address
      expect(r).to be_details_loaded
    end
  end
end
