<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetMasterRpt.aspx.cs" Inherits="Reports_AssetMasterRpt" %>


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

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-')[0];

            var plt = $('.txtPlant').val().split('-')[0];

            sender.set_contextKey(reg + "-" + plt);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            if ($('.txtDistCode').val() != undefined) {
                var key = $('.txtDistCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }

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

        function Reload() {

            if ($('.gvAsset thead tr').length > 0) {

                var table = $(".gvAsset").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "60px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "170px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 11, "sClass": "dtbodyRight" });
                aryJSONColTable.push({ "width": "70px", "aTargets": 12 });

                $('.gvAsset').DataTable(
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
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = $("#lnkTitle").text() + '\n';
                                    data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                    data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") + '\n';
                                    data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "") + '\n';
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                    data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n\n';
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

                                    sheet = ExportXLS(xlsx, 7);

                                    var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                    var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") }]);
                                    var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "") }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                    var now = new Date();
                                    Date.prototype.today = function () {
                                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                                    }
                                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                                    doc.pageMargins = [20, 90, 20, 40];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                           { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                           { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "\n") },
                                                           { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                           { text: 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") }],
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
                                        doc.content[0].table.body[i][6].alignment = 'right';
                                        doc.content[0].table.body[i][8].alignment = 'right';
                                        doc.content[0].table.body[i][11].alignment = 'right';
                                    };
                                }
                            }]
                    }
                );
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

        div.dataTables_wrapper {
            margin: 0 auto;
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
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                            ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDistofPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStateNames"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="11" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerofDist" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvAsset" runat="server" Width="100%" CssClass="gvAsset    table tbl" Style="font-size: 11px;" OnPreRender="gvAsset_Prerender" HeaderStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>



