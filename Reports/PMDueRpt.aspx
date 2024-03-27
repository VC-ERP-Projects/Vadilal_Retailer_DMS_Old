<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PMDueRpt.aspx.cs" Inherits="Reports_PMDue" %>

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
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var City = $('.txtCity').is(":visible") ? $('.txtCity').val().split('-').pop() : "0";
            sender.set_contextKey("0-" + City + "-0" + "-" + "0" + "-" + "0" + "-" + EmpID);
        }

        function acettxtCity_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-" + EmpID);
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

        function ReLoadFn() {

            if ($('.gvpmdue thead tr').length > 0) {
                var table = $('.gvpmdue').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "85px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "72px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "110px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "72px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "79px", "aTargets": 14 });

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                $('.gvpmdue').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": false,
                    "aaSorting": [],
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [

                       {
                           extend: 'csv',
                           footer: true,
                           filename: 'PM Due Report',
                           customize: function (csv) {
                               var data = 'PM Due Report' + '\n';
                               data += 'PM Due As On,' + $('.fromdate').val() + '\n';
                               data += 'Employee/Mechanic,' + ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'RSD Location,' + ($('.txtlocation').length > 0 && $('.txtlocation').val() != "" ? $('.txtlocation').val() : "All") + '\n';
                               data += 'Machine Type,' + ($('.ddlMachineType option:Selected').val() > 0 && $('.ddlMachineType option:Selected').val() != "" ? $('.ddlMachineType option:Selected').text() : "All") + '\n';
                               data += 'Customer ,' + ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n\n';
                               return data + csv;
                           },
                           exportOptions: {
                               format: {
                                   body: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   },
                                   footer: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   }
                               }
                           }
                       },
                       {
                           extend: 'excel', footer: true,
                           filename: 'PM Due Report',
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 7);

                               var r0 = Addrow(1, [{ key: 'A', value: 'PM Due Report' }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'PM Due As On' }, { key: 'B', value: $('.fromdate').val() }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Employee/Mechanic' }, { key: 'B', value: ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'RSD Location' }, { key: 'B', value: ($('.txtlocation').length > 0 && $('.txtlocation').val() != "" ? $('.txtlocation').val() : "All") }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Machine Type' }, { key: 'B', value: ($('.ddlMachineType option:Selected').val() > 0 && $('.ddlMachineType option:Selected').val() != "" ? $('.ddlMachineType option:Selected').text() : "All") }]);
                               var r5 = Addrow(6, [{ key: 'A', value: 'Customer' }, { key: 'B', value: ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: 'PM Due Report',
                           footer: 'false',
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
                               doc.pageMargins = [20, 110, 20, 30];
                               doc.defaultStyle.fontSize = 6;
                               doc.styles.tableHeader.fontSize = 7;
                               doc.styles.tableFooter.fontSize = 7;
                               //doc['content']['0'].table.widths = ['1.5%', '6.5%', '2%', '6%', '3.5%', '6%', '9.5%', '4%', '7.5%', '6%', '4%', '9%', '6%', '6.5%', '5.5%', '4.5%', '5.5%', '5.5%'];
                               doc['header'] = (function () {
                                   return {
                                       columns: [
                                           {
                                               alignment: 'left',
                                               italics: false,
                                               text: [
                                                   { text: 'PM Due As On            : ' + ($('.fromdate').val() + "\n") },
                                                   { text: 'Employee/Mechanic  : ' + ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                   { text: 'RSD Location              : ' + (($('.txtlocation').length > 0 && $('.txtlocation').val() != "") ? $('.txtlocation').val() : "All") + '\n' },
                                                   { text: 'Machine Type             : ' + (($('.ddlMachineType option:Selected').val() > 0 && $('.ddlMachineType option:Selected').val() != "" ? $('.ddlMachineType option:Selected').text() : "All") + "\n") },
                                                   { text: 'Customer                    : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                               ],

                                               fontSize: 10,
                                               height: 500,
                                           },
                                           {
                                               alignment: 'right',
                                               fontSize: 14,
                                               text: 'PM Due Report',
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
                               //objLayout['hLineWidth'] = function (i) { return .5; };
                               //objLayout['vLineWidth'] = function (i) { return .5; };
                               objLayout['hLineColor'] = function (i) { return '#000'; };
                               objLayout['vLineColor'] = function (i) { return '#000'; };
                               //objLayout['paddingLeft'] = function (i) { return 4; };
                               //objLayout['paddingRight'] = function (i) { return 4; };
                               doc.content[0].layout = objLayout;
                           }
                       }

                    ],
                });
            }
        }
    </script>
    <style>
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

        table.dataTable thead th {
            padding: 5px;
        }

        table.dataTable tbody td {
            padding: 5px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group divasondate">
                        <asp:Label ID="lblAsOnDate" runat="server" Text="As on Date" CssClass="lblAsOnDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAsOnDate" runat="server" MaxLength="10" TabIndex="1" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee/ Mechanic" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div1" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="RSD Location" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtlocation" runat="server" CssClass="form-control txtlocation" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetStorageLocation"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtlocation">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div2" runat="server" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMechEmp" runat="server" Text="Mechanic Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMechEmp" runat="server" CssClass="form-control txtMechEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMechEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label Text="Dealer City" ID="lblCity" runat="server" CssClass="lblCity input-group-addon" autocomplete="off" />
                        <asp:TextBox runat="server" ID="txtCity" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="5" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetCitysCurrHierarchy" OnClientPopulating="acettxtCity_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Machine Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMachineType" TabIndex="6" CssClass="ddlMachineType form-control" DataTextField="MachineTypeName" DataValueField="MachineTypeID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetCustomerByAllTypeWithoutTemp" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="8" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvpmdue" runat="server" CssClass="gvpmdue table tbl" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvpmdue_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found.">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

