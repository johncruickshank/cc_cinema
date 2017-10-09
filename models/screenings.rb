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

  def self.all()
    sql = "SELECT * FROM screenings;"
    values = []
    screenings = SqlRunner.run(sql, values)
    result = screenings.map { |screening| Screening.new(screening)}
    return result
  end

  # Write a method that finds out what is the most popular time (most tickets sold) for a given film
  ##doesn't work yet##
  def most_popular()
    sql = "SELECT customer_id COUNT(*) AS count FROM tickets WHERE film_id = tickets.film_id AND film_id = $1 GROUP BY screening_id;"
    values = [@film_id]
    most_pop = SqlRunner.run(sql, values)
    return most_pop.first
  end

end
