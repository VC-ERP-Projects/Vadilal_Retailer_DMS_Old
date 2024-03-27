<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimProcessParent.aspx.cs" Inherits="Sales_ClaimProcessParent" %>

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
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }

        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            var SalesAmount = 0, SchemeAmount = 0, CompanyCont = 0, DistCont = 0, DistContTax = 0, TotalCompanyCont = 0, TotalQty = 0;

            if ($('.gvCommon thead tr').length > 0) {
                $('.gvCommon').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: '70vh',
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    buttons: [{ extend: 'copy', footer: true },
                         {
                             extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                             customize: function (csv) {
                                 var data = $("#lnkTitle").text() + '\n';
                                 data += 'Claim Month,' + ($('.onlymonth').val()) + '\n';
                                 data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                                 data += 'Display,' + $('.ddlDisplay option:Selected').text() + '\n';
                                 data += 'Customer,' + $('.txtCustCode').val() + '\n';

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

                                 sheet = ExportXLS(xlsx, 5);
                                 var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                 var r1 = Addrow(2, [{ key: 'A', value: 'Claim Month' }, { key: 'B', value: ($('.onlymonth').val()) }]);
                                 var r2 = Addrow(3, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').text()) }]);
                                 var r3 = Addrow(4, [{ key: 'A', value: 'Display' }, { key: 'B', value: ($('.ddlDisplay option:Selected').text()) }]);
                                 var r4 = Addrow(5, [{ key: 'A', value: 'Customer' }, { key: 'B', value: ($('.txtCustCode').val()) }]);

                                 sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
                             }
                         },
                         {
                             extend: 'pdfHtml5',
                             orientation: 'landscape', //portrait
                             pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                             title: $("#lnkTitle").text(),
                             footer: 'true',
                             exportOptions: {
                                 columns: [0, 2, 3, 4, 5, 6, 7],
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
                                 doc.defaultStyle.fontSize = 8;
                                 doc.styles.tableHeader.fontSize = 8;
                                 doc.styles.tableFooter.fontSize = 8;
                                 doc['header'] = (function () {
                                     return {
                                         columns: [
                                             {
                                                 alignment: 'left',
                                                 italics: true,
                                                 text: [{ text: 'Claim Month : ' + $('.onlymonth').val() + "\n" },
                                                        { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                                        { text: 'Display : ' + $('.ddlDisplay option:Selected').text() + '\n' },
                                                        { text: 'Customer : ' + $('.txtCustCode').val() + "\n" },
                                                 ],

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
                                                 fontSize: 8,
                                                 text: ['Created on: ', { text: jsDate.toString() }]
                                             },
                                             {
                                                 alignment: 'right',
                                                 fontSize: 8,
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
                                     doc.content[0].table.body[i][3].alignment = 'right';
                                     doc.content[0].table.body[i][4].alignment = 'right';
                                     doc.content[0].table.body[i][5].alignment = 'right';
                                     doc.content[0].table.body[i][6].alignment = 'right';
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

                        SchemeAmount = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        Deduction = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        Apporved = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        SalesAmount = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).text());
                        }, 0);

                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(6).footer()).html(Deduction.toFixed(2));
                        $(api.column(7).footer()).html(Apporved.toFixed(2));
                        $(api.column(9).footer()).html(SalesAmount.toFixed(2));
                    }
                });
            }
        }

        function btnGenerat_Click() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
    <style type="text/css">
        .ui-datepicker-calendar {
            display: none;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }
        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 0px 4px !important;
        }

        table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 0px 18px 6px 18px !important;
            border-top: 1px solid #111;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <asp:UpdatePanel ID="up1" runat="server">
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnGenerat" />
                        <asp:PostBackTrigger ControlID="btnSumbit" />
                        <asp:PostBackTrigger ControlID="btnClear" />
                    </Triggers>
                    <ContentTemplate>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="ddlDisplay form-control" Enabled="false">
                                    <asp:ListItem Text="Pending" Value="1" Selected="True" />
                                    <asp:ListItem Text="Error" Value="2" />
                                    <asp:ListItem Text="Success" Value="3" />
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Button ID="btnGenerat" runat="server" Text="Search" TabIndex="5" CssClass="btn btn-info" OnClick="btnGenerat_Click" OnClientClick="return btnGenerat_Click();" />
                                &nbsp
                        <asp:Button Text="Submit For Approval" ID="btnSumbit" TabIndex="6" CssClass="btn btn-success" runat="server" OnClick="btnSumbit_Click" />
                                &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-danger" OnClick="btnClear_Click" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control">
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCustCode" TabIndex="2" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server"
                                    ServicePath="~/WebService.asmx" UseContextKey="true" ServiceMethod="GetOnlyChildCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                                </asp:AutoCompleteExtender>
                            </div>

                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="Label2" runat="server" Text="Upload Claim Report" CssClass="input-group-addon"></asp:Label>
                                <asp:FileUpload ID="flpFileUpload" runat="server" CssClass="form-control" Multiple="Multiple"></asp:FileUpload>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap tbl table" Style="font-size: 11px;" OnPreRender="gvCommon_PreRender" Width="100%"
                ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No.">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ParentClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Customer Code" DataField="CustomerCode" />
                    <asp:BoundField HeaderText="Customer Name" DataField="CustomerName" />
                    <asp:BoundField HeaderText="Reason Code" DataField="SAPReasonItemCode" />
                    <asp:BoundField HeaderText="Scheme Type" DataField="ReasonName" />
                    <asp:TemplateField HeaderText="Scheme Amount">
                        <ItemTemplate>
                            <asp:Label ID="lblSchemeAmount" runat="server" Text='<%# Bind("SchemeAmount", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Claim Amount">
                        <ItemTemplate>
                            <asp:Label ID="lblApproved" runat="server" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Purchase Amount of Customer">
                        <ItemTemplate>
                            <asp:Label ID="lblTotalPurchase" runat="server" Text='<%# Bind("TotalPurchase", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

