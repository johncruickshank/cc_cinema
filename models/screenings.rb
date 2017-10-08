require_relative("../db/sql_runner")
require_relative("films")

class Screening
  attr_reader :id
  attr_accessor :film_id, :show_time, :capacity

  def initialize(options)
    @id = options['id'].to_i()
    @film_id = options['film_id'].to_i()
    @show_time = options['show_time']
    @capacity = options['capacity'].to_i()
  end

  def save()
    sql = "INSERT INTO screenings (film_id, show_time, capacity) VALUES ($1, $2, $3) RETURNING id;"
    values = [@film_id, @show_time, @capacity]
    screening = SqlRunner.run(sql, values).first()
    @id = screening['id'].to_i()
  end

  def self.delete_all()
    sql = "DELETE FROM screenings;"
    values = []
    SqlRunner.run(sql, values)
  end

# return all customers who attended a screening
  def customers()
    sql = "SELECT customers.* FROM customers INNER JOIN tickets ON customers.id = tickets.customer_id WHERE screening_id = $1;"
    values = [@id]
    customers = SqlRunner.run(sql, values)
    return customers.map { |customer| Customer.new(customer) }
  end

# return number of people who attended a given screening
  def num_customers()
    sql = "SELECT customers.* FROM customers INNER JOIN tickets ON customers.id = tickets.customer_id WHERE screening_id = $1;"
    values = [@id]
    customers = SqlRunner.run(sql, values)
    return (customers.map { |customer| Customer.new(customer) }).length()
  end

# return screening with most customers for given film
# had hundreds of efforts at getting this function working in various ways
  def self.get_screenings_for_movie(film)
    sql = "SELECT * FROM screenings WHERE film_id = $1"
    values = [@film_id]
    return SqlRunner.run(sql, values)

  end
end
