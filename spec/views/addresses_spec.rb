RSpec.describe 'spree/addresses/new', type: :view do
  let(:address) { FactoryGirl.build(:address) }

  it 'renders new.html.erb for new address' do
    assign(:address, address)
    render :template => 'spree/addresses/new', :address => address

    expect(rendered).to have_content('New Shipping Address')

    expect(rendered).to have_field('First Name', :type => 'text')
    expect(rendered).to have_field('Last Name', :type => 'text')
    expect(rendered).to have_field(Spree.t(:street_address), :type => 'text')
    expect(rendered).to have_field(Spree.t(:street_address_2), :type => 'text')
    # Javascript can't be tested in views spec
    expect(rendered).to have_selector('select#address_country_id')
    # Javascript can't be tested in views spec
    expect(rendered).to have_selector('#address_state_name')
    expect(rendered).to have_field('City', :type => 'text')
    expect(rendered).to have_field('Zip', :type => 'text')
    expect(rendered).to have_field('Phone', :type => 'tel')
  end

end

RSpec.describe 'spree/addresses/edit', type: :view do
  let(:address) { FactoryGirl.create(:address) }

  it 'renders edit.html.erb for editing an existing address' do
    assign(:address, address)
    render :template => 'spree/addresses/edit', :address => address

    expect(rendered).to have_field('First Name', :with => address.firstname, :type => 'text')
    expect(rendered).to have_field('Last Name', :with => address.lastname, :type => 'text')
    expect(rendered).to have_field(Spree.t(:street_address), :with => address.address1, :type => 'text')
    expect(rendered).to have_field(Spree.t(:street_address_2), :with => address.address2, :type => 'text')
    # Javascript can't be tested in views spec
    expect(rendered).to have_selector('select#address_country_id')
    # Javascript can't be tested in views spec
    expect(rendered).to have_selector('#address_state_name')
    expect(rendered).to have_field('City', :with => address.city, :type => 'text')
    expect(rendered).to have_field('Zip', :with => address.zipcode, :type => 'text')
    expect(rendered).to have_field('Phone', :with => address.phone, :type => 'tel')
  end
end


# a few methods to deal with problems in the views, due to the usage of form_for @address.
def address_path(address, format)
  return spree.address_path(address, format)
end

def addresses_path(format)
  return spree.addresses_path(format)
end

def countries_url(*args)
  spree.countries_url(*args)
end

def states_url(*args)
  spree.states_url(*args)
end

# I'm not sure why this method isn't available, or how to make it available, so
# I've cloned it from Spree::BaseHelper.
def available_countries
  countries = Spree::Zone.find_by_name(Spree::Config[:checkout_zone]).try(:country_list) || Spree::Country.all
  countries.collect do |c|
    c.name = t(c.name, :scope => 'countries', :default => c.name)
    c
  end.sort{ |a,b| a.name <=> b.name }
end
