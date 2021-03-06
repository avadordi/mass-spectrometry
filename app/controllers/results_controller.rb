class ResultsController < ApplicationController
  before_filter :authenticate_user!

  def finish
    # final results
    if !current_user.current_result
      #error
      flash[:warning] = "Please upload files to run."
    elsif
      if !current_user.current_result.mass_params_id || !current_user.current_result.mass_data_id
        #error
        flash[:warning] = "Please upload files to run."
      else
        #start ssh session in background
        current_user.current_result.delay.start_ssh
        flash[:notice] = "Tag finder is successfully running. You will be able to download the results from the uploads page when your analysis is complete."
        current_user.current_result.set_as_run
      end
    end
    redirect_to finish_index_path
  end

  def index

  end

  def review
   # "review and run"
   current_result = current_user.current_result
   @message = "Please upload files before running."
   if !current_result
     flash[:warning] = "No files have been uploaded."
     @disabled = true
   elsif !current_result.mass_params_id
       flash[:warning] = "One of the files has not been uploaded."
       @message = "Please select a parameters file."
       @disabled = true
   elsif !current_result.mass_data_id
       flash[:warning] = "One of the files has not been uploaded."
       @message = "Please select a data .mzXML file."
       @disabled = true
   else
       @message = "Data: #{current_result.get_mass_data.get_title}\n\n Parameters: #{current_result.get_mass_params.get_title}"
   end
  end
end
