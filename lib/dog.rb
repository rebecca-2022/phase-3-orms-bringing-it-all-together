class Dog

  attr_accessor :name, :breed, :id

  def initialize name:, breed:, id: nil
      @name = name
      @breed = breed
      @id = id
  end

  # def initialize(attributes, id = nil)
  # attributes.each do |key, value|
  #     # create a getter and setter by calling the attr_accessor method
  #     self.class.attr_accessor(key)
  #     self.send("#{key}=", value)
  #     end
  #     @id = id
  # end

  def self.create_table 
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
      DB[:conn].execute(sql)
  end

  def save
      if self.id
          self.update
      else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
      end
  end

  def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
  end

  def self.new_from_db (row)
      Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
      sql = <<-SQL
      SELECT * FROM dogs
      SQL
      DB[:conn].execute(sql).map do |row|
          Dog.new_from_db(row)
      end
  end

  def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
          FROM dogs
          WHERE name LIKE ?
          LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
      end.first
  end

  def self.find(id)
      sql = <<-SQL
        SELECT *
          FROM dogs
          WHERE id LIKE ?
          LIMIT 1
      SQL
      DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
      end.first
  end

  #bonus methods
  def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          LIMIT 1
          SQL
      row = DB[:conn].execute(sql, name, breed).first
      if row
          self.new_from_db(row)
      else
          self.create(name: name, breed: breed)
      end
  end

  def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end