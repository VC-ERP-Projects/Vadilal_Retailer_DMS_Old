<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="ReturnAgainstSales.aspx.cs" Inherits="Reports_SalesReturnRegister" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <script type="text/javascript">

        var strIds = "";
        var CustType = '<% = CustType%>';
        var ParentID = '<% = ParentID%>';

        $(function () {

            Reload();


            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

        });

        function EndRequestHandler2(sender, args) {

            Reload();

        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            if ($('.txtDistCode').val() != undefined) {
                var key = $('.txtDistCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
            else {
                sender.set_contextKey(ParentID);
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


        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
        function Reload() {

            if ($('.gvSalesRegister thead tr').length > 0) {
                if ($('.ddlInvoiceType').val() == "1") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 24 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 25 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 26 });

                    $('.gvSalesRegister').DataTable({
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
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data =$("#lnkTitle").text() + '\n';
                                   data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                   data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Distributor GSTNo # City,' + $('.txtData').val() + '\n';
                                   data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Invoice Type,' + $('.ddlDocType option:Selected').text() + '\n';
                                   data += 'Group By,' + $('.ddlInvoiceType option:Selected').text() + '\n';
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

                                   sheet = ExportXLS(xlsx, 7);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text()  }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Distributor GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                   var r5 = Addrow(6, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlInvoiceType option:Selected').text()) }]);
                                   var r6 = Addrow(7, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlDocType option:Selected').text()) }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                          {
                              extend: 'pdfHtml5',
                              orientation: 'landscape', //portrait
                              pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                              title: $("#lnkTitle").text() ,
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
                                  doc.pageMargins = [20, 100, 20, 30];
                                  doc.defaultStyle.fontSize = 5;
                                  doc.styles.tableHeader.fontSize = 5;
                                  doc.styles.tableFooter.fontSize = 5;
                                  doc['header'] = (function () {
                                      return {
                                          columns: [
                                              {
                                                  alignment: 'left',
                                                  italics: true,
                                                  text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                         { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Distributor GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                         { text: 'Dealer : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Group By : ' + ($('.ddlInvoiceType option:Selected').text()) + '\n' },
                                                         { text: 'Invoice Type :' + ($('.ddlDocType option:Selected').text()) + '\n' }],
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
                                      doc.content[0].table.body[i][5].alignment = 'right';
                                      doc.content[0].table.body[i][12].alignment = 'right';
                                      doc.content[0].table.body[i][13].alignment = 'right';
                                      doc.content[0].table.body[i][14].alignment = 'right';
                                      doc.content[0].table.body[i][15].alignment = 'right';
                                      doc.content[0].table.body[i][16].alignment = 'right';
                                      doc.content[0].table.body[i][17].alignment = 'right';
                                      doc.content[0].table.body[i][18].alignment = 'right';
                                      doc.content[0].table.body[i][19].alignment = 'right';
                                      doc.content[0].table.body[i][20].alignment = 'right';
                                      doc.content[0].table.body[i][21].alignment = 'right';
                                      doc.content[0].table.body[i][22].alignment = 'right';
                                      doc.content[0].table.body[i][23].alignment = 'right';
                                      doc.content[0].table.body[i][24].alignment = 'right';
                                      doc.content[0].table.body[i][25].alignment = 'right';
                                      doc.content[0].table.body[i][26].alignment = 'right';
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


                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col14 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col17 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col19 = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col20 = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col24 = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col25 = api.column(25, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col26 = api.column(26, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);


                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                            $(api.column(24).footer()).html(col24.toFixed(2));
                            $(api.column(25).footer()).html(col25.toFixed(2));
                            $(api.column(26).footer()).html(col26.toFixed(2));
                        }
                    });
                }
                if ($('.ddlInvoiceType').val() == "2") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];
                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 24 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 25 });

                    $('.gvSalesRegister').DataTable({
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
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                   data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Distributor GSTNo # City,' + $('.txtData').val() + '\n';
                                   data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Group By,' + $('.ddlInvoiceType option:Selected').text() + '\n';
                                   data += 'Invoice Type,' + $('.ddlDocType option:Selected').text() + '\n';
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

                                   sheet = ExportXLS(xlsx, 7);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() + '_' }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Distributor GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                   var r5 = Addrow(6, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlInvoiceType option:Selected').text()) }]);
                                   var r6 = Addrow(7, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlDocType option:Selected').text()) }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                           {
                               extend: 'pdfHtml5',
                               orientation: 'landscape', //portrait
                               pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                               title: $("#lnkTitle").text() ,
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
                                   doc.pageMargins = [20, 100, 20, 30];
                                   doc.defaultStyle.fontSize = 5;
                                   doc.styles.tableHeader.fontSize = 5;
                                   doc.styles.tableFooter.fontSize = 5;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: true,
                                                   text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                          { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                          { text: 'Distributor GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                          { text: 'Dealer : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                          { text: 'Group By : ' + ($('.ddlInvoiceType option:Selected').text()) + '\n' },
                                                          { text: 'Invoice Type :' + ($('.ddlDocType option:Selected').text()) }],
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
                                       doc.content[0].table.body[i][5].alignment = 'right';
                                       doc.content[0].table.body[i][11].alignment = 'right';
                                       doc.content[0].table.body[i][12].alignment = 'right';
                                       doc.content[0].table.body[i][13].alignment = 'right';
                                       doc.content[0].table.body[i][14].alignment = 'right';
                                       doc.content[0].table.body[i][15].alignment = 'right';
                                       doc.content[0].table.body[i][16].alignment = 'right';
                                       doc.content[0].table.body[i][17].alignment = 'right';
                                       doc.content[0].table.body[i][18].alignment = 'right';
                                       doc.content[0].table.body[i][19].alignment = 'right';
                                       doc.content[0].table.body[i][20].alignment = 'right';
                                       doc.content[0].table.body[i][21].alignment = 'right';
                                       doc.content[0].table.body[i][22].alignment = 'right';
                                       doc.content[0].table.body[i][23].alignment = 'right';
                                       doc.content[0].table.body[i][24].alignment = 'right';
                                       doc.content[0].table.body[i][25].alignment = 'right';
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

                            col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col14 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col16 = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);
                            col17 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col19 = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col20 = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col24 = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col25 = api.column(25, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            $(api.column(11).footer()).html(col11.toFixed(2));
                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));
                            $(api.column(16).footer()).html(col16.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                            $(api.column(24).footer()).html(col24.toFixed(2));
                            $(api.column(25).footer()).html(col25.toFixed(2));
                        }
                    });
                }
                else if ($('.ddlInvoiceType').val() == "3") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "250px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 24 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 25 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 26 });

                    $('.gvSalesRegister').DataTable({
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
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   var data = $("#lnkTitle").text() + '\n';
                                   data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                   data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Distributor GSTNo # City,' + $('.txtData').val() + '\n';
                                   data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                   data += 'Group By,' + $('.ddlInvoiceType option:Selected').text() + '\n';
                                   data += 'Invoice Type,' + $('.ddlDocType option:Selected').text() + '\n';
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

                                   sheet = ExportXLS(xlsx, 7);

                                   var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text()  }]);
                                   var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                   var r2 = Addrow(3, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                   var r3 = Addrow(4, [{ key: 'A', value: 'Distributor GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                   var r4 = Addrow(5, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                   var r5 = Addrow(6, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlInvoiceType option:Selected').text()) }]);
                                   var r6 = Addrow(7, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlDocType option:Selected').text()) }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + sheet.childNodes[0].childNodes[1].innerHTML;
                               }
                           },
                          {
                              extend: 'pdfHtml5',
                              orientation: 'landscape', //portrait
                              pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                              title: $("#lnkTitle").text() ,
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
                                  doc.pageMargins = [20, 100, 20, 30];
                                  doc.defaultStyle.fontSize = 5;
                                  doc.styles.tableHeader.fontSize = 5;
                                  doc.styles.tableFooter.fontSize = 5;
                                  doc['header'] = (function () {
                                      return {
                                          columns: [
                                              {
                                                  alignment: 'left',
                                                  italics: true,
                                                  text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                         { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Distributor GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                         { text: 'Dealer : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Group By : ' + ($('.ddlInvoiceType option:Selected').text()) + '\n' },
                                                         { text: 'Invoice Type :' + ($('.ddlDocType option:Selected').text()) }],
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
                                      doc.content[0].table.body[i][5].alignment = 'right';
                                      doc.content[0].table.body[i][12].alignment = 'right';
                                      doc.content[0].table.body[i][13].alignment = 'right';
                                      doc.content[0].table.body[i][14].alignment = 'right';
                                      doc.content[0].table.body[i][15].alignment = 'right';
                                      doc.content[0].table.body[i][16].alignment = 'right';
                                      doc.content[0].table.body[i][17].alignment = 'right';
                                      doc.content[0].table.body[i][18].alignment = 'right';
                                      doc.content[0].table.body[i][19].alignment = 'right';
                                      doc.content[0].table.body[i][20].alignment = 'right';
                                      doc.content[0].table.body[i][21].alignment = 'right';
                                      doc.content[0].table.body[i][22].alignment = 'right';
                                      doc.content[0].table.body[i][23].alignment = 'right';
                                      doc.content[0].table.body[i][24].alignment = 'right';
                                      doc.content[0].table.body[i][25].alignment = 'right';
                                      doc.content[0].table.body[i][26].alignment = 'right';
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


                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col14 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col17 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col19 = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col20 = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col24 = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col25 = api.column(25, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col26 = api.column(26, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);


                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                            $(api.column(24).footer()).html(col24.toFixed(2));
                            $(api.column(25).footer()).html(col25.toFixed(2));
                            $(api.column(26).footer()).html(col26.toFixed(2));
                        }
                    });
                }
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
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">
    <div class="panel">
        <div class="panel-body ">

            <div class="row _masterForm">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupBy" runat="server" Text="Invoice Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDocType" CssClass="ddlDocType form-control">
                            <asp:ListItem Text="UIN" Value="N" />
                            <asp:ListItem Text="Composite" Value="C" />
                            <asp:ListItem Text="Unregisterd" Value="U" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblInvoiceType" runat="server" Text="Group By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlInvoiceType" runat="server" CssClass="ddlInvoiceType form-control">
                            <asp:ListItem Text="Division Wise" Value="1" />
                            <asp:ListItem Text="Invoice Wise" Value="2" Selected="True" />
                            <asp:ListItem Text="HSN Wise" Value="3" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" CssClass="txtDistCode form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="11" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerofDist" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblData" runat="server" Text="GST # City" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtData" runat="server" CssClass="txtData form-control" Width="180%" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="5" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <asp:GridView ID="gvSalesRegister" runat="server" CssClass="gvSalesRegister table" Style="font-size: 11px;" Width="100%"
                    OnPreRender="gvSalesRegister_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    EmptyDataText="No data found. ">
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
