
# parameters:
#  output     => the formatted to use
#  backtrace  => number of lines, nil =  everything
guard 'eetee', :output => "BetterOutput", :backtrace => nil do
  watch(%r{^lib/eetee/(.+)\.rb$})     { |m| "specs/unit/#{m[1]}_spec.rb" }
  watch(%r{specs/.+\.rb$})
end
