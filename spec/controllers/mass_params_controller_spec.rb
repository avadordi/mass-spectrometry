require 'spec_helper'

describe MassParamsController do

  before :each do
    @dataxml = fixture_file_upload('/files/test_data.xml', 'text/xml')
    @email = "example@example.com"
    @paramsxml = fixture_file_upload('/files/test_params.txt', 'text/xml')
    #@dataother = fixture_file_upload('/files/test_data.txt', 'text/txt')
    #@paramsother = fixture_file_upload('/files/test_params.bad.txt', 'text/txt')
  end

  describe 'upload a mass data' do
    it "can upload a param file" do
      # fake_data = mock('MassData', :title => 'test_data.xml')
      # MassData.stub(:create!).with({:file => @dataxml}).and_return(fake_data)
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      user.stub(:id).and_return(1)

      result2 = Result.create(:user_id => 1)
      user.stub(:current_result).and_return(result2)

      post :create, :s3_key => 'key'
      response.should redirect_to review_path
    end

    it "should not accept an empty file" do
      # fake_data = mock('MassData', :title => 'test_data.xml')
      # MassData.stub(:create!).with({:file => @dataxml}).and_return(fake_data)
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }

      post :create, :s3_key => nil, :email => @email
      response.should redirect_to new_mass_param_path
      flash[:warning].should == "No file input."
    end

    it "should create a new result result if necessary" do
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      user.stub(:id).and_return(1)
      user.should_receive(:current_result).and_return(nil)
      Result.should_receive(:create)

      post :create, :s3_key => 'key'
      response.should redirect_to review_path
    end

    it "should not accept nonexisting ids" do
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }
      
      post :update_params, :data_id => 100
      response.should redirect_to choose_params_path
      flash[:warning].should == "Please choose an existing params file."
    end

  #  it "should not upload a non xml file" do
  #    MassData.stub(:create!).with({:file => @dataother})
  #    post :uploadData, :upload => @dataother
  #    response.should redirect_to new_mass_datum_path
  #    flash[:notice].should == "test_data.txt is not a xml file."
  #  end
  end
  
   describe 'fill out parameters form' do
    it "can generate the correct .params file" do
      user = double('user')
      allow(request.env['warden']).to receive(:authenticate!) { user }
      allow(controller).to receive(:current_user) { user }

      params = {:file => {:filename => 'test_form', :charge_min => '1', :charge_max => '5', :mz_tolerance => '0.01', :mz_tolerance_2 => '0.005', :scan_tolerance => '10', :pattern_size => '5', :min_score => '1', :retention_time_window => '2.0', :include_mass_mod => '2.0', :sigma => '0.0', :per_sigma => '0.085', :log_file => 'ms_searching', :search_pattern => 'pattern=0.25, 0.0, 0.5, 0.0, 0.25; mw=500; prior=0.0001', :alt_pattern => 'pattern=1; mw=0; prior=1;', :full_output => 'ture', :inclusion_list => 'false', :mz_charge => 'true', :mz_charge_scan => 'true'}, :alt_pattern_more => "pattern=0.1, 0.5, 0.25; mw=300; prior=0.0001\npattern=1, 1, 1, 1, 1, 1, 1; mw=10000; prior=0.001"}
      content = "charge_min: 1\ncharge_max: 5\nmz_tolerance: 0.01\nmz_tolerance_2: 0.005\nscan_tolerance: 10\npattern_size: 5\nmin_score: 1\nretention_time_window: 2.0\ninclude_mass_mod: 2.0\nsigma: 0.0\nper_sigma: 0.085\nlog_file: ms_searching.log\nsearch_pattern: pattern=0.25, 0.0, 0.5, 0.0, 0.25; mw=500; prior=0.0001\nalt_pattern: pattern=1; mw=0; prior=1;\nalt_pattern: pattern=0.1, 0.5, 0.25; mw=300; prior=0.0001\nalt_pattern: pattern=1, 1, 1, 1, 1, 1, 1; mw=10000; prior=0.001\nfull_output: ture\ninclusion_list: false\nmz_charge: true\nmz_charge_scan: true\n"
      controller.should_receive(:send_data).with(content, :filename => 'test_form.params', :disposition => "attachment").and_return { @controller.render nothing: true } 
      put :new_file, params
    end
  end
end
