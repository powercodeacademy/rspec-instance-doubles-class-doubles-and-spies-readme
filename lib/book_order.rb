# lib/book_order.rb

class BookOrder
  attr_reader :book_title, :customer, :status

  def initialize(book_title, customer)
    @book_title = book_title
    @customer = customer
    @status = :pending
  end

  def place
    @status = :placed
  end

  def cancel
    @status = :cancelled
  end

  def placed?
    @status == :placed
  end

  def cancelled?
    @status == :cancelled
  end
end
