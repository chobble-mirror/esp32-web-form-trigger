require "rails_helper"

RSpec.describe "Forms", type: :request do
<<<<<<< HEAD
  let!(:form) { create_test_form }
=======
  let!(:form) do
    Form.create!(
      background_color: "#ffffff",
      text_color: "#000000",
      button_color: "#0000ff",
      button_text_color: "#ffffff",
      button_text: "Submit",
      header_text: "Test form",
      target_email_address: "test@example.com"
    )
  end
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea

  describe "authorization" do
    context "when not logged in" do
      it "redirects to login for index" do
        get forms_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for new" do
        get new_form_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for edit" do
        get edit_form_path(form)
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for create" do
        post forms_path, params: {
<<<<<<< HEAD
          form: valid_form_attributes
=======
          form: {
            button_text: "New Form",
            header_text: "New Header",
            target_email_address: "new@example.com"
          }
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
        }
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for update" do
        patch form_path(form), params: {
          form: {button_text: "Updated Form"}
        }
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for destroy" do
        delete form_path(form)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as non-admin user" do
      before { login_as_user }

      it "redirects to root for index" do
        get forms_path
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for new" do
        get new_form_path
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for edit" do
        get edit_form_path(form)
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for create" do
        post forms_path, params: {
<<<<<<< HEAD
          form: valid_form_attributes
=======
          form: {
            button_text: "New Form",
            header_text: "New Header",
            target_email_address: "new@example.com"
          }
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
        }
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for update" do
        patch form_path(form), params: {
          form: {button_text: "Updated Form"}
        }
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for destroy" do
        delete form_path(form)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged in as admin user" do
      before { login_as_admin }

      it "allows access to index" do
        get forms_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to new" do
        get new_form_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to edit" do
        get edit_form_path(form)
        expect(response).to have_http_status(:success)
      end

      it "displays device links on the edit page" do
        device = Device.create!(name: "Test Device", location: "Test Location")
        get edit_form_path(form)
        expect(response.body).to include(public_form_path(form.id, device.id))
        expect(response.body).to include("Test Device")
      end

      it "allows form creation" do
        expect {
          post forms_path, params: {
<<<<<<< HEAD
            form: valid_form_attributes
=======
            form: {
              button_text: "New Form",
              header_text: "New Header",
              target_email_address: "new@example.com"
            }
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
          }
        }.to change(Form, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end

      it "allows form update" do
        patch form_path(form), params: {
          form: {button_text: "Updated Form"}
        }
        expect(form.reload.button_text).to eq("Updated Form")
        expect(response).to have_http_status(:redirect)
      end

      it "allows form deletion" do
        expect {
          delete form_path(form)
        }.to change(Form, :count).by(-1)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
