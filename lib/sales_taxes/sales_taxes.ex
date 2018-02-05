defmodule SalesTaxes do

  alias NimbleCSV.RFC4180, as: CSV


  @doc """
  start the process and pass to pid to loop function to manage state
  """
  def start do
    {:ok, pid} = SalesTaxes.Server.start_link
    loop(pid)
  end

  @doc """
  loop function that handle response base on the input.

  Input should be "checkout" or a three valaue string that is separated by a comma(",").

  If "checkout" returns the output of calculated sales taxes data.

  If Three valaue string that is separated by a comma(",") loop through the input and save the state of data.

  Else Any invalid input will return an "error" message
  """
  def loop(pid) do
    # set the table like iput
    IO.puts "\nINPUT \nQuantity, Product, Price"
    # set the state of sales
    get_sales(SalesTaxes.Server.get_sales(pid))
    # input data that automatically formatted
    formatted_data = input_data |> format_data
    cond do
      # input is "checkout"
      "checkout" in formatted_data ->
        IO.puts "\nOUTPUT \nQuantity, Product, Price"
        output_sales_with_tax(SalesTaxes.Server.get_sales(pid))
        print_sales_taxes_output(SalesTaxes.Server.get_sales(pid))

      # input is a normal 3 value string separated by commas(",")
      Enum.count(formatted_data) === 3 ->
        [quantity, product, price] = formatted_data
        sale = %{quantity: String.to_integer(quantity), product: product, price: price |> String.to_float}
        SalesTaxes.Server.add_sale(pid, sale)
        loop(pid)

      # input is not valid
      true ->
        IO.puts "error"
        loop(pid)

    end
  end

  defp input_data do
    IO.gets ""
  end


  defp get_sales(sales) do
    cond do
      Enum.count(sales) > 0 ->
        sales
        |> Enum.reverse
        |> Enum.map(fn sale -> IO.puts "#{sale.quantity}, #{sale.product}, #{sale.price |> float_precision}" end)
      true ->
        IO.puts "no sales yet"
    end
  end

  defp format_data(data) do
    data
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.map(&(String.replace(&1, "\n", "")))
  end

  defp output_sales_with_tax(sales) do
    sales
    |> Enum.reverse
    |> Enum.map(fn sale -> IO.puts "#{sale.quantity}, #{sale.product}, #{price_with_tax(sale.product, sale.price) |> float_precision}" end)
  end

  defp print_sales_taxes_output(sales) do
    total_sales = Enum.map(sales, fn sale -> sale.price end)
    |> Enum.sum

    total_sales_with_tax = Enum.map(sales, fn sale -> price_with_tax(sale.product, sale.price) end)
    |> Enum.sum


    sales_tax = total_sales_with_tax - total_sales

    IO.puts "\nSales Taxes: #{sales_tax |> float_precision} \nTotal: #{total_sales_with_tax |> float_precision}"
  end

  defp price_with_tax(product, price) do
    product_tax_price = product
    |> String.split(" ")
    |> product_tax(price)


    product_imported_price = product
    |> String.split(" ")
    |> product_imported(price)

    price + product_tax_price + product_imported_price
    |> Float.round(2)
  end

  defp product_tax(product_name_split, price) do
    cond do
      Enum.any?(product_name_split, fn word -> word in non_taxable_products end) ->
        0.00
      true ->
        # n%p / 100
        10 * price / 100
        |> round_tax_price
    end
  end

  defp product_imported(product_name_split, price) do
    cond do
      Enum.any?(product_name_split, fn word -> word in ["import", "imported"] end) ->
        # n%p / 100
        5 * price / 100
        |> round_tax_price
      true ->
        0.00
    end
  end

  defp non_taxable_products do
    "non_taxable_products.csv"
    |> File.read!
    |> CSV.parse_string
    |> Enum.map(fn [_id, product, _category] -> product end)
  end

  defp float_precision(num) do
    num
    |> :erlang.float_to_binary(decimals: 2)
  end

  defp round_tax_price(number) do
    # round to 2 decimal places
    # get the number after decimal
    # check if divisible by 5

    [w, d] = number
    |> Float.round(2)
    |> float_precision
    |> String.split(".")

    {whole, _} = w |> Integer.parse
    {decimal, _} = d |> Integer.parse

    rem_by_five = rem(decimal, 5)
    rem_by_ten = rem(decimal, 10)

    cond do
      # decimal is divisible by 5
      rem_by_five == 0 ->
        "#{whole}.#{decimal}" |> String.to_float
      rem_by_ten > 5 ->
        new_remainder = decimal + (10 - rem_by_ten)
        "#{whole}.#{new_remainder}" |> String.to_float
      # decimal rem_by_five is lesser than 3
      rem_by_five < 3 ->
        new_remainder = decimal - rem_by_five
        "#{whole}.#{new_remainder}" |> String.to_float
      # decimal rem_by_five is greater than 3
      true ->
        new_remainder = decimal + (5 - rem_by_five)
        "#{whole}.#{new_remainder}" |> String.to_float
    end

  end
end
