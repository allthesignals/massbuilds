require 'rails_helper'

RSpec.describe "Edits", type: :request do
  let(:valid_jsonapi_params) {
    hash = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }
    hash["data"]["type"] = "edit"
    hash["data"]["attributes"] = FactoryBot.attributes_for(:edit)
    hash.to_json
  }

  describe "GET /edits" do
    it "works as an admin" do
      get edits_path, headers: admin_user_session
      expect(response).to have_http_status(:success)
    end

    it "does not work as a user" do
      get edits_path, headers: guest_user_session
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /edits" do
    it "works as a verified user" do
      post edits_path, params: valid_jsonapi_params, headers: verified_guest_user_session
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include('application/vnd.api+json')
    end

    it "works as a municipal user" do
      post edits_path, params: valid_jsonapi_params, headers: municipal_user_session
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include('application/vnd.api+json')
    end

    it "works as an admin" do
      post edits_path, params: valid_jsonapi_params, headers: admin_user_session
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include('application/vnd.api+json')
    end

    it "works as a registered user" do
      post edits_path, params: valid_jsonapi_params, headers: registered_user_session
      expect(response).to have_http_status(:success)
      expect(response.header['Content-Type']).to include('application/vnd.api+json')
    end
  end

  describe "PATCH /edits/:id" do
    it "works as an admin" do
      edit = FactoryBot.create(:edit)
      put "/edits/#{edit.id}", params: valid_jsonapi_params, headers: admin_user_session
      expect(response).to have_http_status(:no_content)
    end

    it "does not work as a guest user" do
      edit = FactoryBot.create(:edit)
      put "/edits/#{edit.id}", params: valid_jsonapi_params, headers: guest_user_session
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /edits/:id" do
    it "works as an admin" do
      edit = FactoryBot.create(:edit)
      delete "/edits/#{edit.id}", headers: admin_user_session
      expect(response).to have_http_status(:no_content)
    end

    it "works for your own edit if it was not approved yet" do
      user = FactoryBot.create(:user, role: 'user')
      edit = FactoryBot.create(:edit, user: user)
      user_session = {
                        Authorization: "Token token=#{user.authentication_token}, email=#{user.email}",
                        'Content-Type': 'application/vnd.api+json',
                        'Accept': 'application/vnd.api+json'
                      }
      delete "/edits/#{edit.id}", headers: user_session
      expect(response).to have_http_status(:no_content)
    end

    it "works as a verified user" do
      # setup verified user scenarios here
      edit = FactoryBot.create(:edit)
      delete "/edits/#{edit.id}", headers: verified_user_session
      expect(response).to have_http_status(:no_content)
    end

    it "does not work as a guest user" do
      # setup guest user scenarios here
      edit = FactoryBot.create(:edit)
      delete "/edits/#{edit.id}", headers: guest_user_session
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
