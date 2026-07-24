require "rails_helper"

RSpec.describe ImageCreation do
  subject(:service) { described_class.new(caption) }

  let(:caption_url) { "https://example.com/photo.png" }
  let(:caption_text) { "How to sleep 8 hours in 2 hours?" }
  let(:caption_name) { "sample-caption-123" }
  let(:image) { instance_double(MiniMagick::Image) }

  let(:caption) do
    double(
      "Caption",
      url: caption_url,
      text: caption_text,
      unique_name: caption_name
    )
  end

  before do
    allow(MiniMagick::Image).to receive(:open).with(caption_url).and_return(image)
    allow(image).to receive(:combine_options)
    allow(image).to receive(:write)
    allow(FileUtils).to receive(:mkdir_p)
  end

  describe "#call" do
    it "returns the public image path" do
      expect(service.call).to eq("/images/sample-caption-123.png")
    end

    it "adds text annotations to the image" do
      expect(image).to receive(:combine_options)
      service.call
    end

    it "writes the image file to public/images" do
      expected_path = Rails.root.join("public", "images", "sample-caption-123.png").to_s
      expect(image).to receive(:write).with(expected_path)
      service.call
    end

    context "when the caption URL has no file extension" do
      let(:caption_url) { "https://example.com/image_without_ext" }
      let(:caption_name) { "no-extension-123" }
      let(:caption_text) { "How to sleep 8 hours in 2 hours?" }

      it "uses .jpg as the fallback extension" do
        expect(service.call).to eq("/images/no-extension-123.jpg")
      end
    end

    context "when downloading the image fails" do
      before do
        allow(MiniMagick::Image).to receive(:open)
          .with(caption_url)
          .and_raise(OpenURI::HTTPError.new("404 Not Found", nil))
      end

      it "raises a DownloadError" do
        expect { service.call }.to raise_error(
          ImageCreation::DownloadError,
          %r{Could not download image from https://example.com/photo.png}
        )
      end
    end
  end
end
