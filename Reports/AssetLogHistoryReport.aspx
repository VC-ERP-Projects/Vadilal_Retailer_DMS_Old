<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="AssetLogHistoryReport.aspx.cs" Inherits="Reports_AssetLogHistoryReport" %>

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
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function EndRequestHandler2(sender, args) {
            Reload();

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

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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

        function Reload() {

            if ($('.gvAssetLog thead tr').length > 0) {

                var now = new Date();

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "5%", "sClass": "dtbodyCenter", "aTargets": 0 }); ////Sr
                aryJSONColTable.push({ "width": "14%", "aTargets": 1 }); ////Asset Sr.No.
                aryJSONColTable.push({ "width": "7%", "sClass": "dtbodyCenter", "aTargets": 2 });////LGM Date
                aryJSONColTable.push({ "width": "30%", "aTargets": 3 });////From Code & Name
                aryJSONColTable.push({ "width": "13%", "aTargets": 4 });////From Code City
                aryJSONColTable.push({ "width": "7%", "sClass": "dtbodyCenter", "aTargets": 5 });////Lifting Date
                aryJSONColTable.push({ "width": "5%", "sClass": "dtbodyRight", "aTargets": 6 });////Kept Days
                aryJSONColTable.push({ "width": "30%", "aTargets": 7 });////To Code & Name
                aryJSONColTable.push({ "width": "13%", "aTargets": 8 });////To Code City
                aryJSONColTable.push({ "width": "12%", "sClass": "dtbodyCenter", "aTargets": 9 });////Synced Date/Time

                $('.gvAssetLog').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '63vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": true,
                    "bSort": false,  // To Remove All Sorting.
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [
                       {
                           extend: 'csv',
                           footer: true,
                           filename: $("#lnkTitle").text(),
                           customize: function (csv) {
                               var data = $("#lnkTitle").text() + '\n';
                               data += 'From,' + $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) + ',To,' + $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) + '\n';
                               data += 'Asset Serial No,' + $('.txtSerialNo').val() + '\n';
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
                           filename: $("#lnkTitle").text(),
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 5);

                               var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'From' }, { key: 'B', value: $.datepicker.formatDate('dd-M-yy', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To' }, { key: 'D', value: $.datepicker.formatDate('dd-M-yy', $('.todate').datepicker('getDate')) }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Asset Serial No' }, { key: 'B', value: $('.txtSerialNo').val() }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yyyy HH:mm:ss')) }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: $("#lnkTitle").text(),
                           footer: 'false',
                           exportOptions: {
                               columns: ':visible',
                               search: 'applied',
                               order: 'applied'
                           },
                           customize: function (doc) {
                               doc.content.splice(0, 1);
                               var now = new Date();
                               doc.pageMargins = [20, 70, 20, 30];
                               doc.defaultStyle.fontSize = 6;
                               doc.styles.tableHeader.fontSize = 7;
                               doc.styles.tableFooter.fontSize = 7;
                               doc['header'] = (function () {
                                   return {
                                       columns: [
                                           {
                                               alignment: 'left',
                                               italics: false,
                                               text: [{ text: $("#lnkTitle").text() + "\n" },
                                                        { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                        { text: 'Asset Serial No : ' + (($('.txtSerialNo').length > 0 && $('.txtSerialNo').val() != "") ? $('.txtSerialNo').val() : "All") + "\n" },
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

                               for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                   doc.content[0].table.body[i][0].alignment = 'center';
                                   doc.content[0].table.body[i][2].alignment = 'center';
                                   doc.content[0].table.body[i][5].alignment = 'center';
                                   doc.content[0].table.body[i][6].alignment = 'right';
                                   doc.content[0].table.body[i][9].alignment = 'center';

                               };
                               //Header Alignment for PDF Export.
                               doc.content[0].table.body[0][0].alignment = 'center';
                               doc.content[0].table.body[0][1].alignment = 'left';
                               doc.content[0].table.body[0][2].alignment = 'center';
                               doc.content[0].table.body[0][3].alignment = 'left';
                               doc.content[0].table.body[0][4].alignment = 'left';
                               doc.content[0].table.body[0][5].alignment = 'center';
                               doc.content[0].table.body[0][6].alignment = 'right';
                               doc.content[0].table.body[0][7].alignment = 'left';
                               doc.content[0].table.body[0][8].alignment = 'left';
                               doc.content[0].table.body[0][9].alignment = 'center';
                           }
                       }
                    ],
                });
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

        /*.dataTables_scrollBody {
            overflow: hidden !important;
        }*/

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable thead th, table.dataTable thead td, table.dataTable tbody td, table.dataTable tfoot td {
            padding: 5px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">From Date</label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">To Date</label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSerialNo" runat="server" Text="Asset Serial No" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSerialNo" TabIndex="3" runat="server" CssClass="txtSerialNo form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender4" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSerialNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="4" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvAssetLog" runat="server" CssClass="gvAssetLog table tbl " Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvAssetLog_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found.">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
