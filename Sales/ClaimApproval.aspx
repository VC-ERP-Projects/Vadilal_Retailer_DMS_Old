<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimApproval.aspx.cs" Inherits="Sales_ClaimApproval" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript">
        var Version = '<% = Version%>';
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';
        var IpAddress;
        $(function () {
            ReLoadFn();
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
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
            try {
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                    noop = function () { },
                    localIPs = {},
                    ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                    key;
            }
            catch (err) {

            }
            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            try {
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
            catch (err) {

            }
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

            if ($('.gvCommon thead tr').length > 0) {
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 1 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 2 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 3 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 4 });

                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyleft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "120px", "sClass": "dtbodyleft", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyleft", "aTargets": 7 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 11 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 13 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 14 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 15 });

                aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 16 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 17 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyleft", "aTargets": 18 });

                $('.gvCommon').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '60vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": false,
                    deferRender: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
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
                            sheet = ExportXLS(xlsx, 6);
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
                            columns: [0, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
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
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'Claim Month : ' + $('.onlymonth').val() + "\n" },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'Display : ' + $('.ddlDisplay option:Selected').text() + '\n' },
                                            { text: 'Customer : ' + $('.txtCustCode').val() + "\n" },
                                            ],

                                            fontSize: 10,
                                            height: 500,
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
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                            };
                        }
                    }],
                    "drawCallback": function (settings) {
                        var Deduction = 0, Approve = 0, PreApproveAmt = 0;
                        $('.gvCommon tbody tr').each(function () {
                            Deduction += Number($(this).find('.txtDeduction').val());
                            Approve += Number($(this).find('[id*=lblApproved]').val());
                            PreApproveAmt += Number($(this).find('[id*=lblPrevApprovedAmt]').text()) != "" ? parseFloat(Number($(this).find('[id*=lblPrevApprovedAmt]').text())) : 0;
                        });
                        $('.dataTables_scrollFoot tfoot td:eq(9)').text(PreApproveAmt.toFixed(2));
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

                        SchemeAmount = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Deduction = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal($(b).val());
                        }, 0);

                        Apporved = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        ScmTotal = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        Total = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(8).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(10).footer()).html(Deduction.toFixed(2));
                        $(api.column(12).footer()).html(Apporved.toFixed(2));
                        $(api.column(13).footer()).html(ScmTotal.toFixed(2));
                        $(api.column(14).footer()).html(Total.toFixed(2));
                    }
                }).on('change', function () {
                    var Deduction = 0, Approve = 0, PreApproveAmt = 0;
                    $('.gvCommon tbody tr').each(function () {
                        Deduction += Number($(this).find('.txtDeduction').val());
                        Approve += Number($(this).find('[id*=lblApproved]').val());
                        PreApproveAmt += Number($(this).find('[id*=lblPrevApprovedAmt]').text()) != "" ? parseFloat(Number($(this).find('[id*=lblPrevApprovedAmt]').text())) : 0;
                    });
                    $('.dataTables_scrollFoot tfoot td:eq(9)').text(PreApproveAmt.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(10)').text(Deduction.toFixed(2));
                    $('.dataTables_scrollFoot tfoot td:eq(12)').text(Approve.toFixed(2));
                });
            }


            var SelectedMonthYear = $('.onlymonth').val();
            var AppliMode = $('.ddlMode').val();

            $('.txtDeduction').removeAttr('onkeypress');

            if (SelectedMonthYear != '' && AppliMode == 'C06') {

                var SelectedMonth = SelectedMonthYear.split('/')[0];
                var SelectedYear = SelectedMonthYear.split('/')[1];

                if ($.isNumeric(SelectedMonth) && $.isNumeric(SelectedYear)) {

                    if (SelectedYear < parseInt('2018') || (SelectedYear = parseInt('2018') && SelectedMonth <= parseInt('10'))) {
                        $('.txtDeduction').attr('onkeypress', 'return isNumberKeyWithMinus(event)');
                    }
                    else
                        $('.txtDeduction').attr('onkeypress', 'return isNumberKeyForAmount(event)');
                }
                else
                    $('.txtDeduction').attr('onkeypress', 'return isNumberKeyForAmount(event)');
            }
            else
                $('.txtDeduction').attr('onkeypress', 'return isNumberKeyWithMinus(event)');
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
                MinusClaimAmtChecking();
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function ClickDocHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkDoc').find('input:enabled').prop('checked', true); //:not([disabled])
            }
            else {
                $('.chkDoc').find('input:enabled').prop('checked', false); //:not([disabled])
            }
        }
        function MinusClaimAmtChecking() {
            var flag = true;
            $('.ClaimAmount').each(function () {
                if (Number($(this).parent().find('.txtDeduction').parent().parent().find('.lblApproved').val()) > Number($(this).parent().find('.ClaimAmount').text())) {
                    if (Number($(this).parent().find('.txtDeduction').val()) > Number($(this).parent().find('.ClaimAmount').text()) && (Number($(this).parent().find('.txtDeduction').val()) != Number($(this).parent().find('.txtDeduction').parent().parent().find('.lblPrevApprovedAmt').text()))) {
                        ModelMsg("Approved amount must be less than claim amount.", 3);
                        flag = false;
                        return flag;
                    }
                }
                if (($(this).parent().find('.chkCheck').is(':checked') == true) && ($(this).parent().find('.ClaimAmount').text() < 0 || $(this).parent().find('.txtDeduction').parent().parent().find('.lblApproved').val() < 0)) {

                    if ($(this).parent().find('.txtDeduction').parent().parent().find('.lblApproved').val() == 0 && $(this).parent().find('.txtRemarks').val() == 'Minus Amount as Zero') {
                        return flag;
                    }

                    if ($(this).parent().find('.ClaimAmount').text() > 0 && $(this).parent().find('.txtDeduction').parent().parent().find('.lblPrevApprovedAmt').text() < 0) {
                        $(this).parent().find('.txtDeduction').val($(this).parent().find('.txtDeduction').parent().parent().find('.lblPrevApprovedAmt').text());
                    }
                    else {
                        if ($(this).parent().find('.txtDeduction').parent().parent().find('.lblPrevApprovedAmt').text() < 0) {
                            $(this).parent().find('.txtDeduction').val($(this).text());
                        }
                        else {
                            $(this).parent().find('.txtDeduction').val(0);
                        }
                    }
                    $(this).parent().find('.txtDeduction').change();
                    $(this).parent().find('.txtRemarks').val('Minus Amount as Zero');
                    ModelMsg("Claim Amount is Minus so, it will approve with Zero Amount", 3);
                    summary($(this).parent().find('.txtDeduction'));
                    flag = false;
                    return flag;
                }
            });
            return flag;
        }
        function ReloadDocRadio(chck) {
            if ($('.chkDoc').find('input').length == $('.chkDoc').find('input:checked').length)
                $('.chkDochead').prop('checked', true);
            else
                $('.chkDochead').prop('checked', false);
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
            MinusClaimAmtChecking();
        }

        function summary(txt) {

            var Row = $(txt).parent().parent();

            var Deduction = Number($(Row).find('[id*=txtDeduction]').val());
            if (isNaN(Deduction))
                Deduction = 0;
            var PrevApprovedAmt = Number($(Row).find('.lblPrevApprovedAmt').text());

            Row.find('[id*=lblApproved]').val((PrevApprovedAmt - Deduction).toFixed(2));
        }

        function ClaimPopup(lnk) {

            var customerid = Number($(lnk).attr('customerid'));
            var parentclaimid = Number($(lnk).attr('parentclaimid'));

            $.colorbox({
                width: '95%',
                height: '90%',
                iframe: true,
                href: '../Sales/ClaimPopUp.aspx?customerid=' + customerid + '&parentclaimid=' + parentclaimid,
            });
        }

        function CheckValid(bool) {
            //if ($(".chkCheck:checked").length == 0) {
            //    ModelMsg("Please select at least One Record", 3);
            //    return false;
            //}
            //if (MinusClaimAmtChecking() == true) {
            //    if (bool)
            //        return confirm('Are you sure?');
            //    else
            //        return confirm('Are you sure you want to Submit?');
            //}
            //else {
            //    return false;
            //}
        }

        function CheckDocValid() {
            if (!$('.chkDoc').find('input').is(':checked')) {
                ModelMsg("Please select at least One Record", 3);
                return false;
            }
            return confirm('Are you sure want to Submit?');
        }
        function OpenItemImage(ClaimId, ParentId) {
            $.colorbox({
                width: '40%',
                height: '40%',
                iframe: true,
                href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=0'
            });
        }
        function acetxtName_OnClientPopulating(sender, args) {
            var ss = $('.txtSSDist').val().split('-').pop();
            var Reason = $('.ddlMode option:Selected').val();
            var Status = $('.ddlDisplay option:Selected').val();
            var ClaimMonth = $('.onlymonth').val();
            sender.set_contextKey(Reason + "-" + ClaimMonth + "-0-" + Status);
        }
    </script>
    <style type="text/css">
        .form-control, .input-group-addon {
            height: 25px !important;
            padding: 6px 6px !important;
            font-size: 10px !important;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif !important;
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

        table.dataTable.nowrap th {
            white-space: unset !important;
        }

        body {
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        }

        .txtDeduction {
            height: 25px !important;
            padding: 0px 3px 0px !important;
        }

        table.dataTable thead .sorting_asc, table.dataTable thead .sorting {
            background-image: none !important;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 8px 4px !important;
        }
        /*table.dataTable tbody th, table.dataTable tbody td {
            padding: 0px 4px !important;
        }*/

        /*table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 0px 18px 6px 18px !important;
            border-top: 1px solid #111;
        }*/
        table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 0px 5px 0px 27px !important;
            border-top: 1px solid #111;
        }

        #body_gvCommon_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        .ui-datepicker-calendar {
            display: none;
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

        .dataTables_scroll {
            overflow: auto;
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
            #body_gvCommon_wrapper .dataTables_scrollHead {
                width: 1835px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollBody {
                width: 1835px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollFoot {
                width: 1835px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollFootInner {
                width: 1835px !important;
            }
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
                        <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="1" CssClass="onlymonth form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDisplay" CssClass="ddlDisplay form-control" TabIndex="4">
                            <asp:ListItem Text="Pending" Value="1" Selected="True" />
                            <asp:ListItem Text="Error" Value="2" />
                            <asp:ListItem Text="Success" Value="3" />
                            <asp:ListItem Text="Rejected" Enabled="false" Value="5" />
                        </asp:DropDownList>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" TabIndex="2">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divManger" runat="server">
                        <asp:Label ID="lblManager" runat="server" Text="Manager" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtManager" TabIndex="5" runat="server" MaxLength="200" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetApprovalEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtManager">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divCustomer" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" TabIndex="3" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/service.asmx" UseContextKey="true"
                            ServiceMethod="GetDistributrSSForClaimApproval" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="acetxtName_OnClientPopulating" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                        <%--   <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx" UseContextKey="true"
                            ServiceMethod="GetCustomerByTypePlantState" ContextKey="0-0-0-2,4" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>--%>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Search" TabIndex="6" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                    &nbsp
                        <asp:Button Text="Submit For Approval" ID="btnSumbit" TabIndex="7" CssClass="btn btn-success" runat="server" OnClick="btnSumbit_Click" OnClientClick="return CheckValid();" />
                    &nbsp
                        <asp:Button Text="Document Received" ID="btnDocRecv" TabIndex="8" CssClass="btn btn-success" runat="server" OnClick="btnDocRecv_Click" OnClientClick="return CheckDocValid();" />
                    &nbsp                    
                        <asp:Button Text="Sent To Account (SAP / DMS)" Style="float: right;" ID="btnSAPSync" TabIndex="6" CssClass="btn btn-danger" runat="server" OnClick="btnSAPSync_Click" OnClientClick="return CheckValid(true);" />
                </div>
            </div>
            <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap table" Style="font-size: 11px;" OnPreRender="gvCommon_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvCommon_RowCommand"
                OnRowDataBound="gvCommon_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="No.">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Check">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" /><br />
                            <label id="lblChkDocRecv">Submit</label>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            <input type="hidden" id="hdnClaimRequestID" runat="server" value='<%# Eval("ClaimRequestID") %>' />
                            <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                            <input type="hidden" id="hdnCreateDate" runat="server" value='<%# Eval("UpdatedDate") %>' />
                            <asp:HiddenField ID="hdnParentClaimID" runat="server" Value='<%# Eval("ParentClaimID") %>' />
                            <asp:HiddenField ID="hdnCustomerID" runat="server" Value='<%# Eval("CustomerID") %>' />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Docu.">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkDochead" class="chkDochead" id="chkDochead" runat="server" onchange="ClickDocHead(this);" /><br />
                            <label id="lblChkDocRecv">Docu</label>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox CssClass="chkDoc" ID="chkDoc" runat="server" Enabled='<%# Eval("DocDate").ToString() == "" ? true : false %>'
                                Checked='<%# Eval("DocDate").ToString() == "" ? false : true %>' onchange="ReloadDocRadio(this);" />
                            <%--<input type="checkbox" name="chkDoc" class="chkDoc" id="chkdoc" runat="server" onchange="ReloadDocRadio();" />--%>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                    </asp:TemplateField>

                    <asp:BoundField HeaderText="Doc Receive Date" DataField="DocDate" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Doc No" DataField="DocNo" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Dist Code" DataField="CustomerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Dist Name" DataField="CustomerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Claim Type" DataField="ReasonName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                    <asp:BoundField HeaderText="Claim Amount" DataField="SchemeAmount" ItemStyle-CssClass="ClaimAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Prev Approved Amt" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:LinkButton ID="lblPrevApprovedAmt" runat="server" customerid='<%# Eval("CustomerID") %>' parentclaimid='<%# Eval("ParentClaimID") %>' OnClientClick="ClaimPopup(this); return false;" CssClass="lblPrevApprovedAmt" Style="text-align: right;" Text='<%# Bind("PrevApprovedAmt", "{0:0.00}") %>'></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDeduction" runat="server" CssClass="txtDeduction form-control" MaxLength="10" onpaste="return false;" Style="text-align: right;"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Deduction Remarks">
                        <ItemTemplate>
                            <asp:TextBox ID="txtRemarks" runat="server" Text='<%# Eval("DeductionRemarks") %>' CssClass="txtRemarks form-control" MaxLength="40"></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Approved Amount" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:TextBox ID="lblApproved" Enabled="false" runat="server" CssClass="lblApproved form-control" Style="text-align: right;" Text='<%# Bind("PrevApprovedAmt", "{0:0.00}") %>'></asp:TextBox>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Right" />
                        <HeaderStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Scheme Sale" DataField="SchemeSale" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:BoundField HeaderText="Pur Amt of Dealer" DataField="TotalSale" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right" />
                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                            <asp:Label ID="lblClmLevel" Text='<%# Eval("ClaimLevel") %>' runat="server" Visible="false"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Auto" DataField="IsAuto" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Parent Code" DataField="ParentCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Parent Name" DataField="ParentName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />

                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
