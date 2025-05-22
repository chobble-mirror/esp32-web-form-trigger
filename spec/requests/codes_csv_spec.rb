require "rails_helper"

RSpec.describe "Codes CSV Export", type: :request do
  include AuthHelpers
  
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) { Form.create!(name: "Test Form", button_text: "Submit") }
  let!(:code) { Code.create!(device: device, form: form) }
  let!(:claimed_code) { 
    c = Code.create!(device: device, form: form) 
    c.claim!
    c
  }
  
  describe "GET /codes.csv" do
    context "when not logged in" do
      it "redirects to login" do
        get codes_path(format: :csv)
        expect(response).to redirect_to(login_path)
      end
    end
    
    context "when logged in as admin" do
      before { login_as_admin }
      
      it "returns a CSV file" do
        get codes_path(format: :csv)
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to include(".csv")
        
        # Check CSV content
        csv_content = response.body
        expect(csv_content).to include("Code,Device Name,Form Name,Status,Created At,URL,QR Code URL")
        expect(csv_content).to include(code.id)
        expect(csv_content).to include(claimed_code.id)
        expect(csv_content).to include("Unclaimed")
        expect(csv_content).to include("Claimed")
      end
      
      it "applies filters to the CSV export" do
        get codes_path(format: :csv, filter: "unclaimed")
        
        # Should only include unclaimed code
        csv_content = response.body
        expect(csv_content).to include(code.id)
        expect(csv_content).not_to include(claimed_code.id)
      end
    end
  end
end