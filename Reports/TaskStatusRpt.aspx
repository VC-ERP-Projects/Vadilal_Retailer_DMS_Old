<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="TaskStatusRpt.aspx.cs" Inherits="Reports_TaskStatus" %>

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

        function aceMechEmp_OnClientPopulating(sender, args) {

            sender.set_contextKey($('.txtCode').val().split('-').pop());
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

            if ($('.gvtaskstatus thead tr').length > 0) {
                var table = $('.gvtaskstatus').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "55px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 12 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 14 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 15 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 16 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 17 });

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                $('.gvtaskstatus').DataTable({
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
                           filename: 'Task Status Report',
                           customize: function (csv) {
                               var data = 'Task Status Report' + '\n';
                               data += 'Task Status Report From,' + $('.fromdate').val() + ',To,' + $('.todate').val() + '\n';
                               data += 'Employee/Mechanic,' + ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'RSD Location,' + ($('.txtlocation').length > 0 && $('.txtlocation').val() != "" ? $('.txtlocation').val() : "All") + '\n';
                               data += 'Task Status,' + ($('.ddlTaskStatus option:Selected').val() > 0 ? $('.ddlTaskStatus option:Selected').text() : "All") + '\n';
                               data += 'Asset Serial Number,' + ($('.txtAssetSerialNo').length > 0 && $('.txtAssetSerialNo').val() != "" ? $('.txtAssetSerialNo').val() : "All") + '\n';
                               data += 'Customer ,' + ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'Task Type,' + ($('.ddlTaskType option:Selected').val() > 0 && $('.ddlTaskType option:Selected').val() != "" ? $('.ddlTaskType option:Selected').text() : "Both") + '\n\n';
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
                           filename: 'Task Status Report',
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 9);

                               var r0 = Addrow(1, [{ key: 'A', value: 'Task Status Report' }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'Task Status Report From' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To' }, { key: 'D', value: $('.todate').val() }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Employee/Mechanic' }, { key: 'B', value: ($('.txtCode').val().length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'RSD Location' }, { key: 'B', value: ($('.txtlocation').val().length > 0 && $('.txtlocation').val() != "" ? $('.txtlocation').val() : "All") }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Task Status' }, { key: 'B', value: ($('.ddlTaskStatus option:Selected').val() > 0 ? $('.ddlTaskStatus option:Selected').text() : "All") }]);
                               var r5 = Addrow(6, [{ key: 'A', value: 'Asset Serial Number' }, { key: 'B', value: ($('.txtAssetSerialNo').length > 0 && $('.txtAssetSerialNo').val() != "" ? $('.txtAssetSerialNo').val() : "All") }]);
                               var r6 = Addrow(7, [{ key: 'A', value: 'Customer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") }]);
                               var r7 = Addrow(8, [{ key: 'A', value: 'Task Type' }, { key: 'B', value: ($('.ddlTaskType option:Selected').val() > 0 && $('.ddlTaskType option:Selected').val() != "" ? $('.ddlTaskType option:Selected').text() : "Both") }]);

                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: 'Task Status Report',
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
                               doc.pageMargins = [20, 120, 20, 30];
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
                                               text: [{ text: 'Task Status Report From  : ' + ($('.fromdate').val() + ' To ' + $('.todate').val() + "\n") },
                                                      { text: 'Employee/Mechanic         : ' + ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'RSD Location                      : ' + (($('.txtlocation').length > 0 && $('.txtlocation').val() != "") ? $('.txtlocation').val() : "All") + '\n' },
                                                      { text: 'Task Status                         : ' + ($('.ddlTaskStatus option:Selected').val() > 0 ? $('.ddlTaskStatus option:Selected').text() + "\n" : "All" + "\n") },
                                                      { text: 'Asset Serial Number         : ' + ($('.txtAssetSerialNo').val() != "" ? $('.txtAssetSerialNo').val() : "All") + '\n' },
                                                      { text: 'Customer                            : ' + ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'Task Type                            : ' + ($('.ddlTaskType option:Selected').val() > 0 && $('.ddlTaskType option:Selected').val() != "" ? $('.ddlTaskType option:Selected').text() + "\n" : "Both" + "\n") },
                                               ],

                                               fontSize: 10,
                                               height: 500,
                                           },
                                           {
                                               alignment: 'right',
                                               fontSize: 14,
                                               text: 'Task Status Report',
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

        /*.dataTables_scroll {
            max-height: 308px;
        }*/
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group divfromdate">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="lblFromDate input-group-addon"></asp:Label>
                        <asp:Label ID="lbldate" runat="server" Text="Set Date" Visible="false" CssClass="lbldate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" TabIndex="1" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group divtodate">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee/Mechanic" CssClass="input-group-addon"></asp:Label>
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
                        <asp:TextBox ID="txtlocation" runat="server" CssClass="form-control txtlocation" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetStorageLocation"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtlocation">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div3" runat="server" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMechEmp" runat="server" Text="Mechanic Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMechEmp" runat="server" CssClass="form-control txtMechEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceMechEmp" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="aceMechEmp_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMechEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div2" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTaskStatus" runat="server" Text="Task Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlTaskStatus" runat="server" CssClass="ddlTaskStatus form-control" TabIndex="6" DataTextField="TaskStatusName" DataValueField="TaskStatusID" AppendDataBoundItems="true">
                        </asp:DropDownList>
                    </div>
                </div>
                <%--<div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="City" ID="lblCity" runat="server" CssClass="lblCity input-group-addon" autocomplete="off" />
                        <asp:TextBox runat="server" ID="txtCity" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="7" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server"
                            ServicePath="../WebService.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetCityNames"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>--%>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSerialNumber" runat="server" Text='Asset Serial Number' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAssetSerialNo" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetSerialNo form-control" runat="server" TabIndex="8"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtAssetSerialNo" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetSerialNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetCustomerByAllTypeWithoutTemp" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <%-- <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Hierarchy Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlHierarchyType" TabIndex="10" CssClass="ddlHierarchyType form-control">
                            <asp:ListItem Text="Customer" Value="1" Selected="True" />
                            <asp:ListItem Text="User" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>--%>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="TaskType" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlTaskType" TabIndex="11" CssClass="ddlTaskType form-control">
                            <asp:ListItem Text="Both" Value="0" Selected="True" />
                            <asp:ListItem Text="PM" Value="1" />
                            <asp:ListItem Text="Break Down" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="12" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvtaskstatus" runat="server" CssClass="gvtaskstatus table tbl" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvtaskstatus_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found.">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

