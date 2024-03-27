<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GrossDealerSummary.aspx.cs" Inherits="Reports_GrossDealerSummary" %>

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

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';

        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';

        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];
        $(function () {
            Reload();
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            ChangeReportFor('1');
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
            ChangeReportFor('1');
            Reload();
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }
        function acetxtCustName_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            var SS = $('.txtSSCode').is(":visible") ? $('.txtSSCode').val().split('-').pop() : "0";
            var dist = "";
            dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            sender.set_contextKey("0-0-0-" + SS + "-" + dist + "-" + EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSCode').is(":visible") ? $('.txtSSCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSCode').is(":visible") ? $('.txtSSCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + ss + "-" + EmpID);
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
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtSSCode").val('');
            }
        }

        function getCurDate() {
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            return jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
        }

        function Reload() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });
            var PurAmtofDealer = 0, SubTotal = 0, Tax = 0, Total = 0, DistClaimAmount = 0, InvRate = 0, NormalRate = 0, InvQty = 0, GrossAmt = 0, SchemeAmount = 0, CompanyCont = 0, DistCont = 0, DistContTax = 0, TotalCompanyCont = 0, TotalQty = 0;

            if ($('.gvMasterScheme thead tr').length > 0) {
                var table = $('.gvMasterScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "columnDefs": [
                        {
                            "targets": [18, 19],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],
                    buttons: [
                        {
                            extend: 'copy', footer: true,
                            exportOptions: {
                                columns: ':visible'
                            }
                        }, {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = $("#lnkTitle").val() + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlSaleBy').val() == "4")
                                    data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlSaleBy').val() == "2")
                                    data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                                data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + getCurDate() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                columns: ':visible',//For exporting only visible columns. 
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
                                var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                if ($('.ddlSaleBy').val() == "4") {
                                    var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                    var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                }
                                if ($('.ddlSaleBy').val() == "2") {
                                    var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                    var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                }
                                var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                                var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                            },
                            exportOptions: {
                                columns: ':visible'
                            },
                        },
                        {
                            extend: 'pdfHtml5',
                            className: "buttonsToHide",
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
                                doc.pageMargins = [20, 105, 20, 30];
                                doc.defaultStyle.fontSize = 6;
                                doc.styles.tableHeader.fontSize = 6;
                                doc['content']['0'].table.widths = ['2%', '6%', '6%', '5%', '4%', '7%', '5%', '6%', '6%', '6%', '6%', '6%', '6%', '6%', '6%', '6%', '6%', '6%'];
                                doc.styles.tableFooter.fontSize = 6;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {

                                                alignment: 'left',
                                                italics: false,
                                                text: [
                                                    { text: $("#lnkTitle").text() + "\n" },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                                    { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                                    { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                                    { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                    { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                                    { text: 'UserId : ' + $('.hdnUserName').val() + '\n' }],
                                                fontSize: 10,
                                                height: 900,
                                            }
                                            //,
                                            // {
                                            //     alignment: 'right',
                                            //     width: 70,
                                            //     height: 50,
                                            //     image: imagebase64
                                            // }
                                        ],
                                        margin: 20,
                                        height: 900
                                    }
                                });
                                doc['footer'] = (function (page, pages) {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                fontSize: 8,
                                                text: ['Created on: ', { text: getCurDate() }]
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

                                    doc.content[0].table.body[i][6].alignment = 'right';
                                    doc.content[0].table.body[i][7].alignment = 'right';
                                    doc.content[0].table.body[i][8].alignment = 'right';
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
                                //Header Alignment for PDF Export.
                                doc.content[0].table.body[0][0].alignment = 'right';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';
                                doc.content[0].table.body[0][6].alignment = 'right';
                                doc.content[0].table.body[0][7].alignment = 'right';
                                doc.content[0].table.body[0][8].alignment = 'right';
                                doc.content[0].table.body[0][9].alignment = 'right';
                                doc.content[0].table.body[0][10].alignment = 'right';
                                doc.content[0].table.body[0][11].alignment = 'right';
                                doc.content[0].table.body[0][12].alignment = 'right';
                                doc.content[0].table.body[0][13].alignment = 'right';
                                doc.content[0].table.body[0][14].alignment = 'right';
                                doc.content[0].table.body[0][15].alignment = 'right';
                                doc.content[0].table.body[0][16].alignment = 'right';
                                doc.content[0].table.body[0][17].alignment = 'right';
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
                        GrossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(13).footer()).html(DistContTax.toFixed(2));
                        $(api.column(14).footer()).html(DistCont.toFixed(2));
                        $(api.column(15).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(16).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(17).footer()).html(SubTotal.toFixed(2));
                        $(api.column(18).footer()).html(Tax.toFixed(2));
                        $(api.column(19).footer()).html(Total.toFixed(2));
                    }
                });
                table.columns.adjust().draw();
            }
            else if ($('.gvQPSScheme thead tr').length > 0) {

                var table = $('.gvQPSScheme').DataTable({
                    bFilter: true,
                    responsive: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],

                    "columnDefs": [
                        {
                            "targets": [25, 26],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],

                    buttons: [{
                        extend: 'copy', footer: true,
                        exportOptions: {
                            columns: ':visible'
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',//For exporting only visible columns. 
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
                        extend: 'excel',
                        footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        },
                        exportOptions: {
                            columns: ':visible'
                        },
                    },

                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['1.5%', '3.5%', '3.5%', '8%', '4%', '10%', '1.7%', '5.8%', '5.8%', '3.5%', '3.5%', '10%', '3.5%', '3.5%', '3.8%', '3.3%', '3%', '4.5%', '3.8%', '5%', '5%', '5%', '5%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.defaultStyle.height = '500px';
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + ($('.hdnUserName').val() + "\n") }],
                                            fontSize: 10,
                                            height: 900,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                            objLayout['paddingLeft'] = function (i) { return 2; };
                            objLayout['paddingRight'] = function (i) { return 2; };
                            doc.content[0].layout = objLayout;

                            var rowCount = doc.content[0].table.body.length;
                            for (i = 1; i < rowCount; i++) {
                                doc.content[0].table.body[i][0].alignment = 'right';
                                doc.content[0].table.body[i][1].alignment = 'center';
                                doc.content[0].table.body[i][2].alignment = 'center';
                                doc.content[0].table.body[i][4].alignment = 'left';
                                doc.content[0].table.body[i][5].alignment = 'left';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'left';
                                doc.content[0].table.body[i][9].alignment = 'center';
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
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'center';
                            doc.content[0].table.body[0][2].alignment = 'center';
                            doc.content[0].table.body[0][3].alignment = 'left';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'left';
                            doc.content[0].table.body[0][6].alignment = 'left';
                            doc.content[0].table.body[0][7].alignment = 'left';
                            doc.content[0].table.body[0][8].alignment = 'left';
                            doc.content[0].table.body[0][9].alignment = 'center';
                            doc.content[0].table.body[0][10].alignment = 'left';
                            doc.content[0].table.body[0][11].alignment = 'left';
                            doc.content[0].table.body[0][12].alignment = 'right';
                            doc.content[0].table.body[0][13].alignment = 'right';
                            doc.content[0].table.body[0][14].alignment = 'right';
                            doc.content[0].table.body[0][15].alignment = 'right';
                            doc.content[0].table.body[0][16].alignment = 'right';
                            doc.content[0].table.body[0][17].alignment = 'right';
                            doc.content[0].table.body[0][18].alignment = 'right';
                            doc.content[0].table.body[0][19].alignment = 'right';
                            doc.content[0].table.body[0][20].alignment = 'right';
                            //doc.content[0].table.body[0][21].alignment = 'right';
                        }
                    }],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;
                        };

                        TotalQty = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //GrossAmt = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        SchemeAmount = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistClaimAmount = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(23, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(24, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //Tax = api.column(21, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //Total = api.column(22, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);


                        $(api.column(6).footer()).html(TotalQty);
                        //$(api.column(12).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(17).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(18).footer()).html(DistClaimAmount.toFixed(2));
                        $(api.column(19).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(20).footer()).html(DistContTax.toFixed(2));
                        $(api.column(21).footer()).html(DistCont.toFixed(2));
                        $(api.column(22).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(23).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(24).footer()).html(SubTotal.toFixed(2));
                        //$(api.column(21).footer()).html(Tax.toFixed(2));
                        //$(api.column(22).footer()).html(Total.toFixed(2));
                    }
                    //,
                    //"fixedHeader": true
                });
                table.columns.adjust().draw();
            }
            else if ($('.gvMachineScheme thead tr').length > 0) {
                $('.gvMachineScheme').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "columnDefs": [
                        {
                            "targets": [18, 19],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],
                    buttons: [{
                        extend: 'copy', footer: true, exportOptions: {
                            columns: ':visible'//For exporting only visible columns. 
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',//For exporting only visible columns. 
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
                        exportOptions: {
                            columns: ':visible'
                        },
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '6%', '21%', '5%', '6%', '7%', '6%', '6%', '6%', '6%', '10%', '6%', '6%', '6%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][3].alignment = 'center';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'center';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'left';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'right';
                            doc.content[0].table.body[0][12].alignment = 'right';
                            doc.content[0].table.body[0][13].alignment = 'right';
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
                        GrossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(13).footer()).html(DistContTax.toFixed(2));
                        $(api.column(14).footer()).html(DistCont.toFixed(2));
                        $(api.column(15).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(16).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(17).footer()).html(SubTotal.toFixed(2));
                        $(api.column(18).footer()).html(Tax.toFixed(2));
                        $(api.column(19).footer()).html(Total.toFixed(2));
                    }
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
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "columnDefs": [
                        {
                            "targets": [18, 19],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],
                    buttons: [{
                        extend: 'copy', footer: true, exportOptions: {
                            columns: ':visible'
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';

                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',
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
                        exportOptions: {
                            columns: ':visible'
                        },
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '6%', '18%', '6.5%', '6%', '8%', '6%', '6%', '6.5%', '6.5%', '9%', '6%', '6%', '6%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][3].alignment = 'center';
                                doc.content[0].table.body[i][5].alignment = 'left';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';

                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'center';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'left';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'right';
                            doc.content[0].table.body[0][12].alignment = 'right';
                            doc.content[0].table.body[0][13].alignment = 'right';
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
                        grossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(grossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(13).footer()).html(DistContTax.toFixed(2));
                        $(api.column(14).footer()).html(DistCont.toFixed(2));
                        $(api.column(15).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(16).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(17).footer()).html(SubTotal.toFixed(2));
                        $(api.column(18).footer()).html(Tax.toFixed(2));
                        $(api.column(19).footer()).html(Total.toFixed(2));
                    }
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
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "columnDefs": [
                        {
                            "targets": [18, 19],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],
                    buttons: [{
                        extend: 'copy', footer: true, exportOptions: {
                            columns: ':visible'
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',
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
                        exportOptions: {
                            columns: ':visible'
                        },
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '6%', '18%', '6.5%', '6%', '8%', '6%', '6%', '6.5%', '6.5%', '9%', '6%', '6%', '6%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][3].alignment = 'center';
                                doc.content[0].table.body[i][5].alignment = 'left';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';

                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'center';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'left';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'right';
                            doc.content[0].table.body[0][12].alignment = 'right';
                            doc.content[0].table.body[0][13].alignment = 'right';
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
                        grossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(grossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(13).footer()).html(DistContTax.toFixed(2));
                        $(api.column(14).footer()).html(DistCont.toFixed(2));
                        $(api.column(15).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(16).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(17).footer()).html(SubTotal.toFixed(2));
                        $(api.column(18).footer()).html(Tax.toFixed(2));
                        $(api.column(19).footer()).html(Total.toFixed(2));
                    }
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
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['5%', '15%', '18%', '8%', '8%', '8%', '10%', '8%', '9%', '9%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][4].alignment = 'right';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'left';
                            doc.content[0].table.body[0][4].alignment = 'right';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';

                        }
                    }],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            if (i == '&nbsp' || isNaN(i))
                                return i = 0;
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                    i : 0;


                        };
                        GrossAmt = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(8).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(9).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(10).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(11).footer()).html(SubTotal.toFixed(2));
                        $(api.column(12).footer()).html(Tax.toFixed(2));
                        $(api.column(13).footer()).html(Total.toFixed(2));
                    }
                });
            }
            else if ($('.gvSecondTrans thead tr').length > 0) {
                var table = $('.gvSecondTrans').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    //destroy: true,
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [{ extend: 'copy', footer: true },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "")+ '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
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
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '8%', '22%', '5%', '5%', '8%', '8%', '8%', '5%', '8%', '6%', '6%', '6%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][3].alignment = 'center';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'center';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'left';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][8].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'right';
                            doc.content[0].table.body[0][12].alignment = 'right';
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
                        GrossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);
                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompContriAmount = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompContriAmount.toFixed(2));
                        $(api.column(13).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(14).footer()).html(SubTotal.toFixed(2));
                        $(api.column(15).footer()).html(Tax.toFixed(2));
                        $(api.column(16).footer()).html(Total.toFixed(2));
                    }
                });
            }
            else if ($('.gvRateDiff thead tr').length > 0) {
                $('.gvRateDiff').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [{
                        extend: 'copy', footer: true, exportOptions: {
                            columns: ':visible'//For exporting only visible columns. 
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';

                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + getCurDate() + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',//For exporting only visible columns. 
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
                        exportOptions: {
                            columns: ':visible'
                        },
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '6%', '12%', '5%', '4%', '4%', '4%', '5%', '13%', '4%', '5%', '6%', '6%', '6%', '8%', '6%', '6%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                            text: ['Created on: ', { text: getCurDate() }]
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
                                doc.content[0].table.body[i][3].alignment = 'center';
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                                doc.content[0].table.body[i][11].alignment = 'right';
                                doc.content[0].table.body[i][12].alignment = 'right';
                                doc.content[0].table.body[i][13].alignment = 'right';
                                doc.content[0].table.body[i][14].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'right';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'center';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
                            doc.content[0].table.body[0][11].alignment = 'right';
                            doc.content[0].table.body[0][12].alignment = 'right';
                            doc.content[0].table.body[0][13].alignment = 'right';
                            doc.content[0].table.body[0][14].alignment = 'right';
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
                        InvRate = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        InvQty = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        NormalRate = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        GrossAmt = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(20, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(9).footer()).html(InvRate.toFixed(2));
                        $(api.column(10).footer()).html(InvQty);
                        $(api.column(11).footer()).html(NormalRate.toFixed(2));
                        $(api.column(14).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(15).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(16).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(17).footer()).html(DistContTax.toFixed(2));
                        $(api.column(18).footer()).html(DistCont.toFixed(2));
                        $(api.column(19).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(20).footer()).html(PurAmtofDealer.toFixed(2));
                    }
                });
            }
            else if ($('.gvIOUClaim thead tr').length > 0) {
                $('.gvIOUClaim').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [{
                        extend: 'copy', footer: true, exportOptions: {
                            columns: ':visible'//For exporting only visible columns. 
                        }
                    },
                    {
                        extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        customize: function (csv) {
                            var data = $("#lnkTitle").text() + '\n';
                            data += 'From Date,' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + ',To,' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + '\n';
                            data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                            data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "4")
                                data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                            if ($('.ddlSaleBy').val() == "2")
                                data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                            data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                            data += 'UserId,' + $('.hdnUserName').val() + '\n';
                            data += 'Created on,' + '\'' + new Date().format('dd-MMM-yy HH:mm') + '\n';
                            return data + csv;
                        },
                        exportOptions: {
                            columns: ':visible',//For exporting only visible columns. 
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
                        exportOptions: {
                            columns: ':visible'
                        },
                        customize: function (xlsx) {

                            sheet = ExportXLS(xlsx, 9);

                            var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                            var r1 = Addrow(2, [{ key: 'A', value: 'From' }, { key: 'B', value: $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To' }, { key: 'D', value: $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) }]);
                            var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                            var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                            if ($('.ddlSaleBy').val() == "4") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            if ($('.ddlSaleBy').val() == "2") {
                                var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                            }
                            var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                            var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                            var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                            sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                        }
                    },
                    {
                        extend: 'pdfHtml5',
                        className: "buttonsToHide",
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
                            doc.pageMargins = [20, 105, 20, 30];
                            doc['content']['0'].table.widths = ['2%', '6%', '21%', '5%', '20%', '4%', '8%', '8%', '9%', '8%', '8%'];
                            doc.defaultStyle.fontSize = 6;
                            doc.styles.tableHeader.fontSize = 6;
                            doc.styles.tableFooter.fontSize = 6;
                            doc['header'] = (function () {
                                return {
                                    columns: [
                                        {
                                            alignment: 'left',
                                            italics: false,
                                            text: [{ text: $("#lnkTitle").text() + "\n" },
                                            { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                            { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                            { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                            { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                            { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                            { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                            { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                            { text: 'UserId : ' + $('.hdnUserName').val() + "\n" }],
                                            fontSize: 10,
                                            height: 600,
                                        }
                                        //,
                                        //{
                                        //    alignment: 'right',
                                        //    width: 70,
                                        //    height: 50,
                                        //    image: imagebase64
                                        //}
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
                                doc.content[0].table.body[i][5].alignment = 'right';
                                doc.content[0].table.body[i][6].alignment = 'right';
                                doc.content[0].table.body[i][7].alignment = 'right';
                                doc.content[0].table.body[i][8].alignment = 'right';
                                doc.content[0].table.body[i][9].alignment = 'right';
                                doc.content[0].table.body[i][10].alignment = 'right';
                            };
                            //Header Alignment for PDF Export.
                            doc.content[0].table.body[0][0].alignment = 'center';
                            doc.content[0].table.body[0][1].alignment = 'left';
                            doc.content[0].table.body[0][2].alignment = 'left';
                            doc.content[0].table.body[0][3].alignment = 'left';
                            doc.content[0].table.body[0][4].alignment = 'left';
                            doc.content[0].table.body[0][5].alignment = 'right';
                            doc.content[0].table.body[0][6].alignment = 'right';
                            doc.content[0].table.body[0][7].alignment = 'right';
                            doc.content[0].table.body[0][9].alignment = 'right';
                            doc.content[0].table.body[0][10].alignment = 'right';
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

                        InvRate = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistClaimAmount = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        //DistContTax = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        //DistCont = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                        //    return intVal(a) + intVal(b);
                        //}, 0);

                        $(api.column(9).footer()).html(InvRate);
                        $(api.column(10).footer()).html(DistClaimAmount.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));

                        var hdnGrossPurchaseDist = intVal($(".hdnGrossPurchaseDist").val());
                        $(api.column(12).footer()).html(hdnGrossPurchaseDist.toFixed(2));

                        var PurClaimPerAmt = intVal($(".hdnClaimPurAmtForPer").val());
                        $(api.column(13).footer()).html(PurClaimPerAmt.toFixed(2));

                        var FinalClaimAmt = intVal((intVal(PurClaimPerAmt.toFixed(2)) <= intVal(SchemeAmount.toFixed(2))) ? PurClaimPerAmt.toFixed(2) : SchemeAmount.toFixed(2));
                        $(api.column(14).footer()).html(FinalClaimAmt.toFixed(2));

                        //$(api.column(9).footer()).html(DistContTax.toFixed(2));
                        //$(api.column(10).footer()).html(DistCont.toFixed(2));
                    }
                });
            }
            else if ($('.gvSTODClaim thead tr').length > 0) {
                var table = $('.gvSTODClaim').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    "columnDefs": [
                        {
                            "targets": [18, 19],//Column no that needs to hide from DataTable but not from Exporting.
                            "visible": false,
                            "searchable": false
                        }],
                    buttons: [
                        {
                            extend: 'copy', footer: true,
                            exportOptions: {
                                columns: ':visible'
                            }
                        }, {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = $("#lnkTitle").text() + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                data += 'Report For,' + $('.ddlSaleBy option:selected').text() + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlSaleBy').val() == "4")
                                    data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                if ($('.ddlSaleBy').val() == "2")
                                    data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                data += 'Claim Type,' + $('.ddlMode option:Selected').text() + '\n';
                                data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + getCurDate() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                columns: ':visible',//For exporting only visible columns. 
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
                                var r2 = Addrow(3, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                var r8 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                if ($('.ddlSaleBy').val() == "4") {
                                    var r3 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-').slice(0, 2) : "") }]);
                                    var r4 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                }
                                if ($('.ddlSaleBy').val() == "2") {
                                    var r3 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                    var r4 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                }
                                var r5 = Addrow(7, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: $('.ddlMode option:Selected').text() }]);
                                var r6 = Addrow(8, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r7 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (getCurDate()) }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r8 + r3 + r4 + r5 + r6 + r7 + sheet.childNodes[0].childNodes[1].innerHTML;
                            },
                            exportOptions: {
                                columns: ':visible'
                            },
                        },
                        {
                            extend: 'pdfHtml5',
                            className: "buttonsToHide",
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
                                doc.pageMargins = [20, 105, 20, 30];
                                doc.defaultStyle.fontSize = 6;
                                doc.styles.tableHeader.fontSize = 6;
                                doc['content']['0'].table.widths = ['2%', '6%', '28%', '5%', '4%', '7%', '5%', '6%', '6%', '6%', '6%', '6%', '6%', '6%'];
                                doc.styles.tableFooter.fontSize = 6;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {

                                                alignment: 'left',
                                                italics: false,
                                                text: [
                                                    { text: $("#lnkTitle").text() + "\n" },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    { text: 'Report For : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                                    { text: 'Employee : ' + ((($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + "\n") },
                                                    { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[1] + "\n" : "\n") : '') },
                                                    { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                    { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                    { text: 'Claim Type : ' + $('.ddlMode option:Selected').text() + '\n' },
                                                    { text: 'UserId : ' + $('.hdnUserName').val() + '\n' }],
                                                fontSize: 10,
                                                height: 900,
                                            }
                                            //,
                                            // {
                                            //     alignment: 'right',
                                            //     width: 70,
                                            //     height: 50,
                                            //     image: imagebase64
                                            // }
                                        ],
                                        margin: 20,
                                        height: 900
                                    }
                                });
                                doc['footer'] = (function (page, pages) {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                fontSize: 8,
                                                text: ['Created on: ', { text: getCurDate() }]
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
                                    doc.content[0].table.body[i][3].alignment = 'center';
                                    doc.content[0].table.body[i][6].alignment = 'right';
                                    doc.content[0].table.body[i][7].alignment = 'right';
                                    doc.content[0].table.body[i][8].alignment = 'right';
                                    doc.content[0].table.body[i][9].alignment = 'right';
                                    doc.content[0].table.body[i][10].alignment = 'right';
                                    doc.content[0].table.body[i][11].alignment = 'right';
                                    doc.content[0].table.body[i][12].alignment = 'right';
                                    doc.content[0].table.body[i][13].alignment = 'right';

                                };
                                //Header Alignment for PDF Export.
                                doc.content[0].table.body[0][0].alignment = 'right';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'center';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';
                                doc.content[0].table.body[0][6].alignment = 'right';
                                doc.content[0].table.body[0][7].alignment = 'right';
                                doc.content[0].table.body[0][8].alignment = 'right';
                                doc.content[0].table.body[0][9].alignment = 'right';
                                doc.content[0].table.body[0][10].alignment = 'right';
                                doc.content[0].table.body[0][11].alignment = 'right';
                                doc.content[0].table.body[0][12].alignment = 'right';
                                doc.content[0].table.body[0][13].alignment = 'right';
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
                        GrossAmt = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        CompanyCont = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistContTax = api.column(13, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        DistCont = api.column(14, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalCompanyCont = api.column(15, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        PurAmtofDealer = api.column(16, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(17, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(18, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(19, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(10).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(11).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(12).footer()).html(CompanyCont.toFixed(2));
                        $(api.column(13).footer()).html(DistContTax.toFixed(2));
                        $(api.column(14).footer()).html(DistCont.toFixed(2));
                        $(api.column(15).footer()).html(TotalCompanyCont.toFixed(2));
                        $(api.column(16).footer()).html(PurAmtofDealer.toFixed(2));
                        $(api.column(17).footer()).html(SubTotal.toFixed(2));
                        $(api.column(18).footer()).html(Tax.toFixed(2));
                        $(api.column(19).footer()).html(Total.toFixed(2));
                    }
                });
                table.columns.adjust().draw();
            }
            //var table = $('#gvMasterScheme').DataTable();

            //// Hide two columns
            ////table.columns([0, 1, 2, 3]).visible(false, false);
            //table.column(0).visible(false);
            //table.columns.adjust().draw(false);

        }

    </script>

    <style>
        .buttonsToHide {
            display: none !important;
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

        table.tbody tr td {
            height: 10px;
        }

            table.tbody tr td.span {
                height: 10px;
            }

        table.dataTable thead th {
            padding-top: 4px;
            padding-left: 2px;
        }

        table.dataTable tbody td {
            padding-top: 4px;
            padding-right: 2px;
            padding-left: 2px;
            padding-bottom: 2px;
        }

        table.dataTable tfoot td {
            padding-top: 4px;
            padding-right: 2px;
            padding-left: 2px;
            padding-bottom: 2px;
        }

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

        .table-header-gradient .WordWrap {
            white-space: pre-wrap !important;
        }

        .table-header-gradient .TextRightAlign {
            text-align: right;
        }

        .table-header-gradient .TextLeftAlign {
            text-align: left;
        }

        .table-header-gradient .TextCenterAlign {
            text-align: center;
        }

        th.WordWrap.CompContri.sorting {
            width: 6% !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" TabIndex="3">
                            <asp:ListItem Text="Extra Discount (%) (C01)" Value="M" Selected="True" />
                            <asp:ListItem Text="QPS Scheme (C06)" Value="S" />
                            <asp:ListItem Text="Free I/C Scheme - Machine Purchase Dlr. (C33)" Value="D" />
                            <asp:ListItem Text="Free I/C Scheme For Parlour (C34)" Value="P" />
                            <%--<asp:ListItem Text="FOW Electricity Claim" Value="F" />--%>
                            <asp:ListItem Text="Outstation Freight Claims (%) (C04)" Value="T" />
                            <asp:ListItem Text="Free Ice Cream for FOW VRS & Vendor (C61)" Value="V" />
                            <asp:ListItem Text="Online Rate Difference Claim (C68)" Value="R" />
                            <asp:ListItem Text="Online IOU Claim (Master/QPS/Free) (C69)" Value="I" />
                            <asp:ListItem Text="S TO D" Value="A" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="4" CssClass="ddlSaleBy form-control" OnChange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="6" CssClass="txtDistCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="7" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="8" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>

            <asp:GridView ID="gvMasterScheme" runat="server" CssClass="gvMasterScheme nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvMasterScheme_PreRender" ShowFooter="True" HeaderStyle-Wrap="true" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." HeaderStyle-Wrap="true" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="Inv. Date" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="5%" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField DataField="InvoiceNumber" HeaderStyle-CssClass="WordWrap" HeaderText="Inv. No." HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="7%" HeaderStyle-CssClass="WordWrap">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="2%" />
                    <asp:BoundField DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total Claim Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderStyle-Wrap="true" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="2%" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Sub Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="GST" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />

                    <asp:BoundField DataField="TotalCompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="DistContTax" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="1%" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvQPSScheme" runat="server" CssClass="gvQPSScheme nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvQPSScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="1%" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField ItemStyle-Width="3%" DataField="StartDate" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="Start Date" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="3%" DataField="EndDate" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="End Date" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="6%" DataField="SchemeCode" HeaderStyle-Width="6%" HeaderStyle-CssClass="WordWrap" DataFormatString="{0:0.00}" HeaderText="Scheme Code" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField ItemStyle-Width="40px" DataField="ItemCode" HeaderStyle-Width="40px" ItemStyle-Wrap="true" HeaderStyle-CssClass="WordWrap" HeaderText="Item Code" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField ItemStyle-Width="230px" DataField="ItemName" HeaderStyle-Width="230px" ItemStyle-CssClass="WordWrap" ItemStyle-Wrap="true" HeaderText="Item Name" ItemStyle-HorizontalAlign="Left" />
                    <asp:BoundField ItemStyle-Width="2%" DataField="TotalQty" HeaderStyle-Width="2%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0}" HeaderText="Sch. Qty" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField ItemStyle-Width="5%" DataField="InvoiceDate" HeaderStyle-Width="5%" HeaderStyle-CssClass="TextCenterAlign WordWrap " HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField ItemStyle-Width="1%" DataField="InvoiceNumber" HeaderStyle-Width="1%" HeaderStyle-CssClass="WordWrap " HeaderText="Invoice No." ItemStyle-HorizontalAlign="Left" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>' runat="server" />
                        </ItemTemplate>
                        <HeaderStyle Width="50%" />
                    </asp:TemplateField>

                    <asp:BoundField ItemStyle-Width="3%" DataField="CalcPrice" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Claim Rate" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="2%" DataField="CompanyCont" HeaderStyle-Width="2%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="40px" DataField="DistCont" HeaderStyle-Width="40px" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="30px" DataField="SchemeAmount" HeaderStyle-Width="30px" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Total Claim Amt" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField ItemStyle-Width="3%" DataField="SalesAmount" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="3%" DataField="GrossAmt" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField ItemStyle-Width="5%" DataField="SubTotal" HeaderStyle-Width="5%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Sub Total" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="3%" DataField="Tax" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="3%" DataField="Total" HeaderStyle-Width="3%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField ItemStyle-Width="1%" DataField="DistContTax" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="1%" DataField="TotalCompanyCont" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient footerWidth" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvMachineScheme" runat="server" CssClass="gvMachineScheme nowrap table" Visible="false" Style="font-size: 10px;" OnPreRender="gvMachineScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />

                    <asp:BoundField ItemStyle-Width="5%" DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField ItemStyle-Width="5%" DataField="InvoiceNumber" HeaderText="Invoice No." ItemStyle-HorizontalAlign="Left" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField ItemStyle-Width="5%" DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="5%" DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="4%" DataField="SchemeAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Total Claim Amount" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField ItemStyle-Width="5%" DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />

                    <asp:BoundField ItemStyle-Width="5%" DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="SubTotal" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="5%" DataField="Tax" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="6%" DataField="Total" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField ItemStyle-Width="0%" DataField="DistContTax" HeaderStyle-CssClass="TextRightAlign WordWrap CompContri" DataFormatString="{0:0.00}" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField ItemStyle-Width="5%" DataField="TotalCompanyCont" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvParlourScheme" runat="server" CssClass="gvParlourScheme nowrap table " Visible="false" Style="font-size: 10px;" OnPreRender="gvParlourScheme_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="2%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />

                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign" ItemStyle-Width="2%" HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="InvoiceNumber" ItemStyle-Width="2%" HeaderText="Invoice No." ItemStyle-HorizontalAlign="Left" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="7%" DataFormatString="{0:0.00}" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="5%" DataFormatString="{0:0.00}" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="WordWrap TextRightAlign" ItemStyle-Width="5%" DataFormatString="{0:0.00}" HeaderText="Total Claim Amount" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="4%" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="7%" />
                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="SubTotal" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField DataField="DistContTax" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="2%" DataFormatString="{0:0.00}" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="TotalCompanyCont" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="2%" DataFormatString="{0:0.00}" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" />


                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>
            <asp:GridView ID="gvVRSDiscount" runat="server" CssClass="gvVRSDiscount nowrap table " Visible="false" Style="font-size: 10px;" OnPreRender="gvVRSDiscount_PreRender" ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="2%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />

                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign" ItemStyle-Width="2%" HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="InvoiceNumber" ItemStyle-Width="2%" HeaderText="Invoice No." ItemStyle-HorizontalAlign="Left" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="7%" DataFormatString="{0:0.00}" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="5%" DataFormatString="{0:0.00}" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="WordWrap TextRightAlign" ItemStyle-Width="5%" DataFormatString="{0:0.00}" HeaderText="Total Claim Amount" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="4%" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="7%" />
                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="SubTotal" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="8%" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField DataField="DistContTax" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="2%" DataFormatString="{0:0.00}" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="TotalCompanyCont" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="2%" DataFormatString="{0:0.00}" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" />


                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>
            <asp:GridView ID="gvFOWScheme" runat="server" CssClass="gvFOWScheme nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvFOWScheme_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="6%" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <%-- <asp:BoundField DataField="InvoiceDate" ItemStyle-Width="9%" ItemStyle-CssClass="TextCenterAlign" HeaderStyle-CssClass="TextCenterAlign" HeaderText="Invoice Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />--%>
                    <asp:BoundField DataField="SchemeAmount" ItemStyle-Width="8%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="Total Claim Amount" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="SalesAmount" ItemStyle-Width="10%" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="6%" />

                    <asp:BoundField DataField="SubTotal" ItemStyle-Width="10%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="SubTotal" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Tax" ItemStyle-Width="8%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Total" ItemStyle-Width="8%" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvSecondTrans" runat="server" CssClass="gvSecondTrans nowrap table" Visible="false" Style="font-size: 10px;" OnPreRender="gvSecondTrans_PreRender"
                ShowFooter="True" AutoGenerateColumns="false" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found.">
                <Columns>
                    <asp:TemplateField HeaderText="No." ItemStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="6%" HeaderText="Invoice Date" />
                    <asp:BoundField DataField="InvoiceNumber" ItemStyle-Width="4.5%" HeaderText="Invoice No." ItemStyle-HorizontalAlign="Left" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="5%" HeaderStyle-CssClass="WordWrap DocType">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CompanyContPer" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="3%" DataFormatString="{0:0.00}" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="4%" DataFormatString="{0:0.00}" HeaderText="Total Claim Amount" ItemStyle-HorizontalAlign="Right" />

                    <asp:BoundField DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" ItemStyle-Width="5%" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="6%" />

                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="7%" DataFormatString="{0:0.00}" HeaderText="SubTotal" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="7%" DataFormatString="{0:0.00}" HeaderText="GST" ItemStyle-HorizontalAlign="Right" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" ItemStyle-Width="7%" DataFormatString="{0:0.00}" HeaderText="Total" ItemStyle-HorizontalAlign="Right" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvRateDiff" runat="server" CssClass="gvRateDiff nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvRateDiff_PreRender" ShowFooter="True" HeaderStyle-Wrap="true" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." HeaderStyle-Wrap="true" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="Inv. Date" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="5%" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField DataField="InvoiceNumber" HeaderStyle-CssClass="WordWrap" HeaderText="Inv. No." HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="InvoiceRate" HeaderStyle-CssClass="WordWrap" HeaderText="Inv. Rate" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="TotalQty" HeaderStyle-CssClass="WordWrap" HeaderText="Inv. Qty" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="NormalRate" HeaderStyle-CssClass="WordWrap" HeaderText="Normal Rate" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="Item" HeaderStyle-CssClass="WordWrap" HeaderText="Item" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="7%" HeaderStyle-CssClass="WordWrap">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="2%" />
                    <asp:BoundField DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total Claim Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Sub Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="GST" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvIOUClaim" runat="server" CssClass="gvIOUClaim nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvIOUClaim_PreRender" ShowFooter="True" HeaderStyle-Wrap="true" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." HeaderStyle-Wrap="true" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextCenterAlign" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                            <input type="hidden" id="hdnGrossPurchaseDist" class="hdnGrossPurchaseDist" runat="server" value='<%# Eval("GrossPurchase") %>' />
                            <input type="hidden" id="hdnClaimPurAmtForPer" class="hdnClaimPurAmtForPer" runat="server" value='<%# Eval("ClaimPurAmtForPer") %>' />
                            <input type="hidden" id="hdnFinalClaimAmt" class="hdnFinalClaimAmt" runat="server" value='' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField DataField="ItemCode" HeaderStyle-CssClass="TextLeftAlign WordWrap" HeaderText="Item Code" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField DataField="ItemName" HeaderStyle-CssClass="WordWrap" HeaderText="Item Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="Quantity" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderText="Total Qty" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="ClaimAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderText="Dist. Claim Amount" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />
                    <asp:BoundField DataField="ClaimAmtForPer" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderText="Per. Claim Amt." DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />
                    <%--<asp:BoundField DataField="GrossPurchase" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderText="Purchase Amt. of Dist." DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="4%" />--%>
                    <asp:TemplateField HeaderText="I/c Purchase Amount" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderStyle-Width="4%" ItemStyle-HorizontalAlign="Right" HeaderStyle-Wrap="true" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate></ItemTemplate>
                    </asp:TemplateField>
                    <%--<asp:BoundField DataField="ClaimPurAmtForPer" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Per. Purchase Amt." ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />--%>
                    <asp:TemplateField HeaderText="Per. Purchase Amt." HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderStyle-Width="3%" ItemStyle-Width="30px" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate></ItemTemplate>
                    </asp:TemplateField>
                    <%--<asp:BoundField DataField="FinalClaimAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Final Claim Amt." ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />--%>
                    <asp:TemplateField HeaderText="Final Claim Amt." HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderStyle-Width="5%" ItemStyle-Width="30px" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Right" FooterStyle-HorizontalAlign="Right">
                        <ItemTemplate></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>

            <asp:GridView ID="gvSTODClaim" runat="server" CssClass="gvSTODClaim nowrap table" Visible="false" Style="font-size: 10px;"
                OnPreRender="gvSTODClaim_PreRender" ShowFooter="True" HeaderStyle-Wrap="true" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." HeaderStyle-Wrap="true" HeaderStyle-Width="1%" HeaderStyle-CssClass="TextRightAlign" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <asp:Literal ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ParentCode" HeaderText="Dist. Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="ParentName" HeaderText="Dist Name" HeaderStyle-CssClass="WordWrap" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="CityName" HeaderText="City" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="StateName" HeaderText="State" HeaderStyle-CssClass="WordWrap" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1%" />
                    <asp:BoundField DataField="DealerCode" HeaderText="Dealer Code" HeaderStyle-CssClass="WordWrap" HeaderStyle-Wrap="true" ItemStyle-CssClass="CustName" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="1.2%" />
                    <asp:BoundField DataField="DealerName" HeaderText="Dealer Name" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-Width="15%" />
                    <asp:BoundField DataField="InvoiceDate" HeaderStyle-CssClass="TextCenterAlign WordWrap" HeaderText="Inv. Date" HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="5%" ItemStyle-VerticalAlign="Middle" />
                    <asp:BoundField DataField="InvoiceNumber" HeaderStyle-CssClass="WordWrap" HeaderText="Inv. No." HeaderStyle-Wrap="true" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="4%" />
                    <asp:TemplateField HeaderText="Doc Type" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="7%" HeaderStyle-CssClass="WordWrap">
                        <ItemTemplate>
                            <asp:Literal Text='<%# Eval("DocType").ToString() == "SALE" ? "SALES INVOICE" : "SALES RETURN" %>'
                                runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="CompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Comp. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="2%" />
                    <asp:BoundField DataField="DistCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Dist. Contri" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="SchemeAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total Claim Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="SalesAmount" HeaderStyle-CssClass="TextRightAlign WordWrap" HeaderStyle-Wrap="true" DataFormatString="{0:0.00}" HeaderText="Purch.Amt.[Gross-QPS]" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="2%" />
                    <asp:BoundField DataField="GrossAmt" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Gross Amt" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="SubTotal" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Sub Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                    <asp:BoundField DataField="Tax" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="GST" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="Total" HeaderStyle-CssClass="TextRightAlign" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />

                    <asp:BoundField DataField="TotalCompanyCont" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Total Company Contribution" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                    <asp:BoundField DataField="DistContTax" HeaderStyle-CssClass="TextRightAlign WordWrap" DataFormatString="{0:0.00}" HeaderStyle-Wrap="true" HeaderText="Distribution Contribution bared by Company" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="1%" />
                </Columns>
                <FooterStyle CssClass=" table-header-gradient" HorizontalAlign="Right"></FooterStyle>
            </asp:GridView>
        </div>
    </div>

</asp:Content>
