require "rails_helper"

RSpec.describe "Public user creation", type: :request do
  describe "POST /signup" do
    before do
      # Clear all users to start fresh
      User.destroy_all
    end
    
    context "when not logged in" do
      it "allows any visitor to create a new user account" do
        # Create an existing user so our test user won't be the first
        User.create!(
          email: "existing@example.com",
          password: "password",
          password_confirmation: "password"
        )
        
        post "/signup", params: {
          user: {
            email: "newuser@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq("Account created")
        
        # Verify user was created
        new_user = User.find_by(email: "newuser@example.com")
        expect(new_user).to be_present
        expect(new_user.admin).to be false
        
        # Verify user is logged in after creation
        expect(session[:user_id]).to eq(new_user.id)
      end
      
      it "shows errors when validation fails" do
        post "/signup", params: {
          user: {
            email: "invalid-email",
            password: "pass",
            password_confirmation: "password"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(User.count).to eq(0)
      end
      
      it "requires password confirmation to match" do
        post "/signup", params: {
          user: {
            email: "user@example.com",
            password: "password",
            password_confirmation: "different"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(User.count).to eq(0)
      end
    end
    
    context "with multiple users" do
      it "sets the first user as admin" do
        # First user
        post "/signup", params: {
          user: {
            email: "first@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        
        expect(User.first.admin).to be true
        
        # Second user
        post "/signup", params: {
          user: {
            email: "second@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        
        second_user = User.find_by(email: "second@example.com")
        expect(second_user.admin).to be false
      end
    end
  end
end