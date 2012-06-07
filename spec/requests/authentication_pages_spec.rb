require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "Signin page" do

  	before { visit signin_path }
  	let(:submit_button) { "Sign in" }

  	describe "shoulh have h1 'Sign in'" do
    	it { should have_selector('h1', :text => 'Sign in') }
    end
    describe "shoulh have title 'Sign in'" do
    	it { should have_selector('title', :text => full_title('Sign in')) }
    end


    describe "with empty information" do
    	#it "should not create a session" do
    	#	expect { click_button submit_button }.not_to change(Session, :count)
    	#end
    	before { click_button "Sign in" }

        it "should lead to the same page" do
         	page.should have_selector('title', text: 'Sign in')
        end 
        it "should show error message" do 
        	page.should have_selector('div.alert.alert-error', text: 'Invalid') 
        end

        describe "after visiting another page" do
        	before { click_link "Home" }
        	it { should_not have_selector('div.alert.alert-error') }
     	 end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email
        fill_in "Password", with: user.password
        click_button submit_button
      end

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end

    #describe "with invalid email information" do
    #	it "should not create a session" do
    #		invalid_emails = ["plain text","many@email@symbols","no.valid@email_ending"]
    #		invalid_emails.each do |mail|
    #			before do
    #				fill_in "Email", with: mail
    #				fill_in "Password", with:"foobar"
    #			end
    #			expect { click_button submit_button }.not_to change(Session, :count) 
    #		end
    #	end
    #end

    #describe "with invalid password information" do
    #	it "should not create a session" do
    #		invalid_emails = ["plain text","many@email@symbols","no.valid@email_ending"]
    #		invalid_emails.each do |mail|
    #			before do
    #				fill_in "Email", with: "valid@email.com"
    #				fill_in "Password", with:"a"*7
    #			end
    #			expect { click_button submit_button }.not_to change(Session, :count) 
    #		end
    #	end
    #end

    #describe "with wrong combination of email and password" do
    #	before { @us1 = User.new(:name => "Test User 1", :email => "testuser1@test.com", 
    #								 :password => "testuser1", :password_confirmation => "testuser1") 
    #			 @us2 = User.new(:name => "Test User 2", :email => "testuser2@test.com", 
    #								 :password => "testuser2", :password_confirmation => "testuser2")
    #			fill_in "Email", with: @us1.email
    #			fill_in "Password", with: @us2.password }	
    #	
    #	it "should not create a session" do	
    #		expect { click_button submit_button }.not_to change(Session, :count) 
    #	end

    #	it "should show error message" do
    #		page.should have_selector('h1', :text => 'Sign in')
    #		page.should have_selector('div.alert.alert-error', text: 'Invalid')
    #	end
    #end
    
  end

end
