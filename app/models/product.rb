class Product < ApplicationRecord
  QUOTE_CHAR = '^'.freeze    
  COLUMNS = "price_list, brand, code, stock, cost, name, created_at, updated_at".freeze
  CODE_CONVERTER = {
    'utf-8' => "UTF-8",
    'UTF-8' => "UTF-8",
    'windows-1251' => 'CP1251:utf-8'
  }.freeze
  COLUMN_PARSER = {
    'Производитель' => "brand",
    'Бренд' => "brand",
    'Артикул' => 'code',
    "﻿\"Артикул\"" => 'code',
    'Номер' => 'code',
    'Кол-во' => "stock",
    'Количество' => "stock",
    'Цена' => "cost",
    'Наименование' => "name",
    'НаименованиеТовара' => "name",
  }.freeze

	def self.import(file)
    mem_usage_before = print_memory if Rails.env.development?
    time = Benchmark.realtime do
      price_list = file.original_filename.to_s
      ActiveRecord::Base.transaction do
        # https://postgrespro.ru/docs/enterprise/12/sql-copy
        products_command =
          "copy products (#{COLUMNS}) from stdin with csv delimiter ';' quote '#{QUOTE_CHAR}'"

        Product.where(price_list: price_list).delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('products')

        strVar = File.open(file.path, &:readline)
        col_del = strVar.index(';').nil? ? ',' : ';'
        char_detect = CharDet.detect(strVar)

        raw_connection.copy_data products_command do
          # https://ruby-doc.org/stdlib-2.7.2/libdoc/csv/rdoc/CSV.html
          CSV.foreach(file.path, 
                      headers: :first_row, 
                      liberal_parsing: true, 
                      encoding: CODE_CONVERTER[char_detect['encoding']], 
                      col_sep: col_del
                     ) do |row|
            begin
              import_action(row.to_hash, price_list)
            rescue 
              # ignore record
            end
          end
        end 
      end 
    end 
    if Rails.env.development?
      mem_usage_after = print_memory
      mem_usage = mem_usage_after - mem_usage_before
      puts "Memory usage: #{mem_usage} KB"
      puts "Finish in: #{time.round(2)}"
    end
  end	

  def created_at_time()
    # https://devdocs.io/ruby~3/datetime#method-i-strftime
    created_at.strftime("%T")  
  end

  private
  def self.raw_connection
    @raw_connection ||= ActiveRecord::Base.connection.raw_connection
  end

  def self.import_action(input_hash, file_name)
    # парсим данные
    hsh = input_hash.transform_keys {|k| COLUMN_PARSER[k] }
    # только для разрешённых записей
    if !hsh['brand'].empty? && !hsh['code'].empty? 
      # дополнительные условия
      hsh['stock'] = hsh['stock'].index('>').nil? ? 
        hsh['stock'] : hsh['stock'].gsub('>', '')
      hsh['cost'] = input_hash['Цена'].tr(',', '.')
      # недостающие данные
      time = Time.now.localtime.strftime("%Y-%m-%d %H:%M:%S")
      # стримим подготовленный чанк данных в postgres 
      s = "#{file_name};#{hsh['brand']};#{hsh['code']};#{hsh['stock']};#{hsh['cost']};#{hsh['name']};#{time};#{time}\n"
      raw_connection.put_copy_data(s)
    end 
  end

  def self.memory
    `ps -o rss= -p #{Process.pid}`.to_i
  end

  def self.print_memory
    m = memory
    puts "Memory: #{m} KB"
    m
  end
end
