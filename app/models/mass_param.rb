class MassParam < ActiveRecord::Base
  has_many :results
  belongs_to :user

  attr_accessible :title, :s3id, :user_id

  def get_title
    t = /.*\/(.*)$/.match(s3id)
    return t.captures[0]
  end

  def self.get_param_or_nil(id)
    begin
      return MassParam.find(id)
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

end
