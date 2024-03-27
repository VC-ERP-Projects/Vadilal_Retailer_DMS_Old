<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DealerWiseGrowthSaleReport.aspx.cs" Inherits="Reports_DealerWiseGrowthSaleReport" %>

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
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtRegion").val('');
                $(".txtCity").val('');
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

        function acettxtCity_OnClientPopulating(sender, args) {
            var State = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(State + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            ReLoadFn();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                $('.lblRegion').text('SuperStockist Region');
                $('.lblCity').text('Distributor City');
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                $('.lblRegion').text('Distributor Region');
                $('.lblCity').text('Dealer City');
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }

        function ReLoadFn() {
            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            if ($('.gvGrid thead tr').length > 0) {
                var table = $('.gvGrid').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "sClass": "dtbodyRight", "aTargets": 8 });

                $('.gvGrid').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '40vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: 'Dealer Wise Growth Sale Report '+  new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = 'Dealer Wise Growth Sale Report '+'\n';
                            data += 'Month Duration From,' + $('.txtFromMonth1').val() + ' - ' + $('.txtToMonth1').val() + ',To,'  + $('.txtFromMonth2').val() + ' - ' + $('.txtToMonth2').val() +'\n';
                            data += 'Sale By,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += $('.lblRegion').text() +',' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                            data += $('.lblCity').text() + ',' +  (($('.txtCity').length > 0 && $('.txtCity').val() != "")  ? $('.txtCity').val().split('-')[1] : "All City") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "")  ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") + '\n';
                            data += 'Division,' +  (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[1] : "All Employee") + '\n\n';
                           
                            return data + csv;
                        }
                    },
                    {
                        extend: 'excel', footer: true, filename: $("#lnkTitle").text() + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 10);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text()  }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'Month Duration From' }, { key: 'B', value: $('.txtFromMonth1').val() + ' - ' + $('.txtToMonth1').val() }, { key: 'C', value: 'To' }, { key: 'D', value:$('.txtFromMonth2').val() + ' - ' + $('.txtToMonth2').val()  }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r3 = Addrow(4, [{ key: 'A', value: $('.lblRegion').text() }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Region")}]);
                            var r4 = Addrow(5, [{ key: 'A', value: $('.lblCity').text() }, { key: 'B', value: (($('.txtCity').length > 0 && $('.txtCity').val() != "")  ? $('.txtCity').val().split('-')[1] : "All City")}]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r7 = Addrow(8, [{ key: 'A', value: 'Division' }, { key: 'B', value: (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") }]);
                            var r8 = Addrow(9, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[1] : "All Employee") }]);
                           
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
                            doc.pageMargins = [20, 120, 20, 30];
                            doc.defaultStyle.fontSize = 7;
                            doc.styles.tableHeader.fontSize = 7;
                            doc.styles.tableFooter.fontSize = 7;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: true,
                                            text:[{ text: 'Month Duration From : ' + $('.txtFromMonth1').val() + ' - ' +  $('.txtToMonth1').val() +'\t To : ' + $('.txtFromMonth2').val() + ' - ' + $('.txtToMonth2').val() + '\n' },
                                                  { text: 'Sale By : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                                  { text: $('.lblRegion').text() + ' : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Region") +'\n' },
                                                  { text: $('.lblCity').text() + ' : ' + (($('.txtCity').length > 0 && $('.txtCity').val() != "")  ? $('.txtCity').val().split('-')[1] : "All City") +'\n' },   
                                                  { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") + '\n' : '') },
                                                  { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") +'\n' },
                                                  { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "")  ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") +'\n' : '') },
                                                  { text: 'Division :' +  (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() + "\n" : "All Division" + "\n") },
                                                  { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[1] : "All Employee") + '\n' }],
                                            fontSize: 10,
                                            height: 600,
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 14,
                                            text: $("#lnkTitle").text() ,
                                            height: 600,
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
                                for (var j = 8; j < colCount; j++) {
                                    doc.content[0].table.body[i][j].alignment = 'right';
                                }
                            };
                        }
                    }
                    ],
                    "footerCallback": function (row, data, start, end, display) {

                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };

                        col9 = api.column(9,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col10 = api.column(10,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col11 = api.column(11,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col12 = api.column(12,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col13 = api.column(13,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col14 = api.column(14,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        
                        $(api.column(9).footer()).html(col9.toFixed(2));
                        $(api.column(10).footer()).html(col10.toFixed(2));
                        $(api.column(11).footer()).html(col11.toFixed(2));
                        $(api.column(12).footer()).html(col12.toFixed(2));
                        $(api.column(13).footer()).html(col13.toFixed(2));
                        $(api.column(14).footer()).html(col14.toFixed(2));

                    }
                });
            }

        }
       
        function ChangeState()
        {
            $('.txtCity').val('');
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

    </script>
    <style type="text/css">
        .ui-datepicker-calendar {
            display: none;
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

        div.dataTables_wrapper {
            margin: 0 auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate1" runat="server" Text="From Month 1" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtFromMonth1" TabIndex="1" runat="server" MaxLength="7" CssClass="txtFromMonth1 onlymonth form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate1" runat="server" Text="To Month 1" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtToMonth1" TabIndex="2" runat="server" MaxLength="7" CssClass="onlymonth txtToMonth1 form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate2" runat="server" Text="From Month 2" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtFromMonth2" TabIndex="3" runat="server" MaxLength="7" CssClass="txtFromMonth2 onlymonth form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate2" runat="server" Text="To Month 2" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtToMonth2" TabIndex="4" runat="server" MaxLength="7" CssClass="txtToMonth2 onlymonth form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="6" CssClass="ddlSaleBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Distributor Region' CssClass="lblRegion input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="7"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3" id="divCity" runat="server">
                    <div class="input-group form-group">
                        <asp:Label Text="Distributor City" ID="lblCity" runat="server" CssClass="lblCity input-group-addon" autocomplete="off" />
                        <asp:TextBox runat="server" ID="txtCity" TabIndex="8" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass"
                            OnClientPopulating="acettxtCity_OnClientPopulating" ID="acettxtCity" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" ServiceMethod="GetCitysCurrHierarchy" MinimumPrefixLength="1"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="10" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="11" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="12" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="13" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp;
                        <asp:Button ID="btnExport" runat="server" Text="Export to Excel" TabIndex="13" CssClass="btn btn-default" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvGrid" runat="server" CssClass="gvGrid table" Style="font-size: 11px;" Width="100%" AutoGenerateColumns="false" ShowFooter="true"
                        FooterStyle-HorizontalAlign="Right" OnPreRender="gvGrid_PreRender" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                        <Columns>
                            <asp:BoundField HeaderText="Sr No" DataField="SrNo" HeaderStyle-Width="20px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Parent Code" DataField="DistriButorCode" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Parent Name" DataField="DistributorName" HeaderStyle-Width="230px" ItemStyle-HorizontalAlign="left" />
                            <asp:BoundField HeaderText="Parent Region" DataField="State" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="left" />
                            <asp:BoundField HeaderText="Customer City" DataField="City" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="left" />
                            <asp:BoundField HeaderText="Customer Code" DataField="DealerCode" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="left" />
                            <asp:BoundField HeaderText="Customer Name" DataField="DealerName" HeaderStyle-Width="230px" ItemStyle-HorizontalAlign="left" />
                            <asp:BoundField HeaderText="Customer Start Date" DataFormatString="{0:dd/MM/yyyy}" DataField="DealerStartDate" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField HeaderText="Total Assets" DataField="TotalAsset" HeaderStyle-Width="55px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="FromLtrs" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="FromValue" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="ToLtrs" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="ToValue" HeaderStyle-Width="90px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Difference Ltrs." DataField="DifferenceLtrs" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Difference Value" DataField="DifferenceValue" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Growth % Ltrs." DataField="growth%ltr" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField HeaderText="Growth % Value" DataField="growth%value" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

