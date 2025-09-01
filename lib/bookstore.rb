# lib/bookstore.rb

class Bookstore
  def self.find(title)
    # Simulate finding a book
    "Book: #{title}"
  end

  def self.all
    ["Book: Ruby 101", "Book: RSpec Mastery"]
  end

  def order_book(book_title, customer)
    # Simulate ordering a book
    "Order placed for #{book_title} by #{customer}"
  end

  def notify_customer(customer, message)
    # Simulate notifying a customer
    "Notified #{customer}: #{message}"
  end
end
