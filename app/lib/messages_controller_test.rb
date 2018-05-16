require "test_helper"
feature "MessagesControllerTest" do
  include SignInHelper, MiscHelper

  setup do
    @active_program = programs(:active_program)
    @coach = coaches(:coach_steve_w)
  end

  scenario 'Index' do
    coach_log_in_as(email: @coach.email, password: 'BlueBird22')
    visit '/messages'
    expect(page).must_have_content('Jane Doe')
  end

  scenario 'Index - Unauthenticated' do
    visit '/messages'
    expect(page)
      .must_have_content('You need to sign in or sign up before continuing.')
  end


  scenario 'As a coch: Send a messsagee to participant' do
    coach_log_in_as(email: @coach.email, password: 'BlueBird22')
    visit '/messages/2'
    within('form#new_message') do
      fill_in(
        'message_content',
        with: 'This is a test message'
      )
      click_button 'Send'
    end
    expect(page).must_have_content('This is a test message')
  end

  scenario 'show' do
    coach_log_in_as(email: @coach.email, password: 'BlueBird22')
    visit '/messages/2'
    expect(page).must_have_content('Jane Doe')
  end

end
