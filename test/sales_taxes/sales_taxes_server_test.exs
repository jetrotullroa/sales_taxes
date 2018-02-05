defmodule SalesTaxesTest.Server do
  use ExUnit.Case

  @valid_data1 %{quantity: "1", product: "banana", price: 21.30}
  @valid_data2 %{quantity: "3", product: "imported perfume", price: 35.30}

  test "start_link/0 start a new process" do
    {:ok, pid} = SalesTaxes.Server.start_link
    assert Process.alive?(pid)
  end

  test "get_sales/1 returns the state" do
    {:ok, pid} = SalesTaxes.Server.start_link
    assert [] == SalesTaxes.Server.get_sales(pid)
  end

  test "add_sale/2 add sales to state" do
    {:ok, pid} = SalesTaxes.Server.start_link
    SalesTaxes.Server.add_sale(pid, @valid_data1)
    SalesTaxes.Server.add_sale(pid, @valid_data2)
    assert [@valid_data2, @valid_data1] == SalesTaxes.Server.get_sales(pid)
  end

end
