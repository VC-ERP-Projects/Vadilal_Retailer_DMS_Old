<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SalesOrderData.aspx.cs" Inherits="Sales_SalesOrderData" %>

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
    <script type="text/javascript">

        $(function () {
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function ReLoadFn() {

            //var table = $('.gvOrder').DataTable();
            var aryJSONColTable = [];

            aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "width": "20px", "sClass": "CustName", "aTargets": 2 });
            aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 3 });
            aryJSONColTable.push({ "width": "120px", "aTargets": 4 });
            aryJSONColTable.push({ "width": "15px", "aTargets": 5 });
            aryJSONColTable.push({ "width": "40px", "aTargets": 6 });
            aryJSONColTable.push({ "width": "30px", "aTargets": 7 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "width": "30px", "aTargets": 8 });
            aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
            aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 10 });
            //aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 10 });
            //aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 11 });
            //aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 12 });
            //aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 13 });
            //aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 14 });
            setTimeout(function () {
                $('.gvOrder').DataTable({
                    bFilter: false,
                    scrollCollapse: true,
                    "sExtends": "collection",
                    scrollX: true,
                    scrollY: '63vh',
                    responsive: true,
                    "bPaginate": false,
                    ordering: false,
                    "bInfo": true,
                    "autoWidth": false,
                    destroy: true,
                    responsive: true,
                    "aoColumnDefs": aryJSONColTable,
                });
            }, 500);

            $(".txtgvItemSearch").keyup(function () {
                var word = this.value;
                $(".gvOrder > tbody tr").not(':first').each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();

                });
            });
        }

        function _btnCheckCancel() {

            if (confirm('Are you sure you want to cancel order?')) {

                if ($('.chkCheck:checked').length == 0) {
                    ModelMsg('Please Select at least one checkbox for cancel', 3);
                    return false;
                }
                return true;
            }
            else {
                return false;
            }

        }

        function OpenInvoice(saleid, parentid) {
            window.open("../Sales/SaleDirect.aspx?DocNo=" + saleid + "&DocKey=" + parentid);
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

    </script>
    <style>
        /*#page-content-wrapper {
            overflow: hidden;
        }*/

        /*.dataTables_scrollHeadInner {
            width: auto;
        }*/
        body {
            overflow: hidden; /* Hide scrollbars */
        }
          .dataTables_scrollBody {
            overflow-x: hidden !important;
        }
        .dataTables_scroll {
            overflow: auto;
        }

        table.dataTable thead th.dtbodySrNo {
            padding: 5px 10px !important;
        }
          table.dataTable thead th {
            padding-right:3px !important;
        }
        .dtbodyRight {
            text-align: right !important;
            margin-right:2px !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            /*padding: 4px 0px 0px 2px !important;*/
            padding:0px;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        .tdleftalign {
            margin-left: 2px !important;
        }

        .tdrightalign {
            margin-right: 2px !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }
        /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDocNo" runat="server" Text="Order Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtDocNo" TabIndex="2" CssClass="form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetSalesOrderNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="5" CssClass="btn btn-info" OnClick="btnSearch_Click" />
                        &nbsp;&nbsp;
                         <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="6" CssClass="btnCancel btn btn-danger" OnClientClick="return _btnCheckCancel();" OnClick="btnCancel_Click" />

                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblOrderType" runat="server" Text="Order Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="drpOrderType" runat="server" CssClass="drpOrderType form-control">
                            <asp:ListItem Text="Open Order" Value="11"></asp:ListItem>
                            <asp:ListItem Text="Cancel Order" Value="14"></asp:ListItem>
                            <asp:ListItem Text="Open SO" Value="15"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:TextBox runat="server" placeholder="Search here" ID="txtgvItemSearch" TabIndex="9" CssClass="txtgvItemSearch form-control" Style="display: inline-block; width: 216%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="2" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div id="divEmpDiscountEntry" class="divEmpDiscountEntry" runat="server" style="max-height: 55vh;">
                        <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder table tbl table-striped table-bordered datatable" Width="100%" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found." Font-Size="11px" OnPreRender="gvOrder_PreRender">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr.">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Invoice No" HeaderStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOrderID" Text='<%# Eval("OrderID") %>' runat="server" Visible="false"></asp:Label>
                                        <asp:Label ID="lblInvNo" Text='<%# Eval("InvoiceNumber") %>' runat="server" Visible="false"></asp:Label>
                                        <asp:LinkButton ID="lnkInvNo" Text='<%# Eval("InvoiceNumber") %>' PostBackUrl='<%# string.Format("~/Sales/SaleDirect.aspx?DocNo={0}&DocKey={1}&Type={2}",Eval("OrderID"),Eval("ParentID"),Eval("Type"))%>' runat="server" CssClass="tdleftalign"></asp:LinkButton>
                                    </ItemTemplate>
                                    <HeaderStyle Width="10%" HorizontalAlign="Left" CssClass="CustName"/>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Date">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd-MMM-yy}") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle Width="10%" HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer" ItemStyle-CssClass="CustName" HeaderStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCust" Text='<%# Eval("CustomerName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle  HorizontalAlign="Left" CssClass="CustName" />
                                </asp:TemplateField>
                                 <asp:TemplateField HeaderText="Qty" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" runat="server" Text='<%# Eval("Qty","{0:0}") %>' CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle Width="15%" HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Gross Amount" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("SubTotal","{0:0.00}") %>' CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle Width="15%" HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="GST Amount" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTax" Text='<%# Eval("Tax","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle Width="15%" HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Net Amount" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotal" Text='<%# Eval("Total","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle Width="15%" HorizontalAlign="Right" />
                                </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Created By" ItemStyle-CssClass="CustName" HeaderStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCreated" Text='<%# Eval("CreatedBy") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle  HorizontalAlign="Left" CssClass="CustName" />
                                </asp:TemplateField>
                                 <asp:TemplateField HeaderText="Created Date/Time" >
                                    <ItemTemplate>
                                        <asp:Label ID="lblCreateDatetime" Text='<%# Eval("CreateDate") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <HeaderStyle  HorizontalAlign="Left" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div id="pager" style="display: none;">
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


