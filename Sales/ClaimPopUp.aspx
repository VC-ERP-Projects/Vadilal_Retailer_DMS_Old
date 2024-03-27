<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ClaimPopUp.aspx.cs" Inherits="Sales_ClaimPopUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <script type="text/javascript">

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

        $(function () {

            if ($('.gvCommon thead tr').length > 0) {
                var table = $('.gvCommon').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 2 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });

                $('.gvCommon').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '60vh',
                    scrollX: '90vh',
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [],
                    buttons: [{ extend: 'copy', footer: true },
                         {
                             extend: 'csv', footer: true, filename: 'ClaimDetails_' + new Date().toLocaleDateString(),
                             customize: function (csv) {
                                 var data = 'Claim Details' + '\n';
                                 data += $('.lblMonth').text() + '\n';
                                 data += $('.lblAppMode').text() + '\n';
                                 data += $('.lblCustomer').text() + '\n';
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
                             extend: 'excel', footer: true, filename: 'ClaimDetails_' + new Date().toLocaleDateString(),
                             customize: function (xlsx) {

                                 sheet = ExportXLS(xlsx, 5);
                                 var r0 = Addrow(1, [{ key: 'A', value: 'Claim Details' }]);
                                 var r1 = Addrow(2, [{ key: 'A', value: $('.lblMonth').text() }]);
                                 var r2 = Addrow(3, [{ key: 'A', value: $('.lblAppMode').text() }]);
                                 var r3 = Addrow(4, [{ key: 'A', value: $('.lblCustomer').text() }]);
                                 sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                             }
                         },
                         {
                             extend: 'pdfHtml5',
                             orientation: 'landscape', //portrait
                             pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                             title: 'Claim Details',
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
                                 doc.defaultStyle.fontSize = 8;
                                 doc.styles.tableHeader.fontSize = 8;
                                 doc.styles.tableFooter.fontSize = 8;
                                 doc['header'] = (function () {
                                     return {
                                         columns: [
                                             {
                                                 alignment: 'left',
                                                 italics: true,
                                                 text: [{ text: $('.lblMonth').text() + "\n" },
                                                           { text: $('.lblAppMode').text() + "\n" },
                                                           { text: $('.lblCustomer').text() + "\n" }],

                                                 fontSize: 10,
                                                 height: 500,
                                             },
                                             {
                                                 alignment: 'right',
                                                 fontSize: 14,
                                                 text: 'Claim Detail',
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
                                     doc.content[0].table.body[i][0].alignment = 'right';
                                     doc.content[0].table.body[i][1].alignment = 'right';
                                     doc.content[0].table.body[i][2].alignment = 'right';
                                     doc.content[0].table.body[i][3].alignment = 'right';
                                     doc.content[0].table.body[i][4].alignment = 'right';
                                     doc.content[0].table.body[i][5].alignment = 'right';
                                     doc.content[0].table.body[i][12].alignment = 'right';
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
                        col3 = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        $(api.column(4).footer()).html(col3.toFixed(2));
                    }
                })
            }
        });
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

        .dtbodyRight {
            text-align: right;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="margin: 10px;">
            <div>
                <div style="float: left; margin-left: 20px;">
                    <asp:Label ID="lblMonth" runat="server" Text="Month : " CssClass="lblMonth input-group-addon"></asp:Label>
                    <asp:Label ID="lblAppMode" runat="server" Text="Application Mode : " CssClass="lblAppMode input-group-addon"></asp:Label>
                    <asp:Label ID="lblCustomer" runat="server" Text="Customer : " CssClass="lblCustomer input-group-addon"></asp:Label>
                    <br />
                </div>
            </div>
            <br />
            <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap tbl table" Width="100%" Style="font-size: 11px;" AutoGenerateColumns="true"
                OnPreRender="gvCommon_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                ShowFooter="true" EmptyDataText="No data found. ">
            </asp:GridView>
        </div>
    </form>
</body>
</html>
