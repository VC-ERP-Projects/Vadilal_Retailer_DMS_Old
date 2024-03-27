<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmployeeHeirarchyList.aspx.cs" Inherits="Reports_EmployeeHeirarchyList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <script type="text/javascript">

        var UserID = '<% =UserID%>';

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-0-0-" + EmpID);
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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

        function Reload() {

            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvEmpHeiList thead tr').length > 0) {

                var table = $('.gvEmpHeiList').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyTop", "aTargets": 1 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyTop", "aTargets": 2 });
                //aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyTop", "aTargets": 3 });
                //aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyTop", "aTargets": 4 });
                aryJSONColTable.push({ "width": "68px", "sClass": "dtbodyTop", "aTargets": 3 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyTop", "aTargets": 4 });
                aryJSONColTable.push({ "width": "71px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({
                    "width": "230px", "sClass": "dtbodyTop", "aTargets": 7, "mRender": function (data, type, row) {
                        return data.split("#").join("<br/> ");
                    },
                });
                aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyTop", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyTop", "aTargets": 10 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyTop", "aTargets": 11 });
                aryJSONColTable.push({ "width": "83px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyTop", "aTargets": 13 });
                aryJSONColTable.push({ "width": "65px", "sClass": "dtbodyCenter", "aTargets": 14 });
                $('.gvEmpHeiList').DataTable(
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
                        "aoColumnDefs": aryJSONColTable,
                        buttons: [{ extend: 'copy', footer: true },
                        {
                            extend: 'csv', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                data = 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split("-")[0] + " - " + $('.txtCode').val().split("-")[1] : "All") + '\n';
                                data += 'Employee Type,' + (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") + '\n';
                                data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                data += 'Created On,' + jsDate.toString() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                format: {
                                    body: function (data, row, column, node) {
                                        //check if type is input using jquery
                                        if (column == 7) {
                                            return data.replace(/<br\s*\/?>/gi, " ").replace("&nbsp;", " ");
                                        }
                                        else {
                                            return (data == "&nbsp;" || data == "") ? " " : data;
                                        }
                                    }
                                }
                            }
                        },
                            {
                                extend: 'excel', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {
                                    sheet = ExportXLS(xlsx, 5);
                                    var r0 = Addrow(1, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split("-")[0] + " - " + $('.txtCode').val().split("-")[1] : "All") }]);
                                    var r2 = Addrow(2, [{ key: 'A', value: 'Employee Type' }, { key: 'B', value: (($('.ddlEmpType').val() > 0 && $('.ddlEmpType').val() != "") ? $('.ddlEmpType option:Selected').text() : "All Employee Type") }]);
                                    var r3 = Addrow(3, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r4 = Addrow(4, [{ key: 'A', value: 'Created On' }, { key: 'B', value: jsDate.toString() }]);
                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
                                },
                                exportOptions: {
                                    format: {
                                        body: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            if (column == 7) {
                                                return data.replace(/<br\s*\/?>/gi, " ").replace("&nbsp;", " ");
                                            }
                                            else {
                                                return (data == "&nbsp;" || data == "") ? " " : data;
                                            }
                                        }
                                    }
                                }
                            }]
                    });
            }
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
            }
        }

    </script>
    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .dtbodyTop {
            vertical-align: top !important;
        }

        .dtbodyRight {
            text-align: right !important;
            vertical-align: top !important;
        }

        .dtbodyCenter {
            text-align: center !important;
            vertical-align: top !important;
        }

        table.dataTable thead th.dtbodyRight {
            padding: 10px 18px;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding-left: 3PX;
            text-align: left;
            vertical-align: middle !important;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding-left: 3px;
            vertical-align: top !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Employee Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlEmpType" class="ddlEmpType" runat="server" CssClass="ddlEmpType form-control" TabIndex="1">
                            <asp:ListItem Text="Both" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Company Employee" Value="2"></asp:ListItem>
                            <asp:ListItem Text="3rd Party Employee" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblActive" Text="Active Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlActive" CssClass="ddlActive form-control" TabIndex="4">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvEmpHeiList" runat="server" CssClass="gvEmpHeiList table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvEmpHeiList_PreRender" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

