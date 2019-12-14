defmodule GlobalGen do
use GenServer

def start_link(numNodes) do
  GenServer.start_link(__MODULE__,[numNodes])
end
def init(args) do
  state = {}
  count =  Enum.at(args,0)
  {:ok, _} = Registry.register(:OutRegister, "MAX", 0)
  {:ok,count}

end

def handle_cast({:printMax, hops,pid},state) do
  state = state-1
  max =elem(Enum.at(Registry.lookup(:OutRegister, "MAX"),0),1)
  cond do
    hops > max ->
      Registry.unregister(:OutRegister, "MAX")
      Registry.register(:OutRegister, "MAX",hops)
    true ->
  end
  if state == 0 do
    maxval = elem(Enum.at(Registry.lookup(:OutRegister, "MAX"),0),1)
    GenServer.cast(pid,{:final,maxval})
  end
  {:noreply,state}

end


def handle_cast({:final,maxval},state) do
  IO.inspect {"max hops", maxval}
  System.stop(0)
  {:noreply,state}
end


end
