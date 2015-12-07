require 'benchmark_spec'

n = 10000000

describe "literation" do
  before :each do
    a = nil
  end

  benchmark "using `times` operation" do
    n.times do
      a = "1"
    end
  end

  benchmark "using `upto`" do
    1.upto(n) do
      a = "1"
    end
  end

  benchmark "using for loop" do
    for i in 1..n
      a = "1";
    end
  end
end
