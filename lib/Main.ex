defmodule Main do
 def spread(numNodes,numRequests) do
    x = Integer.to_string(numNodes,16)
    len = String.length(x)
    lim = Kernel.trunc(:math.pow(2,4*len))
    nodeIds = createNodeIds(numNodes,len)
    Registry.start_link(keys: :unique, name: :storenodeIds)
    Registry.start_link(keys: :unique, name: :tables)
    Registry.start_link(keys: :duplicate, name: :OutRegister)

   {:ok,pid} = GlobalGen.start_link(numNodes)
  for i <- 1..numNodes do
    {:ok,pid1} = Tapestry.start_link(Enum.at(nodeIds,i-1),nodeIds)
  end
  for i <- 1..numNodes do
    Tapestry.createTable(Enum.at(nodeIds,i-1),nodeIds,numRequests,pid)
  end
end

def createNodeIds(numNodes,len) do
  Enum.reduce(1..numNodes,[],fn(k,acc)->
    diff = len - String.length(Integer.to_string(k,16))
    a = Integer.to_string(k,16)
    cond do
      diff>=1 -> acc ++ [Enum.reduce(1..diff,a,fn(k,acc)-> Enum.join(["0", acc], "")end)]
      true -> acc ++ [a]
    end
   end)
end
  def getpidofnode(nodeid) do
    case Registry.lookup(:storenodeIds, nodeid) do
    [{pid, _}] -> pid
    [] -> nil
    end
  end

end


