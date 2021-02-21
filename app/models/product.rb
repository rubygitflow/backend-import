class Product < ApplicationRecord

	def self.import(file)
    price_list = file.original_filename.to_s
    Product.where(price_list: price_list).destroy_all

    strVar = File.open(file.path, &:readline)
    col_del = strVar.index(';').nil? ? ',' : ';'

    begin
      CSV.foreach(file.path, 
                  headers: :first_row, 
                  liberal_parsing: true, 
                  col_sep: col_del
                 ) do |row|
        begin
          input_hash = row.to_hash
          hsh = select_hash(input_hash, price_list)
          Product.create! hsh if !hsh['brand'].empty? and !hsh['code'].empty? 
        rescue 
          # ignore record
        end

      end
    rescue CSV::MalformedCSVError
      CSV.foreach(file.path, 
                  headers: :first_row, 
                  liberal_parsing: true, 
                  encoding: 'CP1251:utf-8', 
                  col_sep: col_del
                 ) do |row|
        begin
          input_hash = row.to_hash
          hsh = select_hash(input_hash, price_list)
          Product.create! hsh if !hsh['brand'].nil? and !hsh['code'].nil? 
        rescue 
          # ignore record
        end
      end
    end
  end	

  def created_at_time()
    # https://devdocs.io/ruby~3/datetime#method-i-strftime
    created_at.strftime("%T")  
  end

  private

  def self.select_hash(input_hash, file_name)
    res = {}
    res['price_list'] = file_name
    res['brand'] = input_hash['Производитель'] || input_hash['Бренд']
    res['code'] = input_hash['Артикул'] || input_hash["﻿\"Артикул\""] || input_hash['Номер']
    res['stock'] = input_hash['Количество'] || input_hash['Кол-во']
    res['stock'] = res['stock'].index('>').nil? ? res['stock'] : res['stock'].gsub('>', '')
    res['cost'] = input_hash['Цена']
    res['name'] = input_hash['Наименование'] || input_hash['НаименованиеТовара']
    res
  end
end
