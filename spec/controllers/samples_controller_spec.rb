require 'rails_helper'
describe "SamplesController", :type => :request do
  it "has a working method for creating a new sample with false verification" do
    sample_params = {
      sample: {
        label: 2
      }
    }
    expect(Sample.count).to eq(0)
    post create_sample_path, sample_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(Sample.count).to eq(1)
    expect(Sample.first.verified).to eq(false)
  end

  it "has a working admin method for fetching the unverified samples" do
    10.times do |i|
      Sample.create label: i
    end
    Sample.create label: 3, verified: true
    get all_samples_path, format: :json
    response_body = eval(response.body)
    expect(response_body[:samples].size).to eq(10)
    ids = response_body[:samples].pluck(:id)
    expect(ids.size).to eq(10)
    ids.each do |id|
      expect(Sample.find(id).verified).to eq(false)
    end
  end

  it "has a working admin method for verifying a sample" do
    Sample.create label: 1
    sample_params = {
      sample: {
        verified: 2
      },
      token: ENV["COFFEE_TOKEN"]
    }
    expect(Sample.first.verified).to eq(false)
    put verify_sample_path(Sample.first), sample_params.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    expect(Sample.first.verified).to eq(true)
  end

  it "has a working admin method for rejecting new samples that are NOT verified" do
    Sample.create label: 1
    Sample.create label: 2, verified: true
    expect(Sample.count).to eq(2)
    delete deny_sample_path(Sample.first)
    expect(Sample.count).to eq(1)
    delete deny_sample_path(Sample.first)
    expect(Sample.count).to eq(1)
  end

end
