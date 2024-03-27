<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="ReturnAgainstPurchase.aspx.cs" Inherits="Reports_PurchaseReturnRegisterRpt" %>

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
        var Version = 'QA';
        $(function () {
            //if (CustType == 1) {
            Reload();


            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

        });

        function EndRequestHandler2(sender, args) {
            //if (CustType == 1) {
            Reload();

        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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


        function Reload() {

            if ($('.gvSalesRegister thead tr').length > 0) {
                if ($('.ddlGroupBy').val() == "1") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 24 });

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
                                  data += 'Group By,' + $('.ddlGroupBy option:Selected').text() + '\n';
                                  data += 'Customer,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';

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

                                  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                  var r4 = Addrow(5, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                  doc.pageMargins = [20, 80, 20, 30];
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
                                                         { text: 'Customer : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                         { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' }],
                                                  fontSize: 10,
                                                  height: 500,
                                              },
                                              {
                                                  alignment: 'right',
                                                  fontSize: 14,
                                                  text: $("#lnkTitle").text() ,
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
                                                  text: ['Version : ', { text: Version }]
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
                                      doc.content[0].table.body[i][4].alignment = 'right';
                                      doc.content[0].table.body[i][10].alignment = 'right';
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

                            col10 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
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

                            $(api.column(10).footer()).html(col10.toFixed(2));
                            $(api.column(11).footer()).html(col11.toFixed(2));
                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(16).footer()).html(col16.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                            $(api.column(24).footer()).html(col24.toFixed(2));
                        }
                    });
                }
                else if ($('.ddlGroupBy').val() == "2") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 23 });

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
                                 var data = $("#lnkTitle").text() +'\n';
                                 data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                 data += 'Group By,' + $('.ddlGroupBy option:Selected').text() + '\n';
                                 data += 'Customer,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                 data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';

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

                                 var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                 var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                 var r2 = Addrow(3, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                 var r3 = Addrow(4, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                 var r4 = Addrow(5, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);

                                 sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                 doc.pageMargins = [20, 80, 20, 30];
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
                                                        { text: 'Customer : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                        { text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                        { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' }],
                                                 fontSize: 10,
                                                 height: 500,
                                             },
                                             {
                                                 alignment: 'right',
                                                 fontSize: 14,
                                                 text: $("#lnkTitle").text() ,
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
                                                 text: ['Version : ', { text: Version }]
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
                                     doc.content[0].table.body[i][4].alignment = 'right';
                                     doc.content[0].table.body[i][9].alignment = 'right';
                                     doc.content[0].table.body[i][10].alignment = 'right';
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


                            col9 = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col10 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col14 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);
                            col15 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
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


                            $(api.column(9).footer()).html(col9.toFixed(2));
                            $(api.column(10).footer()).html(col10.toFixed(2));
                            $(api.column(11).footer()).html(col11.toFixed(2));
                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(16).footer()).html(col16.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                        }
                    });
                }
                if ($('.ddlGroupBy').val() == "3") {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "200px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "60px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 23 });
                    aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 24 });

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
                                  var data = 'Purchase Return Register Report \n';
                                  data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                  data += 'Group By,' + $('.ddlGroupBy option:Selected').text() + '\n';
                                  data += 'Customer,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';

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

                                  var r0 = Addrow(1, [{ key: 'A', value: 'Purchase Return Register Report' }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                  var r4 = Addrow(5, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                  doc.pageMargins = [20, 80, 20, 30];
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
                                                         { text: 'Customer : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n' },
                                                         { text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                         { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' }],
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
                                                  text: ['Version : ', { text: Version }]
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
                                      doc.content[0].table.body[i][4].alignment = 'right';
                                      doc.content[0].table.body[i][10].alignment = 'right';
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

                            col10 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
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

                            $(api.column(10).footer()).html(col10.toFixed(2));
                            $(api.column(11).footer()).html(col11.toFixed(2));
                            $(api.column(12).footer()).html(col12.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(16).footer()).html(col16.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            $(api.column(19).footer()).html(col19.toFixed(2));
                            $(api.column(20).footer()).html(col20.toFixed(2));
                            $(api.column(21).footer()).html(col21.toFixed(2));
                            $(api.column(22).footer()).html(col22.toFixed(2));
                            $(api.column(23).footer()).html(col23.toFixed(2));
                            $(api.column(24).footer()).html(col24.toFixed(2));
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
        <div class="panel-body">

            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" CssClass="txtDistCode form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblData" runat="server" Text="GST # City" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtData" runat="server" CssClass="txtData form-control" Width="180%" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupBy" runat="server" Text="Group By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlGroupBy" runat="server" CssClass="ddlGroupBy form-control">
                            <asp:ListItem Text="Division Wise" Value="1" />
                            <asp:ListItem Text="Invoice Wise" Value="2" Selected="True" />
                            <asp:ListItem Text="HSN Wise" Value="3" />
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="input-group form-group">
                <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="5" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
            </div>
            <br />
            <div class="row">
                <asp:GridView ID="gvSalesRegister" runat="server" CssClass="gvSalesRegister table" Style="font-size: 11px;" Width="100%"
                    OnPreRender="gvSalesRegister_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    EmptyDataText="No data found. ">
                </asp:GridView>
            </div>
        </div>
    </div>

</asp:Content>


