class Dog
    attr_accessor :id, :name, :breed

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql) 
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql) 
    end

    def save
        sql = "INSERT INTO dogs(name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, @name, @breed)
        sql = "SELECT * FROM dogs ORDER BY id DESC LIMIT 1"
        ret = DB[:conn].execute(sql)[0] 
        @id = ret[0] 
        self 
    end

    def self.create(name:, breed:)
        created_dog = Dog.new(name: name, breed: breed)
        created_dog.save
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(dog_id)
        sql = "SELECT * FROM dogs WHERE dogs.id = ?"
        returned_row = DB[:conn].execute(sql, dog_id)[0]
        new_from_db(returned_row)
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE dogs.name = ? AND dogs.breed = ?"
        returned_rows = DB[:conn].execute(sql, name, breed)
        if (returned_rows.empty?)
            create(name: name, breed: breed)
        else
            dog_data = returned_rows[0]
            Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE dogs.name = ?"
        returned_row = DB[:conn].execute(sql, name)[0]
        new_from_db(returned_row)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id) 
    end

end