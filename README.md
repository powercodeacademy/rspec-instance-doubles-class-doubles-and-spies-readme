
# RSpec: Instance Doubles, Class Doubles, and Spies (BookOrder & Bookstore Edition)

Welcome to Lesson 18! In this lesson, you'll master **verifying doubles**—`instance_double`, `class_double`, and `object_double`—plus **spies**. These tools help you write safer, more robust, and more maintainable tests by ensuring your doubles match the real objects they're standing in for, and by letting you verify that methods were called as expected. All examples use a BookOrder/Bookstore domain for clarity and realism.

---

## What Are Verifying Doubles?

Regular doubles will let you stub *any* method—even ones that don't exist on the real object. This can lead to false confidence and brittle tests. **Verifying doubles** (`instance_double`, `class_double`, and `object_double`) are stricter: they only let you stub or expect methods that actually exist on the real class or instance. If you try to stub a method that doesn't exist, your test will fail!

---

## Instance Doubles

An `instance_double` is a strict test double for an instance of a class. It checks that the methods you stub or expect actually exist on the real class.

### Basic Example of Instance Doubles

```ruby
# /spec/doubles_spec.rb
order = instance_double("BookOrder", place: :placed, status: :pending)
expect(order.place).to eq(:placed)
expect(order.status).to eq(:pending)
```

**What happens?**

If the `BookOrder` class has `place` and `status` methods, this passes. If not, RSpec raises an error: `BookOrder does not implement: place`.

### Scenario: Catching Typos

```ruby
order = instance_double("BookOrder", sttaus: :pending) # typo!
```

This will fail with an error, helping you catch mistakes early.

### Scenario: Stubbing Multiple Methods

```ruby
order = instance_double("BookOrder", place: :placed, cancel: :cancelled, status: :pending)
expect(order.cancel).to eq(:cancelled)
```

---

## Class Doubles

A `class_double` is a strict double for a class itself (for stubbing or expecting class methods).

### Basic Example of Class Doubles

```ruby
store = class_double("Bookstore", find: "Book: Ruby 101")
expect(store.find("Ruby 101")).to eq("Book: Ruby 101")
```

**What happens?**

If the `Bookstore` class has a `find` class method, this passes. If not, RSpec raises an error: `Bookstore does not implement: .find`.

### Scenario: Stubbing Multiple Class Methods

```ruby
store = class_double("Bookstore", find: "Book: Ruby 101", all: ["Book: Ruby 101", "Book: RSpec Mastery"])
expect(store.all).to include("Book: Ruby 101")
```

---

## Spies

**Spies** let you check that a method was called, and with what arguments, *after* the fact. This is useful for verifying side effects or interactions between objects.

### Basic Example of Spies

```ruby
store = double("Bookstore").as_null_object
store.order_book("Ruby 101", "Alice")
expect(store).to have_received(:order_book).with("Ruby 101", "Alice")
```

**What happens?**

The `as_null_object` call lets the double ignore unstubbed methods (so `order_book` doesn't raise an error). After calling `store.order_book(...)`, we check that it was called with the right arguments.

### Scenario: Spying on Real Objects

You can also spy on real objects using `allow(...).to receive` and `expect(...).to have_received`:

```ruby
order = BookOrder.new("Ruby 101", "Alice")
allow(order).to receive(:place).and_call_original
order.place
expect(order).to have_received(:place)
```

---

## More Scenarios & Edge Cases

- If you try to stub a method that doesn't exist on the real class, verifying doubles will fail (and that's a good thing!).
- You can use verifying doubles with modules, too (`object_double`).
- `object_double` is like `instance_double`, but verifies against a specific object instance (not just a class). Use it when you want to double a particular object, not just any instance of a class.
- Spies can be used with both doubles and real objects.
- `as_null_object` lets a double ignore unstubbed methods (useful for spies).

---

## Getting Hands-On

Ready to practice? Here’s how to get started:

1. **Fork and clone this repo to your own GitHub account.**
2. **Install dependencies:**

    ```zsh
    bundle install
    ```

3. **Run the specs:**

    ```zsh
    bin/rspec
    ```

4. **Explore the code:**

   - All lesson code uses the BookOrder and Bookstore domain (see `lib/` and `spec/doubles_spec.rb`).
   - Review the examples for `instance_double`, `class_double`, `object_double`, and spies.

5. **Implement the pending specs:**

   - Open `spec/doubles_spec.rb` and look for specs marked as `pending`.
   - Implement the real methods in `lib/book_order.rb` as needed so the pending specs pass.

6. **Re-run the specs** to verify your changes!

**Challenge:** Try writing your own spec using a verifying double or a spy for a new method on BookOrder or Bookstore.

---

## What's Next?

In the next lab, you'll get hands-on practice test-driving a Ruby service object using doubles and spies. This is your chance to apply verifying doubles and spies in a real-world scenario.

---

## Resources

- [RSpec: Instance Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/instance-doubles)
- [RSpec: Class Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/class-doubles)
- [RSpec: Object Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/object-doubles)
- [RSpec: Spies](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/spies)
- [RSpec: as_null_object](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/null-object-double)
- [Better Specs: Doubles](https://www.betterspecs.org/#doubles)
