<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DistributorLastInvoice.aspx.cs" Inherits="Reports_DistributorLastInvoice" %>

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

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
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

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(key + "-0" + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }

        function Reload() {
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvgrid thead tr').length > 0) {

                var table = $('.gvgrid').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyLeft", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "250px", "sClass": "dtbodyLeft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyLeft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 5 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 10 });

                $('.gvgrid').DataTable(
                {
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "buttons": [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = $("#lnkTitle").text() + '\n';
                                    data += 'Effective ToDate,' + $('.fromdate').val() + '\n';
                                    data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All") + '\n';
                                    data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All") + '\n';
                                    data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                                    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                                    data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                    data += 'Created on,' + jsDate.toString() + '\n\n';

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
                                    var r1 = Addrow(2, [{ key: 'A', value: 'Effective ToDate' }, { key: 'B', value: $('.fromdate').val() }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All") }]);
                                    var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All") }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") }]);
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                                    var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                                    var r7 = Addrow(8, [{ key: 'A', value: 'User Name' }, { key: 'B', value: ($('.hdnUserName').val()) }]);
                                    var r8 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (jsDate.toString()) }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape', //portrait
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),
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
                                    doc.pageMargins = [20, 100, 20, 30];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: false,
                                                    text: [{ text: 'Effective Date    : ' + $('.fromdate').val() + "\n" },
                                                           { text: 'Region                : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "All" + "\n") },
                                                           { text: 'Plant                   : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "All" + "\n") },
                                                           { text: 'Super Stockist  : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "All" + "\n") },
                                                           { text: 'Distributor         : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "All" + "\n") },
                                                           { text: 'Employee          : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[1] + "\n" : "All" + "\n") },
                                                           { text: 'User Name      : ' + ($('.hdnUserName').val()) + "\n" }],

                                                    fontSize: 10,
                                                    height: 700,
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 14,
                                                    text: $("#lnkTitle").text(),
                                                    height: 700,
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
                                                    text: ['Print Date/By: ', { text: jsDate.toString() + " / " + $('.hdnUserName').val() }]
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
                                        doc.content[0].table.body[i][0].alignment = 'right';
                                        doc.content[0].table.body[i][5].alignment = 'center';
                                        doc.content[0].table.body[i][6].alignment = 'center';
                                        doc.content[0].table.body[i][7].alignment = 'right';
                                        doc.content[0].table.body[i][8].alignment = 'right';
                                        doc.content[0].table.body[i][9].alignment = 'right';
                                        doc.content[0].table.body[i][10].alignment = 'center';
                                    };
                                    doc.content[0].table.body[0][0].alignment = 'right';
                                    doc.content[0].table.body[0][1].alignment = 'left';
                                    doc.content[0].table.body[0][2].alignment = 'left';
                                    doc.content[0].table.body[0][3].alignment = 'left';
                                    doc.content[0].table.body[0][4].alignment = 'left';
                                    doc.content[0].table.body[0][7].alignment = 'right';
                                    doc.content[0].table.body[0][8].alignment = 'right';
                                    doc.content[0].table.body[0][9].alignment = 'right';
                                }
                            }]
                });
            }
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtPlant").val('');
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtDistCode").val('');
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

        .dtbodyLeft {
            text-align: left;
        }

        .dtbodyCenter {
            text-align: center;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding-left: 3px;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblEffactiveToDate" runat="server" text="Effactive ToDate" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtEffactiveToDate" runat="server" tabindex="1" maxlength="10" onkeyup="return ValidateDate(this);" cssclass="fromdate form-control"></asp:textbox>
                    </div>
                    <div class="input-group form-group" id="divPlant" runat="server">
                        <asp:label id="lblPlant" runat="server" text='Plant' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtPlant" runat="server" style="background-color: rgb(250, 255, 189);" cssclass="txtPlant form-control" tabindex="4"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="AutoCompleteExtender2" runat="server" servicemethod="GetPlantsCurrHierarchy"
                            servicepath="../Service.asmx" onclientpopulating="autoCompletePlant_OnClientPopulating" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtPlant" usecontextkey="True">
                        </asp:autocompleteextender>
                    </div>
                    <div class="input-group form-group">
                        <asp:button id="btnGenerat" runat="server" text="Go" tabindex="7" cssclass="btn btn-default" onclick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblCode" runat="server" text="Employee" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtCode" onchange="ClearOtherConfig()" runat="server" cssclass="form-control txtCode" style="background-color: rgb(250, 255, 189);" tabindex="2"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acettxtEmployeeCode" runat="server" servicepath="../Service.asmx"
                            usecontextkey="true" servicemethod="GetEmployeeList" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtCode">
                        </asp:autocompleteextender>
                    </div>
                    <div class="input-group form-group">
                        <asp:label id="lblSSCustomer" runat="server" text="Super Stockist" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtSSDistCode" onchange="ClearOtherSSConfig()" runat="server" tabindex="5" style="background-color: rgb(250, 255, 189);" cssclass="txtSSDistCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="aceSStxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetSSCurrHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtSSDistCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divRegion" runat="server">
                        <asp:label id="lblRegion" runat="server" text='Region' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtRegion" cssclass="txtRegion form-control" runat="server" tabindex="3" style="background-color: rgb(250, 255, 189);"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="AutoCompleteExtender1" runat="server" servicemethod="GetStatesCurrHierarchy"
                            servicepath="../Service.asmx" minimumprefixlength="1" completioninterval="10" enablecaching="false" completionsetcount="1"
                            targetcontrolid="txtRegion" usecontextkey="True" onclientpopulating="autoCompleteState_OnClientPopulating">
                        </asp:autocompleteextender>
                    </div>
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:label id="lblCustomer" runat="server" text="Distributor" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtDistCode" runat="server" tabindex="6" style="background-color: rgb(250, 255, 189);" cssclass="txtDistCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acetxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetDistCurrHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtDistCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:gridview id="gvgrid" runat="server" cssclass="gvgrid tbl table" style="font-size: 11px; width: 100%;" onprerender="gvgrid_Prerender" headerstyle-cssclass=" table-header-gradient" emptydatatext="No data found. ">
                    </asp:gridview>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

