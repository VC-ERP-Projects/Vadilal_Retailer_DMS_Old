<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeFile="PurchaseRetunItem.aspx.cs" Inherits="Purchase_PurchaseRetunItem" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/base.css" rel="stylesheet" type="text/css" />
    <link href="../css/index.css" rel="stylesheet" type="text/css" />
    <script src="../Scripts/jquery-1.11.2.min.js" type="text/javascript"></script>
    <script src="../Scripts/index.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div style="width: 100%; text-align: center;">
            <asp:GridView runat="server" ID="gvItemDetail" Width="100%" CssClass="gvItemDetail table" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                <HeaderStyle CssClass="table-header" />
                <Columns>
                    <asp:TemplateField HeaderText="Item Code" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblOrderID" Text='<%# Eval("OITM.ItemCode") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Item Name" HeaderStyle-Width="20%">
                        <ItemTemplate>
                            <asp:Label ID="lblItemName" Text='<%# Eval("OITM.ItemName") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="UnitPrice" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblUnitPrice" Text='<%# Eval("UnitPrice","{0:0.00}") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Quantity" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblUnitPrice" Text='<%# Eval("Quantity","{0:0}") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="SubTotal" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblSubTotal" Text='<%# Eval("SubTotal","{0:0.00}") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Tax" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblTax" Text='<%# Eval("Tax","{0:0.00}") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Total" HeaderStyle-Width="7%">
                        <ItemTemplate>
                            <asp:Label ID="lblTotal" Text='<%# Eval("Total","{0:0.00}") %>' runat="server"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>
