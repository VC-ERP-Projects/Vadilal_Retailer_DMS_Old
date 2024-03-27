﻿<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimProcessCompany.aspx.cs" Inherits="Sales_ClaimProcessCompany" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

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
        var Version = '<% = Version%>';
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';
        var IpAddress;
        $(function () {
            ReLoadFn();
            ToDataURL(LogoURL, function (dataUrl) {
                // imagebase64 = dataUrl;
            })
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
                noop = function () { },
                localIPs = {},
                ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                key;

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            //create a bogus data channel
            pc.createDataChannel("");

            // create offer and set local description
            pc.createOffer(function (sdp) {
                sdp.sdp.split('\n').forEach(function (line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });

                pc.setLocalDescription(sdp, noop, noop);
            }, noop);

            //listen for candidate events
            pc.onicecandidate = function (ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function summary(txt) {

            var Row = $(txt).parent().parent();

            var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($(Row).find('.TotalCompanyCont').text());

            Row.find('[id*=lblApproved]').val((TotalCompanyCont - Deduction).toFixed(2));
        }
        function IOUsummary(txt) {

            var Row = $(txt).parent().parent();

            //var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            var Deduction = Number($(Row).find('.txtIOUDeduction').val());

            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($('.gvIOUClaim tr td .TotalCompanyCont').val());
            var Approve = TotalCompanyCont - Deduction;
            $('.dataTables_scrollFoot tfoot td:eq(11)').text(Approve.toFixed(2));
            $('.gvIOUClaim tbody tr').each(function () {
                $(this).find('.hdnIOUDeduction').val(Deduction.toFixed(2));
                $(this).find('.hdnAprAmt').val(Approve.toFixed(2));
            });
        }
        function IOURemarks(txt) {

            var Row = $(txt).parent().parent();

            var IOURemarks = $(Row).find('.txtIOURemarks').val();
            $('.gvIOUClaim tbody tr').each(function () {
                $(this).find('.hdnDeductionRemarks').val(IOURemarks);
            });
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

        function summaryChild(txt) {

            var Row = $(txt).parent().parent();

            var Deduction = Number($(Row).find('[id*=txtDeductionChild]').val());
            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($(Row).find('[id*=lblPrevApprovedAmt]').text());

            Row.find('[id*=lblApproved]').val((TotalCompanyCont - Deduction).toFixed(2));
        }

        function summaryRateClaim(txt) {

            var Row = $(txt).parent().parent();

            var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($(Row).find('.CompanyCont').text());

            Row.find('[id*=lblApproved]').val((TotalCompanyCont - Deduction).toFixed(2));
        }
        function summaryFOW(txt) {

            var Row = $(txt).parent().parent();

            var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($(Row).find('.SchemeAmount').text());

            Row.find('[id*=lblApproved]').val((TotalCompanyCont - Deduction).toFixed(2));
        }

        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });


            $(".txtDeduction").on('change keyup paste', function (event) {
                summary(this);
            });

            $(".txtDeductionRate").on('change keyup paste', function (event) {
                summaryRateClaim(this);
            });


            $(".txtIOUDeduction").on('change keyup paste', function (event) {
                IOUsummary(this);
            });

            $(".txtIOURemarks").on('change keyup paste', function (event) {
                IOURemarks(this);
            });

            $(".txtDeductionChild").on('change keyup paste', function (event) {
                summaryChild(this);
            });

            $(".txtDeductionFOW").on('change keyup paste', function (event) {
                summaryFOW(this);
            });

            $(".txtDeductionIOU").on('change keyup paste', function (event) {
                summaryFOW(this);
            });
            var SelectedMonthYear = $('.onlymonth').val();
            var AppliMode = $('.ddlMode').val();

            $('.ctrldeduction').removeAttr('onkeypress');

            if (SelectedMonthYear != '' && AppliMode == '13') {

                var SelectedMonth = SelectedMonthYear.split('/')[0];
                var SelectedYear = SelectedMonthYear.split('/')[1];

                if ($.isNumeric(SelectedMonth) && $.isNumeric(SelectedYear)) {

                    if (SelectedYear < parseInt('2018') || (SelectedYear = parseInt('2018') && SelectedMonth <= parseInt('10'))) {
                        $('.ctrldeduction').attr('onkeypress', 'return isNumberKeyWithMinus(event)');
                    }
                    else
                        $('.ctrldeduction').attr('onkeypress', 'return isNumberKeyForAmount(event)');
                }
                else
                    $('.ctrldeduction').attr('onkeypress', 'return isNumberKeyForAmount(event)');
            }
            else
                $('.ctrldeduction').attr('onkeypress', 'return isNumberKeyForAmount(event)');

            var SalesAmount = 0, SchemeAmount = 0, CompanyCont = 0, DistCont = 0, DistContTax = 0, TotalCompanyCont = 0, TotalQty = 0;
            if ($('.gvMasterScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "10px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyleft", "aTargets": 8 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 11 });
                aryJSONColTable.push({ "width": "35px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyleft", "aTargets": 13 });
                $('.gvMasterScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                   /* dom: 'Bfrtip',*/
                    "bSort": false,
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
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
                                            height: 600,
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 14,
                                            text: $("#lnkTitle").text(),
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
                                doc.content[0].table.body[i][4].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvMasterScheme tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(5).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(6).footer()).html(DistContTax.toFixed(2));
                        $(api.column(5).footer()).html(DistCont.toFixed(2));
                        $(api.column(6).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(Deduction.toFixed(2));
                        $(api.column(9).footer()).html(Approved.toFixed(2));
                        $(api.column(10).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvMasterScheme tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvQPSScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "7px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 4 });
                aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyleft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyleft", "aTargets": 6 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyleft", "aTargets": 11 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 13 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 14 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 15 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyleft", "aTargets": 16 });
                $('.gvQPSScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                      /* dom: 'Bfrtip',*/
                    "bSort": false,
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
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
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';
                                doc.content[0].table.body[i][14].alignment = 'right';

                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvQPSScheme tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(10)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(12)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {

                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        TotalQty = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        $(api.column(4).footer()).html(TotalQty);
                        $(api.column(7).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(8).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(9).footer()).html(DistContTax.toFixed(2));
                        $(api.column(8).footer()).html(DistCont.toFixed(2));
                        $(api.column(9).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(10).footer()).html(Deduction.toFixed(2));
                        $(api.column(12).footer()).html(Approved.toFixed(2));
                        $(api.column(13).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvQPSScheme tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(10)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(12)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvMachineScheme thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "8px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "6px", "sClass": "dtbodyCenter", "aTargets": 1 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 7 });//"sClass": "dtbodyLeft",
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 8 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "5px", "sClass": "dtbodyCenter", "aTargets": 11 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "13px", "sClass": "dtbodyleft", "aTargets": 13 });
                //aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 14 });
                //aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 15 });

                $('.gvMachineScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    /* dom: 'Bfrtip',*/
                    "bSort": false,
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
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
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvMachineScheme tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };
                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(5).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(6).footer()).html(DistContTax.toFixed(2));
                        $(api.column(5).footer()).html(DistCont.toFixed(2));
                        $(api.column(6).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(Deduction.toFixed(2));
                        // $(api.column(8).footer()).html(Approved.toFixed(2));
                        //$(api.column(9).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvMachineScheme tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvParlourScheme thead tr').length > 0) {
                $('.gvParlourScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                      /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "bSort": false,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + ' \n';
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
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
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvParlourScheme tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(5).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(6).footer()).html(DistContTax.toFixed(2));
                        $(api.column(5).footer()).html(DistCont.toFixed(2));
                        $(api.column(6).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(Deduction.toFixed(2));
                        $(api.column(9).footer()).html(Approved.toFixed(2));
                        $(api.column(10).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvParlourScheme tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvVRSDiscount thead tr').length > 0) {
                $('.gvVRSDiscount').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                      /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "bSort": false,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + ' \n';
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
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
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvVRSDiscount tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //CompanyCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistContTax = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        DistCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        //$(api.column(5).footer()).html(CompanyCont.toFixed(2));
                        //$(api.column(6).footer()).html(DistContTax.toFixed(2));
                        $(api.column(5).footer()).html(DistCont.toFixed(2));
                        $(api.column(6).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(Deduction.toFixed(2));
                        $(api.column(9).footer()).html(Approved.toFixed(2));
                        $(api.column(10).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvVRSDiscount tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvFOWScheme thead tr').length > 0) {
                $('.gvFOWScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + ' \n';
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8],
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
                                doc.content[0].table.body[i][2].alignment = 'right';
                                doc.content[0].table.body[i][3].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvFOWScheme tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeductionFOW').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(4)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(6)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(3, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(Deduction.toFixed(2));
                        $(api.column(6).footer()).html(Approved.toFixed(2));
                        $(api.column(3).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(7).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvFOWScheme tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeductionFOW').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(4)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(6)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvSecFreight thead tr').length > 0) {
                $('.gvSecFreight').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                   /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "order": [[0, "asc"]],
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
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvSecFreight tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeductionFOW').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(5)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Apporved = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(5).footer()).html(Deduction.toFixed(2));
                        $(api.column(7).footer()).html(Apporved.toFixed(2));
                        $(api.column(8).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvSecFreight tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeductionFOW').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(5)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvRateDiff thead tr').length > 0) {
                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "8px", "sClass": "dtbodyCenter", "aTargets": 1 });
                aryJSONColTable.push({ "width": "17px", "sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "100px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyleft", "aTargets": 8 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 11 });
                aryJSONColTable.push({ "width": "26px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 13 });
                $('.gvRateDiff').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                     /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "bSort": false,
                    "order": [[0, "asc"]],
                    "aoColumnDefs": aryJSONColTable,
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
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
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';

                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvRateDiff tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeductionRate').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {

                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        TotalQty = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Approved = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        $(api.column(4).footer()).html(TotalQty.toFixed(2));
                        $(api.column(5).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(6).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(7).footer()).html(Deduction.toFixed(2));
                        $(api.column(9).footer()).html(Approved.toFixed(2));
                        $(api.column(10).footer()).html(SalesAmount.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvRateDiff tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeductionRate').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(7)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvIOUClaim thead tr').length > 0) {
                $('.gvIOUClaim').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                     /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "order": [[0, "asc"]],
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
                            //columns:[0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
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
                            columns: [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
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
                            doc['content']['0'].table.widths = ['2%', '8%', '26%', '8%', '8%', '8%', '8%', '8%', '6%', '8%', '6%', '4%'];
                            doc.styles.tableHeader.fontSize = 8;
                            doc.styles.tableFooter.fontSize = 8;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'Claim Month : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'Display : ' + $('.ddlDisplay option:Selected').text() + '\n' },
                                            { text: 'Customer : ' + $('.txtCustCode').val() + "\n" },
                                            ],

                                            fontSize: 10,
                                            height: 600,
                                        },
                                        {
                                            alignment: 'right',
                                            width: 70,
                                            height: 50,
                                            image: imagebase64
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
                                            text: ['Created on: ', { text: new Date().format('dd-MMM-yy HH:mm') }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                        },
                                        {
                                            alignment: 'right',
                                            fontSize: 8,
                                            text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
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
                                doc.content[0].table.body[i][0].alignment = 'center';
                                doc.content[0].table.body[i][3].alignment = 'right';
                                doc.content[0].table.body[i][4].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                            };
                            doc.content[0].table.body[0][0].alignment = 'center';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'right';
                            doc.content[0].table.body[0][4].alignment = 'right';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'left';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'left';

                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        Approve = Number($('.gvIOUClaim tbody tr td').find('.hdnApprovedAmount').val());
                        Deduction = Number($('.gvIOUClaim tfoot tr td').find('[id*=txtIOUDeduction]').val());
                        var Remarks = Number($('.gvIOUClaim tfoot tr td').find('[id*=txtRemarks]').val());

                        $('.dataTables_scrollFoot tfoot td:eq(9)').val(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(10)').val(Remarks);
                        $('.dataTables_scrollFoot tfoot td:eq(11)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SalesAmount = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(5).footer()).html(CompanyCont.toFixed(2));
                        var hdnGrossPurchaseDist = intVal($(".hdnGrossPurchaseDist").val());
                        $(api.column(6).footer()).html(hdnGrossPurchaseDist.toFixed(2));

                        var PurClaimPerAmt = intVal($(".hdnlblMonthSale").val());
                        $(api.column(7).footer()).html(PurClaimPerAmt.toFixed(2));

                        var FinalClaimAmt = intVal($(".hdnFinalClaimAmt").val());
                        $(api.column(8).footer()).html(FinalClaimAmt.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    Approve = Number($('.gvIOUClaim tbody tr td').find('.hdnApprovedAmount').val());
                    Deduction = Number($('.gvIOUClaim tfoot tr td').find('[id*=txtIOUDeduction]').val());
                    var Remarks = Number($('.gvIOUClaim tfoot tr td').find('[id*=txtRemarks]').val());

                    $('.dataTables_scrollFoot tfoot td:eq(9)').val(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(10)').val(Remarks);
                    $('.dataTables_scrollFoot tfoot td:eq(11)').text(Approve.toFixed(2));
                });
            }
            else if ($('.gvCommon thead tr').length > 0) {
                $('.gvCommon').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                     /* dom: 'Bfrtip',*/
                    "bPaginate": false,
                    "order": [[0, "asc"]],
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
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0;
                        $('.gvCommon tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeductionFOW').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(3)').text(Deduction.toFixed(2));
                        $('.dataTables_scrollFoot tfoot td:eq(5)').text(Approve.toFixed(2));
                    },
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        SchemeAmount = api.column(2, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(3, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Apporved = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        SalesAmount = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(2).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(3).footer()).html(Deduction.toFixed(2));
                        $(api.column(5).footer()).html(Apporved.toFixed(2));
                        $(api.column(6).footer()).html(SalesAmount.toFixed(2));
                        $(api.column(7).footer()).html(Total.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0;
                    $('.gvCommon tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeductionFOW').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(3)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(5)').text(Approve.toFixed(2));
                });
            }
            $('.chkCheck').prop('checked', true);
            $('.chkhead').prop('checked', true);
            if ($('.gvIOUClaim').is(':visible')) {
                IOUClaimFooterCal();
            }
        }

        function btnGenerat_Click() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function btnSubmit_Click() {

            if ($(".chkCheck:checked").length == 0) {
                ModelMsg("Please select at least One Record", 3);
                return false;
            }
            return confirm('Are you sure want to Submit?');
        }
        function btnRejectSubmit_Click() {

            if ($(".chkCheck:checked").length == 0) {
                ModelMsg("Please select at least One Record", 3);
                return false;
            }
            return confirm('Are you sure want to Reject?');
        }
        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
            if ($('.gvIOUClaim').is(':visible')) {
                IOUClaimFooterCal();
            }
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var Reason = $('.ddlMode option:Selected').val();
            var ClaimMonth = $('.onlymonth').val();
            sender.set_contextKey(Reason + "-" + ClaimMonth + "-0");
          //  sender.set_contextKey("0-0-0");
        }

        function acetxtName_OnClientPopulating(sender, args) {
            var Reason = $('.ddlMode option:Selected').val();
            var ClaimMonth = $('.onlymonth').val();
            sender.set_contextKey(Reason + "-" + ClaimMonth + "-0-0");
        }
        function IOUClaimFooterCal() {

            var Row = $('.dataTables_scrollFoot .gvIOUClaim tfoot');

            //var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            var Deduction = Number($(Row).find('.txtIOUDeduction').val());

            if (isNaN(Deduction))
                Deduction = 0;
            var TotalCompanyCont = Number($('.gvIOUClaim tr td .TotalCompanyCont').val());
            var Approve = TotalCompanyCont - Deduction;
            $('.dataTables_scrollFoot tfoot td:eq(11)').text(Approve.toFixed(2));
            $('.gvIOUClaim tbody tr').each(function () {
                $(this).find('.hdnIOUDeduction').val(Deduction.toFixed(2));
                $(this).find('.hdnAprAmt').val(Approve.toFixed(2));
            });
            //var Deduction = 0, Approve = 0;
            //var Deduction = Number($('.dataTables_scrollFoot .gvIOUClaim tfoot tr td').find('.txtIOUDeduction').val());
            //var TotalCompanyCont = Number($('.dataTables_scrollFoot .gvIOUClaim tbody tr').find('.TotalCompanyCont').val());
            //Approve = TotalCompanyCont - Deduction;
            //var Remarks = Number($('.dataTables_scrollFoot .gvIOUClaim tfoot tr td').find('[id*=txtRemarks]').val());

            //$('.dataTables_scrollFoot .gvIOUClaim tfoot td:eq(9)').val(Deduction.toFixed(2));
            //$('.dataTables_scrollFoot .gvIOUClaim tfoot td:eq(10)').val(Remarks);
            //$('.dataTables_scrollFoot .gvIOUClaim tfoot td:eq(11)').text(Approve.toFixed(2));
        }
        //    $('.gvIOUClaim tbody tr').each(function () {
        //        $(this).find('.hdnIOUDeduction').val(Deduction.toFixed(2));
        //        $(this).find('.hdnAprAmt').val(Approve.toFixed(2));
        //        $('.dataTables_scrollFoot tfoot td:eq(11)').text(Approve.toFixed(2));
        //    });
        //}


        function OpenItemImage(ClaimId, ParentId) {

            $.colorbox({
                width: '40%',
                height: '40%',
                iframe: true,
                href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=0&IsDownload=0'
            });
        }
    </script>
    <style type="text/css">
        table.dataTable.nowrap th {
            white-space: unset !important;
        }

        .collapse {
            visibility: collapse;
        }

        body {
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        }

        .form-control, .input-group-addon {
            height: 25px !important;
            padding: 6px 6px !important;
            font-size: 11px !important;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif !important;
        }

        .txtDeduction {
            height: 25px !important;
            padding: 0px 3px 0px !important;
        }

        .ui-datepicker-calendar {
            display: none;
        }

        #body_txtDate .hidecalendar {
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
            border: 1px solid black;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        table td:last-child {
            border-right: none;
        }

        .gvCommon.nowrap.table.dataTable {
            margin: 0;
        }

        .gvIOUClaim input[type=text] {
            height: 26px;
            padding: 0px 5px;
            font-size: 11px;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
            border: 1px solid black;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 0px 4px !important;
            border: 1px solid black;
        }

        table.dataTable tfoot th {
            padding: 0px 18px 6px 18px !important;
            border-top: 1px solid #111;
            border: 1px solid black;
        }

        table.dataTable tfoot td {
            padding: 0px 4px !important;
            border-top: 1px solid #111;
            border: 1px solid black;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        #body_gvMasterScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            /*margin-left:-10px !important;*/
            border: 1px solid black;
        }

        #body_gvQPSScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvParlourScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvMachineScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvVRSDiscount_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvFOWScheme_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvSecFreight_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvRateDiff_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        #body_gvIOUClaim_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
            border: 1px solid black;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }

        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1073px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            /*.dataTables_scrollHead {
                width: 100% !important;
            }
            .dataTables_scrollFoot {
                width: 100% !important;
            }

            .dataTables_scrollFootInner {
                width: 100% !important;
            }*/
            #body_gvMasterScheme_wrapper .dataTables_scrollHead {
                width: 1300px !important;
            }

            #body_gvMasterScheme_wrapper .dataTables_scrollHeadInner {
                width: 1300px !important;
            }

            #body_gvMasterScheme_wrapper .dataTables_scrollBody {
                width: 1300px !important;
            }

            #body_gvMasterScheme_wrapper .dataTables_scrollFoot {
                width: 1300px !important;
            }

            #body_gvMasterScheme_wrapper .dataTables_scrollFootInner {
                width: 1300px !important;
            }

            #body_gvParlourScheme_wrapper .dataTables_scrollHead {
                width: 1374px !important;
            }

            #body_gvParlourScheme_wrapper .dataTables_scrollBody {
                width: 1374px !important;
            }

            #body_gvParlourScheme_wrapper .dataTables_scrollFoot {
                width: 1374px !important;
            }

            #body_gvParlourScheme_wrapper .dataTables_scrollFootInner {
                width: 1374px !important;
            }

            #body_gvMachineScheme_wrapper .dataTables_scrollHead {
                width: 1330px !important;
            }

            #body_gvMachineScheme_wrapper .dataTables_scrollBody {
                width: 1330px !important;
            }

            #body_gvMachineScheme_wrapper .dataTables_scrollFoot {
                width: 1330px !important;
            }

            #body_gvMachineScheme_wrapper .dataTables_scrollFootInner {
                width: 1330px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollHead {
                width: 1280px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollBody {
                width: 1280px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollFoot {
                width: 1280px !important;
            }

            #body_gvQPSScheme_wrapper .dataTables_scrollFootInner {
                width: 1280px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollHead {
                width: 1000px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollBody {
                width: 1000px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollFoot {
                width: 1000px !important;
            }

            #body_gvFOWScheme_wrapper .dataTables_scrollFootInner {
                width: 1000px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollHead {
                width: 1065px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollBody {
                width: 1065px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollFoot {
                width: 1065px !important;
            }

            #body_gvSecFreight_wrapper .dataTables_scrollFootInner {
                width: 1065px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollHead {
                width: 1270px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollBody {
                width: 1270px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollFoot {
                width: 1270px !important;
            }

            #body_gvRateDiff_wrapper .dataTables_scrollFootInner {
                width: 1270px !important;
            }

            #body_gvIOUClaim_wrapper .dataTables_scrollHead {
                width: 1365px !important;
            }

            #body_gvIOUClaim_wrapper .dataTables_scrollBody {
                width: 1365px !important;
            }

            #body_gvIOUClaim_wrapper .dataTables_scrollFoot {
                width: 1365px !important;
            }

            #body_gvIOUClaim_wrapper .dataTables_scrollFootInner {
                width: 1365px !important;
            }
        }

        .dtbodyCenter {
            text-align: center !important;
            vertical-align: top !important;
        }

        .dtbodyRight {
            text-align: right !important;
            vertical-align: top !important;
        }

        .dtbodyleft {
            text-align: left !important;
            vertical-align: top !important;
        }

        .dataTables_wrapper .dataTables_scroll div.dataTables_scrollBody > table > tbody > tr > td {
            vertical-align: middle !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="Label3" runat="server" Text="Super Stockiest" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDist" TabIndex="4" runat="server" CssClass="txtSSDist form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName2" BehaviorID="bhacetxtName2" runat="server" ServicePath="~/service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSForClaimProcess" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDist">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" TabIndex="2" OnSelectedIndexChanged="ddlMode_SelectedIndexChanged" AutoPostBack="true">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" TabIndex="5" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/service.asmx" UseContextKey="true"
                            ServiceMethod="GetDistributrForClaim" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="acetxtName_OnClientPopulating" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Remarks" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNotes" runat="server" MaxLength="50" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblOERMId" runat="server" CssClass="input-group-addon"></asp:Label>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label ID="Label1" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="ddlDisplay form-control" TabIndex="3">
                            <asp:ListItem Text="Pending" Value="1" Selected="True" />
                            <%-- <asp:ListItem Text="Error" Value="2" />
                            <asp:ListItem Text="Success" Value="3" />--%>
                            <asp:ListItem Text="Reject" Value="5" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblManager" runat="server" Text="Manager" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtManager" TabIndex="5" runat="server" MaxLength="250" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetApprovalEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtManager">
                        </asp:AutoCompleteExtender>
                    </div>

                </div>
                <div class="col-lg-8">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <asp:Button ID="btnGenerat" runat="server" Text="Search" TabIndex="6" CssClass="btn btn-info" OnClick="btnGenerat_Click" OnClientClick="return btnGenerat_Click();" />
                        &nbsp
                        <asp:Button Text="Submit For Approval" ID="btnSumbit" TabIndex="7" CssClass="btn btn-success" runat="server" OnClick="btnSumbit_Click" OnClientClick="return btnSubmit_Click();" />
                        &nbsp
                        <asp:Button Text="Submit For Reject" ID="btnRejectClaim" TabIndex="8" CssClass="btn btn-primary" runat="server" Visible="false" OnClick="btnRejectClaim_Click" OnClientClick="return btnRejectSubmit_Click();" />
                        &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="9" CssClass="btn btn-danger" OnClick="btnClear_Click" />
                    </div>
                </div>
 				<div class="col-lg-4">
                     </div>
                <div class="col-lg-4">
                     </div> <div class="col-lg-4">
                     </div>
                 </div> <div class="col-lg-4">
                     </div>
                <div class="col-lg-8">
                    <asp:Label ID="lblaa" runat="server" Text="Last Proceed By :" Font-Bold="true" ForeColor="Blue"></asp:Label>
                    <asp:Label ID="lblLastProceedby" runat="server" ForeColor="Blue" Font-Bold="false"></asp:Label>
                </div>

            </div>
            <asp:GridView ID="gvMasterScheme" runat="server" CssClass="gvMasterScheme nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvMasterScheme_PreRender" OnRowCommand="gvMasterScheme_RowCommand"
                ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. "
                OnRowDataBound="gvMasterScheme_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle">
                        <ItemTemplate>
                            <asp:Label ID="lblGNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />

                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Distribution Contribution bared by Company" DataField="DistContTax" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Distributor Contribution" DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Middle" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks" HeaderStyle-VerticalAlign="Top">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control txtRemarks" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right" HeaderStyle-VerticalAlign="Top">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="Approved form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Middle" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Middle" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale (Gross - Disc)" FooterStyle-HorizontalAlign="Right" ItemStyle-VerticalAlign="Middle">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image" ItemStyle-VerticalAlign="Middle">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvQPSScheme" runat="server" CssClass="gvQPSScheme nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnRowCommand="gvQPSScheme_RowCommand" OnPreRender="gvQPSScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found."
                OnRowDataBound="gvQPSScheme_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Item Code" DataField="ItemCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Item Name" DataField="ItemName" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Qty" DataField="TotalQty" DataFormatString="{0:0}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distribution Contribution bared by Company" DataField="DistContTax" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Dist. Cont." DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Cont." DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Pur. Amt. of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvMachineScheme" runat="server" CssClass="gvMachineScheme nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvMachineScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvMachineScheme_RowCommand" OnRowDataBound="gvMachineScheme_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />

                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distribution Contribution bared by Company" DataField="DistContTax" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distributor Contribution" DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Pur. Amt. of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvParlourScheme" runat="server" CssClass="gvParlourScheme nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvParlourScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvParlourScheme_RowCommand"
                OnRowDataBound="gvParlourScheme_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distribution Contribution bared by Company" DataField="DistContTax" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distributor Contribution" DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvVRSDiscount" runat="server" CssClass="gvVRSDiscount nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvVRSDiscount_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvVRSDiscount_RowCommand"
                OnRowDataBound="gvVRSDiscount_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distribution Contribution bared by Company" DataField="DistContTax" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" Visible="false" />
                    <asp:BoundField HeaderText="Distributor Contribution" DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvFOWScheme" runat="server" CssClass="gvFOWScheme nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvFOWScheme_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvFOWScheme_RowCommand"
                OnRowDataBound="gvFOWScheme_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeductionFOW ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvSecFreight" runat="server" CssClass="gvSecFreight nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvSecFreight_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvSecFreight_RowCommand"
                OnRowDataBound="gvSecFreight_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeductionFOW ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvRateDiff" runat="server" CssClass="gvRateDiff nowrap table table-bordered" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvRateDiff_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvRateDiff_RowCommand"
                OnRowDataBound="gvRateDiff_RowDataBound">

                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Company Contribution" DataField="CompanyCont" ItemStyle-CssClass="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Distributor Contribution" DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeductionRate ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Pur. Amt. of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvIOUClaim" runat="server" CssClass="gvIOUClaim nowrap table" Visible="false" Width="100%" Style="font-size: 11px;" OnPreRender="gvIOUClaim_PreRender" ShowFooter="true" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvIOUClaim_RowCommand"
                OnRowDataBound="gvIOUClaim_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                            <input type="hidden" id="hdnGrossPurchaseDist" class="hdnGrossPurchaseDist" runat="server" value='<%# Eval("DistCont") %>' />
                            <input type="hidden" id="hdnlblMonthSale" class="hdnlblMonthSale" runat="server" value='<%# Eval("MonthSale") %>' />
                            <input type="hidden" id="hdnFinalClaimAmt" class="hdnFinalClaimAmt TotalCompanyCont" runat="server" value='<%#Eval("TotalCompanyCont") %>' />
                            <input type="hidden" id="hdnApprovedAmount" class="hdnApprovedAmount" runat="server" value='<%#Eval("ApprovedAmount") %>' />
                            <input type="hidden" id="hdnIOUDeduction" class="hdnIOUDeduction" runat="server" value="0" />
                            <input type="hidden" id="hdnAprAmt" class="hdnAprAmt" runat="server" value="0" />
                            <input type="hidden" id="hdnDeductionRemarks" class="hdnDeductionRemarks" runat="server" value="" />

                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <ItemStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code" DataField="DealerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dealer Name" DataField="DealerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Dist. Claim Amt." DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Per. Claim Amt." DataField="CompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Per. Purchase Amt." DataField="DistCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />--%>
                    <asp:TemplateField HeaderText="Per. Purchase Amt." FooterStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                        <ItemTemplate></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Purchase Amt. of Dist." FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <%--<asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>--%>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <%--<asp:BoundField HeaderText="Total Company Contribution" DataField="TotalCompanyCont" ItemStyle-CssClass="TotalCompanyCont" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />--%>
                    <asp:TemplateField HeaderText="Total Company Contribution" FooterStyle-HorizontalAlign="Right" ItemStyle-CssClass="TotalCompanyCont" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <FooterTemplate>
                            <asp:TextBox ID="txtIOUDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtIOUDeduction ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </FooterTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <FooterTemplate>
                            <asp:TextBox ID="txtIOURemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="txtIOURemarks form-control" MaxLength="40" Style="text-align: left;"></asp:TextBox>
                        </FooterTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <FooterTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="lblApproved form-control" Style="text-align: right;" Text=''></asp:TextBox>
                        </FooterTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap table" Width="100%" Style="font-size: 11px;" OnPreRender="gvCommon_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvCommon_RowCommand"
                OnRowDataBound="gvCommon_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Sr">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimID" runat="server" value='<%# Eval("ClaimID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnClaimRequestDate" runat="server" value='<%# Eval("CreatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimId" runat="server" Value='<%# Eval("ClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerId" runat="server" Value='<%# Eval("ParentID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="SchemeAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" Text='<%# Bind("Deduction", "{0:0.00}") %>' CssClass="txtDeductionFOW ctrldeduction form-control" MaxLength="10"
                                onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Bind("DeductionRemarks") %>' CssClass="form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="form-control" Style="text-align: right;" Text='<%# Bind("ApprovedAmount", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Purchase Amount of Dealer" DataField="TotalPurchase" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Total Purchase" DataField="Total" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <%--<asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />--%>
                    <asp:TemplateField HeaderText="Auto">
                        <ItemTemplate>
                            <asp:Label ID="lblIsAuto" Enabled="false" runat="server" Text='<%# Bind("IsAuto") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Month Sale" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Label ID="lblMonthSale" Enabled="false" runat="server" Text='<%# Bind("MonthSale", "{0:0.00}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

