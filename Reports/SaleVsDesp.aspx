<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SaleVsDesp.aspx.cs" Inherits="Reports_SaleVsDesp" %>

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
        var ParentID = '<% =ParentID%>';
        var CustType = '<% =CustType%>';

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
                $(".txtRegion").val('');
                $(".txtDealerCode").val('');
            }
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + EmpID);
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
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + "0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            Relaod();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
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

        function Relaod() {
            if (CustType == 2 || CustType == 4) {
                $('.ddlDealer').val(0);
                $('.ddlDealer').prop("disabled", true);
            }
            else {
                $('.ddlDealer').prop("disabled", false);
            }
            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: new Date(2017, 6, 1),
                "maxDate": '<%=DateTime.Now %>',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                }
            });

            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                "maxDate": '<%=DateTime.Now %>',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });

            if ($('.gvSalevsDispatch thead tr').length > 0) {

                var table = $('.gvSalevsDispatch').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 12 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 14 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 15 });
                aryJSONColTable.push({ "width": "55px", "sClass": "dtbodyRight", "aTargets": 16 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 17 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 18 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 19 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 20 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 21 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 22 });

                $('.gvSalevsDispatch').DataTable({

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
                                  data += 'From Date,' + $('.frommindate').val() + ',To Date,' + $('.tomindate').val() + '\n';
                                  data += 'Date Option,' + $('.ddlDateOption option:selected').text() + '\n';
                                  data += 'Division,' + $('.ddlDivision option:selected').text() + '\n';
                                  data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") + '\n';
                                  data += 'Sale By,' + $('.ddlSaleBy option:selected').text() + '\n';
                                  if ($('.ddlSaleBy').val() == "4")
                                      data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  if ($('.ddlSaleBy').val() == "2")
                                      data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Employee,' + ($('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n\n';
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

                                  sheet = ExportXLS(xlsx, 11);

                                  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.frommindate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.tomindate').val() }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Date Option' }, { key: 'B', value: $('.ddlDateOption option:selected').text() }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivision option:selected').text() }]);
                                  var r4 = Addrow(5, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") }]);
                                  var r5 = Addrow(6, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                  if ($('.ddlSaleBy').val() == "4") {
                                      var r6 = Addrow(7, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r7 = Addrow(8, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  if ($('.ddlSaleBy').val() == "2") {
                                      var r6 = Addrow(7, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r7 = Addrow(8, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  var r8 = Addrow(9, [{ key: 'A', value: 'Employee' }, { key: 'B', value: ($('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                              }
                          }
                          //,{
                          //    extend: 'pdfHtml5',
                          //    orientation: 'landscape',
                          //    pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                          //    title: $("#lnkTitle").text(),
                          //    footer: 'true',
                          //    exportOptions: {
                          //        columns: ':visible',
                          //        search: 'applied',
                          //        order: 'applied'
                          //    },
                          //    customize: function (doc) {
                          //        doc.content.splice(0, 1);
                          //        var now = new Date();
                          //        Date.prototype.today = function () {
                          //            return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                          //        }
                          //        var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                          //        doc.pageMargins = [20, 120, 20, 40];
                          //        doc.defaultStyle.fontSize = 7;
                          //        doc.styles.tableHeader.fontSize = 7;
                          //        doc.styles.tableFooter.fontSize = 7;
                          //        doc['header'] = (function () {
                          //            return {
                          //                columns: [
                          //                    {
                          //                        alignment: 'left',
                          //                        italics: true,
                          //                        text: [{ text: 'From Date : ' + $('.frommindate').val() + '\t To Date : ' + $('.tomindate').val() + "\n" },
                          //                               { text: 'Date Option : ' + ($('.ddlDateOption option:Selected').text() + "\n") },
                          //                               { text: 'Division : ' + ($('.ddlDivision option:Selected').text() + "\n") },
                          //                               { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                          //                               { text: 'Sale By : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                          //                               { text: 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-')[1] + "\n" : "\n") },
                          //                               { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                          //                               { text: 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                          //                               { text: 'Employee : ' + (($('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") }],
                          //                        fontSize: 10,
                          //                        height: 500,
                          //                    },
                          //                    {
                          //                        alignment: 'right',
                          //                        fontSize: 14,
                          //                        text: $("#lnkTitle").text(),
                          //                        height: 500,
                          //                    }
                          //                ],
                          //                margin: 20
                          //            }
                          //        });
                          //        doc['footer'] = (function (page, pages) {
                          //            return {
                          //                columns: [
                          //                    {
                          //                        alignment: 'left',
                          //                        text: ['Created on: ', { text: jsDate.toString() }]
                          //                    },
                          //                    {
                          //                        alignment: 'right',
                          //                        text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                          //                    }
                          //                ],
                          //                margin: 20
                          //            }
                          //        });

                          //        var objLayout = {};
                          //        objLayout['hLineWidth'] = function (i) { return .5; };
                          //        objLayout['vLineWidth'] = function (i) { return .5; };
                          //        objLayout['hLineColor'] = function (i) { return '#000'; };
                          //        objLayout['vLineColor'] = function (i) { return '#000'; };
                          //        objLayout['paddingLeft'] = function (i) { return 4; };
                          //        objLayout['paddingRight'] = function (i) { return 4; };
                          //        doc.content[0].layout = objLayout;

                          //        var rowCount = doc.content[0].table.body.length;
                          //        for (i = 1; i < rowCount; i++) {
                          //            doc.content[0].table.body[i][4].alignment = 'right';
                          //            doc.content[0].table.body[i][5].alignment = 'right';
                          //            doc.content[0].table.body[i][6].alignment = 'right';
                          //            doc.content[0].table.body[i][7].alignment = 'right';
                          //            doc.content[0].table.body[i][8].alignment = 'right';
                          //        };
                          //    }
                          //}
                    ]
                });
            }

        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
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
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" Enabled="false" ID="ddlSaleBy" CssClass="ddlSaleBy form-control" TabIndex="4" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportType" Text="Report Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportType" CssClass="ddlSaleBy form-control" TabIndex="5">
                            <asp:ListItem Text="Sales Against Order" Value="1" Selected="True" />
                            <asp:ListItem Text="Open Order" Value="2" />
                            <asp:ListItem Text="Cancel Order" Value="3" />
                            <asp:ListItem Text="All Order" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="6"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID" TabIndex="9">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblDealerType" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlDealer" runat="server" TabIndex="10" CssClass="ddlDealer form-control">
                            <asp:ListItem Text="Dealer Under Distributor" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Dealer Under Plant" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Both" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Date Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlDateOption" runat="server" CssClass="ddlDateOption form-control" TabIndex="11">
                            <asp:ListItem Text="Order Date" Value="1" Selected="True" />
                            <asp:ListItem Text="Invoice Date" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedBy" runat="server" Text="CreatedBy Wise" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkCreatedBy" runat="server" TabIndex="12" Checked="false" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="13" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />
                    </div>
                </div>

                <%--<div class="input-group form-group" id="divReportType" style="display: none;" runat="server">
                        <asp:Label Text="Report Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReport" runat="server" CssClass="ddlReport form-control" TabIndex="7">
                            <asp:ListItem Text="Distributor + Sales Order + Item wise Order v/s Despatch Report" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Distributor + Sales Order wise Order v/s Despatch Report" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Distributor wise Sales Order v/s Despatch Report" Value="3"></asp:ListItem>
                        </asp:DropDownList>
                    </div>--%>
            </div>
            <div class="row" hidden="hidden">
                <div class="col-lg-12">
                    <asp:GridView ID="gvSalevsDispatch" runat="server" CssClass="gvSalevsDispatch table tbl" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvSalevsDispatch_PreRender" HeaderStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

