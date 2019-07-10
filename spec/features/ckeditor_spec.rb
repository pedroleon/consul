require "rails_helper"

describe "CKEditor" do

  scenario "is present before & after turbolinks update page", :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    within(".translatable-fields[data-locale='en']") do
      expect(page).to have_css ".cke_textarea_inline[aria-label*='debate'][aria-label*='description']"
    end

    click_link "Debates"
    click_link "Start a debate"

    within(".translatable-fields[data-locale='en']") do
      expect(page).to have_css ".cke_textarea_inline[aria-label*='debate'][aria-label*='description']"
    end
  end

end
