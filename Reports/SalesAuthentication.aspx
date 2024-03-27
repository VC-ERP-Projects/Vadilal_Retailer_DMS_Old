<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SalesAuthentication.aspx.cs" Inherits="Reports_SalesAuthentication" MasterPageFile="~/OutletMaster.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" TabIndex="1" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" CssClass="form-control" TabIndex="2" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" TabIndex="5" OnClick="btnGenerat_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" MaxLength="10" TabIndex="3" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="IsAuthenticated" ID="lblIsauth" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" CssClass="form-control" TabIndex="4" ID="ddlIsAuthenticated">
                            <asp:ListItem Value="2">----Select----</asp:ListItem>
                            <asp:ListItem Value="1">Yes</asp:ListItem>
                            <asp:ListItem Value="0">No</asp:ListItem>
                        </asp:DropDownList>

                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvSalesAuth" CssClass="gvAsset table" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="Record Not Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="Sale Number">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderID" Text='<%# Eval("SaleID") %>' runat="server" Visible="true"></asp:Label>
                                </ItemTemplate>
                                  <ItemStyle HorizontalAlign="Right" />  
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd/MM/yyyy}") %>'></asp:Label>
                                </ItemTemplate>
                                  <ItemStyle HorizontalAlign="Center" />  
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Comment">
                                <ItemTemplate>
                                    <asp:Label ID="lblComment" Text='<%# Eval("Comment") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                  <ItemStyle HorizontalAlign="Left" />  
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                                </ItemTemplate>
                                  <ItemStyle HorizontalAlign="Left" />  
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Employee Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblTax" Text='<%# Eval("Name") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                  <ItemStyle HorizontalAlign="Left" />  
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>