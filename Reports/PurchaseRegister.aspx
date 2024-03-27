<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PurchaseRegister.aspx.cs" Inherits="Reports_PurchaseRegister" %>

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
        var ParentID = '<% =ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = 'QA';
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0" + "-0-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + EmpID);
        }

        $(function () {
            Reload();
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor();
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
            }
        }
        function ChangeReportFor(ddl) {

            if (CustType == 1 && $('.ddlPurchaseBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if (CustType == 1 && $('.ddlPurchaseBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
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


            if ($('.ddlGroupBy').val() == "1") {
                if ($('.gvSalesDivision thead tr').length > 0) {
                    var table = $(".gvSalesDivision").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "120px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "95px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    //aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 23 });
                    //aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 24 });

                    $('.gvSalesDivision').DataTable({
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
                                data += 'Group By,' + (($('.ddlGroupBy').val() > 0) ? $('.ddlGroupBy option:Selected').text() : 'All') + '\n';
                                data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';
                                data += 'Invoice Type,' + (($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : 'All') + '\n';
                                if ($('.ddlPurchaseBy').val() == "4")
                                    data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                                if ($('.ddlPurchaseBy').val() == "2")
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                                data += 'PurchaseBy,' + ((parseInt($('.ddlPurchaseBy').val()) > 0) ? $('.ddlPurchaseBy option:Selected').text() : 'All') + '\n';
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

                                sheet = ExportXLS(xlsx, 9);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                //var r2 = Addrow(3, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : "All" }]);
                                if ($('.ddlPurchaseBy').val() == "4")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") }]);
                                if ($('.ddlPurchaseBy').val() == "2")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                                var r7 = Addrow(8, [{ key: 'A', value: 'PurchaseBy' }, { key: 'B', value: ($('.ddlPurchaseBy').val() > 0) ? $('.ddlPurchaseBy option:Selected').text() : "All" }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r5 + r1  + r3 + r4  + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
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
                                doc.pageMargins = [20, 110, 20, 40];
                                doc.defaultStyle.fontSize = 5;
                                doc.styles.tableHeader.fontSize = 5;
                                doc.styles.tableFooter.fontSize = 5;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: true,
                                                text: [
                                                    { text: (($('.ddlPurchaseBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: (($('.ddlPurchaseBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    //{ text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                    { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' },
                                                    { text: 'Invoice Type : ' + (($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : 'All') + '\n' },
                                                    { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                    { text: 'PurchaseBy : ' + (($('.ddlPurchaseBy').val() > 0) ? $('.ddlPurchaseBy option:Selected').text() : 'All') + '\n' }],
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
                                    doc.content[0].table.body[i][3].alignment = 'right';
                                    doc.content[0].table.body[i][4].alignment = 'right';
                                    doc.content[0].table.body[i][10].alignment = 'right';
                                    doc.content[0].table.body[i][11].alignment = 'right';
                                    doc.content[0].table.body[i][12].alignment = 'right';
                                    doc.content[0].table.body[i][13].alignment = 'right';
                                    doc.content[0].table.body[i][15].alignment = 'right';
                                    doc.content[0].table.body[i][16].alignment = 'right';
                                    doc.content[0].table.body[i][17].alignment = 'right';
                                    doc.content[0].table.body[i][18].alignment = 'right';
                                    doc.content[0].table.body[i][19].alignment = 'right';
                                    //doc.content[0].table.body[i][20].alignment = 'right';
                                    //doc.content[0].table.body[i][21].alignment = 'right';
                                    //doc.content[0].table.body[i][22].alignment = 'right';
                                    //doc.content[0].table.body[i][23].alignment = 'right';
                                    //doc.content[0].table.body[i][24].alignment = 'right';
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


                            col10 = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col16 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col17 = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col19 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col20 = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            //col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col24 = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);


                            $(api.column(9).footer()).html(col10);
                            $(api.column(10).footer()).html(col11.toFixed(2));
                            $(api.column(11).footer()).html(col12.toFixed(2));
                            $(api.column(12).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col15.toFixed(2));
                            $(api.column(15).footer()).html(col16.toFixed(2));
                            $(api.column(16).footer()).html(col17.toFixed(2));
                            $(api.column(17).footer()).html(col18.toFixed(2));
                            $(api.column(18).footer()).html(col19.toFixed(2));
                            $(api.column(19).footer()).html(col20.toFixed(2));
                            //$(api.column(21).footer()).html(col21.toFixed(2));
                            //$(api.column(22).footer()).html(col22.toFixed(2));
                            //$(api.column(23).footer()).html(col23.toFixed(2));
                            //$(api.column(24).footer()).html(col24.toFixed(2));
                        }
                    });
                }
            }
            else if ($('.ddlGroupBy').val() == "2") {
                if ($('.gvSalesRegister thead tr').length > 0) {
                    var table = $(".gvSalesRegister").DataTable();
                    var colCount = table.columns()[0].length;

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "120px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "100px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 20 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 21 });
                    //aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 22 });
                    //aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyRight", "aTargets": 23 });

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
                                data += 'Customer,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                data += 'Group By,' + $('.ddlGroupBy option:Selected').text() + '\n';

                                //data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';
                                data += 'Invoice Type,' + $('.ddlInvoiceType option:Selected').text() + '\n';
                                if ($('.ddlPurchaseBy').val() == "4")
                                    data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlPurchaseBy').val() == "2")
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'PurchaseBy,' + $('.ddlPurchaseBy option:Selected').text() + '\n';
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

                                sheet = ExportXLS(xlsx, 9);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                               // var r2 = Addrow(3, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlInvoiceType').val() > 0) ? $('.ddlInvoiceType option:Selected').text() : "\n" }]);
                                if ($('.ddlPurchaseBy').val() == "4")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                if ($('.ddlPurchaseBy').val() == "2")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                var r7 = Addrow(8, [{ key: 'A', value: 'PurchaseBy' }, { key: 'B', value: $('.ddlPurchaseBy option:Selected').text() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r5 + r1  + r3 + r4 +  r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
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
                                doc.pageMargins = [20, 110, 20, 40];
                                doc.defaultStyle.fontSize = 5;
                                doc.styles.tableHeader.fontSize = 5;
                                doc.styles.tableFooter.fontSize = 5;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: true,
                                                text: [
                                                    { text: (($('.ddlPurchaseBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: (($('.ddlPurchaseBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    //    { text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                    { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' },
                                                    { text: 'Invoice Type : ' + ($('.ddlInvoiceType option:Selected').text()) + '\n' },

                                                    { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                    { text: 'PurchaseBy : ' + $('.ddlPurchaseBy option:Selected').text() + '\n' }],
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
                                    doc.content[0].table.body[i][3].alignment = 'right';
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
                                    //doc.content[0].table.body[i][19].alignment = 'right';
                                    //doc.content[0].table.body[i][20].alignment = 'right';
                                    //doc.content[0].table.body[i][21].alignment = 'right';
                                    //doc.content[0].table.body[i][22].alignment = 'right';
                                    //doc.content[0].table.body[i][23].alignment = 'right';
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


                            col8 = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col9 = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col10 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
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

                            col16 = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col17 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            //col20 = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);


                            $(api.column(8).footer()).html(col8);
                            $(api.column(9).footer()).html(col9.toFixed(2));
                            $(api.column(10).footer()).html(col10.toFixed(2));
                            $(api.column(11).footer()).html(col11.toFixed(2));
                            $(api.column(13).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col14.toFixed(2));
                            $(api.column(15).footer()).html(col15.toFixed(2));
                            $(api.column(16).footer()).html(col16.toFixed(2));
                            $(api.column(17).footer()).html(col17.toFixed(2));
                            $(api.column(18).footer()).html(col18.toFixed(2));
                            //$(api.column(20).footer()).html(col20.toFixed(2));
                            //$(api.column(21).footer()).html(col21.toFixed(2));
                            //$(api.column(22).footer()).html(col22.toFixed(2));
                            //$(api.column(23).footer()).html(col23.toFixed(2));
                        }
                    });
                }
            }
            else if ($('.ddlGroupBy').val() == "3") {
                if ($('.gvHSN thead tr').length > 0) {
                    var table = $(".gvHSN").DataTable();
                    var colCount = table.columns()[0].length;
                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "width": "30px", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "120px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "95px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "30px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 18 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 19 });


                    $('.gvHSN').DataTable({
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
                                data += 'Customer,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                data += 'Group By,' + $('.ddlGroupBy option:Selected').text() + '\n';

                                //data += 'Customer GSTNo # City,' + $('.txtData').val() + '\n';
                                data += 'Invoice Type,' + (($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : 'All') + '\n';
                                if ($('.ddlPurchaseBy').val() == "4")
                                    data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlPurchaseBy').val() == "2")
                                    data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                                data += 'PurchaseBy,' + $('.ddlPurchaseBy option:Selected').text() + '\n';
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

                                sheet = ExportXLS(xlsx, 9);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                //var r2 = Addrow(3, [{ key: 'A', value: 'Customer GSTNo # City' }, { key: 'B', value: $('.txtData').val() }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'Group By' }, { key: 'B', value: ($('.ddlGroupBy option:Selected').text()) }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Invoice Type' }, { key: 'B', value: ($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : "All" }]);
                                if ($('.ddlPurchaseBy').val() == "4")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                if ($('.ddlPurchaseBy').val() == "2")
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                                var r7 = Addrow(8, [{ key: 'A', value: 'PurchaseBy' }, { key: 'B', value: ($('.ddlPurchaseBy').val() > 0) ? $('.ddlPurchaseBy option:Selected').text() : "All" }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r5 + r1 + r3 + r4 +  r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
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
                                doc.pageMargins = [20, 110, 20, 40];
                                doc.defaultStyle.fontSize = 5;
                                doc.styles.tableHeader.fontSize = 5;
                                doc.styles.tableFooter.fontSize = 5;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: true,
                                                text: [
                                                    { text: (($('.ddlPurchaseBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: (($('.ddlPurchaseBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    //{ text: 'Customer GSTNo # City : ' + $('.txtData').val() + '\n' },
                                                    { text: 'Group By : ' + ($('.ddlGroupBy option:Selected').text()) + '\n' },
                                                    { text: 'Invoice Type : ' + (($('.ddlInvoiceType').val() != "3,4") ? $('.ddlInvoiceType option:Selected').text() : 'All') + '\n' },

                                                    { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                    { text: 'PurchaseBy : ' + $('.ddlPurchaseBy option:Selected').text() + "\n" }],
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
                                    doc.content[0].table.body[i][3].alignment = 'right';
                                    doc.content[0].table.body[i][4].alignment = 'right';
                                    doc.content[0].table.body[i][10].alignment = 'right';
                                    doc.content[0].table.body[i][11].alignment = 'right';
                                    doc.content[0].table.body[i][12].alignment = 'right';
                                    doc.content[0].table.body[i][13].alignment = 'right';
                                    doc.content[0].table.body[i][15].alignment = 'right';
                                    doc.content[0].table.body[i][16].alignment = 'right';
                                    doc.content[0].table.body[i][17].alignment = 'right';
                                    doc.content[0].table.body[i][18].alignment = 'right';
                                    //doc.content[0].table.body[i][19].alignment = 'right';
                                    //doc.content[0].table.body[i][20].alignment = 'right';
                                    //doc.content[0].table.body[i][21].alignment = 'right';
                                    //doc.content[0].table.body[i][22].alignment = 'right';
                                    //doc.content[0].table.body[i][23].alignment = 'right';
                                    //doc.content[0].table.body[i][24].alignment = 'right';
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


                            col10 = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col11 = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col12 = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col13 = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col15 = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col16 = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col17 = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col18 = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col19 = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            col20 = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                                return intVal(a) + intVal(b);
                            }, 0);

                            //col21 = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col22 = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col23 = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);

                            //col24 = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                            //    return intVal(a) + intVal(b);
                            //}, 0);


                            $(api.column(9).footer()).html(col10);
                            $(api.column(10).footer()).html(col11.toFixed(2));
                            $(api.column(11).footer()).html(col12.toFixed(2));
                            $(api.column(12).footer()).html(col13.toFixed(2));
                            $(api.column(14).footer()).html(col15.toFixed(2));
                            $(api.column(15).footer()).html(col16.toFixed(2));
                            $(api.column(16).footer()).html(col17.toFixed(2));
                            $(api.column(17).footer()).html(col18.toFixed(2));
                            $(api.column(18).footer()).html(col19.toFixed(2));
                            $(api.column(19).footer()).html(col20.toFixed(2));
                            //$(api.column(21).footer()).html(col21.toFixed(2));
                            //$(api.column(22).footer()).html(col22.toFixed(2));
                            //$(api.column(23).footer()).html(col23.toFixed(2));
                            //$(api.column(24).footer()).html(col24.toFixed(2));
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

        table.dataTable thead th, table.dataTable thead td, table.dataTable tfoot td {
            padding: 0px 5px !important;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            padding: 0px !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
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
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" CssClass="form-control txtCode" TabIndex="3" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblPurchaseBy" Text="Purchase By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlPurchaseBy" TabIndex="5" CssClass="ddlPurchaseBy form-control" onchange="ChangeReportFor(this);">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistStoreHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupBy" runat="server" Text="Group By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlGroupBy" TabIndex="8" runat="server" CssClass="ddlGroupBy form-control">
                            <asp:ListItem Text="Division Wise" Value="1" />
                            <asp:ListItem Text="Invoice Wise" Value="2" Selected="True" />
                            <asp:ListItem Text="HSN Wise" Value="3" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-3" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblInvoiceType" runat="server" Text="Inward Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlInvoiceType" TabIndex="9" runat="server" CssClass="ddlInvoiceType form-control">
                            <asp:ListItem Text="-- Select --" Value="3,4" />
                            <asp:ListItem Text="Receipt" Value="3" />
                            <asp:ListItem Text="Direct Receipt" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-6" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblData" runat="server" Text="GST # City" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtData" runat="server" CssClass="txtData form-control" Enabled="false"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="10" OnClientClick="return _btnCheck();" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <br />
            <div class="row">
                <asp:GridView ID="gvSalesRegister" runat="server" CssClass="gvSalesRegister table" Style="font-size: 11px;" Width="100%" AutoGenerateColumns="false"
                    OnPreRender="gvSalesRegister_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    Visible="false">
                    <Columns>
                        <asp:BoundField DataField="Sr" HeaderText="Sr." HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="InvNo" HeaderText="Inv. No" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="GSTInvNo" HeaderText="GST Inv. No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />

                        <asp:TemplateField HeaderText="Receipt Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("ReceiptDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblReceiveDate" runat="server" Text='<%# Eval("InvoiceDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:BoundField DataField="VendorName" HeaderText="Vendor Name" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTNo" HeaderText="Vendor GST No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTState" HeaderText="Vendor GST State" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UOM" HeaderText="UOM" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Quantity" HeaderText="Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="ValueofGoods" HeaderText="Gross Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Discount" HeaderText="Discount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <%-- <asp:TemplateField HeaderText="Discount" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:Label ID="lblDiscount" Text='<%# Eval("Discount","{0:0.00}") %>' runat="server"></asp:Label>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Right" />
                        </asp:TemplateField>--%>
                        <asp:BoundField DataField="TotalValue" HeaderText="Sub Total" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="PerTax" HeaderText="% Tax" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CST" HeaderText="CST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="AddVAT" HeaderText="AddVAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Surcharge" HeaderText="Surcharge" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="VAT" HeaderText="VAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CGST" HeaderText="CGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="IGST" HeaderText="IGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="SGST" HeaderText="SGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UGST" HeaderText="UGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalTax" HeaderText="Total GST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalAmount" HeaderText="Net Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <%--    <asp:TemplateField HeaderText="Net Amount" HeaderStyle-HorizontalAlign="Right">
                            <ItemTemplate>
                                <asp:Label ID="lblTotal" Text='<%# Eval("TotalAmount","{0:0.00}") %>' runat="server"></asp:Label>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Right" />
                        </asp:TemplateField>--%>
                    </Columns>
                </asp:GridView>
                <asp:GridView ID="gvSalesDivision" runat="server" CssClass="gvSalesDivision table" Style="font-size: 11px;" Width="100%" AutoGenerateColumns="false"
                    OnPreRender="gvSalesDivision_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    Visible="false">
                    <Columns>
                        <asp:BoundField DataField="Sr" HeaderText="Sr." HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="InvNo" HeaderText="Inv. No" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="GSTInvNo" HeaderText="GST Inv. No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />

                        <asp:TemplateField HeaderText="Receipt Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("ReceiptDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblReceiveDate" runat="server" Text='<%# Eval("InvoiceDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:BoundField DataField="VendorName" HeaderText="Vendor Name" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTNo" HeaderText="Vendor GST No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTState" HeaderText="Vendor GST State" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UOM" HeaderText="UOM" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Material" HeaderText="Material" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Quantity" HeaderText="Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="ValueofGoods" HeaderText="Gross Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Discount" HeaderText="Discount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="TotalValue" HeaderText="Sub Total" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Tax" HeaderText="% Tax" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CST" HeaderText="CST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="AddVAT" HeaderText="AddVAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Surcharge" HeaderText="Surcharge" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="VAT" HeaderText="VAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CGST" HeaderText="CGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="IGST" HeaderText="IGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="SGST" HeaderText="SGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UGST" HeaderText="UGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalTax" HeaderText="Total GST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalAmount" HeaderText="Net Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />

                    </Columns>
                </asp:GridView>
                <asp:GridView ID="gvHSN" runat="server" CssClass="gvHSN table" Style="font-size: 11px;" Width="100%" AutoGenerateColumns="false"
                    OnPreRender="gvHSN_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                    Visible="false">
                    <Columns>
                        <asp:BoundField DataField="Sr" HeaderText="Sr." HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="InvNo" HeaderText="Inv. No" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="GSTInvNo" HeaderText="GST Inv. No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />

                        <asp:TemplateField HeaderText="Receipt Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("ReceiptDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <asp:Label ID="lblReceiveDate" runat="server" Text='<%# Eval("InvoiceDate","{0:dd-MMM-yyyy}") %>'></asp:Label>
                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:BoundField DataField="VendorName" HeaderText="Vendor Name" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTNo" HeaderText="Vendor GST No" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="VendorGSTState" HeaderText="Vendor GST State" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="HSNCode" HeaderText="HSN Code" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UOM" HeaderText="UOM" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Quantity" HeaderText="Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="ValueofGoods" HeaderText="Gross Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Discount" HeaderText="Discount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="TotalValue" HeaderText="Sub Total" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Tax" HeaderText="% Tax" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CST" HeaderText="CST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="AddVAT" HeaderText="AddVAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="Surcharge" HeaderText="Surcharge" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />

                        <asp:BoundField DataField="VAT" HeaderText="VAT" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="CGST" HeaderText="CGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="IGST" HeaderText="IGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="SGST" HeaderText="SGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="UGST" HeaderText="UGST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalTax" HeaderText="Total GST" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                        <asp:BoundField DataField="TotalAmount" HeaderText="Net Amount" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
