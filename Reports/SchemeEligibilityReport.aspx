<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SchemeEligibilityReport.aspx.cs" Inherits="Reports_SchemeEligibilityReport" EnableEventValidation="false" %>

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
        var IpAddress;
        var imagebase64 = "";
       // var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
            }
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
        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + "0" + "-" + dist + "-" + EmpID);
        }

        $(function () {
            $("#hdnIPAdd").val(IpAddress);
            Reload();
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
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
        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function EndRequestHandler2(sender, args) {
            Reload();
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
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvSchemeEligible thead tr').length > 0) {

                var table = $(".gvSchemeEligible").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "170px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "160px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "110px", "sClass": "dtbodyCenter", "aTargets": 4 });
                aryJSONColTable.push({ "width": "55px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 7 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "110px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyRight", "sClass": "dtbodyRight", "aTargets": 12 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "170px", "aTargets": 14 });

                $('.gvSchemeEligible').DataTable({
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
                               data += 'From Date,' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + ',To Date,' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + '\n';
                               data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'Dist. Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'Division,' + $('.ddlDivision option:Selected').text() + '\n';
                               data += 'QPS Scheme,' + ($('.txtScheme').val() != "" ? $('.txtScheme').val().split('-').slice(0, 2) : "All") + '\n';
                               data += 'User Name,' + $('.hdnUserName').val() + '\n';
                               data += 'Created on,\'' + new Date().format('dd-MMM-yy HH:mm') + '\n';
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

                               sheet = ExportXLS(xlsx, 10);

                               var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To Date' }, { key: 'D', value: $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'Dist. Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').slice(0, 2) : "All") }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                               var r5 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") }]);
                               var r6 = Addrow(7, [{ key: 'A', value: 'Division' }, { key: 'B', value: ($('.ddlDivision option:Selected').text()) }]);
                               var r7 = Addrow(8, [{ key: 'A', value: 'QPS Scheme' }, { key: 'B', value: ($('.txtScheme').val() != "" ? $('.txtScheme').val().split('-').slice(0, 2) : "All") }]);
                               var r8 = Addrow(9, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                               var r9 = Addrow(10, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                               doc.pageMargins = [20, 130, 20, 30];
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
                                                      { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                      { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'Dist. Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'Dealer : ' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'Division : ' + ($('.ddlDivision option:Selected').text()) + '\n' },
                                                      { text: 'QPS Scheme : ' + (($('.txtScheme').length > 0 && $('.txtScheme').val() != "") ? $('.txtScheme').val().split('-').slice(0, 2) : "All") + '\n' },
                                                      { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
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
                                   doc.content[0].table.body[i][4].alignment = 'center';
                                   doc.content[0].table.body[i][5].alignment = 'right';
                                   doc.content[0].table.body[i][7].alignment = 'center';
                                   doc.content[0].table.body[i][8].alignment = 'right';
                                   doc.content[0].table.body[i][9].alignment = 'right';
                                   doc.content[0].table.body[i][12].alignment = 'right';
                               };
                               doc.content[0].table.body[0][0].alignment = 'center';
                               doc.content[0].table.body[0][1].alignment = 'left';
                               doc.content[0].table.body[0][2].alignment = 'left';
                               doc.content[0].table.body[0][3].alignment = 'left';
                               doc.content[0].table.body[0][4].alignment = 'center';
                               doc.content[0].table.body[0][5].alignment = 'right';
                               doc.content[0].table.body[0][6].alignment = 'left';
                               doc.content[0].table.body[0][7].alignment = 'center';
                               doc.content[0].table.body[0][8].alignment = 'right';
                               doc.content[0].table.body[0][9].alignment = 'right';
                               doc.content[0].table.body[0][10].alignment = 'left';
                               doc.content[0].table.body[0][11].alignment = 'left';
                               doc.content[0].table.body[0][12].alignment = 'right';
                               doc.content[0].table.body[0][13].alignment = 'left';
                               doc.content[0].table.body[0][14].alignment = 'left';

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
                    }
                });
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

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
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
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Dist. Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" TabIndex="4" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtDist" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetDistCurrHierarchy" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="7" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="QPS Scheme" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtScheme" CssClass="txtScheme form-control" Style="background-color: rgb(250, 255, 189);" TabIndex="8" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtScheme" runat="server" ServiceMethod="GetQPSScheme"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtScheme" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="9" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvSchemeEligible" runat="server" CssClass="gvSchemeEligible table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvSchemeEligible_PreRender" ShowFooter="false" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
