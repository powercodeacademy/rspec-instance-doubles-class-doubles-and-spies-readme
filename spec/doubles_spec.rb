
require_relative '../lib/book_order'
require_relative '../lib/bookstore'

RSpec.describe 'BookOrder and Bookstore Doubles' do
  it 'allows stubbing methods on a double for BookOrder' do
    order = double('BookOrder')
    allow(order).to receive(:status).and_return(:pending)
    expect(order.status).to eq(:pending)
  end

  it 'allows setting expectations on a double for Bookstore' do
    store = double('Bookstore')
    expect(store).to receive(:order_book).with('Ruby 101', 'Alice').and_return('Order placed for Ruby 101 by Alice')
    expect(store.order_book('Ruby 101', 'Alice')).to eq('Order placed for Ruby 101 by Alice')
  end

  it 'uses instance_double to verify BookOrder methods' do
    order = instance_double('BookOrder', place: :placed, cancel: :cancelled, status: :pending)
    expect(order.place).to eq(:placed)
    expect(order.cancel).to eq(:cancelled)
    expect(order.status).to eq(:pending)
  end

  it 'raises error if method does not exist on instance_double' do
    order = instance_double('BookOrder')
    expect { order.nonexistent_method }.to raise_error(RSpec::Mocks::MockExpectationError)
  end

  it 'uses class_double to verify Bookstore class methods' do
    store = class_double('Bookstore', find: 'Book: Ruby 101', all: ['Book: Ruby 101', 'Book: RSpec Mastery'])
    expect(store.find('Ruby 101')).to eq('Book: Ruby 101')
    expect(store.all).to include('Book: Ruby 101')
  end

  it 'raises error if class method does not exist on class_double' do
    store = class_double('Bookstore')
    expect { store.unknown_class_method }.to raise_error(RSpec::Mocks::MockExpectationError)
  end

  it 'spies on a real BookOrder object' do
    order = BookOrder.new('Ruby 101', 'Alice')
    allow(order).to receive(:place).and_call_original
    order.place
    expect(order).to have_received(:place)
    expect(order.status).to eq(:placed)
  end

  it 'uses object_double to verify methods on a real Bookstore instance' do
    real_store = Bookstore.new
    store = object_double(real_store, order_book: 'Order placed for Ruby 101 by Alice')
    expect(store.order_book('Ruby 101', 'Alice')).to eq('Order placed for Ruby 101 by Alice')
  end

  it 'uses spies to check if Bookstore#notify_customer was called' do
    store = Bookstore.new
    allow(store).to receive(:notify_customer).and_call_original
    store.notify_customer('Alice', 'Your book has shipped!')
    expect(store).to have_received(:notify_customer).with('Alice', 'Your book has shipped!')
  end


  it 'uses instance_double to verify argument errors' do
    order = instance_double('BookOrder')
    expect { order.place('unexpected_arg') }.to raise_error(RSpec::Mocks::MockExpectationError)
  end

  it 'has a pending spec for students to implement: BookOrder#placed? returns true after place' do
    pending('Implement BookOrder#placed? and test that it returns true after place is called')
    raise 'Not implemented'
    # order = BookOrder.new('Ruby 101', 'Alice')
    # order.place
    # expect(order.placed?).to eq(true)
  end

  it 'has a pending spec for students to implement: BookOrder#cancelled? returns true after cancel' do
    pending('Implement BookOrder#cancelled? and test that it returns true after cancel is called')
    raise 'Not implemented'
    # order = BookOrder.new('Ruby 101', 'Alice')
    # order.cancel
    # expect(order.cancelled?).to eq(true)
  end
end
