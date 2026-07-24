require 'rails_helper'

RSpec.describe "Captions API", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe "POST /captions" do
    context "The request is valid" do
      it "creates a new caption and returns 201 Created" do
        fake_image = instance_double(MiniMagick::Image)
        allow(MiniMagick::Image).to receive(:open).and_return(fake_image)
        allow(fake_image).to receive(:combine_options)
        allow(fake_image).to receive(:write)

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

  describe "GET /captions" do
    it "returns 200 and an empty array when there are none" do
      get "/captions"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to eq({ "captions" => [] })
    end

    it "returns 200 and the list of captions" do
      FactoryBot.create(:caption)
      get "/captions"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["captions"].size).to eq(1)
    end
  end

  describe "GET /captions/:id" do
    it "returns 200 and the caption when found" do
      caption = FactoryBot.create(:caption)
      get "/captions/#{caption.id}"
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["caption"]["id"]).to eq(caption.id)
    end

    it "returns 404 when not found" do
      get "/captions/999999"
      expect(response).to have_http_status(404)
    end
  end

  describe "DELETE /captions/:id" do
    it "returns 200 and deletes the caption" do
      caption = FactoryBot.create(:caption)
      delete "/captions/#{caption.id}"
      expect(response).to have_http_status(200)
      expect(Caption.exists?(caption.id)).to be false
    end

    it "returns 404 when not found" do
      delete "/captions/999999"
      expect(response).to have_http_status(404)
    end
  end
end
