require 'rails_helper'

RSpec.describe "Captions API", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe "POST /captions" do
    context "when the request is valid" do
      it "creates a new caption and returns 201 Created" do
        post "/captions", params: {
          caption: {
            url: "https://example.com/meme.jpg",
            text: "Când codul compilează din prima",
            kind: "simple"
          }
        }.to_json, headers: headers

        expect(response).to have_http_status(:created)
        expect(Caption.count).to eq(1)
      end
    end

    context "when the root 'caption' parameter is missing" do
      it "returns 400 Bad Request" do
        post "/captions", params: {
          url: "https://example.com/meme.jpg",
          text: "Acest request va eșua"
        }.to_json, headers: headers

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when parameters are present but invalid" do
      it "returns 422 Unprocessable Entity" do
        post "/captions", params: {
          caption: {
            url: "https://example.com/not-an-image.pdf",
            text: ""
          }
        }.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end