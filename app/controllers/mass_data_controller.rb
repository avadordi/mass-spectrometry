class MassDataController < ApplicationController
  before_filter :authenticate_user!
  def create
    if params[:s3_key].nil?
      flash[:warning] = "No file input."
      redirect_to new_mass_datum_path
    else
      mass_datum = MassDatum.create(:s3id => params[:s3_key], :user_id => current_user.id)
      current_result = current_user.current_result
      if current_result
        current_result.mass_data_id = mass_datum.id
        current_result.save
      else
        Result.create(:mass_data_id => mass_datum.id, :user_id => current_user.id, :flag => false)
      end
      redirect_to new_mass_param_path
    end
  end

  def new
    @disabled_page = true
    current_result = current_user.current_result
    current_mass_data = if current_result then current_result.get_mass_data else nil end
    if current_result && current_mass_data
      @message = "You have already uploaded #{current_mass_data.get_title}."
      #@message = "#{current_result.get_mass_data.s3id}"
    else
      @message = "Please choose a .zxml file to upload."
    end
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201)
    @mass_datum = MassDatum.new
  end

  def choose
    @all_data = MassDatum.where(:user_id => current_user.id)
    @disabled_page = true
    @results = current_user.results
    current_result = current_user.current_result
    current_mass_data = if current_result then current_result.get_mass_data else nil end
    if current_result && current_mass_data
      @message = "You have already uploaded #{current_mass_data.get_title}."
      #@message = "#{current_result.get_mass_data.s3id}"
    else
      @message = "Please choose a file to upload."
    end
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201)
    @mass_datum = MassDatum.new
  end

  def update_choice
    data = MassDatum.find(params[:data_id])
    if !data
      flash[:warning] = "Please choose an existing .zxml file."
      return redirect_to choose_data_path
    end
    current_result = current_user.current_result
    if current_result
      current_result.mass_data_id = params[:data_id]
      current_result.save
    else
      Result.create(:mass_data_id => params[:data_id], :user_id => current_user.id, :flag => false)
    end
    redirect_to new_mass_param_path
  end
end
