<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="SchemeReport.aspx.cs"
    Inherits="Reports_ShemeReport" %>

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

            if ($('.gvScheme thead tr').length > 0) {

                var table = $(".gvScheme").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];
                var ddlType = $(".ddltype").val();
                if (ddlType == "M") {
                    aryJSONColTable.push({ "width": "50px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 11 });
                }
                else if (ddlType == "S") {
                    aryJSONColTable.push({ "width": "60px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "250px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 14 });
                }
                else if (ddlType == "T") {
                    aryJSONColTable.push({ "width": "70px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 0 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 1 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 2 });
                    //aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyRight", "aTargets": 3 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 4 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                    //aryJSONColTable.push({ "width": "200px", "aTargets": 6 });
                }
                else {
                    aryJSONColTable.push({ "width": "70px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 13 });

                }

                $('.gvScheme').DataTable(
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
                                   var data = $("#lnkTitle").text() + '_' + '\n';
                                   data += 'Scheme Type,' + $('.ddltype option:Selected').text() + '\n';
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
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Scheme Type' }, { key: 'B', value: $('.ddltype option:Selected').text() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "") }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                   var r5 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);

                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'landscape', //portrait
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
                                   doc.pageMargins = [20, 80, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc.styles.tableFooter.fontSize = 7;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: true,
                                                   text: [{ text: 'Scheme Type :' + ($('.ddltype option:Selected').text()) + '\n' },
                                                          { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                          { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "\n") },
                                                          { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                          { text: 'Dealer : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n' }],
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
                                   var ddlType = $(".ddltype").val();
                                   if (ddlType == "M") {
                                       for (i = 1; i < rowCount; i++) {
                                           doc.content[0].table.body[i][6].alignment = 'right';
                                           doc.content[0].table.body[i][7].alignment = 'right';
                                           doc.content[0].table.body[i][8].alignment = 'right';
                                           doc.content[0].table.body[i][9].alignment = 'right';
                                           doc.content[0].table.body[i][10].alignment = 'right';
                                           doc.content[0].table.body[i][11].alignment = 'right';
                                       };
                                   }
                                   else if (ddlType == "S") {
                                       for (i = 1; i < rowCount; i++) {
                                           doc.content[0].table.body[i][6].alignment = 'right';
                                           doc.content[0].table.body[i][7].alignment = 'right';
                                           doc.content[0].table.body[i][8].alignment = 'right';
                                           doc.content[0].table.body[i][9].alignment = 'right';
                                           doc.content[0].table.body[i][10].alignment = 'right';
                                           doc.content[0].table.body[i][11].alignment = 'right';
                                           doc.content[0].table.body[i][12].alignment = 'right';
                                           doc.content[0].table.body[i][13].alignment = 'right';
                                           doc.content[0].table.body[i][14].alignment = 'right';
                                       };
                                   }
                                   else if (ddlType == "T") {
                                       for (i = 1; i < rowCount; i++) {
                                           doc.content[0].table.body[i][3].alignment = 'right';
                                           doc.content[0].table.body[i][4].alignment = 'right';
                                           doc.content[0].table.body[i][5].alignment = 'right';
                                           doc.content[0].table.body[i][6].alignment = 'right';
                                       };
                                   }
                                   else {
                                       for (i = 1; i < rowCount; i++) {
                                           doc.content[0].table.body[i][6].alignment = 'right';
                                           doc.content[0].table.body[i][7].alignment = 'right';
                                           doc.content[0].table.body[i][8].alignment = 'right';
                                           doc.content[0].table.body[i][9].alignment = 'right';
                                           doc.content[0].table.body[i][10].alignment = 'right';
                                           doc.content[0].table.body[i][12].alignment = 'right';
                                           doc.content[0].table.body[i][13].alignment = 'right';
                                       };
                                   }
                               }
                           }]
                        //buttons: [{ extend: 'copy', footer: true }, { extend: 'csv', footer: true, filename: 'SchemeReport_' + new Date().toLocaleDateString() }, { extend: 'excel', footer: true, filename: 'SchemeReport_' + new Date().toLocaleDateString() }]
                    }
                    );
            }
        }

        function acetxtCustName_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }

    </script>

    <style type="text/css">
        div.dataTables_wrapper {
            margin: 0 auto;
        }

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
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltype" runat="server" Text="Scheme Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddltype" TabIndex="1" CssClass="ddltype form-control">
                            <asp:ListItem Text="Master" Value="M" />
                            <asp:ListItem Text="QPS" Value="S" />
                            <asp:ListItem Text="Machine Discount" Value="D" />
                            <asp:ListItem Text="Parlour Discount" Value="P" />
                            <asp:ListItem Text="Secondary Freight Transportation" Value="T" />
                            <asp:ListItem Text="VRS Discount" Value="V" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDistofPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="7" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
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
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                            ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="6" Checked="true" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvScheme" TabIndex="8" Width="100%" Font-Size="11px" CssClass="gvScheme table" AutoGenerateColumns="true" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found." OnPreRender="gvScheme_PreRender">
                    </asp:GridView>
                </div>
            </div>

        </div>
    </div>
</asp:Content>
