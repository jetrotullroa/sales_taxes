defmodule SalesTaxes.Server do
  use GenServer

  def start_link do
    GenServer.start_link __MODULE__, []
  end

  def get_sales(pid) do
    GenServer.call pid, :get_sales
  end

  def add_sale(pid, sale) do
    GenServer.cast pid, {:add_sale, sale}
  end

  ####
  # Genserver implementation

  def handle_call(:get_sales, _from, products) do
    {:reply, products, products}
  end

  def handle_cast({:add_sale, sale}, sales) do
    {:noreply, [sale | sales]}
  end
end
