<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ConfirmSalesRetrun.aspx.cs" Inherits="Sales_ConfirmSalesRetrun" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">

        function ViewDetails(OrderNo) {
            $.colorbox({
                width: '80%',
                height: '80%',
                iframe: true,
                href: 'PurchaseRetunItem.aspx?ORETID=' + OrderNo
            });
        }

        function CheckMain(chk) {
            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkCheck').prop('checked', true);
                }
                else {
                    $('.chkCheck').prop('checked', false);
                }
            }
        }

        function CheckValidation() {
            var flag = false;
            $('.gvOrder tr').each(function (row, tr) {
                var row = $(this);
                if (row.find('input[type="checkbox"]').is(':checked')) {
                    flag = true;
                }
            });
            if (flag == false)  // Do not submit form for any unselected row
            {
                ModelMsg('You must select atleast one checkbox.!', 3);
                event.preventDefault();
                return false;
            }
            return true;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
     <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnResendAll" runat="server" Visible="false" Text="Send All" OnClientClick="return CheckValidation();" CssClass="btn btn-default" OnClick="btnResendAll_Click" />
                        <asp:Button ID="btnCancelAll" runat="server" Visible="false" Text="Cancel All" OnClientClick="return CheckValidation();" CssClass="btn btn-default" OnClick="btnCancelAll_Click" />
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
                        <asp:Label ID="Label1" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="form-control">
                            <asp:ListItem Text="Open" Value="O" />
                            <asp:ListItem Text="Confirm" Value="C" />
                            <asp:ListItem Text="Cancel" Value="L" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-default" OnClick="btnSearch_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvOrder" Width="100%" CssClass="gvOrder table" AutoGenerateColumns="false" OnRowCommand="gvOrder_RowCommand" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();" />
                                </ItemTemplate>
                                <HeaderStyle Width="7%" />
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="ID" ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderID" Text='<%# Eval("ORETID") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Bill Ref.No." ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderNo" Text='<%# Eval("BillRefNo") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Date" ItemStyle-Width="10%" HeaderStyle-Width="10%">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd/MM/yyyy}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SubTotal" ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("Amount","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Message" ItemStyle-Width="35%" HeaderStyle-Width="30%">
                                <ItemTemplate>
                                    <asp:Label ID="lblMessage" runat="server" Text='<%# Eval("Ref1") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Send" ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:Button ID="btnResend" runat="server" Text="Send" CommandName="RESEND" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Details" ItemStyle-Width="7%" HeaderStyle-Width="7%">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkViewDetail" runat="server" Text="View Details" OnClientClick="ViewDetails('')" OnClick="lnkViewDetail_Click"/>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>       
        </div>
    </div>
</asp:Content>

