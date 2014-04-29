module DeviseController
  def login(frequency = :each)
    before(frequency) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user)
      @user.confirm!
      sign_in @user 
    end
  end
end

