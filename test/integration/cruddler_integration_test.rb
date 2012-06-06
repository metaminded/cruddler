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

    %w{Moritz Klara Finka Willi}.each do |nam|
      visit "/houses/#{house.id}/cats"

      # CREATE
      click_link 'Create'
      assert_equal "/houses/#{house.id}/cats/new", current_path
      fill_in 'cat_name', with: nam
      click_button 'Create Cat'

      # INDEX, again
      assert_equal "/houses/#{house.id}/cats", current_path
      assert page.has_content?('Cat House')
      assert page.has_content?(nam)
    end

    house.cats.each do |cat|
      visit "/houses/#{house.id}/cats/#{cat.id}/edit"
      fill_in 'cat_name', with: "Moo#{cat.name}"
      click_button 'Update Cat'
      assert_equal "/houses/#{house.id}/cats", current_path
      assert page.has_content?("Moo#{cat.name}")
    end
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

    %w{Wau Bello Hasso Brain}.each do |nam|
      visit "/houses/#{house.id}/dogs"

      # CREATE
      click_link 'Create'
      assert_equal "/houses/#{house.id}/dogs/new", current_path
      fill_in 'dog_name', with: nam
      click_button 'Create Dog'

      # INDEX, again
      assert_equal "/houses/#{house.id}/dogs", current_path
      assert page.has_content?('Dog House')
      assert page.has_content?(nam)
    end

    house.dogs.each do |dog|
      visit "/houses/#{house.id}/dogs/#{dog.id}/edit"
      fill_in 'dog_name', with: "Moo#{dog.name}"
      click_button 'Update Dog'
      assert_equal "/houses/#{house.id}/dogs", current_path
      assert page.has_content?("Moo#{dog.name}")
    end

     # save_and_open_page
  end

  test "Double Nested has_many CRUD" do
    house = House.create!(name: 'Cat House', number: 666)
    cat = Cat.new(name: 'Mouw')
    cat.house = house
    cat.save!

    prefix = "/houses/#{house.id}/cats/#{cat.id}"

    # INDEX
    visit "#{prefix}/parasites"
    assert page.has_content?('No Parasites')

    # CREATE
    click_link 'Create'
    assert_equal "#{prefix}/parasites/new", current_path
    fill_in 'parasite_name', with: "Sucker"
    click_button 'Create Parasite'

    # INDEX, again
    assert_equal "#{prefix}/parasites", current_path
    assert page.has_content?('Cat House')
    assert page.has_content?('Mouw')
    assert page.has_content?('Sucker')

    # SHOW
    click_link 'Show'
    assert_equal "#{prefix}/parasites/#{cat.parasites.first.id}", current_path
    assert page.has_content?('Sucker')
    assert page.has_content?('Mouw')
    assert page.has_content?('Cat House')
    click_link 'Abort'
    assert_equal "#{prefix}/parasites", current_path

    # EDIT
    click_link 'Edit'
    assert_equal "#{prefix}/parasites/#{cat.parasites.first.id}/edit", current_path
    fill_in 'parasite_name', with: "Vampire"
    click_button 'Update Parasite'

    # INDEX, again
    assert !page.has_content?('Sucker')
    assert page.has_content?('Vampire')

    # DESTROY
    click_link "Destroy"
    assert_equal "#{prefix}/parasites", current_path
    assert page.has_content?('No Parasites')

    %w{Moritz Klara Finka Willi}.each do |nam|
      visit "#{prefix}/parasites"

      # CREATE
      click_link 'Create'
      assert_equal "#{prefix}/parasites/new", current_path
      fill_in 'parasite_name', with: nam
      click_button 'Create Parasite'

      # INDEX, again
      assert_equal "#{prefix}/parasites", current_path
      assert page.has_content?('Cat House')
      assert page.has_content?(nam)
    end

    cat.parasites.each.with_index do |parasite, i|
      visit "#{prefix}/parasites/#{parasite.id}/edit"
      fill_in 'parasite_name', with: "Moo#{parasite.name}"
      fill_in 'parasite_legs', with: 3*i+1
      click_button 'Update Parasite'
      assert_equal "#{prefix}/parasites", current_path
      assert page.has_content?("Moo#{parasite.name}")
      assert page.has_content?("#{3*i+1}")
    end
  end


end
