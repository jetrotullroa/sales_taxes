defmodule SalesTaxes do

  @moduledoc """
  Documentation for SalesTaxes.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SalesTaxes.hello
      :world

  """


  def init do
    {:ok, pid} = SalesTaxes.Server.start_link
    loop(pid)
  end

  def input_data do
    IO.gets ""
  end

  def loop(pid) do
    IO.puts "Quantity, Product, Price"
    get_sales(pid)
    formatted_data = input_data |> format_data
    cond do
      "checkout" in formatted_data ->
        IO.puts "ending"

      Enum.count(formatted_data) === 3 ->
        [quantity, product, price] = formatted_data
        sale = %{quantity: quantity, product: product, price: price}
        SalesTaxes.Server.add_sale(pid, sale)
        loop(pid)

      true ->
        IO.puts "error"
        loop(pid)

    end
  end

  defp format_data(data) do
    data
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.map(&(String.replace(&1, "\n", "")))
  end

  defp get_sales(pid) do
    sales = SalesTaxes.Server.get_sales(pid)
    cond do
      Enum.count(sales) > 0 ->
        Enum.map(sales, fn sale -> IO.puts "#{sale.quantity}, #{sale.product}, #{sale.price}" end)
      true ->
        IO.puts "no sales yet"
    end
  end

end
