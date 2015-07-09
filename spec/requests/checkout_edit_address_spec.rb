require 'spec_helper'

describe "User editing saved address during checkout", :js => true do
  include_context "store products"
  include_context "checkout with product"
  include_context "user with address"

  before(:each) { sign_in!(user); visit spree.checkout_state_path('address') }

  it "can update billing address" do
    within("#billing #billing_address_#{address.id}") do
      click_link "Edit"
    end
    expect(current_path).to eq(spree.edit_address_path(address))
    new_street = FFaker::Address.street_address
    fill_in I18n.t('activerecord.attributes.spree/address.address1'), :with => new_street
    click_button "Update"
    expect(current_path).to eq(spree.checkout_state_path('address'))
    within("h1") { expect(page).to have_content("Checkout") }
    within("#billing") do
      expect(page).to have_content(new_street)
    end
  end

  it "can update shipping address", :js => true do
    uncheck 'order_use_billing'
    within("#shipping #shipping_address_#{address.id}") do
      click_link "Edit"
    end
    expect(current_path).to eq(spree.edit_address_path(address))
    new_street = FFaker::Address.street_address
    fill_in I18n.t('activerecord.attributes.spree/address.address1'), :with => new_street
    click_button "Update"
    expect(current_path).to eq(spree.checkout_state_path('address'))
    within("h1") { expect(page).to have_content("Checkout") }
    within("#shipping") do
      expect(page).to have_content(new_street)
    end
  end
end
