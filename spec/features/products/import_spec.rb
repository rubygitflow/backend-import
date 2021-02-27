require 'rails_helper'

feature 'User can import products list from file' do
  describe 'User' do
    background do
      visit root_path
    end

    scenario 'attaches UTF8 file with col_del as "," ' do
      attach_file 'File', "#{Rails.root}/spec/fixtures/files/test1.csv"
      click_on 'Upload'

      # save_and_open_page
      expect(page).to have_content 'test1.csv'
      expect(page).to have_content 'Products added successfully'
    end

    scenario 'attaches UTF8BOM file with col_del as ";" ' do
      attach_file 'File', "#{Rails.root}/spec/fixtures/files/test2.csv"
      click_on 'Upload'

      # save_and_open_page
      expect(page).to have_content 'test2.csv'
      expect(page).to have_content 'Products added successfully'
    end

    scenario 'attaches empty field of brand' do
      file2 = "#{Rails.root}/spec/fixtures/files/test2.csv"

      file = File.open(file2, 'r')
      strVar2 = file.read
      file.close

      expect(strVar2).to have_content '00000001226'

      attach_file 'File', file2
      click_on 'Upload'
      
      # save_and_open_page
      expect(page).not_to have_content '00000001226'
    end

    scenario 'attaches CP1251 file with col_del as ";"' do
      attach_file 'File', "#{Rails.root}/spec/fixtures/files/test3.csv"
      click_on 'Upload'

      expect(page).to have_content 'test3.csv'
      expect(page).to have_content 'Products added successfully'
    end

    scenario 'reattaches the same file' do
      attach_file 'File', "#{Rails.root}/spec/fixtures/files/test1.csv"
      click_on 'Upload'

      # save_and_open_page
      expect(page).to have_content 'Колодки тормозные'

      attach_file 'File', "#{Rails.root}/spec/fixtures/files/short/test1.csv"
      click_on 'Upload'

      # save_and_open_page
      expect(page).not_to have_content 'Колодки тормозные'
    end

    scenario 'attaches prises with different col_names' do
      file1 = "#{Rails.root}/spec/fixtures/files/test1.csv"
      file2 = "#{Rails.root}/spec/fixtures/files/test2.csv"

      file = File.open(file1, 'r')
      strVar1 = file.read
      file.close
      file = File.open(file2, 'r')
      strVar2 = file.read
      file.close

      expect(strVar1).to have_content 'Производитель'
      expect(strVar1).to have_content 'SUPPORT'
      expect(strVar2).to have_content 'Бренд'
      expect(strVar2).to have_content 'ASPOECK'

      attach_file 'File', file1
      click_on 'Upload'

      attach_file 'File', file2
      click_on 'Upload'
      
      expect(page).to have_content 'SUPPORT'
      expect(page).to have_content 'ASPOECK'
    end

    scenario 'attaches prises with stock that doesnt include ">" ' do
      file1 = "#{Rails.root}/spec/fixtures/files/test1.csv"

      file = File.open(file1, 'r')
      strVar1 = file.read
      file.close

      expect(strVar1).to have_content '>10'

      attach_file 'File', file1
      click_on 'Upload'
      
      expect(page).not_to have_content '>10'
    end
  end 
end
