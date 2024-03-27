<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="DealerHistoryRpt.aspx.cs" Inherits="Reports_DealerHistoryRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">
        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';
        $(function () {
            Reload();
            $("#hdnIPAdd").val(IpAddress);
            ChangeReportFor('3');
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
        function EndRequestHandler2(sender, args) {
            ChangeReportFor('3');
            Reload();
        }
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
        function ChangeReportFor(RptType) {


            if ($('.ddlReportBy').val() == "4") {

                $('.divEmpCode').removeAttr('style');
                $('.divDlrEmpCode').attr('style', 'display:none;');
                $(".txtEmployee").val('');
                $('.divSS').removeAttr('style');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');

                $('.divDealer').attr('style', 'display:none;');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                $('.txtSSCode').val('');
                $('.txtDealerCode').val('');
                $(".txtEmployee").val('');
                $('.divEmpCode').removeAttr('style');
                $('.divDlrEmpCode').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
            else if ($('.ddlReportBy').val() == "3") {
                $('.txtSSCode').val('');
                $('.txtDistCode').val('');
                $('.divDlrEmpCode').removeAttr('style');
                $('.divEmpCode').attr('style', 'display:none;');
                $(".txtCode").val('');

                $('.divDistributor').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0 || $(".txtEmployee").length > 0) {
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtSSCode").val('');
            }
        }
        function Reload() {
            $("#btnImport").bind("click", function () {
                var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
                if (regex.test($(".CustCodeUpload").val().toLowerCase())) {
                    if (typeof (FileReader) != "undefined") {
                        var reader = new FileReader();
                        reader.onload = function (e) {
                            var rows = e.target.result.split("\n");
                            var row = ""
                            for (var i = 1; i < rows.length; i++) {
                                var cells = rows[i].split(",");
                                for (var j = 0; j < cells.length; j++) {
                                    row += cells[j] + ','
                                }
                            }
                            $(".hdnCustCode").val(row);
                        }
                        reader.readAsText($(".CustCodeUpload")[0].files[0]);
                        ModelMsg("Uploaded Succesfully", 1);
                    } else {
                        ModelMsg("This browser does not support HTML5.", 3);
                    }
                } else {
                    ModelMsg("Please upload a valid csv file.", 3);
                }
            });
            $(".gvMissdata").tableHeadFixer('65vh');

            if ($('.gvHistory thead tr').length > 0) {

                var now = new Date();
                //Date.prototype.today = function () {
                //    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                //}
                //var jsDate = now.toLocaleString('en-GB', { timeStyle: 'full', day: 'numeric', month: 'short', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: false });

                var aryJSONColTable = [];

                if ($('.ddlRptType option:Selected').val() == "1") {
                    aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "110px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "65px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "230px", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 13 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    if ($('.chkLatLong').find('input').is(':checked')) {
                        aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                        aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 17 });
                        aryJSONColTable.push({ "width": "300px", "aTargets": 18 });

                    }
                    else {
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 16 });
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 17 });
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 18 });

                    }
                }
                else {
                    aryJSONColTable.push({ "width": "15px", "sClass": "dtbodyCenter", "aTargets": 0 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 1 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 2 });
                    aryJSONColTable.push({ "width": "110px", "aTargets": 3 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 4 });
                    aryJSONColTable.push({ "width": "50px", "aTargets": 5 });
                    aryJSONColTable.push({ "width": "65px", "aTargets": 6 });
                    aryJSONColTable.push({ "width": "180px", "aTargets": 7 });
                    aryJSONColTable.push({ "width": "70px", "aTargets": 8 });
                    aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyCenter", "aTargets": 9 });
                    aryJSONColTable.push({ "width": "80px", "aTargets": 10 });
                    aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyRight", "aTargets": 11 });
                    aryJSONColTable.push({ "width": "90px", "aTargets": 12 });
                    aryJSONColTable.push({ "width": "180px", "aTargets": 13 });
                    if ($('.chkLatLong').find('input').is(':checked')) {
                        aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 14 });
                        aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                        aryJSONColTable.push({ "width": "300px", "aTargets": 16 });

                    }
                    else {
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 14 });
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 15 });
                        aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 16 });

                    }
                }

                $('.gvHistory').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '46vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": false,
                    "bSort": false,  // To Remove All Sorting.
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [
                       {
                           extend: 'csv',
                           footer: true,
                           filename: 'Dealer History Report',
                           customize: function (csv) {
                               var data = 'Dealer History Report' + '\n';
                               data += 'Stored Hierarchy,' + ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") + '\n';
                               data += 'From,' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + ',To,' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + '\n';
                               data += 'Option,' + $('.ddlReportBy option:Selected').text() + '\n';
                               if ($('.ddlReportBy').val() == "3")
                                   data += 'Employee,' + ($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "" ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() : "All") + '\n';
                               else
                                   data += 'Employee,' + ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-')[0].trim() + " # " + $('.txtCode').val().split('-')[1].trim() : "All") + '\n';
                               data += 'Report Type,' + $('.ddlRptType option:Selected').text() + '\n';
                               if ($('.ddlReportBy').val() == "4")
                                   data += 'Super Stockist,' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[0].trim() + " # " + $('.txtSSCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) + '\n';
                               if ($('.ddlReportBy').val() == "2")
                                   data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) + '\n';
                               if ($('.ddlReportBy').val() == "3")
                                   data += 'Dealer,' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) + '\n';
                               data += 'With LatLong,' + ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") + '\n';
                               data += 'UserId,' + $('.hdnUserName').val() + '\n';
                               data += 'Created on,\'' + new Date().format('dd-MMM-yyyy HH:mm:ss') + '\n';
                               return data + csv;
                           },
                           exportOptions: {
                               columns: ':visible',//For exporting only visible columns. 
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
                           extend: 'excel', footer: true,
                           filename: 'Dealer History Report',
                           exportOptions: {
                               columns: ':visible'
                           },
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 10);

                               var r0 = Addrow(1, [{ key: 'A', value: 'Dealer History Report' }]);
                               var r8 = Addrow(2, [{ key: 'A', value: 'Stored Hierarchy' }, { key: 'B', value: ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") }]);
                               var r1 = Addrow(3, [{ key: 'A', value: 'From' }, { key: 'B', value: $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To' }, { key: 'D', value: $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) }]);
                               var r2 = Addrow(4, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlReportBy option:selected').text() }]);
                               if ($('.ddlReportBy').val() == "3") {
                                   var r3 = Addrow(5, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "") ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() : "All") }]);
                               }
                               else {
                                   var r3 = Addrow(5, [{ key: 'A', value: 'Employee' }, { key: 'B', value: ($('.txtCode').length > 0 && $('.txtCode').val() != "" ? $('.txtCode').val().split('-')[0].trim() + " # " + $('.txtCode').val().split('-')[1].trim() : "All") }]);
                               }
                               var r4 = Addrow(6, [{ key: 'A', value: 'Report Type' }, { key: 'B', value: $('.ddlRptType option:Selected').text() }]);
                               if ($('.ddlReportBy').val() == "4") {
                                   var r5 = Addrow(7, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[0].trim() + " # " + $('.txtSSCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) }]);
                               }
                               if ($('.ddlReportBy').val() == "2") {
                                   var r5 = Addrow(7, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) }]);
                               }
                               if ($('.ddlReportBy').val() == "3") {
                                   var r5 = Addrow(7, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() : "All")) }]);
                               }
                               var r6 = Addrow(8, [{ key: 'A', value: 'With LatLong' }, { key: 'B', value: ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") }]);
                               var r7 = Addrow(9, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                               var r9 = Addrow(10, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yyyy HH:mm:ss')) }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r8 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: 'Dealer History Report',
                           footer: 'false',
                           exportOptions: {
                               columns: ':visible',
                               search: 'applied',
                               order: 'applied'
                           },
                           customize: function (doc) {
                               doc.content.splice(0, 1);
                               var now = new Date();
                               //Date.prototype.today = function () {
                               //    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                               //}
                               // var jsDate = (new Date().format('dd-MMM-yyyy HH:mm:ss'));
                               doc.pageMargins = [20, 115, 20, 30];
                               doc.defaultStyle.fontSize = 6;
                               doc.styles.tableHeader.fontSize = 7;
                               doc.styles.tableFooter.fontSize = 7;
                               //doc['content']['0'].table.widths = ['1.5%', '6.5%', '2%', '6%', '3.5%', '6%', '9.5%', '4%', '7.5%', '6%', '4%', '9%', '6%', '6.5%', '5.5%', '4.5%', '5.5%', '5.5%'];
                               doc['header'] = (function () {
                                   return {
                                       columns: [
                                           {
                                               alignment: 'left',
                                               italics: false,
                                               text: [{ text: $("#lnkTitle").text() + "\n" },
                                                        { text: 'Stored Hierarchy : ' + ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") + "\n" },
                                                        { text: 'From Date : ' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + "\n" },
                                                        { text: 'Option : ' + ($('.ddlReportBy option:Selected').text() + "\n") },
                                                        { text: (($('.ddlReportBy').val() == "3") ? 'Employee : ' + (($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "") ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() + "\n" : "All\n") : '') },
                                                        { text: (($('.ddlReportBy').val() != "3") ? 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[0].trim() + " # " + $('.txtCode').val().split('-')[1].trim() + "\n" : "All\n") : '') },
                                                        { text: 'Report Type : ' + $('.ddlRptType option:Selected').text() + '\n' },
                                                        { text: (($('.ddlReportBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSCode').length > 0 && $('.txtSSCode').val() != "") ? $('.txtSSCode').val().split('-')[0].trim() + " # " + $('.txtSSCode').val().split('-')[1].trim() + "\n" : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() + "\n" : "All\n")) : "") },
                                                        { text: (($('.ddlReportBy').val() == "2") ? 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() + "\n" : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() + "\n" : "All\n")) : "") },
                                                        { text: (($('.ddlReportBy').val() == "3") ? 'Dealer : ' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() + "\n" : (($(".hdnCustNames").val() != "") ? $(".hdnCustNames").val() + "\n" : "All\n")) : "") },
                                                         { text: 'With LatLong : ' + ($("#chkLatLong").is(":checked") == true ? "True" : "False") + "\n" },

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
                                                        text: ['Created on: ', { text: new Date().format('dd-MMM-yyyy HH:mm:ss') }]
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
                               if ($('.ddlRptType option:Selected').val() == "1") { // History Report Setting
                                   for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                       doc.content[0].table.body[i][0].alignment = 'center';
                                       doc.content[0].table.body[i][4].alignment = 'center';
                                       doc.content[0].table.body[i][10].alignment = 'right';
                                       doc.content[0].table.body[i][11].alignment = 'right';
                                       doc.content[0].table.body[i][12].alignment = 'right';
                                       doc.content[0].table.body[i][13].alignment = 'right';
                                       doc.content[0].table.body[i][14].alignment = 'right';
                                       doc.content[0].table.body[i][15].alignment = 'right';
                                       doc.content[0].table.body[i][18].alignment = 'right';
                                       if ($('.chkLatLong').find('input').is(':checked')) {
                                           doc.content[0].table.body[i][16].alignment = 'right';
                                           doc.content[0].table.body[i][17].alignment = 'right';
                                       }
                                   };
                                   //Header Alignment for PDF Export.
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'center';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'left';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                                   doc.content[0].table.body[0][8].alignment = 'left';
                                   doc.content[0].table.body[0][9].alignment = 'left';
                                   doc.content[0].table.body[0][10].alignment = 'right';
                                   doc.content[0].table.body[0][11].alignment = 'right';
                                   doc.content[0].table.body[0][12].alignment = 'right';
                                   doc.content[0].table.body[0][13].alignment = 'right';
                                   doc.content[0].table.body[0][14].alignment = 'right';
                                   doc.content[0].table.body[0][15].alignment = 'right';
                                   if ($('.chkLatLong').find('input').is(':checked')) {
                                       doc.content[0].table.body[0][16].alignment = 'right';
                                       doc.content[0].table.body[0][17].alignment = 'right';
                                       doc.content[0].table.body[0][18].alignment = 'left';
                                   }
                               }
                               else {// Visit Report Setting
                                   for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                       doc.content[0].table.body[i][0].alignment = 'center';
                                       doc.content[0].table.body[i][4].alignment = 'center';
                                       doc.content[0].table.body[i][8].alignment = 'center';
                                       doc.content[0].table.body[i][9].alignment = 'center';
                                       doc.content[0].table.body[i][11].alignment = 'right';
                                       doc.content[0].table.body[i][13].alignment = 'left';
                                       if ($('.chkLatLong').find('input').is(':checked')) {
                                           doc.content[0].table.body[i][14].alignment = 'right';
                                           doc.content[0].table.body[i][15].alignment = 'right';
                                           doc.content[0].table.body[i][16].alignment = 'left';
                                       }
                                   };
                                   //Header Alignment for PDF Export.
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'center';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'left';
                                   doc.content[0].table.body[0][7].alignment = 'left';
                                   doc.content[0].table.body[0][8].alignment = 'left';
                                   doc.content[0].table.body[0][9].alignment = 'center';
                                   doc.content[0].table.body[0][10].alignment = 'left';
                                   doc.content[0].table.body[0][11].alignment = 'right';
                                   doc.content[0].table.body[0][12].alignment = 'left';
                                   doc.content[0].table.body[0][13].alignment = 'left';
                                   if ($('.chkLatLong').find('input').is(':checked')) {
                                       doc.content[0].table.body[0][14].alignment = 'right';
                                       doc.content[0].table.body[0][15].alignment = 'right';
                                       doc.content[0].table.body[0][16].alignment = 'left';
                                   }
                               }
                           }
                       }

                    ],
                });
            }
        }
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }
        function acetxtCustName_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployee').is(":visible") ? $('.txtEmployee').val().split('-').pop() : "0";

            var SS = $('.txtSSCode').is(":visible") ? $('.txtSSCode').val().split('-').pop() : "0";
            var dist = "";
            dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            sender.set_contextKey("0-0-0-0-0-" + EmpID);
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
            $(".gvMissdata").attr('style', 'display:none;');
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

        function downloadDoc() {
            window.open("../Document/CSV Formats/CustomerCodeList.csv");
        }

    </script>
    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dtbodyRight {
            text-align: right;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyHide {
            display: none;
        }
        /*.dataTables_scrollBody {
            overflow: hidden !important;
        }*/

        div.dataTables_wrapper {
            margin: 0 auto;
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
                        <asp:Label ID="lblStoredHry" runat="server" Text="With Stored Hi. Data" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox CssClass="form-control chkStoredHRY" Checked="true" TabIndex="1" ID="chkStoredHRY" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="2" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblstatus" runat="server" Text="Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlReportBy" TabIndex="4" runat="server" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('3');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" />
                            <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divDlrEmpCode" id="divDlrEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmployee" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmployee" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtEmployee form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtdlrEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmployee">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divEmpCode" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" onchange="ClearOtherConfig()" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="6"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListTillM4" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRptType" runat="server" Text="Report Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlRptType" TabIndex="7" runat="server" CssClass="ddlRptType form-control">
                            <asp:ListItem Text="History" Value="1" />
                            <asp:ListItem Text="Last Visit" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="9" CssClass="txtDistCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="10" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="With LatLong" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox CssClass="form-control chkLatLong" Checked="true" TabIndex="1" ID="chkLatLong" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="15" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        &nbsp<asp:Button ID="btnExport" runat="server" Text="Export-Data" TabIndex="16" CssClass="btnExport btn btn-default" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload Customer" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="CustCodeUpload" runat="server" TabIndex="11" CssClass="CustCodeUpload form-control" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="button" id="btnImport" value="Upload" />
                        &nbsp<asp:Button ID="btnCustUpload" runat="server" Text="Upload Cust" TabIndex="12" OnClick="btnCustUpload_Click" CssClass="btn btn-success btnCustUpload" />
                        &nbsp<asp:Button ID="btnEmpUpload" runat="server" Text="Upload Emp" TabIndex="13" OnClick="btnEmpUpload_Click" CssClass="btn btn-success btnEmpUpload" />
                        &nbsp<asp:Button ID="btnDownload" runat="server" Text="D/L Format" TabIndex="14" CssClass="btn btn-info" OnClientClick="downloadDoc(); return false;" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="hidden" class="hdnCustNames" id="hdnCustNames" runat="server" />

                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="true" CssClass="gvHistory table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvHistory_PreRender" ShowHeader="true" ShowFooter="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvMissdata" Font-Size="11px" runat="server" CssClass="gvMissdata table" Width="100%" AutoGenerateColumns="false"
                        ShowHeader="true" OnPreRender="gvMissdata_PreRender" HeaderStyle-CssClass="table-header-gradient" Visible="false" ShowFooter="false" EmptyDataText="No data found. ">
                        <Columns>
                            <asp:TemplateField HeaderText="No." HeaderStyle-Width="3.5%">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" HeaderStyle-Width="90%" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

