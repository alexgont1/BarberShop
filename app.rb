require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where barbername=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'INSERT INTO Barbers (name) VALUES (?)', [barber]
		end
	end
end

def get_db
	return SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

before do
	db = get_db
	@barbers = db.execute 'SELECT * FROM Barbers'
end

#do smth when app starts
configure do
	db = get_db
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

	seed_db db, ['Walter White', 'Jessie Pinkman', 'Gus Fring', 'Uncle Tom']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
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
	@results = db.execute 'SELECT * FROM Users ORDER BY id DESC'

	erb :showusers
end