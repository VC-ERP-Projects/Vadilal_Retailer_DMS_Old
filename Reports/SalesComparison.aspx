<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SalesComparison.aspx.cs" Inherits="Reports_SalesComparison" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <style type="text/css">
        table.dataTable thead th, table.dataTable thead td {
            padding: 10px 8px;
            border-bottom: 1px solid #111;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 10px 8px;
            border-bottom: 1px solid #111;
        }

        table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 10px 8px;
            border-bottom: 1px solid #111;
        }


        .dtbodyRight {
            text-align: right;
        }
    </style>

    <script type="text/javascript">

        var April = 0, May = 0, June = 0, July = 0, August = 0, Septmber = 0, Octomber = 0, November = 0, December = 0, January = 0, February = 0, March = 0;

        $(function () {
            Load();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

            $('.gvSalesComparison').DataTable({
                bFilter: true,
                paging: true,
                scrollY: '150vh',
                scrollCollapse: true,
                ordering: true,
                dom: 'Brtip',
                "lengthMenu": [[10, -1], [10, "All"]],
                buttons: [{ extend: 'copy', footer: true }, { extend: 'csv', footer: true }, { extend: 'excel', footer: true, filename: 'SalesComparision_' + new Date().toLocaleString() + '.xlsx' },
                    {
                        extend: 'pdfHtml5',
                        title: 'Sales Comparision Report',
                        footer: 'true',
                        orientation: 'landscape', //portrait
                        pageSize: 'A4', //A3 , A5 , A6 , legal , letter
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
                            doc.pageMargins = [20, 50, 20, 30];
                            doc.defaultStyle.fontSize = 7;
                            doc.styles.tableHeader.fontSize = 7;
                            doc.styles.tableFooter.fontSize = 7;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: true,
                                            text: [{ text: 'Year : ' + $('.OnlyYear').val() + "\n" },
                                                   { text: 'Distributor : ' + (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val().split('-').slice(0, 2) + "\n" : "\n") }
                                                ],
                                                fontSize: 10,
                                            height: 700,
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 14,
                                            text: 'Sales Comparision Report',
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

                            var table = $('.gvSalesComparison').DataTable();
                            var colCount = table.columns()[0].length;
                            var rowCount = doc.content[0].table.body.length;
                            var tds = document.getElementsByTagName("td");
                            //for (i = 1; i < rowCount; i++) {
                            //    for (var j = 0; j < colCount; j++) {
                            //        if (tds[j].align == 'right') {
                            //            doc.content[0].table.body[i][j].alignment = 'right';
                            //        }
                            //    }
                            //}
                            for (i = 1; i < rowCount; i++) {
                                doc.content[0].table.body[i][2].alignment = 'right';
                                doc.content[0].table.body[i][3].alignment = 'right';
                                doc.content[0].table.body[i][4].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
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

                    // Total over all pages [ put (column(3, { page: 'current' }) for page wise sum) ]

                    April = api.column(3, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    May = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    June = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    July = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    August = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    Septmber = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    Octomber = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    November = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    December = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    January = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    February = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    March = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    $(api.column(3).footer()).html(April.toFixed(2));
                    $(api.column(4).footer()).html(May.toFixed(2));
                    $(api.column(5).footer()).html(June.toFixed(2));
                    $(api.column(6).footer()).html(July.toFixed(2));
                    $(api.column(7).footer()).html(August.toFixed(2));
                    $(api.column(8).footer()).html(Septmber.toFixed(2));
                    $(api.column(9).footer()).html(Octomber.toFixed(2));
                    $(api.column(10).footer()).html(November.toFixed(2));
                    $(api.column(11).footer()).html(December.toFixed(2));
                    $(api.column(12).footer()).html(January.toFixed(2));
                    $(api.column(13).footer()).html(February.toFixed(2));
                    $(api.column(14).footer()).html(March.toFixed(2));
                }
            });

        });

        function EndRequestHandler2(sender, args) {
            Load();
        }

        function Load() {
            $(".OnlyYear").datepicker({ dateFormat: 'yy', changeYear: true });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblYear" runat="server" Text="Year" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtYear" runat="server" CssClass="OnlyYear form-control" onfocus="this.blur();"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvSalesComparison" runat="server" CssClass="gvSalesComparison HighLightRowColor2 table tbl" OnPreRender="gvSalesComparison_PreRender" ShowFooter="True" AutoGenerateColumns="False"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                        <Columns>
                            <asp:TemplateField HeaderText="Customer Code">
                                <ItemTemplate>
                                    <asp:Label ID="lblCusCode" CssClass="lblPrice" runat="server" Text='<%# Eval("CustomerCode") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Customer Name">
                                <ItemTemplate>
                                    <asp:Label ID="lblCustName" CssClass="lblCustName" runat="server" Text='<%# Eval("CustomerName") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Year">
                                <ItemTemplate>
                                    <asp:Label ID="lblSaleYear" CssClass="lblSaleYear" runat="server" Text='<%# Eval("Saleyear") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>

                            <asp:BoundField DataField="April" DataFormatString="{0:0.00}" HeaderText="April" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="May" DataFormatString="{0:0.00}" HeaderText="May" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="June" DataFormatString="{0:0.00}" HeaderText="June" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="July" DataFormatString="{0:0.00}" HeaderText="July" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="August" DataFormatString="{0:0.00}" HeaderText="August" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="Septmber" DataFormatString="{0:0.00}" HeaderText="September" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="Octomber" DataFormatString="{0:0.00}" HeaderText="October" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="November" DataFormatString="{0:0.00}" HeaderText="November" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="December" DataFormatString="{0:0.00}" HeaderText="December" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="January" DataFormatString="{0:0.00}" HeaderText="January" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="February" DataFormatString="{0:0.00}" HeaderText="February" ItemStyle-HorizontalAlign="Right" />
                            <asp:BoundField DataField="March" DataFormatString="{0:0.00}" HeaderText="March" ItemStyle-HorizontalAlign="Right" />
                        </Columns>
                        <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
                        <HeaderStyle CssClass=" table-header-gradient"></HeaderStyle>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

