require 'test/unit'

class Mock
  include Test::Unit::Assertions
  
  def initialize
    @expected_methods=[]
    @expected_validation_procs=[]
    @setup_call_procs={}
  end

  def __expect(method, &validation_proc)
    validation_proc=Proc.new {|*args| nil} if validation_proc.nil?
    @expected_methods<<method
    @expected_validation_procs<<validation_proc
  end
  
  def __setup(method, &proc)
    proc=Proc.new {|*args| nil} if proc.nil?
    @setup_call_procs[method]=proc
  end
  
  def __verify
    assert_all_expected_methods_called
  end
  
  def method_missing(method, *args)
    if (is_setup_call(method)) then
      handle_setup_call(method, *args)
    else
      handle_expected_call(method, *args)
    end
  end

private
  
  def assert_all_expected_methods_called
    assert(@expected_validation_procs.empty?, "not all expected methods called, calls left: #{@expected_methods.join(', ')}")
  end
  
  def is_setup_call(method)
    not @setup_call_procs[method].nil?
  end
  
  def handle_setup_call(method, *args)
    @setup_call_procs[method].call(*args)
  end
  
  def handle_expected_call(method, *args)
    assert_equal(currently_expected_method, method, "got unexpected call")
    validation_proc = current_validation_proc
    next_call
    validation_proc.call(args)
  end
  
  def currently_expected_method
    if @expected_methods.empty? then nil 
    else @expected_methods[0] end
  end
  
  def current_validation_proc
    if @expected_validation_procs.empty? then nil 
    else @expected_validation_procs[0] end
  end
  
  def next_call
    @expected_methods.delete_at(0)
    @expected_validation_procs.delete_at(0)
  end
  
end

class MockTest < Test::Unit::TestCase
  def setup
    @mock = Mock.new
  end

  def test_unmocked_call_fails
    @mock = Mock.new
    assert_raises(Test::Unit::AssertionFailedError) do
      @mock.unmocked_call
    end
  end
  
  def test_expected_call_works
    @mock.__expect(:expected_call)
    @mock.expected_call
  end
  
  def test_sequential_expected_methods_work
    @mock.__expect(:expected_call1)
    @mock.__expect(:expected_call2)
    @mock.expected_call1
    @mock.expected_call2
  end
  
  def test_sequential_expected_methods_in_wrong_order_fails
    @mock.__expect(:expected_call1)
    @mock.__expect(:expected_call2)
    assert_raises(Test::Unit::AssertionFailedError) do
      @mock.expected_call2
      @mock.expected_call1
    end
  end
  
  def test_provided_block_can_validate_arguments
    @mock.__expect(:expected_call) {|arg| assert_equal("arg", arg)}
    assert_raises(Test::Unit::AssertionFailedError) do
      @mock.expected_call("incorrect arg")
    end
  end
  
  def test_verify_fails_if_not_all_expected_methods_were_called
    @mock.__expect(:expected_call)
    assert_raises(Test::Unit::AssertionFailedError) do
      @mock.__verify
    end
  end

  def test_verify_fails_with_verbose_message_if_not_all_expected_methods_were_called
    @mock.__expect(:expected_call_one)
    @mock.__expect(:expected_call_two)
    begin
      @mock.__verify
      fail
    rescue Test::Unit::AssertionFailedError => afe
      assert_equal("not all expected methods called, calls left: expected_call_one, expected_call_two", afe.message)
    end
  end
  
  def test_setup_method_can_always_be_called_and_procs_returns_value
    @mock.__setup(:setup_call) {|| :return_value}
    assert_equal(:return_value, @mock.setup_call)
    assert_equal(:return_value, @mock.setup_call)
    assert_equal(:return_value, @mock.setup_call)
  end
end