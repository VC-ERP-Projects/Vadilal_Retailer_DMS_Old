<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmpWiseOutCityVisit.aspx.cs" Inherits="Reports_EmpWiseOutCityVisit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
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
        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
        }

        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.txtTtryHead').val().split("-").pop().trim();
            sender.set_contextKey(key == "" ? null : key);
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

            $(".FromOnlymonth").datepicker({
                dateFormat: 'mm/yy',
                showButtonPanel: true,
                changeYear: true,
                changeMonth: true,
                maxDate: '+0d',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            $(".ToOnlymonth").datepicker({
                dateFormat: 'mm/yy',
                showButtonPanel: true,
                changeYear: true,
                changeMonth: true,
                maxDate: '+0d',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                },
            });

            if ($('.gvgrid thead tr').length > 0) {
                var table = $('.gvgrid').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "10px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                for (var i = 3; i < colCount; i++) {
                    aryJSONColTable.push({
                        "aTargets": [i],
                        "width": "100px"
                        //mRender: function (data, type, row) {
                        //    return data.split("#").join("<br/>");
                        //}
                    });

                }

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

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
                                        var data = 'Month/Employee Wise OutCity Visit' + '\n';
                                        data += 'From Month,' + $('.FromOnlymonth').val() + ',To Month,' + $('.ToOnlymonth').val() + '\n';
                                        data += 'Territory Head,' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") + '\n';
                                        data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                        data += 'Employee Group,' + (($('.ddlEGroup').length > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Employee Group") + '\n';
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
                                        sheet = ExportXLS(xlsx, 8);
                                        var r0 = Addrow(1, [{ key: 'A', value: 'Month/Employee Wise OutCity Visit' }]);
                                        var r1 = Addrow(2, [{ key: 'A', value: 'From Month' }, { key: 'B', value: $('.FromOnlymonth').val() }, { key: 'C', value: 'To Month' }, { key: 'D', value: $('.ToOnlymonth').val() }]);
                                        var r2 = Addrow(3, [{ key: 'A', value: 'Territory Head' }, { key: 'B', value: (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() : "All Employee") }]);
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                        var r4 = Addrow(5, [{ key: 'A', value: 'Employee Group' }, { key: 'B', value: (($('.ddlEGroup').length > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Employee Group") }]);
                                        var r5 = Addrow(6, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                        var r6 = Addrow(7, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);

                                        sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + sheet.childNodes[0].childNodes[1].innerHTML;
                                    }
                                },
                                {
                                    extend: 'pdfHtml5',
                                    orientation: 'landscape',
                                    pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                    title: $("#lnkTitle").text(),
                                    exportOptions: {
                                        columns: ':visible',
                                        search: 'applied',
                                        order: 'applied'
                                    },
                                    customize: function (doc) {
                                        doc.content.splice(0, 1);

                                        doc.pageMargins = [20, 80, 20, 40];
                                        doc.defaultStyle.fontSize = 7;
                                        doc.styles.tableHeader.fontSize = 7;
                                        doc['header'] = (function () {
                                            return {
                                                columns: [
                                                    {
                                                        alignment: 'left',
                                                        italics: true,
                                                        text: [{ text: 'From Month : ' + $('.FromOnlymonth').val() + '\t To Month : ' + $('.ToOnlymonth').val() + "\n" },
                                                               { text: 'Territory Head : ' + (($('.txtTtryHead').length > 0 && $('.txtTtryHead').val() != "") ? $('.txtTtryHead').val() + "\n" : "All Employee" + "\n") },
                                                               { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee" + "\n") },
                                                               { text: 'Employee Group : ' + (($('.ddlEGroup').length > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() + "\n" : "All Employee Group\n") },
                                                               { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                        fontSize: 10,
                                                        height: 300,
                                                    },
                                                    {
                                                        alignment: 'right',
                                                        fontSize: 14,
                                                        text: 'Month/Employee Wise OutCity Visit',
                                                        height: 300,
                                                    }
                                                ],
                                                margin: 20
                                            }
                                        });
                                        doc['footer'] = (function (page, pages) {
                                            return {
                                                columns: [
                                                    {
                                                        alignment: 'left',
                                                        text: ['Created on: ', { text: jsDate.toString() }]
                                                    },
                                                    {
                                                        alignment: 'right',
                                                        text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                                    }
                                                ],
                                                margin: 20
                                            }
                                        });

                                        var objLayout = {};
                                        objLayout['hLineWidth'] = function (i) { return .5; };
                                        objLayout['vLineWidth'] = function (i) { return .5; };
                                        objLayout['hLineColor'] = function (i) { return '#000'; };
                                        objLayout['vLineColor'] = function (i) { return '#000'; };
                                        objLayout['paddingLeft'] = function (i) { return 4; };
                                        objLayout['paddingRight'] = function (i) { return 4; };
                                        doc.content[0].layout = objLayout;

                                        //var rowCount = doc.content[0].table.body.length;
                                        //for (i = 1; i < rowCount; i++) {
                                        //    for (var j = 4; j < colCount; j++) {
                                        //        doc.content[0].table.body[i][j].alignment = 'right';
                                        //    }
                                        //};
                                    }
                                }]
                        }
                    );

            }
        }
    </script>
    <style>
        .ui-datepicker-calendar {
            display: none;
        }

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
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Year/Month From" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="7" TabIndex="1" CssClass="FromOnlymonth form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Year/Month To" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" MaxLength="7" TabIndex="2" CssClass="ToOnlymonth form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" DataTextField="EmpGroupName" DataValueField="EmpGroupID" onchange="ClearEmp(this);">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divTHead" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTtryHead" runat="server" Text="Territory Head" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtTtryHead" runat="server" CssClass="form-control txtTtryHead" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode1" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTtryHead">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divEmpCode" runat="server">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" TabIndex="3" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acettxtEmployeeCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="4" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        &nbsp; &nbsp; 
                    <span style="color: red; font-weight: bold">Report Processed only 12 Month.</span>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvgrid" runat="server" CssClass="gvgrid table" Width="100%" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvgrid_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
</asp:Content>

