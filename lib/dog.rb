class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(name:, breed:)
      @id = nil
      @name = name
      @breed = breed
    end
  
    def self.create_table
      DB[:conn].execute(
        "CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )"
      )
    end
  
    def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end
  
    def save
      if id.nil?
        DB[:conn].execute(
          "INSERT INTO dogs (name, breed) VALUES (?, ?)",
          name, breed
        )
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      else
        DB[:conn].execute(
          "UPDATE dogs SET name = ?, breed = ? WHERE id = ?",
          name, breed, id
        )
      end
      self
    end
  
    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end
  
    def self.new_from_db(row)
      id, name, breed = row
      Dog.new(name: name, breed: breed).tap { |dog| dog.id = id }
    end
  
    def self.all
      DB[:conn].execute("SELECT * FROM dogs").map do |row|
        new_from_db(row)
      end
    end
  
    def self.find_by_name(name)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
      new_from_db(row) unless row.nil?
    end
  
    def self.find(id)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
      new_from_db(row) unless row.nil?
    end
  end
  