namespace :spree do
	desc "Update / Import products from CSV File, expects file=/path/to/import.csv"
	task :import_products => :environment do
		require 'fastercsv'
		n = 0
		u = 0
		FasterCSV.foreach(ENV['file']) do |row|
			if row[0].nil?
				# Adding new product
				puts "Adding new product: #{row[1]}"
				product = Product.new()
				n += 1
			else
				# Updating existing product
			next if row[0].downcase == "id" #skip header row
				puts "Updating product: #{row[1]}"
				product = Product.find(row[0])
				u += 1
			end
			product.name = row[1]
			product.description = row[2]
			product.sku = row[3].to_s
			product.master_price = row[4].to_d
			product.save!
		end
		puts ""
		puts "Import Completed - Added: #{n} | Updated #{u} Products"
	end
end
