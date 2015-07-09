shared_context "checkout with product" do
  before :each do
    FactoryGirl.create :store
    @state = Spree::State.all.first || FactoryGirl.create(:state)
    @zone = Spree::Zone.find_by_name('GlobalZone') || FactoryGirl.create(:global_zone)
    @zone.states << @state
    @shipping = Spree::ShippingMethod.find_by_name('UPS Ground') || FactoryGirl.create(:shipping_method)

    FactoryGirl.create(:check_payment_method)
    reset_spree_preferences do |config|
      config.company = true
      config.alternative_billing_phone = false
      config.alternative_shipping_phone = false
    end

    visit spree.root_path
    click_link 'Ruby on Rails Mug'
    click_button 'add-to-cart-button'
  end

  let(:state) { @state }

  private

  def should_have_address_fields
    expect(page).to have_field("First Name")
    expect(page).to have_field("Last Name")
    expect(page).to have_field(I18n.t('activerecord.attributes.spree/address.address1'))
    expect(page).to have_field("City")
    expect(page).to have_field("Country")
    expect(page).to have_field("Zip")
    expect(page).to have_field(I18n.t('activerecord.attributes.spree/address.phone'))
  end

  def complete_checkout
    click_button Spree.t(:save_and_continue)
    choose "UPS Ground"
    click_button Spree.t(:save_and_continue)
    choose "Check"
    click_button Spree.t(:save_and_continue)
  end

  def fill_in_address(address, type = :bill)
    fill_in "First Name", :with => address.firstname
    fill_in "Last Name", :with => address.lastname
    fill_in "Company", :with => address.company if Spree::Config[:company]
    fill_in I18n.t('activerecord.attributes.spree/address.address1'), :with => address.address1
    fill_in I18n.t('activerecord.attributes.spree/address.address2'), :with => address.address2
    select address.state.name, :from => "order_#{type}_address_attributes_state_id"
    fill_in "City", :with => address.city
    fill_in I18n.t('activerecord.attributes.spree/address.zipcode'), :with => address.zipcode
    fill_in I18n.t('activerecord.attributes.spree/address.phone'), :with => address.phone
    fill_in 'Alternative phone', :with => address.alternative_phone if Spree::Config[:alternative_billing_phone]
  end

  def expected_address_format(address)
    [
      "#{address.firstname} #{address.lastname}",
      address.company.to_s,
      address.address1.to_s,
      address.address2.to_s,
      "#{address.city} #{address.state ? address.state.abbr : address.state_name} #{address.zipcode}",
      address.country.to_s
    ].reject(&:empty?).join(" ")
  end
end
