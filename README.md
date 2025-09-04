
# RSpec: Instance Doubles, Class Doubles, and Spies (BookOrder & Bookstore Edition)

Welcome to an in-depth exploration of **verifying doubles** and **spies** in RSpec! In this lesson, you'll learn how to write safer, more maintainable tests using `instance_double`, `class_double`, `object_double`, and spies. All examples use a realistic BookOrder/Bookstore domain to help you understand these concepts in context.

## Learning Objectives

By the end of this lesson, you will be able to:

- Explain the difference between regular doubles and verifying doubles
- Use `instance_double` to create strict doubles for class instances
- Use `class_double` to create strict doubles for class methods
- Use `object_double` to create doubles based on real object instances
- Implement spies to verify method calls after they happen
- Choose the appropriate type of double for different testing scenarios

---

## The Problem with Regular Doubles

Before we dive into verifying doubles, let's understand why they exist. Regular doubles (`double`) will let you stub *any* method—even ones that don't exist on the real object:

```ruby
# This works but is dangerous!
order = double("BookOrder")
allow(order).to receive(:nonexistent_method).and_return("oops!")
```

This can lead to:

- False confidence in your tests
- Broken code that passes tests
- Maintenance nightmares when APIs change

**Verifying doubles** solve this by only allowing you to stub methods that actually exist on the real class.

---

## What Are Verifying Doubles?

**Verifying doubles** (`instance_double`, `class_double`, and `object_double`) are stricter versions of regular doubles. They verify that:

1. The methods you stub actually exist on the real class
2. The method signatures match (correct number of arguments)
3. Your tests stay in sync with your actual code

If you try to stub a method that doesn't exist, your test will fail immediately—and that's a good thing!

---

## Instance Doubles

An `instance_double` creates a strict test double that represents an **instance** of a class. It only allows you to stub methods that exist on the real class, helping catch typos and API changes early.

### When to Use Instance Doubles

Use `instance_double` when you want to:

- Test interactions with an object without creating a real instance
- Ensure your doubles stay in sync with the real class interface
- Catch typos in method names during testing
- Speed up tests by avoiding expensive object creation

### Basic Example

```ruby
# This creates a double that behaves like a BookOrder instance
order = instance_double("BookOrder", place: :placed, status: :pending)
expect(order.place).to eq(:placed)
expect(order.status).to eq(:pending)
```

**What happens?**

RSpec checks that `BookOrder` has `place` and `status` methods. If they exist, the test passes. If not, you get an error like: `BookOrder does not implement: place`.

### Catching Typos Early

This is one of the biggest benefits of verifying doubles:

```ruby
# This will fail immediately!
order = instance_double("BookOrder", sttaus: :pending) # typo in "status"
# Error: BookOrder does not implement: sttaus
```

Without verifying doubles, this typo might go unnoticed until much later.

### Stubbing Multiple Methods

```ruby
order = instance_double("BookOrder",
  place: :placed,
  cancel: :cancelled,
  status: :pending
)

expect(order.cancel).to eq(:cancelled)
expect(order.status).to eq(:pending)
```

---

## Class Doubles

A `class_double` creates a strict double for a **class itself**, allowing you to stub or mock class methods (also called static methods). This is perfect when you need to test interactions with class-level functionality.

### When to Use Class Doubles

Use `class_double` when you want to:

- Stub class methods like `find`, `create`, or `all`
- Test code that calls class methods without hitting a database
- Ensure your class method calls are correct
- Mock external services accessed through class methods

### Basic Class Double Example

```ruby
# This creates a double for the Bookstore class itself
store = class_double("Bookstore", find: "Book: Ruby 101")
expect(store.find("Ruby 101")).to eq("Book: Ruby 101")
```

**What happens?**

RSpec verifies that `Bookstore` has a class method called `find`. If it doesn't exist, you get: `Bookstore does not implement: .find` (note the dot indicating a class method).

### Real-World Scenario

Imagine testing a service that finds books:

```ruby
class BookSearchService
  def self.search_for(title)
    book = Bookstore.find(title)
    "Found: #{book}"
  end
end

# In your test:
it "searches for a book using Bookstore.find" do
  store = class_double("Bookstore", find: "Book: Ruby 101")
  allow(Bookstore).to receive(:find).and_return("Book: Ruby 101")

  result = BookSearchService.search_for("Ruby 101")
  expect(result).to eq("Found: Book: Ruby 101")
end
```

### Stubbing Multiple Class Methods

```ruby
store = class_double("Bookstore",
  find: "Book: Ruby 101",
  all: ["Book: Ruby 101", "Book: RSpec Mastery"]
)

expect(store.find("Ruby 101")).to eq("Book: Ruby 101")
expect(store.all).to include("Book: Ruby 101")
```

---

## Object Doubles

An `object_double` creates a strict double based on a **specific object instance**. Unlike `instance_double` which uses the class name, `object_double` takes an actual object and ensures your double matches that specific object's interface.

