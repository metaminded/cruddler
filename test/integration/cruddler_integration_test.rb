require 'test_helper'

class CruddlerIntegrationTest < ActionDispatch::IntegrationTest

  test "Basic CRUD" do
    # INDEX
    visit '/houses'
    assert page.has_content?('No Houses')

    # CREATE
    click_link 'Create'
    assert_equal '/houses/new', current_path
    fill_in 'house_name', with: "First House"
    fill_in 'house_number', with: '1'
    click_button 'Create House'

    # INDEX, again
    assert_equal '/houses', current_path
    assert page.has_content?('First House')
    assert !page.has_content?('No Houses')

    # SHOW
    click_link 'Show'
    assert page.has_content?('First House')
    click_link 'Abort'
    assert_equal '/houses', current_path

    # EDIT
    click_link 'Edit'
    #assert page.has_content?('FancyGallery')
    fill_in 'house_name', with: "Another House"
    click_button 'Update House'

    # INDEX, again
    assert_equal '/houses', current_path
    assert !page.has_content?('First House')
    assert page.has_content?('Another House')

    # DESTROY
    click_link "Destroy"
    assert_equal '/houses', current_path
    assert page.has_content?('No Houses')
  end

  test "Nested has_many CRUD" do
    house = House.create!(name: 'Cat House', number: 666)

    # INDEX
    visit "/houses/#{house.id}/cats"
    assert page.has_content?('No Cats')

    # CREATE
    click_link 'Create'
    assert_equal "/houses/#{house.id}/cats/new", current_path
    fill_in 'cat_name', with: "Sheldon"
    click_button 'Create Cat'

    # INDEX, again
    assert_equal "/houses/#{house.id}/cats", current_path
    assert page.has_content?('Cat House')
    assert page.has_content?('Sheldon')

    # SHOW
    click_link 'Show'
    assert_equal "/houses/#{house.id}/cats/#{house.cats.first.id}", current_path
    assert page.has_content?('Sheldon')
    assert page.has_content?('Cat House')
    click_link 'Abort'
    assert_equal "/houses/#{house.id}/cats", current_path

    # EDIT
    click_link 'Edit'
    assert_equal "/houses/#{house.id}/cats/#{house.cats.first.id}/edit", current_path
    fill_in 'cat_name', with: "Lennard"
    click_button 'Update Cat'

    # INDEX, again
    assert !page.has_content?('Sheldon')
    assert page.has_content?('Lennard')

    # DESTROY
    click_link "Destroy"
    assert_equal "/houses/#{house.id}/cats", current_path
    assert page.has_content?('No Cats')
  end

  test "Nested polymorphic has_many CRUD" do
    house = House.create!(name: 'Dog House', number: 666)

    # INDEX
    visit "/houses/#{house.id}/dogs"
    assert page.has_content?('No Dogs')

    # CREATE
    click_link 'Create'
    assert_equal "/houses/#{house.id}/dogs/new", current_path
    fill_in 'dog_name', with: "Waldi"
    click_button 'Create Dog'

    # INDEX, again
    assert_equal "/houses/#{house.id}/dogs", current_path
    assert page.has_content?('Dog House')
    assert page.has_content?('Waldi')

    # SHOW
    click_link 'Show'
    assert_equal "/houses/#{house.id}/dogs/#{house.dogs.first.id}", current_path
    assert page.has_content?('Waldi')
    assert page.has_content?('Dog House')
    click_link 'Abort'
    assert_equal "/houses/#{house.id}/edit", current_path

    # EDIT
    visit "/houses/#{house.id}/dogs"
    click_link 'Edit'
    assert_equal "/houses/#{house.id}/dogs/#{house.dogs.first.id}/edit", current_path
    fill_in 'dog_name', with: "Fifi"
    click_button 'Update Dog'

    # INDEX, again
    assert !page.has_content?('Waldi')
    assert page.has_content?('Fifi')

    # DESTROY
    click_link "Destroy"
    assert_equal "/houses/#{house.id}/dogs", current_path
    assert page.has_content?('No Dogs')
  end
   # save_and_open_page

end
