<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DateWiseDispatchSumm.aspx.cs" Inherits="Reports_DateWiseDispatchSumm" %>

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

    <script type="text/javascript">

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(key + "-0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            Reload();
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor();
            Reload();
        }

        function ChangeReportFor(ddl) {
            if (CustType == 1 && $('.ddlSaleBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if (CustType == 1 && $('.ddlSaleBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }

        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }
        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function Reload() {

            if ($('.gvgrid thead tr').length > 0) {
                var table = $('.gvgrid').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                aryJSONColTable.push({ "width": "15px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 7 });

                for (var i = 8; i < colCount; i++) {

                    aryJSONColTable.push({
                        "aTargets": [i],
                        "sClass": "dtbodyRight",
                        "width": "50px"
                    });

                }
                $('.gvgrid').DataTable(
                        {
                            bFilter: true,
                            scrollCollapse: true,
                            "stripeClasses": ['odd-row', 'even-row'],
                            destroy: true,
                            scrollY: '50vh',
                            scrollX: true,
                            responsive: true,
                            "aaSorting": [],
                            dom: 'Bfrtip',
                            "bPaginate": false,
                            "aoColumnDefs": aryJSONColTable,
                            buttons: [{ extend: 'copy', footer: true },
                                {
                                    extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                    customize: function (csv) {
                                        var data = $("#lnkTitle").text() + '\n';
                                        data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                        data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") + '\n';
                                        data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(0, 2) : "") + '\n';
                                        if ($('.ddlSaleBy').val() == "2")
                                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                        if ($('.ddlSaleBy').val() == "4")
                                            data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                        data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                        data += 'SaleBy,' + $('.ddlSaleBy option:Selected').text() + '\n';
                                        data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                        data += 'Created on,' + jsDate.toString() + '\n';
                                        return data + csv;
                                    },
                                    exportOptions: {
                                        format: {
                                            body: function (data, row, column, node) {
                                                //check if type is input using jquery
                                                return (data == "&nbsp;" || data == "") ? " " : data;
                                                var D = data;
                                            }
                                        }
                                    }
                                },
                                {
                                    extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                    customize: function (xlsx) {
                                        sheet = ExportXLS(xlsx, 10);

                                        var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                        var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                        var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") }]);
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(0, 2) : "All Plant") }]);
                                        if ($('.ddlSaleBy').val() == "2")
                                            var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                        if ($('.ddlSaleBy').val() == "4")
                                            var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                        var r5 = Addrow(6, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                        var r6 = Addrow(7, [{ key: 'A', value: 'SaleBy' }, { key: 'B', value: $('.ddlSaleBy option:Selected').text() }]);
                                        var r7 = Addrow(8, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                        var r8 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);

                                        sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                                    }
                                }]
                        }
                    );
            }
        }
    </script>
    <style>
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }
    </style>
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
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="4" ID="ddlSaleBy" CssClass="ddlSaleBy form-control" onchange="ChangeReportFor(this);">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Selected="True" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPlant" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="8" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        &nbsp; &nbsp; 
                        <span style="color: red; font-weight: bold">Report Processed only 45 Days.</span>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvgrid" runat="server" CssClass="gvgrid  table" Width="100%" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvgrid_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