### When to Use Object Doubles

Use `object_double` when you:

- Have a specific object instance you want to double
- Need to ensure your double matches a particular object's current state
- Want to test against an object that might have been configured or modified

### Basic Object Double Example

```ruby
real_store = Bookstore.new
store_double = object_double(real_store, order_book: "Order placed for Ruby 101 by Alice")
expect(store_double.order_book("Ruby 101", "Alice")).to eq("Order placed for Ruby 101 by Alice")
```

The double will only allow methods that exist on the `real_store` instance.

---

## Spies: Verifying Method Calls After the Fact

**Spies** are a powerful testing pattern that lets you verify that methods were called *after* your code runs. This is particularly useful for testing side effects, logging, notifications, or any scenario where you care *that* something happened, not just *what* it returned.

### Why Use Spies?

Traditional mocks require you to set expectations *before* the code runs:

```ruby
# Traditional mock: expectation BEFORE the call
expect(mailer).to receive(:send_email).with("alice@example.com")
UserService.welcome_new_user("alice@example.com")
```

Spies let you verify *after* the call, which can make tests more readable:

```ruby
# Spy: verify AFTER the call
UserService.welcome_new_user("alice@example.com")
expect(mailer).to have_received(:send_email).with("alice@example.com")
```

### Setting Up Spies on Real Objects

To spy on a real object, you use `allow(...).to receive(...)`:

```ruby
it "notifies customer when order is placed" do
  store = Bookstore.new
  # Set up the spy
  allow(store).to receive(:notify_customer).and_call_original

  # Execute the code you're testing
  store.notify_customer("Alice", "Your book has shipped!")

  # Verify the method was called correctly
  expect(store).to have_received(:notify_customer).with("Alice", "Your book has shipped!")
end
```

### Spying Without Changing Behavior

The `and_call_original` ensures the real method still runs. If you want to spy without executing the real method:

```ruby
allow(store).to receive(:notify_customer) # method won't actually run
store.notify_customer("Alice", "Your book has shipped!")
expect(store).to have_received(:notify_customer).with("Alice", "Your book has shipped!")
```

### Spying on Multiple Calls

Spies can verify multiple calls and their order:

```ruby
store = Bookstore.new
allow(store).to receive(:notify_customer)

store.notify_customer("Alice", "Order received")
store.notify_customer("Alice", "Order shipped")

expect(store).to have_received(:notify_customer).twice
expect(store).to have_received(:notify_customer).with("Alice", "Order received").ordered
expect(store).to have_received(:notify_customer).with("Alice", "Order shipped").ordered
```

---

## Choosing the Right Tool

Here's a quick guide for when to use each type of double:

| Use Case | Tool | Example |
|----------|------|---------|
| Mock an instance of a class | `instance_double` | `instance_double("BookOrder", status: :pending)` |
| Mock class methods | `class_double` | `class_double("Bookstore", find: "Book: Ruby 101")` |
| Mock based on specific object | `object_double` | `object_double(real_store, order_book: "result")` |
| Verify method was called | Spy | `expect(store).to have_received(:notify_customer)` |

---

## Getting Hands-On

Ready to practice? Here's how to get started:

1. **Fork and clone this repo to your own GitHub account.**

2. **Install dependencies:**

    ```zsh
    bundle install
    ```

3. **Run the specs to see the current state:**

    ```zsh
    bin/rspec
    ```

4. **Explore the code:**

   - Review `lib/book_order.rb` and `lib/bookstore.rb` to understand the domain
   - Examine `spec/doubles_spec.rb` to see examples of all the concepts in action
   - Notice how the pending specs guide you toward implementation

5. **Experiment with the concepts:**

   - Try modifying the doubles in the specs to see validation errors
   - Add new methods to the classes and create doubles for them
   - Practice creating spies for different scenarios

6. **Complete the pending specs:**

   The specs marked as `pending` are already implemented in the classes, but the tests need to be uncommented. This simulates a common scenario where you have working code but need to add proper test coverage.

---

## Best Practices

1. **Use verifying doubles by default** - They catch more errors and keep tests in sync with code
2. **Prefer spies for side effects** - When you care that something happened, not what it returned
3. **Use class doubles for external services** - Great for mocking APIs, databases, or third-party services
4. **Keep doubles simple** - Don't recreate complex object hierarchies with doubles
5. **Test the interaction, not the implementation** - Focus on what your code does, not how it does it

---

## What's Next?

Now that you understand verifying doubles and spies, you're ready to write more robust tests. In the next lesson, you'll apply these concepts to test-drive a real-world service object, dealing with external dependencies and complex interactions.

---

## Resources

- [RSpec: Instance Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/instance-doubles)
- [RSpec: Class Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/class-doubles)
- [RSpec: Object Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/object-doubles)
- [RSpec: Spies](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/spies)
- [Better Specs: Doubles](https://www.betterspecs.org/#doubles)
