<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Popup.aspx.cs" Inherits="Popup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title>Vadilal House Vadilal Enterprises Ltd.</title>

    <link href="Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/datatable/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable/buttons.dataTables.min.css" rel="stylesheet" />


    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/Bootstrap/bootstrap.js" type="text/javascript"></script>
    <script src="../Scripts/datatable/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable/buttons.flash.min.js"></script>

    <script type="text/javascript">

        $(function () {

            $('.gvDelearSummary').DataTable({
                bFilter: true,
                paging: true,
                scrollY: '150vh',
                scrollCollapse: true,
                ordering: true,
                dom: 'Brtip',
                "lengthMenu": [[100, -1], [100, "All"]],
                buttons: [{ extend: 'copy', footer: true }, { extend: 'csv', footer: true }, { extend: 'excel', footer: true, filename: 'GetDetailDealerSummary_' + new Date().toLocaleString() + '.xlsx' }, { extend: 'pdf', footer: true }],
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

                    TotalQty = api.column(5,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    Subtotal = api.column(6,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    CompanyDis = api.column(7,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    DistributorDis = api.column(8,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    AVAT1TaxAmt = api.column(9,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    VT4TaxAmt = api.column(10,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    AVAT2 = api.column(11,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    VT12 = api.column(12,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    VTEXPTTaxAmt = api.column(13,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);


                    Total = api.column(14,{ page: 'current'}).data().reduce(function (a, b) {
                        return intVal(a) + intVal(b);
                    }, 0);

                    $(api.column(5).footer()).html(TotalQty.toFixed(2));
                    $(api.column(6).footer()).html(Subtotal.toFixed(2));
                    $(api.column(7).footer()).html(CompanyDis.toFixed(2));
                    $(api.column(8).footer()).html(DistributorDis.toFixed(2));
                    $(api.column(9).footer()).html(AVAT1TaxAmt.toFixed(2));
                    $(api.column(10).footer()).html(VT4TaxAmt.toFixed(2));
                    $(api.column(11).footer()).html(AVAT2.toFixed(2));
                    $(api.column(12).footer()).html(VT12.toFixed(2));
                    $(api.column(13).footer()).html(VTEXPTTaxAmt.toFixed(2));
                    $(api.column(14).footer()).html(Total.toFixed(2));
                }
            });

        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div class="col-lg-4">
                <div class="input-group form-group">
                    Press ESC to exit!
                </div>
            </div>
            <asp:GridView ID="gvDelearSummary" runat="server" CssClass="gvDelearSummary HighLightRowColor2 table tbl" OnPreRender="gvDelearSummary_PreRender" ShowFooter="True" AutoGenerateColumns="false"
                HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="Customer Code">
                        <ItemTemplate>
                            <asp:Label ID="lblCusCode" CssClass="lblPrice" runat="server" Text='<%# Eval("CustomerCode") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Customer Name">
                        <ItemTemplate>
                            <asp:Label ID="lblCustName" class="lblCustName" runat="server" Text='<%# Eval("CustomerName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Invoice Date">
                        <ItemTemplate>
                            <asp:Label ID="lblInvoiceDate" runat="server" Text='<%# Eval("InvoiceDate") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Invoice Number">
                        <ItemTemplate>
                            <asp:Label ID="lblInvoiceNumber" runat="server" Text='<%# Eval("InvoiceNumber") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="InvoiceType" DataFormatString="{0:0.00}" HeaderText="Invoice Type" />
                    <asp:BoundField DataField="TotalQty" DataFormatString="{0:0.00}" HeaderText="TotalQty" />
                    <asp:BoundField DataField="SubTotal" DataFormatString="{0:0.00}" HeaderText="SubTotal" />
                    <asp:BoundField DataField="CompanyDisc" DataFormatString="{0:0.00}" HeaderText="Company Dis." />
                    <asp:BoundField DataField="DistributorDisc" DataFormatString="{0:0.00}" HeaderText="Distributor Dis." />
                    <asp:BoundField DataField="AVAT1TaxAmt" DataFormatString="{0:0.00}" HeaderText="AVAT1Tax Amt" />
                    <asp:BoundField DataField="VT4TaxAmt" DataFormatString="{0:0.00}" HeaderText="VT4Tax Amt" />
                    <asp:BoundField DataField="AVAT2.5TaxAmt" DataFormatString="{0:0.00}" HeaderText="AVAT2.5 TaxAmt" />
                    <asp:BoundField DataField="VT12.5TaxAmt" DataFormatString="{0:0.00}" HeaderText="VT12.5 TaxAmt" />
                    <asp:BoundField DataField="VTEXPTTaxAmt" DataFormatString="{0:0.00}" HeaderText="VTEXPT TaxAmt" />
                    <asp:BoundField DataField="Total" DataFormatString="{0:0.00}" HeaderText="Total" />
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>
