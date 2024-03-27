<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SalesInvioce.aspx.cs" Inherits="Reports_SalesRetailInvioce" %>

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
        
        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;

        $(function () {
            ReLoadFn();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            //$('.gvOrder').tableHeadFixer('65vh');
            //$('.divCustEntry').tableHeadFixer('65vh');
            $(".gvOrder").tableHeadFixer('52vh');
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
        }

        function OpenInvoices(OrderNo, CustomerID, PrintSize, IsOld) {
            $.colorbox({
                width: '85%',
                height: '85%',
                iframe: true,
                href: '../Reports/ViewReport.aspx?SalesOrderNo=' + OrderNo + '&CompCust=' + CustomerID + '&SalesOrderPageSize=' + PrintSize + '&SalesOrderIsOld=' + IsOld
            });
        }

        function OpenTripReport(OrderNo, CustomerID) {
            $.colorbox({
                width: '85%',
                height: '85%',
                iframe: true,
                href: '../Reports/ViewReport.aspx?TripReportOrderNo=' + OrderNo + '&CompCust=' + CustomerID
            });
        }

        function OpenSalesRegister(OrderNo, CustomerID) {
            $.colorbox({
                width: '85%',
                height: '85%',
                iframe: true,
                href: '../Reports/ViewReport.aspx?SalesRegisterOrderNo=' + OrderNo + '&CompCust=' + CustomerID
            });
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }
        $(document).ready(function () {
            $('.gvOrder').DataTable();       //capital "D"
        });
        function ReLoadFn() {
            var table = $('.gvOrder').DataTable();
            var aryJSONColTable = [];

            aryJSONColTable.push({ "bSortable": "false","width": "30px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "bSortable": "false","width": "30px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "bSortable": "false","width": "30px", "aTargets": 2 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px", "sClass": "dtbodyCenter",  "aTargets": 3 });
            aryJSONColTable.push({ "bSortable": "false","width": "35px", "aTargets": 4 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px","sClass": "dtbodyCenter", "aTargets": 5 });
            aryJSONColTable.push({ "bSortable": "false","width": "50px", "aTargets": 6 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "bSortable": "false","width": "150px", "aTargets": 7 });
            aryJSONColTable.push({ "bSortable": "false","width": "20px","sClass": "dtbodyRight", "aTargets": 8 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px","sClass": "dtbodyRight", "aTargets": 9 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px", "sClass": "dtbodyRight","aTargets": 10 });
            aryJSONColTable.push({ "bSortable": "false","width": "30px", "sClass": "dtbodyRight","aTargets": 11 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px","sClass": "dtbodyRight", "aTargets": 12 });
            aryJSONColTable.push({ "bSortable": "false","width": "40px","sClass": "dtbodyRight", "aTargets": 13 });
            aryJSONColTable.push({ "bSortable": "false","width": "35px","sClass": "dtbodyRight", "aTargets": 14 });
           
            $('.gvOrder').DataTable({
                bFilter: false,
                scrollCollapse: false,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '53vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": true,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
                "ordering": false,
                "bSort": false ,
            });
            $('.dataTables_scrollFoot').css('overflow', 'auto');
            $($.fn.dataTable.tables(true)).DataTable().columns.adjust();
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

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtCustCode').is(":visible") ? $('.txtCustCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtCustCode').is(":visible") ? $('.txtCustCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-0-" + "0" + "-" + EmpID);
        }
        function ChangeReportFor(ReportBy) {

            if ($('.ddlReportBy').val() == "4") {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }

        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }
        
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtCustCode").val('');
                $(".txtSSDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtVehicle").val('');
                $(".txtDocNo").val('');
            }
        }

        function ClearOtherDistConfig() {
            if ($(".txtCustCode").length > 0) {
                $(".txtDealerCode").val('');
            }
        }

        function ClearOtherSSConfig() {
            if ($(".txtSSDistCode").length > 0) {
                $(".txtCustCode").val('');
            }
        }

    </script>
    <style>
       

         #page-content-wrapper {
            overflow: hidden;
        }
         .dataTables_scrollHeadInner {
            width: auto;
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

        .dtbodyRight {
            text-align: right !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            padding: 0px !important;
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
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" onchange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Report By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="4" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" onchange="ClearOtherSSConfig()" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divCustomer" runat="server">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" onchange="ClearOtherDistConfig()" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Order Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddltype" TabIndex="8" CssClass="form-control">
                            <asp:ListItem Text="Open Order" Value="11" />
                            <asp:ListItem Text="Dispatch Order" Value="12" />
                            <asp:ListItem Text="Direct Sale" Value="13" />
                            <asp:ListItem Text="Direct + Order Sales" Value="-1" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDocNo" runat="server" Text="Order Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtDocNo" TabIndex="9" CssClass="txtDocNo form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDocNumber" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetOrderNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDocNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divvehicle" runat="server">
                        <asp:Label Text="Vehicle No." ID="lblVehicle" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtVehicle" TabIndex="10" CssClass="txtVehicle form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtVehicle" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveVehicle" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVehicle">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label ID="lblPrintSize" runat="server" Text="Print Size" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlPrintSize" CssClass="form-control">
                            <asp:ListItem Text="A4 - Full Page" Value="A4" Selected="True" />
                            <asp:ListItem Text="A5 - Half Page" Value="A5" />
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="10" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Sales Invoice" TabIndex="11" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                    <asp:Button ID="btnTripReport" runat="server" Text="Vehicle Summary" TabIndex="12" CssClass="btn btn-info" OnClick="btnTripReport_Click" />
                    <asp:Button ID="btnSalesRegister" runat="server" Text="Customer Summary" TabIndex="13" CssClass="btn btn-info" OnClick="btnSalesRegister_Click" />
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:Button ID="btnJsonDownload" runat="server" Text="Download Json File" TabIndex="14" CssClass="btn btn-primary" OnClientClick="return _btnCheck();" OnClick="btnJsonDownload_Click" ToolTip="Json File Creation For E-Invoice & Upload to GST Server"/>
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" ID="txtgvItemSearch" TabIndex="14" CssClass="txtgvItemSearch" Style="display: inline-block; width: 100%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div id="divEmpDiscountEntry" class="divEmpDiscountEntry" runat="server" style="max-height: 50vh;">
                        <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder table tbl" Width="100%" AutoGenerateColumns="false" Style="border-collapse: collapse;" Font-Size="11px" HeaderStyle-CssClass="table-header-gradient"  OnPreRender="gvOrder_Prerender">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Check" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="60px">
                                    <HeaderTemplate>
                                        <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" visible='<%# (Eval("PrintFlag").ToString() == "1" ? true : false) %>' onchange="ReloadRadio();" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Order No" HeaderStyle-Width="84px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblober" Text='<%# Eval("OrderNumber") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                        <asp:Label ID="lblParentID" Text='<%# Eval("ParentID") %>' runat="server" Visible="false" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Order Date" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="57px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblndate" Text='<%# Eval("OrderDate","{0:dd-MMM-yyyy}") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Invoice No" HeaderStyle-Width="80px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblOrderID" Text='<%# Eval("SaleID") %>' runat="server" Visible="false"></asp:Label>
                                        <asp:Label ID="lblnber" Text='<%# Eval("InvoiceNumber") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Invoice Date" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="99px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("Date","{0:dd-MMM-yyyy}") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Vehicle No">
                                    <ItemTemplate>
                                        <asp:Label ID="lblVehicleNo" Text='<%# Eval("VehicleNumber") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer" ItemStyle-CssClass="CustName">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCust" Text='<%# Eval("CustomerName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>

                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Qty" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" Text='<%# Eval("Qty","{0:0}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />

                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Gross Amt" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSubTotal" runat="server" Text='<%# Eval("GroassAmt","{0:0.00}") %>' CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Discount Amt" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDisc" Text='<%# Eval("Scheme","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="GST" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblGST" Text='<%# Eval("Tax","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Net Amt" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNet" Text='<%# Eval("Total","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Paid Amt" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPaid" Text='<%# Eval("Paid","{0:0.00}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Pending Amt" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPending" runat="server" Text='<%# Eval("Pending","{0:0.00}") %>' CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </div>
        </div>
    </div>
    <div id="pager" style="display: none;">
        <asp:Repeater ID="rptPager" runat="server">
            <ItemTemplate>
                <asp:LinkButton ID="lknPage" runat="server" Text='<%# Eval("Text") %>' CommandArgument='<%# Eval("Value") %>'
                    CommandName='<%# Eval("Text") %>' OnClick="Page_Changed" EnableTheming="false"> </asp:LinkButton>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>


