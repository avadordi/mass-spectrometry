require 'spec_helper'

describe Result do
  describe "SSH Access" do
    
    it "should send correct commands to the connection" do
      ssh_connection = mock("SSH Connection")
      Net::SSH.stub(:start).and_yield(ssh_connection)
      ssh_connection.should_receive(:exec!).with("echo 'Graph search is successfully running. You will receive an email when your analysis is complete.'")
      Result.start_ssh
    end
  end

  describe "Getting Related Files" do
    before :each do
      @mass_datum = MassDatum.create(:s3id => "uploads/21998eeb-ed54-4914-9844-7a4b94008985/mass_data.xml", :user_id => 1)
      @mass_param = MassParam.create(:s3id => "uploads/21998eeb-ed54-4914-9844-7a4c2400800f/mass_param.txt", :user_id => 1)
      @mass_result  = Result.create(:mass_data_id => @mass_datum.id, :mass_params_id => @mass_param.id, :user_id => 1)
    end
    it "should return the proper data file" do
      @mass_result.get_mass_data.should == @mass_datum
    end

    it "should return the proper param file" do
      @mass_result.get_mass_params.should == @mass_param
    end
  end

  describe "Failing to Get Related Files" do
    before :each do
      @mass_result  = Result.create(:user_id => 1)
    end
    it "should return nil if no data file" do
      @mass_result.get_mass_data.should == nil
    end
    it "should return nil if no params file" do
      @mass_result.get_mass_params.should == nil
    end
  end
end
