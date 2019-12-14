defmodule Project3 do
  def off() do
    off()
  end
  def main(arg) do
  numNodes = String.to_integer(Enum.at(arg,0))
  numRequests = String.to_integer(Enum.at(arg,1))
  Main.spread(numNodes,numRequests)
  off()
  end

end
Project3.main(System.argv())
