require 'spec_helper'

describe MassDataController do

  before :each do
    @dataxml = fixture_file_upload('/files/test_data.xml', 'text/xml')
    @paramsxml = fixture_file_upload('/files/test_params.txt', 'text/xml')
    #@dataother = fixture_file_upload('/files/test_data.txt', 'text/txt')
    #@paramsother = fixture_file_upload('/files/test_params.bad.txt', 'text/txt')
  end

  describe 'upload a mass data' do
    it "can upload a mass data xml file" do
      # fake_data = mock('MassData', :title => 'test_data.xml')
      # MassData.stub(:create!).with({:file => @dataxml}).and_return(fake_data)
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      user.stub(:id).and_return(1)

      user.stub(:current_result).and_return(nil)

      post :create, :s3_key => 'key'
      response.should redirect_to new_mass_param_path
      # flash[:notice].should == "test_data.xml was successfully uploaded."
    end

    it "should not accept an empty file" do
      # fake_data = mock('MassData', :title => 'test_data.xml')
      # MassData.stub(:create!).with({:file => @dataxml}).and_return(fake_data)
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      
      post :create, :s3_key => nil
      response.should redirect_to new_mass_datum_path
      flash[:warning].should == "No file input."
    end

    it "can update an existing result" do
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      user.stub(:id).and_return(1)

      result = Result.create(:user_id => 1, :mass_params_id => 1)
      user.stub(:current_result).and_return(result)
      result.should_receive(:mass_data_id)

      post :create, :s3_key => 'key'
      response.should redirect_to new_mass_param_path
    end

    it "should not accept nonexisting ids" do
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      
      post :update_choice, :data_id => 100
      response.should redirect_to choose_data_path
      flash[:warning].should == "Please choose an existing .zxml file."
    end
    #it "should not accept an empty email" do
    #  # fake_data = mock('MassData', :title => 'test_data.xml')
    #  # MassData.stub(:create!).with({:file => @dataxml}).and_return(fake_data)
    #  post :upload, :xml_file => @dataxml, :email => ""
    #  response.should redirect_to new_mass_datum_path
    #  flash[:warning].should == "No email input."
    #end



  #  it "should not upload a non xml file" do
  #    MassData.stub(:create!).with({:file => @dataother})
  #    post :uploadData, :upload => @dataother
  #    response.should redirect_to new_mass_datum_path
  #    flash[:notice].should == "test_data.txt is not a xml file."
  #  end
  end

end
