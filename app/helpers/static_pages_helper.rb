module StaticPagesHelper

  def home
    @micropost = current_user.microposts.build if signed_in?
  end

end
