<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetScanOrderRpt.aspx.cs" Inherits="Reports_AssetScanOrderRpt" %>

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
        $(function () {
            Reload();
            $("#hdnIPAdd").val(IpAddress);
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

        function ClearOtherConfig() {
            if ($(".txtEmployee").length > 0 || $(".txtEmployee").length > 0) {
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtDistRegion").val('');
            }
        }
        function Reload() {
            //$(".gvAssetOrderList").tableHeadFixer('70vh');

            if ($('.gvAssetOrderList thead tr').length > 0) {
                var table = $(".gvAssetOrderList").DataTable();
                var colCount = table.columns()[0].length;

                var now = new Date();

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "85px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyCenter", "aTargets": 3 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "120px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "52px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyCenter", "aTargets": 13 });
                aryJSONColTable.push({ "width": "48px", "aTargets": 14 });
                if ($('.chkLatLong').find('input').is(':checked')) {
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 15 });
                    aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 16 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 17 });
                    aryJSONColTable.push({ "width": "300px", "aTargets": 18 });
                }
                else {
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 15 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 16 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 17 });
                    aryJSONColTable.push({ "sClass": "dtbodyHide", "aTargets": 18 });
                }
                $('.gvAssetOrderList').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": false,
                    "bSort": false,  // To Remove All Sorting.
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                       {
                           extend: 'csv',
                           footer: true,
                           filename: 'Asset Scan Order Report',
                           customize: function (csv) {
                               var data = 'Asset Scan Order Report' + '\n';
                               data += 'Stored Hierarchy,' + ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") + '\n';
                               data += 'From,' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + ',To,' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + '\n';
                               data += 'Employee,' + ($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "" ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() : "All") + '\n';
                               data += 'Dist. Region,' + ($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "" ? $('.txtDistRegion').val().split('-')[0].trim() + " # " + $('.txtDistRegion').val().split('-')[1].trim() : "All") + '\n';
                               data += 'Distributor,' + ($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "" ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : "All") + '\n';
                               data += 'Customer,' + ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : "All") + '\n';
                               data += 'With LatLong,' + ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") + '\n';
                               data += 'UserId,' + $('.hdnUserName').val() + '\n';
                               data += 'Created on,\'' + new Date().format('dd-MMM-yy HH:mm') + '\n';
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
                           filename: 'Asset Scan Order Report',
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 9);

                               var r0 = Addrow(1, [{ key: 'A', value: 'Asset Scan Order Report' }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'Stored Hierarchy' }, { key: 'B', value: ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'From' }, { key: 'B', value: $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To' }, { key: 'D', value: $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "") ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() : "All") }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Dist. Region' }, { key: 'B', value: (($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "") ? $('.txtDistRegion').val().split('-')[0].trim() + " # " + $('.txtDistRegion').val().split('-')[1].trim() : "All") }]);
                               var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : "All") }]);
                               var r6 = Addrow(7, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : "All") }]);
                               var r7 = Addrow(8, [{ key: 'A', value: 'With LatLong' }, { key: 'B', value: ($('.chkLatLong').find('input').is(':checked') ? "True" : "False") }]);
                               var r8 = Addrow(9, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                               var r9 = Addrow(10, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r8 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: 'Asset Scan Order Report',
                           footer: 'false',
                           exportOptions: {
                               columns: ':visible',
                               search: 'applied',
                               order: 'applied'
                           },
                           customize: function (doc) {
                               doc.content.splice(0, 1);
                               var now = new Date();
                               doc.pageMargins = [20, 115, 20, 30];
                               doc.defaultStyle.fontSize = 5;
                               doc.styles.tableHeader.fontSize = 6;
                               doc.styles.tableFooter.fontSize = 6;
                               doc['header'] = (function () {
                                   return {
                                       columns: [
                                           {
                                               alignment: 'left',
                                               italics: false,
                                               text: [{ text: $("#lnkTitle").text() + "\n" },
                                                        { text: 'Stored Hierarchy : ' + ($("#chkStoredHRY").is(":checked") == true ? "Yes" : "No") + "\n" },
                                                        { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                        { text: ('Employee : ' + (($('.txtEmployee').length > 0 && $('.txtEmployee').val() != "") ? $('.txtEmployee').val().split('-')[0].trim() + " # " + $('.txtEmployee').val().split('-')[1].trim() + "\n" : "All\n")) },
                                                        { text: ('Dist. Region : ' + (($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "") ? $('.txtDistRegion').val().split('-')[0].trim() + " # " + $('.txtDistRegion').val().split('-')[1].trim() + "\n" : "All\n")) },
                                                        { text: ('Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() + "\n" : "All\n")) },
                                                        { text: ('Customer : ' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() + "\n" : "All\n")) },
                                                        { text: 'With LatLong : ' + ($('.chkLatLong').find('input').is(':checked') ? "True" : "False" + "\n") }
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
                               for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                   doc.content[0].table.body[i][0].alignment = 'center';
                                   doc.content[0].table.body[i][3].alignment = 'center';
                                   doc.content[0].table.body[i][8].alignment = 'right';
                                   doc.content[0].table.body[i][9].alignment = 'right';
                                   doc.content[0].table.body[i][12].alignment = 'right';
                                   doc.content[0].table.body[i][13].alignment = 'center';
                                   if ($('.chkLatLong').find('input').is(':checked')) {
                                       doc.content[0].table.body[i][15].alignment = 'right';
                                       doc.content[0].table.body[i][16].alignment = 'right';
                                   }
                               };
                               doc.content[0].table.body[0][0].alignment = 'center';
                               doc.content[0].table.body[0][1].alignment = 'left';
                               doc.content[0].table.body[0][2].alignment = 'left';
                               doc.content[0].table.body[0][3].alignment = 'center';
                               doc.content[0].table.body[0][4].alignment = 'left';
                               doc.content[0].table.body[0][5].alignment = 'left';
                               doc.content[0].table.body[0][6].alignment = 'left';
                               doc.content[0].table.body[0][7].alignment = 'left';
                               doc.content[0].table.body[0][8].alignment = 'right';
                               doc.content[0].table.body[0][9].alignment = 'right';
                               doc.content[0].table.body[0][10].alignment = 'left';
                               doc.content[0].table.body[0][11].alignment = 'left';
                               doc.content[0].table.body[0][12].alignment = 'right';
                               doc.content[0].table.body[0][13].alignment = 'center';
                               doc.content[0].table.body[0][14].alignment = 'left';
                               if ($('.chkLatLong').find('input').is(':checked')) {
                                   doc.content[0].table.body[0][15].alignment = 'right';
                                   doc.content[0].table.body[0][16].alignment = 'right';
                                   doc.content[0].table.body[0][17].alignment = 'left';
                                   doc.content[0].table.body[0][18].alignment = 'left';
                               }
                           }
                       }
                    ],
                });
            }
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployee').is(":visible") ? $('.txtEmployee').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployee').is(":visible") ? $('.txtEmployee').val().split('-').pop() : "0";
            var Region = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";

            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployee').is(":visible") ? $('.txtEmployee').val().split('-').pop() : "0";
            var reg = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
            var dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            sender.set_contextKey(reg + "-0-" + "0" + "-" + "0" + "-" + dist + "-" + EmpID);
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

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable tbody th, table.dataTable tbody td, table.dataTable thead th, table.dataTable thead td, table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 3px 5px;
        }

        .dtbodyHide {
            display: none;
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
                <div class="col-lg-4 divDlrEmpCode" id="divDlrEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmployee" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmployee" runat="server" onchange="ClearOtherConfig()" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtEmployee form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtdlrEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmployee">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Dist. Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistRegion" CssClass="txtDistRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetDistributorRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDistRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
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
                        <asp:Label ID="lbldealer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="7" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
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
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="8" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvAssetOrderList" runat="server" AutoGenerateColumns="true" CssClass="gvAssetOrderList table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvAssetOrderList_PreRender" ShowHeader="true" ShowFooter="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

