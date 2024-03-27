<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DeviceInfo.aspx.cs" Inherits="Reports_DeviceInfo" %>

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

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
        }

        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.ddlEGroup').val();
            sender.set_contextKey(key);
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

            if ($('.gvdevice thead tr').length > 0) {

                var table = $('.gvdevice').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "90px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "170px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "170px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 3 });
                aryJSONColTable.push({ "width": "110px", "sClass": "dtbodyCenter", "aTargets": 4 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 11 });
                if ($('.chkLatLong').find('input').is(':checked')) {
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 14 });

                }
                else {
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 12 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 13 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 14 });

                }


                $('.gvdevice').DataTable(
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
                                   data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "") + '\n';
                                   data += 'Employee Group,' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() + "\n" : "") + '\n';
                                   data += 'With LatLong,' + ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") + '\n';
                                   return data + csv;
                               },
                               exportOptions: {
                                   columns: ':visible',
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
                               exportOptions: {
                                   columns: ':visible'
                               },
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 5);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "") }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Employee Group' }, { key: 'B', value: (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "") }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'With LatLong' }, { key: 'B', value: ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                   doc.pageMargins = [20, 70, 20, 30];
                                   doc.defaultStyle.fontSize = 7;
                                   doc.styles.tableHeader.fontSize = 7;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: true,
                                                   text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                          { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "\n") },
                                                          { text: 'Employee Group : ' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() + "\n" : "\n") },
                                                          { text: 'With LatLong : ' + ($("#chkLatLong").is(":checked") == true ? "True" : "False") + "\n" }],
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
                                       doc.content[0].table.body[i][3].alignment = 'center';
                                       doc.content[0].table.body[i][4].alignment = 'center';
                                       doc.content[0].table.body[i][7].alignment = 'right';
                                       if ($('.chkLatLong').find('input').is(':checked')) {
                                           doc.content[0].table.body[i][12].alignment = 'right';
                                           doc.content[0].table.body[i][13].alignment = 'right';
                                       }
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

        .dtbodyCenter {
            text-align: center;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .dtbodyHide {
            display: none;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>

                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>

                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveEmployee" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acettxtEmployeeCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="With LatLong" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox CssClass="form-control chkLatLong" Checked="true" TabIndex="1" ID="chkLatLong" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <asp:GridView ID="gvdevice" runat="server" CssClass="gvdevice table" Font-Size="11px" Width="100%"
                            OnPreRender="gvdevice_Prerender" EmptyDataText="No data found." AutoGenerateColumns="true" HeaderStyle-CssClass="table-header-gradient">
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <br />
        </div>
    </div>
</asp:Content>
