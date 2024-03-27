<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AttendenceDetails.aspx.cs" Inherits="Reports_AttendenceDetails" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../css/base.css" rel="stylesheet" type="text/css" />
    <link href="../css/index.css" rel="stylesheet" type="text/css" />

    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

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

        $(function () {

            $('.gvDetail').DataTable({
                bFilter: true,
                scrollCollapse: true,
                destroy: true,
                "ordering": true,
                "order": [[0, "asc"]],
                scrollY: '50vh',
                scrollX: true,
                responsive: true,
                dom: 'Bfrtip',
                "stripeClasses": ['odd-row', 'even-row'],
                "bPaginate": false,
                buttons: [{ extend: 'copy', footer: true }, {
                    extend: 'csv', header: 'AttendenceDetails_', footer: true, filename: 'AttendenceDetails_' + new Date().toLocaleDateString(),
                    customize: function (csv) {
                        var data = 'Date wise Daily Activities Detail Report For : ' + $('.txtCode').text() + '\n';
                        data += 'Date,' + $('.fromdate').text() + '\n';
                        return data + csv;
                    },
                    exportOptions: {
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
                    extend: 'excel', header: 'DailyActivityViewReport_', footer: true, filename: 'DailyActivityViewReport_' + '_' + new Date().toLocaleDateString(),
                    customize: function (xlsx) {

                        sheet = ExportXLS(xlsx, 3);

                        var r0 = Addrow(1, [{ key: 'A', value: 'Date wise Daily Activities Detail Report For' }, { key: 'B', value: $('.txtCode').text() }]);
                        var r1 = Addrow(2, [{ key: 'A', value: 'Date' }, { key: 'B', value: $('.fromdate').text() }]);

                        sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + sheet.childNodes[0].childNodes[1].innerHTML;
                    }
                },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape', //portrait
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: 'Attendence Details',
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
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                 {
                                                     alignment: 'left',
                                                     italics: true,
                                                     text: [{ text: 'Date wise Daily Activities Detail Report For : ' + $('.txtCode').text() + "\n" },
                                                     { text: 'Date : ' + $('.fromdate').text() + "\n" }],
                                                     fontSize: 10,
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

                                        doc.content[0].table.body[i][3].alignment = 'right';
                                        //doc.content[0].table.body[i][8].alignment = 'right';
                                        //doc.content[0].table.body[i][9].alignment = 'right';

                                    };
                                }
                            }]
            });
        });
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

        div.dataTables_wrapper {
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="panel">
            <div class="panel-body">
                <div>
                    <div style="float: left; margin-left: 20px;">
                        <asp:Label ID="lblCode" runat="server" Text="Employee : " CssClass="input-group-addon"></asp:Label>
                        <asp:Label ID="txtCode" runat="server" CssClass="form-control txtCode"></asp:Label>
                        <br />
                        <asp:Label ID="lblFromDate" runat="server" Text="Date : " CssClass="input-group-addon"></asp:Label>
                        <asp:Label ID="txtFromDate" runat="server" CssClass="fromdate form-control"></asp:Label>
                    </div>
                    <div style="float: right; margin-right: 50px;">
                        <asp:GridView runat="server" ID="gvData" EmptyDataText="No Item Found." Style="font-size: 10px;">
                        </asp:GridView>
                    </div>
                    <div style="clear: both;"></div>
                </div>
                <br />
                <asp:GridView runat="server" ID="gvDetail" CssClass="gvDetail table" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                    Width="120%" EmptyDataText="No Item Found." Style="font-size: 10px;" OnPreRender="gvDetail_PreRender">
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
