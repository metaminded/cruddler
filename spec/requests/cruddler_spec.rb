require 'spec_helper'

describe "Cruddler" do
  
  vendor1 = Vendor.create!(:name => "ven d'or", :active => true)
  vendor2 = Vendor.create!(:name => 'producer', :active => true)
  tag1 = Tag.create!(:title => 'foo')
  tag2 = Tag.create!(:title => 'bar')
  tag3 = Tag.create!(:title => 'fubar')
  ids = []

  describe "General data" do

    it "contains the actual data" do
      product = Product.create!(:title => "Eierkarton", :active => true, :price => 10.0, :description => 'blah blah')
      visit admin_products_path
      page.should have_content("Eierkarton")
      page.should have_content("true")
      page.should have_content("10,0")
      visit new_admin_product_path()
      fill_in('product_title', with: "Zweierkarton")
      fill_in('product_price', with: "9.70")
      fill_in('product_description', with: 'Zweier Karton lorem Ipsum!')
      click_button("Create Product")
      page.should have_content("Zweierkarton")
      visit edit_admin_product_path(product)
      fill_in('product_price', with: "4.30")
      click_button("Update Product")
      page.should have_content("4,3")
    end 

  #   it "correctly contains the association data" do
  #     product = Product.first
  #     [tag1, tag2, tag3].each_with_index do |tag, i|
  #       product.tags << tag
  #       visit index_simple_products_path
  #       page.should have_content tag.title
  #       page.should have_content(sprintf("--%d--", i+1))
  #     end
  #   end if CONTAINS_ASSOC_DATA
  # 
  #   it "contains the actual data multiple" do
  #     9.times do |i|
  #       product = Product.create!(:title => names[i+1], :active => i.even?, :price => 11.0+i,
  #         :description => "blah blah #{i}", :vendor => i.even? ? vendor1 : vendor2)
  #       ids << product.id
  #       visit index_simple_products_path
  #       page.should have_content(names[i])
  #       page.should have_content((11.0+i).to_s)
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], i+2, i+2, 0, i+2))
  #     end
  #   end if CONTAINS_ACTUAL_DATA_MULTIPLE
  # 
  #   it "contains row identifiers" do
  #     visit index_simple_products_path
  #     Product.all.each do |product|
  #       page.should have_css("#product_#{product.id}")
  #     end
  #   end if CONTAINS_ACTUAL_DATA
  # 
  #   it "contains the further data on the further pages" do
  #     names[10..-1].each_with_index do |n,i|
  #       product = Product.create!(:title => n, :active => i.even?, :price => 20.0+i,
  #         :description => "blah blah #{i}", :vendor => i.even? ? vendor1 : vendor2)
  #       ids << product.id
  #       visit index_simple_products_path
  #       page.should_not have_content(n)
  #       page.should_not have_content((30.0+i).to_s)
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, i+11, 0, i+11))
  #     end
  #   end if CONTAINS_DATA_ON_FURTHER_PAGES
  # end
  # 
  # describe "Pagination" do
  #   it "pages up and down" do
  #     visit index_simple_products_path
  #     k = 1+names.length/10
  #     k.times do |i|
  #       ((i*10)...[names.length, ((i+1)*10)].min).each do |j|
  #         page.should have_content(names[j])
  #       end
  #       if i==0
  #         page.should have_no_button('product_pagination_page_left')
  #       else
  #         page.should have_button('product_pagination_page_left')
  #       end
  #       if i==k-1
  #         page.should have_no_button('product_pagination_page_right')
  #       else
  #         page.should have_button('product_pagination_page_right')
  #         click_button('product_pagination_page_right')
  #       end
  #     end
  #     # ...and down
  #     k.times do |ii|
  #       i = k-ii-1
  #       ((i*10)...[names.length, ((i+1)*10)].min).each do |j|
  #         page.should have_content(names[j])
  #       end
  #       if i==k-1
  #         page.should have_no_button('product_pagination_page_right')
  #       else
  #         page.should have_button('product_pagination_page_right')
  #       end
  #       if i==0
  #         page.should have_no_button('product_pagination_page_left')
  #       else
  #         page.should have_button('product_pagination_page_left')
  #         click_button('product_pagination_page_left')
  #       end
  #     end
  #   end if PAGES_UP_AND_DOWN
  # 
  #   it "jumps to the correct page" do
  #     visit index_simple_products_path
  #     k = 1+names.length/10
  #     l = (1..k).entries.shuffle
  #     l.each do |ii|
  #       i = ii-1
  #       fill_in("product_pagination[page]", :with => ii.to_s)
  #       click_button("Apply")
  #       ((i*10)...[names.length, ((i+1)*10)].min).each do |j|
  #         page.should have_content(names[j])
  #       end
  #       if i==0
  #         page.should have_no_button('product_pagination_page_left')
  #       else
  #         page.should have_button('product_pagination_page_left')
  #       end
  #       if i==k-1
  #         page.should have_no_button('product_pagination_page_right')
  #       else
  #         page.should have_button('product_pagination_page_right')
  #       end
  #     end
  #   end if JUMPS_TO_CORRECT_PAGE
  # 
  #   it "changes the page size" do
  #     visit index_simple_products_path
  #     [50,20,10].each do |s|
  #       select s.to_s, :from => "product_pagination[pagesize]"
  #       click_button "Apply"
  #       s.times do |i|
  #         page.should have_content(names[i])
  #       end
  #       page.should_not have_content(names[s])
  #     end
  #   end if CHANGES_PAGE_SIZE
  # end
  # 
  # describe "Filters" do
  #   it "filters" do
  #     visit index_simple_products_path
  #     #save_and_open_page
  #     fill_in("product_filter[title]", :with => "lorem")
  #     click_button("Apply")
  #     page.should have_content("lorem")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 1, names.length, 0, 1))
  #     fill_in("product_filter[title]", :with => "loreem")
  #     click_button("Apply")
  #     page.should_not have_content("lorem")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 0, names.length, 0, 0))
  #   end if FILTERS
  # 
  #   it "filters with like" do
  #     visit index_filters_products_path
  #     %w{a o lo lorem}.each do |str|
  #       fill_in("product_filter[title][like]", :with => str)
  #       click_button("Apply")
  #       page.should have_content(str)
  #       tot = (names.select do |s| s.match Regexp.new(str) end).length
  #       #save_and_open_page
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, names.length, 0, tot))
  #     end
  #   end if FILTERS_WITH_LIKE
  # 
  #   it "filters with range" do
  #     visit index_filters_products_path
  #     n = names.length
  #     (0..n/2).each do |i|
  #       fill_in("product_filter[price][from]", :with => (10+i).to_s)
  #       fill_in("product_filter[price][to]", :with => "")
  #       click_button("Apply")
  #       tot = n-i
  #       #save_and_open_page
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
  #       fill_in("product_filter[price][to]", :with => (10+i).to_s)
  #       fill_in("product_filter[price][from]", :with => "")
  #       click_button("Apply")
  #       tot = i+1
  #       #save_and_open_page
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
  #       fill_in("product_filter[price][from]", :with => (10+i).to_s)
  #       fill_in("product_filter[price][to]", :with => (10+n-i-1).to_s)
  #       click_button("Apply")
  #       tot = n-i*2
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], [10,tot].min, n, 0, tot))
  #     end
  #   end if FILTERS_WITH_RANGE
  # end
  # 
  # describe "Sorting" do
  #   it "knows how to sort" do
  #     visit index_sort_products_path
  #     # save_and_open_page
  #     (1..10).each do |i|
  #       page.should have_content names[-i]
  #     end
  #     click_button("product_sort_title_desc")
  #     snames = names.sort
  #     (1..10).each do |i|
  #       page.should have_content snames[-i]
  #     end
  #     click_button("product_sort_title_asc")
  #     (1..10).each do |i|
  #       page.should have_content snames[i-1]
  #     end
  #   end if KNOWS_HOW_TO_SORT
  # end
  # 
  # describe "statefulness" do
  #   it "sorts statefully" do
  #     visit index_stateful_products_path
  #     click_button("product_sort_title_desc")
  #     snames = names.sort
  #     (1..10).each do |i|
  #       page.should have_content snames[-i]
  #     end
  #     visit index_stateful_products_path
  #     (1..10).each do |i|
  #       page.should have_content snames[-i]
  #     end
  #     click_button("Reset")
  #     (1..10).each do |i|
  #       page.should have_content names[i-1]
  #     end
  #   end if SORTS_STATEFULLY
  # 
  #   it "filters statefully" do
  #     Capybara.reset_sessions!
  #     visit index_stateful_products_path
  #     fill_in("product_filter[title]", :with => "lorem")
  #     click_button("Apply")
  #     visit index_stateful_products_path
  #     #save_and_open_page
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 1, names.length, 0, 1))
  #     click_button("Reset")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, names.length, 0, names.length))
  #   end if FILTERS_STATEFULLY
  # 
  #   it "selects statefully" do
  #     visit index_stateful_products_path
  #     fill_in("product_filter[title]", :with => "")
  #     click_button("Apply")
  #     n = names.length
  #     (n/10).times do |i|
  #       (1..3).each do |j|
  #         check("product_checked_#{ids[10*i+j]}")
  #       end
  #       click_button("Apply")
  #       tot = 3*(i+1)
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, tot, n))
  #       click_button('product_pagination_page_right')
  #     end
  #     visit index_stateful_products_path
  #     tot = 3*(n/10)
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], names.length % 10, n, tot, n))
  #     click_button("Reset")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, names.length, 0, names.length))
  #   end if SELECTS_STATEFULLY
  # 
  # end
  # 
  # describe "Select and Batch actions" do
  #   it "knows how to interpret the select_... buttons" do
  #     # Showing 10, total 54, selected 54, matching 54
  #     n = names.length
  #     visit index_select_products_path
  #     click_button('Select All')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, n, n))
  #     click_button('Select None')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, 0, n))
  #     click_button('Select visible')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, 10, n))
  #     click_button('Select None')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, 0, n))
  #     fill_in("product_filter[title][like]", :with => "a")
  #     click_button("Apply")
  #     tot = (names.select do |s| s.match /a/ end).length
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, 0, tot))
  #     click_button('Select filtered')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, tot, tot))
  #     fill_in("product_filter[title][like]", :with => "")
  #     click_button("Apply")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, tot, n))
  #     click_button("Unselect visible")
  #     tot -= (names[0..9].select do |s| s.match /a/ end).length
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, tot, n))
  #     click_button('Select None')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, 0, n))
  #     click_button('Select All')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, n, n))
  #     fill_in("product_filter[title][like]", :with => "a")
  #     click_button("Apply")
  #     tot = (names.select do |s| s.match /a/ end).length
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, n, tot))
  #     click_button('Unselect filtered')
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, n-tot, tot))
  #     fill_in("product_filter[title][like]", :with => "")
  #     click_button("Apply")
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, n-tot, n))
  #   end if SELECT_BUTTONS_WORK
  # 
  #   it "knows how to select and apply batch actions" do
  #     visit index_select_products_path
  #     n = names.length
  #     (n/10).times do |i|
  #       (1..3).each do |j|
  #         check("product_checked_#{ids[10*i+j]}")
  #       end
  #       click_button("Apply")
  #       tot = 3*(i+1)
  #       page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, n, tot, n))
  #       click_button('product_pagination_page_right')
  #     end
  #     select 'Delete', :from => 'product_batch'
  #     click_button("Apply")
  #     tot = n-3*(n/10)
  #     page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, tot, 0, tot))
  #     #save_and_open_page
  #   end if KNOWS_HOW_TO_SELECT_AND_APPLY_BATCH_ACTIONS
  end
  # 
  # # describe "GET /products empty" do
  # #   it "works in general" do
  # #     get products_path
  # #     response.status.should be(200)
  # #   end
  # # end
  # 

end





