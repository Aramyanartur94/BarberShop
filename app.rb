#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'INSERT INTO Barbers (name) values (?)', [barber]
		end
	end
end

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

configure do
	db = get_db
	
	db.execute 'CREATE TABLE IF NOT EXISTS
	"Users"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"username"	TEXT,
		"phone"	TEXT,
		"datestamp"	TEXT,
		"barber"	TEXT,
		"color" TEXT
	)'
	
	db.execute 'CREATE TABLE IF NOT EXISTS
	"Barbers"
	(
		"id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"name"	TEXT
	)'

	seed_db db, ['Евгений Пупкин', 'Серго Бандит', 'Анастасия Нускина']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	@error = 'Something wrong!'
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/showusers' do
	
	db = get_db
	
	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@nameparihmaher = params[:nameparihmaher]
	@color = params[:color]

	# хеш
	hh ={   :username => 'Введите имя',
		 	:phone => 'Введите телефон', 
		 	:datetime => 'Введите дату и время' }
		 	# Первый способ
	## для каждой пары ключ-значение
	#hh.each do |key, value|
	#	# если параметр пуст
	#	if params[key]  == ''
	#		# то переменной error присвоить value из хеша hh
	#		@error = hh[key]
	#		# вернуть представление visit
	#		return erb :visit
	#	end
	#end

			#Второй способ
	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :visit
	end

			#Третий способ
#	if is_parameters_empty? hh
#		return erb :visit
#	end
#	
#	def is_parameters_empty? hh	
#	
#	end
	db = get_db
	db.execute 'INSERT INTO Users (username, phone, datestamp, barber, color) 
	values (?,?,?,?,?)', [@username, @phone, @datetime, @nameparihmaher, @color]
	db.close
	@title = "Спасибо!"
	@message = "Уважаемый, #{@username}, #{@nameparihmaher} будет Вас ждать #{@datetime}" 

	f = File.open './public/users.txt', 'a'
	f.write "Клиент: #{@username}, Телефон #{@phone}, Дата и время записи: #{@datetime}, Парихмахер: #{@nameparihmaher}, цвет: #{@color}\n"
	f.close
	erb :message
end

post '/contacts' do
	@personname = params[:personname]
	@useremail = params[:useremail]
	@question = params[:question]

	hh1 ={ 	:personname => 'Введите Ваше имя',
	 		:useremail => 'Введите email',
	 		:question => 'Введите вопрос'}

	@error = hh1.select {|key,_| params[key] == ""}.values.join(", ")
	if @error != ''
		return erb :contacts
	end

	a = File.open './public/contacts.txt', 'a'
	a.write "Вопрос от #{@personname}: #{@question}, почта: #{@useremail}\n"
	a.close
end