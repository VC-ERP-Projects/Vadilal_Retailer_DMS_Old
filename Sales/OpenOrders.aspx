<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="OpenOrders.aspx.cs" Inherits="Sales_OpenOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function twidth() {
            $('.tdiv').css('max-height', (innerHeight - 100) + "px");
        }

        window.onresize = twidth;

        function Relaod() {

            if ($(".gvItem > tbody tr:first td").text() != 'No Item Found.') {
                $(".gvItem").css('width', '140%');
            }

            twidth();

            $(".txtSearch").keyup(function () {
                var word = this.value;

                $(".gvItem > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
                
                $(".gvDispatch > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" CssClass="form-control" Text="Search" OnClick="btnSearch_Click" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                 <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblOrderType" runat="server" Text="Order Type" CssClass="input-group-addon"></asp:Label>
                          <asp:DropDownList runat="server" ID="ddlType" CssClass="ddlType form-control" >
                            <asp:ListItem Text="Open" Value="O" />
                            <asp:ListItem Text="Delivered" Value="R" />
                    </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsMobile" runat="server" Text="Is Mobile" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsMobile" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="row">
                <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearch form-control" />
                <div style="overflow-x: auto; overflow-y: auto" class="tdiv">
                    <asp:GridView runat="server" Style="max-width: 100%;" ID="gvItem" Visible="false" CssClass="gvItem HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItem_PreRender" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="5%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Bill No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblBillRefNo" Enabled="false" runat="server" Text='<%# Eval("BillRefNo") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Order Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblDate" CssClass="lblDate" Enabled="false" runat="server" Text='<%# Eval("Date","{0:d}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="9%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Customer Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustName" Enabled="false" runat="server" Text='<%# Eval("CustomerName") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="15%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Address">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustAddress" Enabled="false" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Pincode">
                                <ItemTemplate>
                                    <asp:Label ID="lblpincode" Enabled="false" runat="server" Text='<%# Eval("Zipcode") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="7%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Mobile">
                                <ItemTemplate>
                                    <asp:Label ID="lblPhone" Enabled="false" runat="server" Text='<%# Eval("PhoneNumber") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                             <asp:TemplateField HeaderText="SubTotal">
                                <ItemTemplate>
                                    <asp:Label ID="lblSubTotal" CssClass="lblSubTotal" Enabled="false" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Discount">
                                <ItemTemplate>
                                    <asp:Label ID="lblDiscount" CssClass="lblDiscount" Enabled="false" runat="server" Text='<%# Eval("Discount","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="6%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotal" CssClass="lblTotal" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Edit">
                                <ItemTemplate>
                                    <asp:HyperLink runat="server" NavigateUrl='<%# string.Format("~/Sales/SaleDeliveryMCom.aspx?SaleID={0}", HttpUtility.UrlEncode(Eval("SaleID").ToString())) %>'
                                        Text="Edit Details" ToolTip="Click to Delivery" />
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Delete">
                                <ItemTemplate>
                                    <asp:LinkButton Text="Delete" runat="server" ID="btnDelete" OnClick="btnDelete_Click" OnClientClick="return confirm('Are sure you want to Delete this?');">
                                    </asp:LinkButton>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <asp:GridView runat="server" Style="max-width: 100%;" ID="gvDispatch" Visible="false" CssClass="gvDispatch HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvDispatch_PreRender" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex+1 %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="5%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Bill No.">
                                <ItemTemplate>
                                    <asp:Label ID="lblBillRefNo" Enabled="false" runat="server" Text='<%# Eval("BillRefNo") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Order Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblDate" CssClass="lblDate" Enabled="false" runat="server" Text='<%# Eval("Date","{0:d}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="9%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Customer Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustName" Enabled="false" runat="server" Text='<%# Eval("CustomerName") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="15%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Address">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustAddress" Enabled="false" runat="server" Text='<%# Eval("Address") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Pincode">
                                <ItemTemplate>
                                    <asp:Label ID="lblpincode" Enabled="false" runat="server" Text='<%# Eval("Zipcode") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="7%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Mobile">
                                <ItemTemplate>
                                    <asp:Label ID="lblPhone" Enabled="false" runat="server" Text='<%# Eval("PhoneNumber") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SubTotal">
                                <ItemTemplate>
                                    <asp:Label ID="lblSubTotal" CssClass="lblSubTotal" Enabled="false" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Discount">
                                <ItemTemplate>
                                    <asp:Label ID="lblDiscount" CssClass="lblDiscount" Enabled="false" runat="server" Text='<%# Eval("Discount","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="6%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotal" CssClass="lblTotal" Enabled="false" runat="server" Text='<%# Eval("Total","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Confirm">
                                <ItemTemplate>
                                    <asp:LinkButton Text="Confirm" runat="server" ID="btnReceipt" ToolTip="Click to Confirm" OnClick="btnReceipt_Click" >
                                    </asp:LinkButton>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Cancel">
                                <ItemTemplate>
                                    <asp:LinkButton Text="Cancel" runat="server" ID="btnDelete" OnClick="btnDelete_Click" OnClientClick="return confirm('Are sure you want to Cancel this?');">
                                    </asp:LinkButton>
                                </ItemTemplate>
                                <HeaderStyle Width="8%" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

