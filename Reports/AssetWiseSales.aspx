﻿<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" CodeFile="AssetWiseSales.aspx.cs" Inherits="Reports_AssetWiseSales" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">

        var ParentID = '<% = ParentID%>';
        var CustType = '<% = CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-0-" + ss + "-" + dist + "-" + EmpID);
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
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
            Reload();
        }

        function ChangeReportFor(ReportBy) {
            if ($('.ddlReportBy').val() == "4") {
                if (ReportBy == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                if (ReportBy == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
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

        function Reload() {
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvAssetWiseSales thead tr').length > 0) {

                var table = $(".gvAssetWiseSales").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "60px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "240px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 11 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                aryJSONColTable.push({ "width": "73px", "sClass": "dtbodyRight", "aTargets": 14 });

                $('.gvAssetWiseSales').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '50vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "order": [],
                        "bPaginate": false,
                        "aoColumnDefs": aryJSONColTable,
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = $("#lnkTitle").text() + '\n';
                                    data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                    data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                                    data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") + '\n';
                                    data += 'Report By,' + $('.ddlReportBy option:selected').text() + '\n';
                                    if ($('.ddlReportBy').val() == "4")
                                        data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") + '\n';
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") + '\n';
                                    if ($('.ddlReportBy').val() == "2")
                                        data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") + '\n';
                                    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All Employee") + '\n';
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
                                        },
                                        footer: function (data, row, column, node) {
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
                                    var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlReportBy option:selected').text() }]);
                                    if ($('.ddlReportBy').val() == "4") {
                                        var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") }]);
                                        var r6 = Addrow(7, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") }]);
                                    }
                                    if ($('.ddlReportBy').val() == "2") {
                                        var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") }]);
                                        var r6 = Addrow(7, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") }]);
                                    }
                                    var r7 = Addrow(8, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All Employee") }]);
                                    var r8 = Addrow(9, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r9 = Addrow(10, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape',
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),
                                footer: 'true',
                                exportOptions: {
                                    columns: ':visible',
                                    search: 'applied',
                                    order: 'applied'
                                },
                                customize: function (doc) {
                                    doc.content.splice(0, 1);
                                    var now = new Date();
                                    Date.prototype.today = function () {
                                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                                    }
                                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                                    doc.pageMargins = [20, 120, 20, 40];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc.styles.tableFooter.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: false,
                                                    text: [{ text: 'From Date          : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                            { text: 'Region                : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "All Region\n") },
                                                            { text: 'Plant                   : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "All Plant\n") },
                                                            { text: 'Report By           : ' + ($('.ddlReportBy option:Selected').text() + "\n") },
                                                            { text: (($('.ddlReportBy').val() == "4") ? 'Super Stockist  : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-')[1] + "\n" : "All Super Stockist\n") : '') },
                                                            { text: 'Distributor         : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "All Distributors\n") },
                                                            { text: (($('.ddlReportBy').val() == "2") ? 'Dealer     : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "All Dealer\n") : '') },
                                                            { text: 'Employee          : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "All Employee\n") },
                                                            { text: 'User Name        : ' + $('.hdnUserName').val() + "\n" }],
                                                    fontSize: 10,
                                                    height: 500,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 500,
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

                                    var rowCount = doc.content[0].table.body.length;
                                    for (i = 1; i < rowCount; i++) {

                                        doc.content[0].table.body[i][9].alignment = 'right';
                                        doc.content[0].table.body[i][10].alignment = 'right';
                                        doc.content[0].table.body[i][11].alignment = 'right';
                                        doc.content[0].table.body[i][12].alignment = 'right';
                                        doc.content[0].table.body[i][13].alignment = 'right';
                                        doc.content[0].table.body[i][14].alignment = 'right';

                                    };
                                }
                            }],
                        "footerCallback": function (row, data, start, end, display) {

                            var api = this.api(), data;

                            // Remove the formatting to get integer data for summation
                            var intVal = function (i) {
                                return typeof i === 'string' ?
                                    i.replace(/[\$,]/g, '') * 1 :
                                    typeof i === 'number' ?
                                    i : 0;
                            };

                            col9 = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            //col10 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            //    if (!isNaN(parseFloat(b).toFixed(2)))
                            //        return (intVal(a)) + (intVal(b));
                            //}, 0);

                            //col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            col14 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            $(api.column(9).footer()).html(col9.toFixed(2));
                            //$(api.column(10).footer()).html(parseFloat(col10));
                            //$(api.column(11).footer()).html(col11.toFixed(2));
                            //$(api.column(12).footer()).html(col12.toFixed(2));
                            //$(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));

                        }
                    });
            }
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtPlant").val('');
            }
        }

        function ClearOtherDistConfig() {
            if ($(".txtDistCode").length > 0) {
                $(".txtDealerCode").val('');
            }
        }

        function ClearOtherSSConfig() {
            if ($(".txtSSDistCode").length > 0) {
                $(".txtDistCode").val('');
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
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
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
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divRegion" runat="server">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="4" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                       <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Report By" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReportBy" TabIndex="6" runat="server" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" OnChange="ClearOtherSSConfig()" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" OnChange="ClearOtherDistConfig()" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="10" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp;
                        <asp:Button ID="btnExport" runat="server" Text="Export To Excel" TabIndex="11" CssClass="btn btn-default" OnClick="btnExport_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvAssetWiseSales" TabIndex="12" Font-Size="11px" Width="100%" CssClass="gvAssetWiseSales table" AutoGenerateColumns="true" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found." OnPreRender="gvAssetWiseSales_PreRender" ShowFooter="true" FooterStyle-CssClass=" table-header-gradient">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
