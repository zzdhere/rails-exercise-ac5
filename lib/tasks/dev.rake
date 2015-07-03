namespace :dev do

  task :get_ubike => :environment do
    conn = Faraday.new(:url => 'http://data.taipei' )
    res = conn.get '/opendata/datalist/apiAccess?scope=resourceAquire&rid=ddb80380-f1b3-4f8e-8016-7ed9cba571d5'
    data = JSON.parse( res.body )

    # Create or Update
    data["result"]["results"].each do |u|
      ubike = Ubike.find_by_iid( u["iid"] )
      if ubike
        ubike.name = u["sna"]
        ubike.data = u["data"]
        ubike.save!
        puts "Update ubike: #{ubike.id}"
      else
        ubike = Ubike.create!( :name => u["sna"], :iid => u["iid"], :data => u )
        puts "Create ubike: #{ubike.id}"
      end
    end

    # Delete
    source_ids = data["result"]["results"].map{ |x| x["iid"] }
    our_ids = Ubike.all.map{ |x| x.iid }
    deleting_ids = our_ids - source_ids
    deleting_ids.each do |i|
      puts "Delete ubike iid: #{i}"
      Ubike.find(i).destroy
    end

  end

  task :rebuild => ["db:drop", "db:setup", :fake]
  #task :rebuild => ["db:drop", "db:create", "db:schema:load", "db:seed", :fake]

  task :fake => :environment do
    User.delete_all
    Event.delete_all
    Attendee.delete_all

    puts "Creating fake data!"

    user = User.create!( :email => "ihower@gmail.com", :password => "12345678")

    50.times do |i|
      e = Event.create( :name => Faker::App.name )
      10.times do |j|
        e.attendees.create( :name => Faker::Name.name )
      end
    end

  end

end