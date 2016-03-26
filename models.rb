if !File.exists?("./spydeer.db")

  # IF YOU DO CHANGES HERE, DELETE THE FILE 'spydeer.db'

  DB = Sequel.connect("sqlite://spydeer.db")

  DB.create_table :humans do
    primary_key :id
    String      :first_name
    String      :last_name
  end

  DB.create_table :devices do
    primary_key :id
    String      :mac_address
    String      :device_type
    String      :name
    foreign_key :human_id
  end

  DB.create_table :presences do
    primary_key :id
    DateTime    :start_date
    DateTime    :end_date
    foreign_key :device_id
  end

  just_created = true
else
  DB = Sequel.connect("sqlite://spydeer.db")
end


class Human < Sequel::Model(:humans)
  one_to_many :device
end

class Device < Sequel::Model
  many_to_one :human
  one_to_many :presence
end

class Presence < Sequel::Model
  many_to_one :device
end
