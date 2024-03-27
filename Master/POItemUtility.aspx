<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeFile="POItemUtility.aspx.cs" Inherits="Master_POItemUtility" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap-theme.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
     
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel">
            <div class="panel-body">

                <div class="row">
                    <div class="col-lg-12">
                        <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder table" AutoGenerateColumns="false" Width="100%" Style="font-size: 12px; border: thin;" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                            <Columns>
                                <asp:TemplateField HeaderText="No.">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle Width="5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Check">
                                    <ItemTemplate>
                                        <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle Width="5%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Code">
                                    <ItemTemplate>
                                        <asp:Label ID="lblInwardID" Text='<%# Eval("InwardID") %>' runat="server" Visible="false"></asp:Label>
                                        <asp:Label ID="lblItemID" Text='<%# Eval("ItemID") %>' runat="server" Visible="false"></asp:Label>
                                        <asp:Label ID="lblItemCode" Text='<%# Eval("ItemCode") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Item Name">
                                    <ItemTemplate>
                                        <asp:Label ID="lblItemName" Text='<%# Eval("ItemName") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" Width="80px" />
                                    <HeaderStyle Width="35%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Unit">
                                    <ItemTemplate>
                                        <asp:Label ID="lblUnitName" Text='<%# Eval("UnitName") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Order Qty.">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotalQty" Text='<%# Eval("TotalQty","{0:0.00}") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="SubTotal">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTSubTotal" CssClass="lblTSubTotal" runat="server"></asp:Label>
                                    </FooterTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tax">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTax" Text='<%# Eval("Tax","{0:0.00}") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTTax" CssClass="lblTTax" runat="server"></asp:Label>
                                    </FooterTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Total">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotal" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:Label>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <asp:Label ID="lblTTotal" CssClass="lblTTotal" runat="server"></asp:Label>
                                    </FooterTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                    <HeaderStyle Width="10%" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
                <asp:Button Text="Delete" CssClass="btn btn-default" runat="server" TabIndex="3" ID="btnSubmit" OnClick="btnSubmit_Click" />
                <asp:Button ID="btnGenerat" runat="server" Text="Export-Data" TabIndex="4" CssClass="btnGenerat btn btn-default" OnClick="btnGenerat_Click" />
            </div>
        </div>
    </form>
</body>
</html>


