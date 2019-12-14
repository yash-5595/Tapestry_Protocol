defmodule Tapestry do
use GenServer

def start_link(nodeId, nodeIds) do
        GenServer.start_link(__MODULE__, [nodeId, nodeIds], name: {:via, Registry, {:storenodeIds, nodeId}})
    end
    def init([nodeId, nodeIds]) do
        table = caltable(nodeId,nodeIds)
        {:ok, _} = Registry.register(:tables,nodeId, table)
        {:ok,nodeId}
    end

    def createTable(nodeId,nodeIds,numRequests,pid) do
        GenServer.cast(elem(Enum.at(Registry.lookup(:storenodeIds, nodeId),0),0),{:createTable,nodeId,nodeIds,numRequests,0,nil,pid})

    end
    def caltable(nodeId,nodeIds) do
        others = List.delete(nodeIds,nodeId)
        acc = Matrix.new(String.length(nodeId), 16,"")
        acc = Enum.reduce(0..length(others)-1,acc,fn(k,acc)-> (
            otherNode = Enum.at(others,k)
            Matrix.set(acc,helper(nodeId,otherNode),elem(Integer.parse(String.at(otherNode,helper(nodeId,otherNode)), 16),0),otherNode) )
           end)
           acc
    end

    def handle_cast({:createTable,nodeId,nodeIds,numRequests,numHops,msg,pid},state) do
        table = elem(Enum.at(Registry.lookup(:tables, nodeId),0),1)
        cond do
            msg == nil ->
                msgs = msgs(nodeId,nodeIds,numRequests)
                new_msg = Enum.at(msgs,0)
                row = helper(nodeId,new_msg)
                cond do
                      row == nil -> GenServer.cast(pid,{:printMax,numHops,pid})
                    true ->
                        column = elem(Integer.parse(String.at(new_msg,helper(nodeId,new_msg)), 16),0)
                        hop = Matrix.elem(table,row,column)
                        GenServer.cast(elem(Enum.at(Registry.lookup(:storenodeIds, hop),0),0),{:createTable,hop,nodeIds,numRequests,numHops+1,new_msg,pid})

                end
            true ->
                row = helper(nodeId,msg)
                cond do
                    row == nil -> GenServer.cast(pid,{:printMax,numHops,pid})
                    true ->
                        column = elem(Integer.parse(String.at(msg,helper(nodeId,msg)), 16),0)
                        hop = Matrix.elem(table,row,column)
                        GenServer.cast(elem(Enum.at(Registry.lookup(:storenodeIds, hop),0),0),{:createTable,hop,nodeIds,numRequests,numHops+1,msg,pid})


                end
        end
    {:noreply,table}

    end

    def helper(string1,string2) do
    acc = Enum.map(0..String.length(string2)-1,fn(k)->
         cond do
            String.at(string1,k) != String.at(string2,k) -> k
            true ->
        end
    end)
        acc
        = Enum.filter(acc, & !is_nil(&1))
        Enum.at(acc,0)
    end
    def msgs(nodeId,nodeIds,numRequests) do
        others = List.delete(nodeIds,nodeId)
        msgs = Enum.take_random(others,numRequests)
        msgs
    end
end
