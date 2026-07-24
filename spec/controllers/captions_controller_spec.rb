require 'rails_helper'

RSpec.describe "Captions API", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe "POST /captions" do
    context "The request is valid" do
      it "creates a new caption and returns 201 Created" do
        post "/captions", params: {
          caption: {
            url: "https://example.com/meme.jpg",
            text: "When the code compiles on the first try",
            kind: "simple"
          }
        }.to_json, headers: headers

        expect(response).to have_http_status(:created)
        expect(Caption.count).to eq(1)
      end
    end

    context "The root 'caption' parameter is missing" do
      it "Bad Request(400)" do
        post "/captions", params: {
          url: "https://example.com/meme.jpg",
          text: "This request will fail"
        }.to_json, headers: headers

        expect(response).to have_http_status(400)
      end
    end

    context "The parameters are present but invalid" do
      it "Unprocessable Entity(422)" do
        post "/captions", params: {
          caption: {
            url: "https://example.com/not-an-image.pdf",
            text: ""
          }
        }.to_json, headers: headers

        expect(response).to have_http_status(422)
      end
    end
  end
end
