<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetConflictRpt.aspx.cs" Inherits="Reports_AssetConflictRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
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
        var IpAddress;
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + dist + "-" + EmpID);
        }

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
            ChangeReportFor('1');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
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
        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor('1');
        }

        function ChangeReportFor(SelType) {

            if (CustType == 1 && $('.ddlReportBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');

            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.txtDealerCode').val('');
                if (SelType == "2") {
                    $('.txtDistCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "3") {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
                $('.divDealer').removeAttr('style');
            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "0") {
                $('.txtSSDistCode').val('');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
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

        function Reload() {

            if ($('.gvAsset thead tr').length > 0) {

                var table = $(".gvAsset").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "140px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyCenter", "aTargets": 2 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "150px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "48px", "aTargets": 10 });
                if ($('.chkLatLong').find('input').is(':checked')) {
                    aryJSONColTable.push({ "width": "47px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "56px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 14 });
                }
                else {
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 11 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 12 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 13 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 14 });
                }
                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                $('.gvAsset').DataTable(
                    {
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
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (csv) {
                                    var data = 'Asset Scan Report for ' + ($('.ddlType').val() == "0" ? "Conflict & Non-Conflict" : $('.ddlType option:Selected').text()) + ' Asset\n';
                                    data += 'From Date,' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + ',To Date,' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + '\n';
                                    data += 'Employee,' + ($('.txtCode').val() != "" ? $('.txtCode').val().split('-').slice(0, 2) : "All Employee") + '\n';
                                    if ($('.ddlReportBy').val() == '0')
                                        data += 'Beat Type,' + ("All Beat Type") + '\n';
                                    if ($('.ddlReportBy').val() == '4')
                                        data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") + '\n';
                                    if ($('.ddlReportBy').val() == '2')
                                        data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") + '\n';
                                    if ($('.ddlReportBy').val() == '3')
                                        data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") + '\n';
                                    data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All Region") + '\n';
                                    data += 'Conflict Type,' + $('.ddlType option:Selected').text() + '\n';
                                    data += 'With LatLong,' + ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") + '\n';
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

                                    sheet = ExportXLS(xlsx, 9);

                                    var r0 = Addrow(1, [{ key: 'A', value: 'Asset Scan Report for ' + (($('.ddlType').val() == "0") ? "Conflict/Non-Conflict" : $('.ddlType option:Selected').text()) + ' Asset' }]);
                                    var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To Date' }, { key: 'D', value: $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[1] : "All Employee") }]);
                                    if ($('.ddlReportBy').val() == '0')
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Beat Type' }, { key: 'B', value: ("All Beat Type") }]);
                                    if ($('.ddlReportBy').val() == '4')
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All Super Stockist") }]);
                                    if ($('.ddlReportBy').val() == '2')
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All Distributor") }]);
                                    if ($('.ddlReportBy').val() == '3')
                                        var r3 = Addrow(4, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All Dealer") }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'Region' }, { key: 'B', value: ($('.txtRegion').val() != "" ? $('.txtRegion').val().split('-').slice(0, 2) : "All Region") }]);
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Conflict Type' }, { key: 'B', value: $('.ddlType option:selected').text() }]);
                                    var r6 = Addrow(7, [{ key: 'A', value: 'With LatLong' }, { key: 'B', value: ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") }]);
                                    var r7 = Addrow(8, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r8 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape',
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),
                                exportOptions: {
                                    columns: ':visible',
                                    search: 'applied',
                                    order: 'applied'
                                },
                                customize: function (doc) {
                                    doc.content.splice(0, 1);
                                    doc.pageMargins = [20, 120, 20, 40];
                                    doc.defaultStyle.fontSize = 6;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc.styles.tableFooter.fontSize = 7;
                                    //doc['content']['0'].table.widths = ['2%', '12%', '6.5%', '8%', '11.5%', '6%', '8.5%', '5%', '11%', '6%', '5%', '5%', '12%'];
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: false,
                                                    text: [{ text: 'Asset Scan Report for ' + ($('.ddlType').val() == "0" ? "Conflict & Non-Conflict" : $('.ddlType option:Selected').text()) + ' Asset' + "\n" },
                                                           { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                           { text: 'Employee : ' + (($('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "All Employee" + "\n") },
                                                           { text: ($('.ddlReportBy').val() == '4') ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) + "\n" : "All Super Stockist" + "\n") : "" },
                                                           { text: ($('.ddlReportBy').val() == '2') ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "All Distributor" + "\n") : "" },
                                                           { text: ($('.ddlReportBy').val() == '3') ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "All Dealer" + "\n") : "" },
                                                           { text: ($('.ddlReportBy').val() == '0') ? 'Beat Type : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "All Beat Type" + "\n") : "" },
                                                           { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "All Region" + "\n") },
                                                           { text: 'Conflict Type : ' + $('.ddlType option:Selected').text() + '\n' },
                                                           { text: 'With LatLong : ' + (($('.chkLatLong').find('input').is(':checked') ? "True" : "False") + "\n") },
                                                           { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }
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
                                        doc.content[0].table.body[i][0].alignment = 'center';
                                        doc.content[0].table.body[i][2].alignment = 'center';
                                        if ($('.chkLatLong').find('input').is(':checked')) {
                                            doc.content[0].table.body[i][11].alignment = 'right';
                                            doc.content[0].table.body[i][12].alignment = 'right';
                                        }
                                    };
                                    doc.content[0].table.body[0][0].alignment = 'center';
                                    doc.content[0].table.body[0][1].alignment = 'left';
                                    doc.content[0].table.body[0][2].alignment = 'center';
                                    doc.content[0].table.body[0][3].alignment = 'left';
                                    doc.content[0].table.body[0][4].alignment = 'left';
                                    doc.content[0].table.body[0][5].alignment = 'left';
                                    doc.content[0].table.body[0][6].alignment = 'left';
                                    doc.content[0].table.body[0][7].alignment = 'left';
                                    doc.content[0].table.body[0][8].alignment = 'left';
                                    doc.content[0].table.body[0][9].alignment = 'left';
                                    doc.content[0].table.body[0][10].alignment = 'left';

                                    if ($('.chkLatLong').find('input').is(':checked')) {
                                        doc.content[0].table.body[0][11].alignment = 'right';
                                        doc.content[0].table.body[0][12].alignment = 'right';
                                        doc.content[0].table.body[0][13].alignment = 'left';
                                        doc.content[0].table.body[0][14].alignment = 'left';
                                    }
                                }
                            }]
                    }
                );
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

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyHide {
            display: none;
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
                        <asp:Label Text="Beat Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReportBy" TabIndex="4" runat="server" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="All Beat Type" Value="0" Selected="True" />
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" />
                            <asp:ListItem Text="Dealer" Value="3" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPlant" runat="server" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblType" runat="server" Text="Conflict Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlType" TabIndex="10" CssClass="form-control ddlType">
                            <asp:ListItem Text="--- ALL ---" Value="0" />
                            <asp:ListItem Text="Conflict" Value="1" />
                            <asp:ListItem Text="Non Conflict" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblLatLong" runat="server" Text="With LatLong" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox CssClass="form-control chkLatLong" Checked="true" TabIndex="11" ID="chkLatLong" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="12" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvAsset" runat="server" Width="100%" CssClass="gvAsset  table tbl" Style="font-size: 11px;" HeaderStyle-CssClass=" table-header-gradient" OnPreRender="gvAsset_Prerender" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

