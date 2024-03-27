<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseOrderRpt.aspx.cs" Inherits="Reports_PurchaseOrderRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    

       <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <style type="text/css">
        .pagination-ys {
            /*display: inline-block;*/
            padding-left: 0;
            margin: 20px 0;
            border-radius: 4px;
        }
        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 0px !important;
        }
            .pagination-ys table > tbody > tr > td {
                display: inline;
                 padding: 10px 10px !important;
            }

        .pagination-ys table > tbody > tr > td > a,
        .pagination-ys table > tbody > tr > td > span {
            position: relative;
            float: left;
            padding: 8px 12px;
            line-height: 1.42857143;
            text-decoration: none;
            color: #000000;
            background-color: #ffffff;
            border: 1px solid #dddddd;
            margin-left: -1px;
        }

                .pagination-ys table > tbody > tr > td > span {
                    position: relative;
                    float: left;
                    padding: 8px 12px;
                    line-height: 1.42857143;
                    text-decoration: none;
                    margin-left: -1px;
                    z-index: 2;
                    color: #aea79f;
                    background-color: #f5f5f5;
                    border-color: #dddddd;
                    cursor: default;
                }

                .pagination-ys table > tbody > tr > td:first-child > a,
                .pagination-ys table > tbody > tr > td:first-child > span {
                    margin-left: 0;
                    border-bottom-left-radius: 4px;
                    border-top-left-radius: 4px;
                }

                .pagination-ys table > tbody > tr > td:last-child > a,
                .pagination-ys table > tbody > tr > td:last-child > span {
                    border-bottom-right-radius: 4px;
                    border-top-right-radius: 4px;
                }
                .dtbodyRight {
            text-align: right !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

                .pagination-ys table > tbody > tr > td > a:hover,
                .pagination-ys table > tbody > tr > td > span:hover,
                .pagination-ys table > tbody > tr > td > a:focus,
                .pagination-ys table > tbody > tr > td > span:focus {
                    color: #97310e;
                    background-color: #eeeeee;
                    border-color: #dddddd;
                }
    </style>
    <script type="text/javascript">
        $(function () {
            laod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            laod();
        }

        function acetxtDocNumber_OnClientPopulating(sender, args) {

            var plt = $('.txtCustCode').val().split('-').pop();

            sender.set_contextKey($('.ddltype').val() + "," + plt);
        }

        //function OpenInvoices(OrderNo, DistributorID,DivisionID) {
        function OpenInvoices(OrderNo, DistributorID) {
            $.colorbox({
                width: '80%',
                height: '80%',
                iframe: true,
                href: '../Reports/ViewReport.aspx?PONumber=' + OrderNo + '&CompCust=' + DistributorID 
            });
        }
        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function laod() {
           // $('.gvOrder').DataTable();
            $(".txtgvItemSearch").keyup(function () {
                var word = this.value;
                $(".gvOrder > tbody tr").not(':first').each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();

                });
            });

            Hidebtn();
        }

        function Hidebtn() {
            if ($(".ddltype").val() == "5") {
                $(".btnGenerat").hide();
            }
            else
                $(".btnGenerat").show();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Inward Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddltype" TabIndex="3" CssClass="ddltype form-control" onchange="Hidebtn(); return false;">
                            <asp:ListItem Text="Only PO Entry" Value="1" />
                            <asp:ListItem Text="Invoice Created But Reciept Pending" Value="2" />
                            <asp:ListItem Text="Invoice Already Recieved" Value="3" />
                            <asp:ListItem Text="Direct Reciept" Value="4" />
                            <asp:ListItem Text="Cancel" Value="5" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDocNo" runat="server" Text="Inward Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtDocNo" TabIndex="4" CssClass="form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetInwardReportNo" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDocNumber_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <%--  <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" Visible="false" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" Visible="false" ID="ddlDivision" TabIndex="5" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>--%>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="5" CssClass="txtCustCode form-control" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <%-- <div style="display: inline-block; width: 100%; margin-bottom: 1%;">--%>

                    <%--  </div>--%>
                    <div class="input-group form-group">
                        <asp:TextBox runat="server" placeholder="Search here" TabIndex="6" ID="txtgvItemSearch" CssClass="txtgvItemSearch" Style="display: inline-block; width: 45%; margin-bottom: 1%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                        &nbsp;
                        <asp:Button ID="btnSearch" runat="server" TabIndex="7" Text="Search" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                        &nbsp;
                        <asp:Button ID="btnGenerat" runat="server" TabIndex="8" Text="Generate" CssClass="btn btn-default btnGenerat" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder table" Font-Size="11px" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                        <Columns>
                            <asp:TemplateField HeaderText="Check">
                                <HeaderTemplate>
                                    <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="PO Number" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblOrderID" Text='<%# Eval("OrderID") %>' runat="server" Visible="false"></asp:Label>
                                    <asp:Label ID="lblOrderNo" Text='<%# Eval("InvoiceNumber") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Bill Number" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Label ID="lblBillNumber" runat="server" Text='<%# Eval("BillRefNo") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="GST Invoice No" ItemStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblGSTInvNO" runat="server" Text='<%# Eval("GSTInvNo") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="PO Date" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd-MMM-yyyy}") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Receive Date" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Label ID="lblReceiveDate" runat="server" Text='<%# Eval("ReceiveDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Cancel / Update Date">
                                <ItemTemplate>
                                    <asp:Label ID="lblCancelDate" runat="server" Text='<%# Eval("UpdatedDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Discount" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblDiscount" Text='<%# Eval("Discount","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="SubTotal" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("SubTotal","{0:0.00}")%>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="GST" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblTax" Text='<%# Eval("Tax","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Net Amount" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotal" Text='<%# Eval("Total","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Paid" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblPaid" Text='<%# Eval("Paid","{0:0.00}") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Pending" HeaderStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:Label ID="lblPending" runat="server" Text='<%# Eval("Pending","{0:0.00}") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                        </Columns>
                        <PagerSettings Mode="NumericFirstLast" FirstPageText="<<" LastPageText=">>" PageButtonCount="5" />
                        <PagerStyle CssClass="pagination-ys" BackColor="#F84D32" Font-Bold="true" Height="25px" VerticalAlign="Bottom" HorizontalAlign="Center" />
                    </asp:GridView>
                    <div id="pager">
                        <asp:Repeater ID="rptPager" runat="server">
                            <ItemTemplate>
                                <asp:LinkButton ID="lknPage" runat="server" Text='<%# Eval("Text") %>' CommandArgument='<%# Eval("Value") %>'
                                    CommandName='<%# Eval("Text") %>' OnClick="Page_Changed" EnableTheming="false"> </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>

