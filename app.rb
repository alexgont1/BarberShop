require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
	return SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

#do smth when app starts
configure do
	@db = SQLite3::Database.new 'barbershop.db'
	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Users"
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"username" TEXT,
		"phone" TEXT,
		"datestamp" TEXT,
		"barber" TEXT,
		"color" TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS
	"Barbers"
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"barbername" TEXT
	)'

	#barbers array
	bb = ['Walter White', 'Jessie Pinkman', 'Gus Fring', 'Uncle Tom']

	#insert barbers if table is empty
	if (@db.execute 'SELECT * FROM Barbers').empty?
		bb.each do |x|
			@db.execute 'INSERT INTO Barbers (barbername) 
			VALUES (?)', [x]
		end		
	end
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	#@error = 'something'
	erb :about
end

get '/visit' do
	#get hash with barbers for select field
	db = get_db
	@bb = db.execute 'SELECT barbername FROM Barbers'

	#prepare html string with all barbers
	@bb_show = ""
	@bb.each do |value|
		aa = value.to_s
		aa[0..1] = ''
		aa[aa.length-2..aa.length] = ''
		@bb_show = @bb_show + "<option>" + aa + "</option>"
		@@bb_show_copy = @bb_show
		#example of string from visit page:
		#<option <%= @barber == 'Gus Fring' ? 'selected' : ''%>>Gus Fring</option>
		#@bb_show = @bb_show + "<option <%= @barber == '" + aa + "' ? 'selected' : ''%>>" + aa + "</option>"

	end

	erb :visit
end

post '/visit' do
	# user_name, phone, date_time
	@user_name = params[:user_name]
	@phone = params[:phone]
	@date_time = params[:date_time]
	@barber = params[:barber]
	#https://github.com/tkrotoff/jquery-simplecolorpicker
	@color = params[:color]

	#validation using hash
	hh = { :user_name => 'Enter your name',
		   :phone => 'Enter your phone',
		   :date_time => 'Enter date and time' }

	hh.each do |key, value|
		if params[key] == ''
			@error = hh[key]
			@bb_show = @@bb_show_copy
			return erb :visit
		end
	end

	db = get_db
	db.execute 'INSERT INTO
	Users
	(
		username,
		phone,
		datestamp,
		barber,
		color
	)
	VALUES (?, ?, ?, ?, ?)',
	[
		@user_name,
		@phone,
		@date_time,
		@barber,
		@color
	]

	@title = "Thank you!"
	@message = "Dear #{@user_name}, your color is #{@color}, #{@barber} will wait for you on #{@date_time}"
		
  # save info to file
 	# f = File.open './public/users.txt', 'a'
	# f.write "#{@user_name}, color: #{@color}, phone: #{@phone}, date and time: #{@date_time}, barber: #{@barber}\n"
	# f.close

	erb :message
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	# email, umessage
	@email = params[:email]
	@umessage = params[:umessage]

	@title = "Thanks for your message!"
	@message = "We'll send all info to your e-mail: #{@email}"
		
  # save info to file
 	f = File.open './public/contacts.txt', 'a'
	f.write "#{@email} : #{@umessage}\n\n"
	f.close

	erb :message
end

#admin access to get list from file
get '/admin' do
	erb :admin
end

post '/admin' do
	@password = params[:password]

	if @password == 'secret'
		erb :admin_inside
	else
		@message = 'Access denied!!!'
		erb :admin
	end
end

post '/admin_inside' do
	@butt = params[:butt]

	if @butt == 'list'
		@file = File.open("./public/users.txt","r")
		erb :users_list	
	else
		@file = File.open("./public/contacts.txt","r")
		erb :users_contacts
	end
end

get '/showusers' do
	db = get_db
	
	#my 1st solution:
	#show hash
	#@info_users = db.execute 'SELECT * FROM Users ORDER BY id DESC'
	#show each id on new line
	#@info_users_show = ""
	#@info_users.each do |value|
	#	@info_users_show = @info_users_show + value.to_s + "<br>"
	#end

	#2nd solution - only logic is here, no HTML
	@results = db.execute 'SELECT * FROM Users ORDER BY id DESC'

	erb :showusers
end