<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseReceiptPendingRPT.aspx.cs" Inherits="Reports_PurchaseReceiptPendingRPT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <style type="text/css">
        .grdAlign {
            text-align: right !important;
        }
    </style>
    <script type="text/javascript">

        var ParentID = <% = ParentID%>;
        var EmpName = '<% = EmpName%>';
        
        $(function () {
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            sender.set_contextKey(reg + "-0-" + plt + "-2,4");
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(key + "-0");
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

            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
            if ($('.gvGrid thead tr').length > 0) {
                $('.gvGrid').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "bAutowidth" : true,
                    "aaSorting": [],
                    //"aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() +  new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() +'\n';
                            data += 'Distributor/SS,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") + '\n';
                            data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions") + '\n';
                            data += 'Plant,' +  (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All Plants") + '\n';
                            data += 'Created By,' + EmpName + '\n';
                            data += 'Created On,' + jsDate.toString() + '\n\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
                            format: {
                                body: function (data, row, column, node) {
                                    //check if type is input using jquery
                                    return (data == "&nbsp;" || data == "") ? " " : data.replace(/<br[^>]*>/g, " ");
                                }
                            }
                        }
                        
                    },
                    {
                        extend: 'excel', footer: true, filename: $("#lnkTitle").text() + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 6);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'Distributor/SS' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions")}]);
                            var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All Plants")}]);
                            var r4 = Addrow(5, [{ key: 'A', value: 'Created By' }, { key: 'B', value: EmpName}]);
                            var r5 = Addrow(6,[{ key: 'A', value: 'Created On'}, { key: 'B', value: jsDate.toString()}]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 +sheet.childNodes[0].childNodes[1].innerHTML;
                        },
                        exportOptions: {
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
                            format: {
                                body: function (data, row, column, node) {
                                    //check if type is input using jquery
                                    return (data == "&nbsp;" || data == "") ? " " : data.replace(/<br[^>]*>/g, " ");
                                }
                            }
                        }
                    },
                    { 
                        extend: 'pdfHtml5',
                        orientation: 'landscape', //portrait
                        pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                        title: $("#lnkTitle").text(),
                        footer : 'true',
                        exportOptions: 
                            {
                                columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
                                search: 'applied',
                                order: 'applied'
                            },
                        customize: function (doc) {
                            doc.content.splice(0, 1);
                            
                            doc.pageMargins = [20, 100, 20, 30];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: true,
                                            text:[
                                                   { text: 'Distributor/SS : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") +'\n' },
                                                   { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions") +'\n' },
                                                   { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All plants") +'\n' },
                                                   { text: 'Created By : ' + EmpName +'\n' },
                                                   { text: 'Created On : ' + jsDate.toString()   +'\n' }],
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
                                    margin: 10
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
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';
                                doc.content[0].table.body[i][14].alignment = 'right';
                                doc.content[0].table.body[i][15].alignment = 'right';
                                doc.content[0].table.body[i][16].alignment = 'right';
                                doc.content[0].table.body[i][17].alignment = 'right';
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

                        col14 = api.column(14, {page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        col15 = api.column(15,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        col16 = api.column(16,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col17 = api.column(17,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col18 = api.column(18,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(col10.toFixed(0));
                        $(api.column(11).footer()).html(col11.toFixed(2));
                        $(api.column(12).footer()).html(col12.toFixed(2));
                        $(api.column(13).footer()).html(col13.toFixed(2));
                        $(api.column(14).footer()).html(col14.toFixed(2));
                        $(api.column(15).footer()).html(col15.toFixed(2));
                        $(api.column(16).footer()).html(col16.toFixed(2));
                        $(api.column(17).footer()).html(col17.toFixed(2)); 
                        $(api.column(18).footer()).html(col18.toFixed(2));}
                });
            }
            else if ($('.gvGrid2 thead tr').length > 0)
            {
                $('.gvGrid2').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "bAutowidth" : true,
                    "aaSorting": [],
                    //"aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() +  new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text()+'\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") + '\n';
                            data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions") + '\n';
                            data += 'Plant,' +  (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All Plants") + '\n';
                            data += 'Created By,' + EmpName + '\n';
                            data += 'Created On,' + jsDate.toString() + '\n\n';
                            return data + csv;
                        },
                        exportOptions: {
                            format: {
                                body: function (data, row, column, node) {
                                    //check if type is input using jquery
                                    return (data == "&nbsp;" || data == "") ? " " : data.replace(/<br[^>]*>/g, " ");
                                }
                            }
                        }
                    },
                    {
                        extend: 'excel', footer: true, filename: $("#lnkTitle").text() + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 6);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions")}]);
                            var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All Plants")}]);
                            var r4 = Addrow(5, [{ key: 'A', value: 'Created By' }, { key: 'B', value: EmpName}]);
                            var r5 = Addrow(6,[{ key: 'A', value: 'Created On'}, { key: 'B', value: jsDate.toString()}]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 +sheet.childNodes[0].childNodes[1].innerHTML;
                        },
                        exportOptions: {
                            format: {
                                body: function (data, row, column, node) {
                                    //check if type is input using jquery
                                    return (data == "&nbsp;" || data == "") ? " " : data.replace(/<br[^>]*>/g, " ");
                                }
                            }
                        }
                    },
                    { 
                        extend: 'pdfHtml5',
                        orientation: 'landscape', //portrait
                        pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                        title: $("#lnkTitle").text(),
                        footer : 'true',
                        exportOptions: 
                            {
                                search: 'applied',
                                order: 'applied'
                            },
                        customize: function (doc) {
                            doc.content.splice(0, 1);
                            
                            doc.pageMargins = [20, 100, 20, 30];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: true,
                                            text:[
                                                   { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributors") +'\n' },
                                                   { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "")  ? $('.txtRegion').val().split('-')[1] : "All Regions") +'\n' },
                                                   { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "")  ? $('.txtPlant').val().split('-')[1] : "All plants") +'\n' },
                                                   { text: 'Created By : ' + EmpName +'\n' },
                                                   { text: 'Created On : ' + jsDate.toString()  +'\n' }],
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
                                    margin: 10
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
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';
                                doc.content[0].table.body[i][14].alignment = 'right';
                                doc.content[0].table.body[i][15].alignment = 'right';
                                doc.content[0].table.body[i][16].alignment = 'right';
                                doc.content[0].table.body[i][17].alignment = 'right';
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

                        col13 = api.column(13, {page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        col14 = api.column(14,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        col15 = api.column(15,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col16 = api.column(16,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        col17 = api.column(17,{ page: 'current'}).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(9).footer()).html(col9.toFixed(0));
                        $(api.column(10).footer()).html(col10.toFixed(2));
                        $(api.column(11).footer()).html(col11.toFixed(2));
                        $(api.column(12).footer()).html(col12.toFixed(2));
                        $(api.column(13).footer()).html(col13.toFixed(2));
                        $(api.column(14).footer()).html(col14.toFixed(2));
                        $(api.column(15).footer()).html(col15.toFixed(2));
                        $(api.column(16).footer()).html(col16.toFixed(2)); 
                        $(api.column(17).footer()).html(col17.toFixed(2));}
                });
            }
        }
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divRegion" runat="server">
                        <asp:Label Text="State" ID="lblRegion" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtRegion" TabIndex="1" CssClass="txtRegion form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtState" runat="server" ServicePath="../Service.asmx" UseContextKey="true" ServiceMethod="GetStates" MinimumPrefixLength="1"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtRegion">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="8" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group" id="divPlant" runat="server">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlants"
                            ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor/SS" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="3" CssClass="txtDistCode form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomerByTypePlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <br />
            <div class="row">
                <asp:GridView ID="gvGrid" runat="server" CssClass="gvGrid nowrap table" Style="font-size: 11px;" ShowFooter="true" AutoGenerateColumns="false"
                    OnPreRender="gvGrid_PreRender" OnRowCommand="gvGrid_RowCommand" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    EmptyDataText="No data found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="5px">
                            <ItemTemplate>
                                <%#Container.DataItemIndex+1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Delete">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnDelete" runat="server" ToolTip="Delete" CommandName="DeleteInward"
                                    OnClientClick="return confirm('Are you sure you want Delete this record?');"
                                    CommandArgument='<%#Eval("InwardID")+ "#" + Eval("ParentID") + "#" + Eval("DocType")%>'><img src="../Images/delete2.png" alt="Delete" style="height:25px; width:25px;"></img></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Invoice Date" DataField="InvoiceDate" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="center" />
                        <asp:BoundField HeaderText="Invoice Number" DataField="InvoiceNumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Indent Number" DataField="IndentNumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="PO number" DataField="PONumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Division" DataField="DivisionName" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Parent Name" DataField="Plant" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Distributor/SS Code" DataField="DistributorCode" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Distributor/SS Name" DataField="DistributorName" HeaderStyle-Width="300px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Qty" DataField="Qty" HeaderStyle-Width="40px" DataFormatString="{0:0}" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Gross Amount" DataField="GrossAmount" DataFormatString="{0:0.00}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Discount" DataField="Discount" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="CGST Amount" DataField="CGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="SGST Amount" DataField="SGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="IGST Amount" DataField="IGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="UGST Amount" DataField="UGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="RoundOff Amount" DataField="Rounding" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Net Amount" DataField="Nettotal" DataFormatString="{0:0.00}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                    </Columns>
                </asp:GridView>

                <asp:GridView ID="gvGrid2" runat="server" CssClass="gvGrid2 table" Style="font-size: 11px;" ShowFooter="true" AutoGenerateColumns="false"
                    OnPreRender="gvGrid2_PreRender" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="5px">
                            <ItemTemplate>
                                <%#Container.DataItemIndex+1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Invoice Date" DataField="InvoiceDate" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="center" />
                        <asp:BoundField HeaderText="Invoice Number" DataField="InvoiceNumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Indent Number" DataField="IndentNumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="PO number" DataField="PONumber" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Division" DataField="DivisionName" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Parent Name" DataField="Plant" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Distributor Code" DataField="DistributorCode" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Distributor Name" DataField="DistributorName" HeaderStyle-Width="300px" ItemStyle-HorizontalAlign="left" />
                        <asp:BoundField HeaderText="Qty" DataField="Qty" HeaderStyle-Width="40px" DataFormatString="{0:0}" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Gross Amount" DataField="GrossAmount" DataFormatString="{0:0.00}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Discount" DataField="Discount" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="CGST Amount" DataField="CGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="SGST Amount" DataField="SGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="IGST Amount" DataField="IGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="UGST Amount" DataField="UGSTAmt" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="RoundOff Amount" DataField="Rounding" DataFormatString="{0:0.00}" HeaderStyle-Width="70px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Net Amount" DataField="Nettotal" DataFormatString="{0:0.00}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Right" HeaderStyle-CssClass="grdAlign" FooterStyle-HorizontalAlign="Right" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>

