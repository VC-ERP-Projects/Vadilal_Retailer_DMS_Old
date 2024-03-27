<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="QPSCommonReport.aspx.cs" Inherits="Reports_QPSCommonReport" %>

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
            ChangeReportFor('1');
        });

        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor('1');
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }

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

        function acetxtDealerCode_OnClientPopulating(sender, args) {
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

        function GetStartEndDate(sender, e) {
            var QPS = $('.txtQPSCode').val().split("|")[1].trim();
            if (QPS.split("#").length == 2) {
                $('.fromdate').val(QPS.split("#")[0].trim());
                $('.todate').val(QPS.split("#")[1].trim());
            }
        }

        function Reload() {
            if ($('.gvQPSCommon thead tr').length > 0) {

                var table = $('.gvQPSCommon').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "90px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "220px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "220px", "aTargets": 12 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 14 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 15 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyRight", "aTargets": 16 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 17 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 18 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 19 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 20 });
                aryJSONColTable.push({ "width": "140px", "sClass": "dtbodyRight", "aTargets": 21 });
                aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyRight", "aTargets": 22 });

                $('.gvQPSCommon').DataTable({

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
                              extend: 'csv', footer: true, filename: 'QPS Common Report' + '_' + new Date().toLocaleDateString(),
                              customize: function (csv) {
                                  var data = 'QPS Common Report' + '\n';
                                  data += 'Invoice From Date,' + $('.fromdate').val() + ',Invoice To Date,' + $('.todate').val() + '\n';
                                  data += 'Sale By,' + $('.ddlSaleBy option:selected').text() + '\n';
                                  data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                                  data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") + '\n';
                                  if ($('.ddlSaleBy').val() == "4")
                                      data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") + '\n';
                                  data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                                  if ($('.ddlSaleBy').val() == "2")
                                      data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") + '\n';
                                  data += 'QPS Scheme,' + ($('.txtQPSCode').val() != "" ? $('.txtQPSCode').val().split('-')[2] : "All QPS Scheme") + '\n';
                                  data += 'Scheme Product,' + ($('.txtItem').val() != "" ? $('.txtItem').val().split('-')[2] : "All Scheme Product") + '\n';
                                  data += 'Company Contribution % between,' + $('.txtCpnyContriFrom').val() + ' To ' + $('.txtCpnyContriTo').val() + '%' + '\n';
                                  data += 'Distribuotor Contribution % between,' + $('.txtDistContriFrom').val() + ' To ' + $('.txtDistContriTo').val() + '%' + '\n';
                                  data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
                                  data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
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

                                  sheet = ExportXLS(xlsx, 15);

                                  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'Invoice From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'Invoice To Date' }, { key: 'D', value: $('.todate').val() }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") }]);
                                  var r4 = Addrow(5, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") }]);
                                  if ($('.ddlSaleBy').val() == "4") {
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r6 = Addrow(7, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  if ($('.ddlSaleBy').val() == "2") {
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r6 = Addrow(7, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  var r7 = Addrow(8, [{ key: 'A', value: 'QPS Scheme' }, { key: 'B', value: ($('.txtQPSCode').val() != "" ? $('.txtQPSCode').val().split('-')[2] : "All QPS Scheme") }]);
                                  var r8 = Addrow(9, [{ key: 'A', value: 'Scheme Product' }, { key: 'B', value: ($('.txtItem').val() != "" ? $('.txtItem').val().split('-')[2] : "All Scheme Product") }]);
                                  var r9 = Addrow(10, [{ key: 'A', value: 'Company Contribution % between' }, { key: 'B', value: $('.txtCpnyContriFrom').val() + ' To ' + $('.txtCpnyContriTo').val() + '%' }]);
                                  var r10 = Addrow(11, [{ key: 'A', value: 'Distribuotor Contribution % between' }, { key: 'B', value: $('.txtDistContriFrom').val() + ' To ' + $('.txtDistContriTo').val() + '%' }]);
                                  var r11 = Addrow(12, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                  var r12 = Addrow(13, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10 + r11 + r12 + sheet.childNodes[0].childNodes[1].innerHTML;
                              }
                          }]
                });
            }

        }

    </script>
    <style>
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
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Invoice From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Invoice To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" hidden="hidden">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" CssClass="ddlSaleBy form-control" TabIndex="4" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divRegion" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" TabIndex="5" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divPlant" id="divPlant" runat="server" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlantsStoreHierarchy"
                            ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="10" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCpnyContriFrom" runat="server" Text='Comp. Contri % From' CssClass="input-group-addon"></asp:Label>
                        <input id="txtCpnyContriFrom" runat="server" tabindex="11" name="txtCpnyContriFrom" class="txtCpnyContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    </div>
                </div>
                <div class="col-lg-4" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistContriFrom" runat="server" Text='Dist. Contri % From' CssClass="input-group-addon"></asp:Label>
                        <input id="txtDistContriFrom" runat="server" tabindex="12" name="txtDistContriFrom" class="txtDistContriFrom form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    </div>
                </div>
                <div class="col-lg-4" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCpnyContriTo" runat="server" Text='Comp. Contri % To' CssClass="input-group-addon"></asp:Label>
                        <input id="txtCpnyContriTo" runat="server" tabindex="13" name="txtCpnyContriTo" class="txtCpnyContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    </div>
                </div>
                <div class="col-lg-4" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistContriTo" runat="server" Text='Dist. Contri % To' CssClass="input-group-addon"></asp:Label>
                        <input id="txtDistContriTo" runat="server" tabindex="14" name="txtDistContriTo" class="txtDistContriTo form-control" type='text' min="0" max='100' oninput="validity.valid||(value='');" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Scheme Product" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" TabIndex="15" ID="txtItem" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServiceMethod="GetQPSSchemeItem"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="QPS Scheme" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" TabIndex="16" ID="txtQPSCode" CssClass="txtQPSCode form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtCode" runat="server" ServiceMethod="GetQPSScheme"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="GetStartEndDate"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtQPSCode" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="17" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:Label runat="server" ID="lblInfoNoMessage" Visible="false"></asp:Label>
                    <asp:GridView ID="gvQPSCommon" runat="server" Width="100%" CssClass="gvQPSCommon  table tbl" Style="font-size: 11px;" OnPreRender="gvQPSCommon_PreRender"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

