<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DistDealerWise_YrMnthDespatch.aspx.cs" Inherits="Reports_DistDealerWise_YrMnthDespatch" %>

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
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script type="text/javascript">

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(key + "-0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            Reload();
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor();
            Reload();
        }

        function ChangeReportFor(ddl) {
            if (CustType == 1 && $('.ddlSaleBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if (CustType == 1 && $('.ddlSaleBy').val() == "2") {
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

            $(".FromOnlymonth").datepicker({
                dateFormat: 'mm/yy',
                showButtonPanel: true,
                changeYear: true,
                changeMonth: true,
                maxDate: '+0d',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            $(".ToOnlymonth").datepicker({
                dateFormat: 'mm/yy',
                showButtonPanel: true,
                changeYear: true,
                changeMonth: true,
                maxDate: '+0d',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                },
            });

            if ($('.gvgrid thead tr').length > 0) {
                var table = $('.gvgrid').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "10px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "80px", "sClass": "noExport", "aTargets": 1 });
                aryJSONColTable.push({ "width": "150px", "sClass": "noExport", "aTargets": 2 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "28px", "aTargets": 5 });

                for (var i = 6; i < colCount; i++) {

                    aryJSONColTable.push({
                        "aTargets": [i],
                        "sClass": "dtbodyRight",
                        "width": "55px"
                    });

                }

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                if ($('.ddlReportOption').val() == 1) {
                    $('.gvgrid').DataTable(
                            {
                                bFilter: true,
                                scrollCollapse: true,
                                "stripeClasses": ['odd-row', 'even-row'],
                                destroy: true,
                                scrollY: '50vh',
                                scrollX: true,
                                responsive: true,
                                "aaSorting": [],
                                dom: 'Bfrtip',
                                "bPaginate": false,
                                "aoColumnDefs": aryJSONColTable,
                                buttons: [{ extend: 'copy', footer: true },
                                    {
                                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                        customize: function (csv) {
                                            var data = 'Distributorwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + '\n';
                                            data += 'From Month,' + $('.FromOnlymonth').val() + ',To Month,' + $('.ToOnlymonth').val() + '\n';
                                            data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                                            data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") + '\n';
                                            data += 'Report Option,' + (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() : "") + '\n';
                                            if ($('.ddlSaleBy').val() == "4")
                                                data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                            if ($('.ddlSaleBy').val() == "2")
                                                data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                                            data += 'Division,' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + '\n';
                                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                            data += 'SaleBy,' + $('.ddlSaleBy option:Selected').text() + '\n';
                                            data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                            data += 'Created on,' + jsDate.toString() + '\n';
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
                                        extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                        customize: function (xlsx) {
                                            sheet = ExportXLS(xlsx, 12);
                                            var r0 = Addrow(1, [{ key: 'A', value: 'Distributorwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") }]);
                                            var r1 = Addrow(2, [{ key: 'A', value: 'From Month' }, { key: 'B', value: $('.FromOnlymonth').val() }, { key: 'C', value: 'To Month' }, { key: 'D', value: $('.ToOnlymonth').val() }]);
                                            var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") }]);
                                            var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") }]);
                                            if ($('.ddlSaleBy').val() == "4")
                                                var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                            if ($('.ddlSaleBy').val() == "2")
                                                var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") }]);
                                            var r5 = Addrow(6, [{ key: 'A', value: 'Division' }, { key: 'B', value: (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") }]);
                                            var r6 = Addrow(7, [{ key: 'A', value: 'Report Option' }, { key: 'B', value: (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() : "") }]);
                                            var r7 = Addrow(8, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                            var r8 = Addrow(9, [{ key: 'A', value: 'SaleBy' }, { key: 'B', value: $('.ddlSaleBy option:Selected').text() }]);
                                            var r9 = Addrow(10, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                            var r10 = Addrow(11, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10 + sheet.childNodes[0].childNodes[1].innerHTML;
                                        }
                                    },
                                    {
                                        extend: 'pdfHtml5',
                                        orientation: 'landscape',
                                        pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                        title: $("#lnkTitle").text(),
                                        exportOptions: {
                                            columns: "thead th:not(.noExport)",
                                            search: 'applied',
                                            order: 'applied'
                                        },
                                        customize: function (doc) {
                                            doc.content.splice(0, 1);
                                            doc.pageMargins = [20, 140, 20, 40];
                                            doc.defaultStyle.fontSize = 8;
                                            doc.styles.tableHeader.fontSize = 8;
                                            doc['header'] = (function () {
                                                return {
                                                    columns: [
                                                        {
                                                            alignment: 'left',
                                                            italics: true,
                                                            text: [{ text: 'Distributorwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + "\n" },
                                                                   { text: 'From Month : ' + $('.FromOnlymonth').val() + '\t To Month : ' + $('.ToOnlymonth').val() + "\n" },
                                                                   { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                                   { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "\n") },
                                                                   { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                                   { text: (($('.ddlSaleBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                                   { text: 'Report Option : ' + (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() + "\n" : "\n") },
                                                                   { text: 'Division : ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() + "\n" : "All Division" + "\n") },
                                                                   { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                                   { text: 'SaleBy : ' + $('.ddlSaleBy option:Selected').text() + "\n" },
                                                                   { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                            fontSize: 10,
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
                                            objLayout['paddingLeft'] = function (i) { return 6; };
                                            objLayout['paddingRight'] = function (i) { return 6; };
                                            doc.content[0].layout = objLayout;

                                            var rowCount = doc.content[0].table.body.length;

                                        }
                                    }]
                            }
                        );
                }
                if ($('.ddlReportOption').val() == 2) {
                    $('.gvgrid').DataTable(
                            {
                                bFilter: true,
                                scrollCollapse: true,
                                "stripeClasses": ['odd-row', 'even-row'],
                                destroy: true,
                                scrollY: '50vh',
                                scrollX: true,
                                responsive: true,
                                "aaSorting": [],
                                dom: 'Bfrtip',
                                "bPaginate": false,
                                "aoColumnDefs": aryJSONColTable,
                                buttons: [{ extend: 'copy', footer: true },
                                    {
                                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                        customize: function (csv) {
                                            var data = 'Dealerwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + '\n';
                                            data += 'From Month,' + $('.FromOnlymonth').val() + ',To Month,' + $('.ToOnlymonth').val() + '\n';
                                            data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                                            data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") + '\n';
                                            if ($('.ddlSaleBy').val() == "4")
                                                data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                            if ($('.ddlSaleBy').val() == "2")
                                                data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                                            data += 'Division,' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + '\n';
                                            data += 'Report Option,' + (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() : "") + '\n';
                                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                            data += 'SaleBy,' + $('.ddlSaleBy option:Selected').text() + '\n';
                                            data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                            data += 'Created on,' + jsDate.toString() + '\n';
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
                                        extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                        customize: function (xlsx) {
                                            sheet = ExportXLS(xlsx, 12);
                                            var r0 = Addrow(1, [{ key: 'A', value: 'Dealerwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") }]);
                                            var r1 = Addrow(2, [{ key: 'A', value: 'From Month' }, { key: 'B', value: $('.FromOnlymonth').val() }, { key: 'C', value: 'To Month' }, { key: 'D', value: $('.ToOnlymonth').val() }]);
                                            var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") }]);
                                            var r3 = Addrow(4, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) : "All Plant") }]);
                                            if ($('.ddlSaleBy').val() == "4")
                                                var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                            if ($('.ddlSaleBy').val() == "2")
                                                var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") }]);
                                            var r5 = Addrow(6, [{ key: 'A', value: 'Division' }, { key: 'B', value: (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") }]);
                                            var r6 = Addrow(7, [{ key: 'A', value: 'Report Option' }, { key: 'B', value: (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() : "") }]);
                                            var r7 = Addrow(8, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                            var r8 = Addrow(9, [{ key: 'A', value: 'SaleBy' }, { key: 'B', value: $('.ddlSaleBy option:Selected').text() }]);
                                            var r9 = Addrow(10, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                            var r10 = Addrow(11, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10 + sheet.childNodes[0].childNodes[1].innerHTML;
                                        }
                                    },
                                    {
                                        extend: 'pdfHtml5',
                                        orientation: 'landscape',
                                        pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                        title: $("#lnkTitle").text(),
                                        exportOptions: {
                                            columns: "thead th:not(.noExport)",
                                            search: 'applied',
                                            order: 'applied'
                                        },
                                        customize: function (doc) {
                                            doc.content.splice(0, 1);
                                            doc.pageMargins = [20, 140, 20, 40];
                                            doc.defaultStyle.fontSize = 8;
                                            doc.styles.tableHeader.fontSize = 8;
                                            doc['header'] = (function () {
                                                return {
                                                    columns: [
                                                        {
                                                            alignment: 'left',
                                                            italics: true,
                                                            text: [{ text: 'Dealerwise/YearMonthwise Despatch Report For ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division") + "\n" },
                                                                   { text: 'From Month : ' + $('.FromOnlymonth').val() + '\t To Month : ' + $('.ToOnlymonth').val() + "\n" },
                                                                   { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                                   { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-').slice(1, 3) + "\n" : "\n") },
                                                                   { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                                   { text: (($('.ddlSaleBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                                   { text: 'Report Option : ' + (($('.ddlReportOption').val() > 0 && $('.ddlReportOption').val() != "") ? $('.ddlReportOption option:Selected').text() + "\n" : "\n") },
                                                                   { text: 'Division : ' + (($('.ddlDivision').val() > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() + "\n" : "All Division" + "\n") },
                                                                   { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                                   { text: 'SaleBy : ' + $('.ddlSaleBy option:Selected').text() + "\n" },
                                                                   { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                            fontSize: 10,
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
                                            objLayout['paddingLeft'] = function (i) { return 6; };
                                            objLayout['paddingRight'] = function (i) { return 6; };
                                            doc.content[0].layout = objLayout;

                                            var rowCount = doc.content[0].table.body.length;
                                            //for (i = 1; i < rowCount; i++) {
                                            //    for (var j = 4; j < colCount; j++) {
                                            //        doc.content[0].table.body[i][j].alignment = 'right';
                                            //    }
                                            //};
                                        }
                                    }]
                            }
                        );
                }
            }
        }
    </script>
    <style>
        .ui-datepicker-calendar {
            display: none;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
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
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Year/Month From" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="7" TabIndex="1" CssClass="FromOnlymonth form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Year/Month To" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" MaxLength="7" TabIndex="2" CssClass="ToOnlymonth form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="3" CssClass="ddlSaleBy form-control" onchange="ChangeReportFor(this);">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="4" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPlant" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblReportOption" runat="server" Text="Report Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlReportOption" TabIndex="8" runat="server" CssClass="ddlReportOption form-control">
                            <asp:ListItem Text="Parent Wise" Value="1" Selected="True" />
                            <asp:ListItem Text="Customer Wise" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="6" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="11" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return _btnCheck();" />&nbsp;&nbsp;&nbsp;
                        <asp:Button ID="btnExport" runat="server" Text="Export To Excel" TabIndex="13" CssClass="btn btn-default" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <span style="color: red; font-weight: bold">Report Processed only 12 Month.</span>
                    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvgrid" runat="server" CssClass="gvgrid table" Width="100%" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvgrid_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

