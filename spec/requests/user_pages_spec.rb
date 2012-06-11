require 'spec_helper'

describe "UserPages" do
  subject { page }
 

  describe "Signup page" do
  	before { visit signup_path }
  	let(:submit) { "Create my account" }
    
    it { should have_selector('h1', :text => 'Sign up') }
    
    it { should have_selector('title', :text => full_title('Sign up')) }
    
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
         valid_signup
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
      
    end
  end

  describe "follow/unfollow buttons" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      before { visit signin_path
               sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end

      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: 'Follow') }
        end
      end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    #let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    #let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }
    before(:all) { 50.times { |n| FactoryGirl.create(:micropost, user: user, content: "Foo#{n}") } }
    after(:all)  { user.microposts.delete_all }
    
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }

    #describe "microposts" do
    #  it { should have_content(m1.content) }
    #  it { should have_content(m2.content) }
    #  it { should have_content(user.microposts.count) }
    #end

    describe "microposts count" do
      it { should have_content(user.microposts.count) }
      it { should have_content('Microposts') }
     
    end 
    describe "pagination" do

      it { should have_selector('div.pagination') }

      it "should list each micropost" do
        user.microposts.paginate(page: 1).each do |micropost|
          page.should have_content(micropost.content)
        end
      end
    end

    describe "should not show delete links for micpoposts other than the current users" do
         let(:user2) { FactoryGirl.create(:user) }
        let!(:m1) { FactoryGirl.create(:micropost, user: user2, content: "Foo") }
        let!(:m2) { FactoryGirl.create(:micropost, user: user2, content: "Bar") }
      before {
        
        visit user_path(user)
      }
  
      it { should_not have_link('delete', title:m1.content) }
      it { should_not have_link('delete', title:m2.content) }
      
    end

  end


  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit signin_path
             sign_in user
             visit edit_user_path(user) }

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password",     with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end

  end

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }

    before(:each) do
      visit signin_path
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          visit signin_path
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }

        describe "should not be able to delete himself" do
          usersbef = User.count
          before { delete user_path(admin) }
          specify { response.should redirect_to(users_path) } 
          usersaft = User.count
          usersbef.should == usersaft
        end
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { visit signin_path 
               sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }        
      end
    end

  end


  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        visit signin_path
        sign_in user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        visit signin_path
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end


end
