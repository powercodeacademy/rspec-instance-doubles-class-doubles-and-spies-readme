# RSpec: Instance Doubles, Class Doubles, and Spies

Welcome to Lesson 18! In this lesson, we're going to level up your test double game by introducing **verifying doubles**—`instance_double` and `class_double`—and **spies**. These tools help you write safer, more robust, and more maintainable tests by ensuring your doubles match the real objects they're standing in for, and by letting you verify that methods were called as expected. We'll break down each concept, show you lots of examples, and give you practice prompts to reinforce your learning.

---

## What Are Verifying Doubles?

Regular doubles will let you stub *any* method—even ones that don't exist on the real object. This can lead to false confidence and brittle tests. **Verifying doubles** (`instance_double`, `class_double`, and `object_double`) are stricter: they only let you stub or expect methods that actually exist on the real class or instance. If you try to stub a method that doesn't exist, your test will fail!

**Rails Context:**

In Rails projects, verifying doubles are especially useful for faking ActiveRecord models, service objects, or other collaborators. They help ensure your tests stay in sync with your real Rails code as it evolves.

---

## Instance Doubles

An `instance_double` is a strict test double for an instance of a class. It checks that the methods you stub or expect actually exist on the real class.

### Basic Example

```ruby
# /spec/instance_double_spec.rb
RSpec.describe "Instance Doubles" do
  it "verifies methods exist" do
    user = instance_double("User", name: "Alice")
    expect(user.name).to eq("Alice")
  end
end
```

**What happens?**

If the `User` class has a `name` method, this passes. If not, RSpec raises an error: `User does not implement: name`.

**Example Output:**

```zsh
Instance Doubles
  verifies methods exist

Finished in 0.00123 seconds (files took 0.12345 seconds to load)
1 example, 0 failures
```

### Scenario: Catching Typos

```ruby
# /spec/instance_double_spec.rb
user = instance_double("User", nmae: "Alice") # typo!
```

This will fail with an error, helping you catch mistakes early.

### Scenario: Stubbing Multiple Methods

```ruby
# /spec/instance_double_spec.rb
user = instance_double("User", name: "Alice", admin?: true)
expect(user.admin?).to be true
```

---

## Class Doubles

A `class_double` is a strict double for a class itself (for stubbing or expecting class methods).

### Basic Example

```ruby
# /spec/class_double_spec.rb
RSpec.describe "Class Doubles" do
  it "verifies class methods exist" do
    user_class = class_double("User", find: "user")
    expect(user_class.find).to eq("user")
  end
end
```

**What happens?**

If the `User` class has a `find` class method, this passes. If not, RSpec raises an error: `User does not implement: .find`.

### Scenario: Stubbing Multiple Class Methods

```ruby
# /spec/class_double_spec.rb
user_class = class_double("User", find: "user", all: ["user1", "user2"])
expect(user_class.all).to eq(["user1", "user2"])
```

---

## Spies

**Spies** let you check that a method was called, and with what arguments, *after* the fact. This is useful for verifying side effects or interactions between objects.

### Basic Example

```ruby
# /spec/spies_spec.rb
RSpec.describe "Spies" do
  it "verifies a method was called" do
    mailer = double("Mailer").as_null_object
    mailer.send_email("hi")
    expect(mailer).to have_received(:send_email).with("hi")
  end
end
```

**What happens?**

The `as_null_object` call lets the double ignore unstubbed methods (so `send_email` doesn't raise an error). After calling `mailer.send_email("hi")`, we check that it was called with the right argument.

**Example Output:**

```zsh
Spies
  verifies a method was called

Finished in 0.00123 seconds (files took 0.12345 seconds to load)
1 example, 0 failures
```

### Scenario: Spying on Real Objects

You can also spy on real objects using `allow(...).to receive` and `expect(...).to have_received`:

```ruby
# /spec/spies_spec.rb
class Notifier
  def notify(msg)
    # ...
  end
end

notifier = Notifier.new
allow(notifier).to receive(:notify)
notifier.notify("hello")
expect(notifier).to have_received(:notify).with("hello")
```

---

## More Scenarios & Edge Cases

- If you try to stub a method that doesn't exist on the real class, verifying doubles will fail (and that's a good thing!).
- You can use verifying doubles with modules, too (`object_double`).
- `object_double` is like `instance_double`, but verifies against a specific object instance (not just a class). Use it when you want to double a particular object, not just any instance of a class.
- Spies can be used with both doubles and real objects.
- `as_null_object` lets a double ignore unstubbed methods (useful for spies).

---

## Practice Prompts

Try these exercises to reinforce your learning:

1. Use `instance_double` to fake a real object and verify a method exists. What happens if you try to stub a method that doesn't exist?
2. Use `class_double` to fake a class and verify a class method exists. Try stubbing multiple class methods.
3. Use a spy to check that a method was called after the fact, both on a double and on a real object.
4. Try using `as_null_object` and see how it changes double behavior.
5. Why might verifying doubles make your test suite safer?

Reflect: How can verifying doubles help prevent regression bugs, especially when working in a larger team or on a growing codebase?

---

## What's Next?

Lab 6 follows this lesson! In Lab 6, you'll get hands-on practice test-driving a Ruby service object using doubles and spies. This is your chance to apply verifying doubles and spies in a real-world scenario.

---

## Resources

- [RSpec: Instance Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/instance-doubles)
- [RSpec: Class Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/class-doubles)
- [RSpec: Object Doubles](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles/object-doubles)
- [RSpec: Spies](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/spies)
- [RSpec: as_null_object](https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/null-object-double)
- [Better Specs: Doubles](https://www.betterspecs.org/#doubles)
