require 'spec_helper'


describe RequestsResourcesController do

  before(:each) do

    u = FactoryBot.create(:admin_user)
    sign_in u

    @course = double(Course, id: 'id', semester: FactoryBot.create(:semester))
    CourseSearch.any_instance.stub(:get).and_return(@course)
  end


  describe :edit do

    it "shows the edit page " do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)

      get :edit, { id: reserve.id }
    end


    it "assigns a view object " do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)

      get :edit, { id: reserve.id }
      assigns(:request)
    end


    it "renders a 404 if the item cannot have a resource" do
      reserve = mock_reserve(FactoryBot.create(:request, :book), @course)
      lambda {
        get :edit, { id: reserve.id }
      }.should render_template(nil)
    end


    it "does not allow non admins in" do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)

      u = FactoryBot.create(:admin_user)
      u.revoke_admin!
      sign_in u

      lambda {
        get :edit, id: reserve.id
      }.should render_template(nil)
    end
  end


  describe :update do
    it "allows you to upload a file" do
      reserve = mock_reserve(FactoryBot.create(:request, :book_chapter), @course)
      reserve.pdf.clear
      reserve.save!

      put :update, { id: reserve.id, :admin_update_resource => { :pdf => fixture_file_upload(Rails.root.join('spec', 'files', 'test.pdf'), 'application/pdf') } }
      response.should be_redirect
    end


    it "allows you to update the url " do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)
      reserve.url = ""
      reserve.save!

      put :update, { id: reserve.id, :admin_update_resource => { :url => "URL" } }
      response.should be_redirect
    end


    it "does not allow non admins in" do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)

      u = FactoryBot.create(:admin_user)
      u.revoke_admin!
      sign_in u

      lambda {
        get :update, id: reserve.id
      }.should render_template(nil)
    end

  end


  describe :destroy do

    it "redirects to the edit page " do
      reserve = mock_reserve(FactoryBot.create(:request, :book_chapter), @course)

      delete :destroy, id: reserve.id
      expect(response).to redirect_to edit_resource_path(reserve.id)
    end

    it "removes an loaded file " do
      reserve = mock_reserve(FactoryBot.create(:request, :book_chapter), @course)

      delete :destroy, id: reserve.id
      reserve.item.reload()
      expect(reserve.pdf.present?).to be_falsey
    end


    it "removes a url " do
      reserve = mock_reserve(FactoryBot.create(:request, :video), @course)

      delete :destroy, id: reserve.id

      reserve.item.reload()
      expect(reserve.url.present?).to be_falsey
    end
  end

end
