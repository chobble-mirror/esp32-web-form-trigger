require 'rails_helper'

RSpec.describe "Devices", type: :request do
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  
  describe "authorization" do
    context "when not logged in" do
      it "redirects to login for index" do
        get devices_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for new" do
        get new_device_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for edit" do
        get edit_device_path(device)
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for create" do
        post devices_path, params: { device: { name: "New Device", location: "New Location" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for update" do
        patch device_path(device), params: { device: { name: "Updated Device" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for archive" do
        post archive_device_path(device)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as non-admin user" do
      before { login_as_user }

      it "redirects to root for index" do
        get devices_path
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for new" do
        get new_device_path
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for edit" do
        get edit_device_path(device)
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for create" do
        post devices_path, params: { device: { name: "New Device", location: "New Location" } }
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for update" do
        patch device_path(device), params: { device: { name: "Updated Device" } }
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for archive" do
        post archive_device_path(device)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged in as admin user" do
      before { login_as_admin }

      it "allows access to index" do
        get devices_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to new" do
        get new_device_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to edit" do
        get edit_device_path(device)
        expect(response).to have_http_status(:success)
      end

      it "allows device creation" do
        expect {
          post devices_path, params: { device: { name: "New Device", location: "New Location" } }
        }.to change(Device, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end

      it "allows device update" do
        patch device_path(device), params: { device: { name: "Updated Device" } }
        expect(device.reload.name).to eq("Updated Device")
        expect(response).to have_http_status(:redirect)
      end

      it "allows device archiving" do
        post archive_device_path(device)
        expect(device.reload.archived).to be true
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end