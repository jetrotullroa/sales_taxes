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
    IO.puts "\nINPUT \nQuantity, Product, Price"
    get_sales(SalesTaxes.Server.get_sales(pid))
    formatted_data = input_data |> format_data
    cond do
      "checkout" in formatted_data ->
        IO.puts "\nOUTPUT \nQuantity, Product, Price"
        get_sales(SalesTaxes.Server.get_sales(pid))
        print_sales_taxes(SalesTaxes.Server.get_sales(pid))

      Enum.count(formatted_data) === 3 ->
        [quantity, product, price] = formatted_data
        sale = %{quantity: String.to_integer(quantity), product: product, price: String.to_float(price)}
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

  defp get_sales(sales) do
    cond do
      Enum.count(sales) > 0 ->
        sales
        |> Enum.reverse
        |> Enum.map(fn sale -> IO.puts "#{sale.quantity}, #{sale.product}, #{sale.price}" end)
      true ->
        IO.puts "no sales yet"
    end
  end

  defp print_sales_taxes(sales) do
    total_sales = Enum.map(sales, fn sale -> sale.price end)
    |> Enum.sum
    |> Float.round(2)

    total_sales_with_tax = Enum.map(sales, fn sale -> price_with_tax(sale.product, sale.price) end)
    |> Enum.sum
    |> Float.round(2)

    sales_tax = total_sales_with_tax - total_sales
    |> Float.round(2)

    IO.puts "\nSales Taxes: #{sales_tax} \nTotal: #{total_sales}"
  end

  defp price_with_tax(product, price) do
    product_tax_price = product
    |> String.split(" ")
    |> product_tax(price)

    product_imported_price = product
    |> String.split(" ")
    |> product_imported(price)

    price + product_tax_price + product_imported_price
  end

  defp product_tax(product_name_split, price) do
    cond do
      Enum.any?(product_name_split, fn word -> word in ["chocollate"] end) ->
        0.00
      true ->
        price * 0.10
    end
  end

  defp product_imported(product_name_split, price) do
    cond do
      Enum.any?(product_name_split, fn word -> word in ["import", "imported"] end) ->
        price * 0.05
      true ->
        0.00
    end
  end

end
