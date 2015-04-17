class MassParamsController < ApplicationController
  before_filter :authenticate_user!
  def create
    if params[:s3_key].nil?
      flash[:warning] = "No file input."
      redirect_to new_mass_param_path
    else
      mass_param = MassParam.create(:s3id => params[:s3_key], :user_id => current_user.id)
      debugger
      if current_user.current_result
        result = current_user.current_result
        result.mass_params_id = mass_param.id
        result.save
      else
        result = Result.create(:mass_params_id => mass_param.id, :user_id => current_user.id, :flag => false)
      end
      redirect_to review_path
    end
  end

  def new
    current_result = current_user.current_result
    current_mass_params = if current_result then current_result.get_mass_params end
    if current_result && current_mass_params
      @message = "You have already uploaded #{current_mass_params.get_title}."
    else
      @message = "Please choose a .txt or .params file to upload."
    end
    @s3_direct_post = S3_BUCKET.presigned_post(key: "params/#{current_user.id}/${filename}", success_action_status: 201)
    @mass_param = MassParam.new
  end
  
  def new_file
    fields = ['charge_min', 'charge_max', 'mz_tolerance', 'mz_tolerance_2', 'scan_tolerance', 'pattern_size', 'min_score', 'retention_time_window', 'include_mass_mod', 'sigma', 'per_sigma', 'log_file', 'search_pattern', 'alt_pattern']
		selects = ['full_output', 'inclusion_list', 'mz_charge', 'mz_charge_scan']
		patterns_more = params['alt_pattern_more']
    file = params[:file]
    filename = file[:filename]
    contents = ""
    fields.each { |f| contents = contents + f + ": " + file[f] + "\n" if !file[f].empty?}
		patterns_more.each_line {|p| contents = contents + "alt_pattern: " + p}
		contents = contents + "\n" unless contents[-1] === "\n"
		selects.each { |s| contents = contents + s + ": " + file[s] + "\n" }
    send_data(contents, :filename => filename, :disposition => "attachment")
  end

end
