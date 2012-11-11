
module SimpleExtension
  def run(&block)
    super{ run_with_changes(&block) }
  end

private
  def run_with_changes(&block)
    Thread.current[:eetee_simple_extension] = [1]
    puts "I did something before the test"
    block.call
    puts "and after the test"
    Thread.current[:eetee_simple_extension] << 2
  end
    
end

