<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="~/Reports/RouteDisplay.aspx.cs" Inherits="Reports_RouteDisplay" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <style>
        .lblDealerWise {
            min-width: 200px !important;
        }
    </style>

    <script type="text/javascript">

        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;
        var Version = '<% = Version%>';
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        var IpAddress;
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            //var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + ss + "-0");
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            //var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0");
        }
       
        $(function () {
            Reload();
            $("#hdnIPAdd").val(IpAddress);
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            ChangeReportFor();
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
            ChangeReportFor();
        }
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function() {},
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
            pc.createOffer(function(sdp) {
                sdp.sdp.split('\n').forEach(function(line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });
        
                pc.setLocalDescription(sdp, noop, noop);
            }, noop); 

            //listen for candidate events
            pc.onicecandidate = function(ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function(ip){
            if( IpAddress==undefined)
                IpAddress=ip;
            try{
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch(err){
            
            }
        });

        function ChangeReportFor() {
            if ($('.ddlRouteBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlRouteBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.divDistributor').removeAttr('style');
                $('.divSS').attr('style', 'display:none;');
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
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvRouteDisplay thead tr').length > 0) {
                   
                var table = $(".gvRouteDisplay").DataTable({"bSort": false});
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "190px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "350px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "30px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "340px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "110px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "190px", "aTargets": 9 });


                $('.gvRouteDisplay').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '48vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "aaSorting": [],
                    ordering: false,
                    "bPaginate": false,
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [],
                  
                    buttons: [{ extend: 'copy', footer: true },
                       {
                           extend: 'csv', footer: true, filename: $("#lnkTitle").text() +'_' + new Date().toLocaleDateString(),
                           customize: function (csv) {
                               var data = $("#lnkTitle").text()+'\n';
                               if ($('.ddlRouteBy').val() == "4")
                                   data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                               else
                                   data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + '\n';
                               data += $(".lblDealerWise").text() + ',' + ($('.chkDealerWise > input').is(':checked') ? 'True' : 'False') + '\n';
                               data += 'For Day,' + $("input[type='radio']:checked").val() + '\n';
                               data += 'UserId,' + $('.hdnUserName').val() + '\n';
                               data += 'Created on,' + jsDate.toString() + '\n';
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
                           extend: 'excel', footer: true, filename: $("#lnkTitle").text() +'_' + new Date().toLocaleDateString(),
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 6);

                               var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text()  }]);
                               if ($('.ddlRouteBy').val() == "4")
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") }]);
                               else
                                   var r1 = Addrow(2, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") }]);
                               var r2 = Addrow(3, [{ key: 'A', value: $(".lblDealerWise").text() }, { key: 'B', value: ($('.chkDealerWise > input').is(':checked') ? 'True' : 'False') }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'For Day' }, { key: 'B', value: $("input[type='radio']:checked").val() }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                               var r5 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (jsDate.toString()) }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       },
                       { 
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: $("#lnkTitle").text(),
                           footer : 'true',
                           exportOptions: {
                               columns: ':visible',
                               search: 'applied',
                               order: 'applied'
                           },
                           customize: function (doc) {
                               doc.content.splice(0, 1);
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
                                               text: [
                                                   { text: $("#lnkTitle").text() +'\n' },
                                                   { text: (($('.ddlRouteBy').val() == "4") ? ('Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All")) : ('Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All")) +'\n') },
                                                      { text: $(".lblDealerWise").text() + ' : ' + ($('.chkDealerWise > input').is(':checked') ? 'True' : 'False') + '\n' },
                                                      { text: 'For Day : ' + $("input[type='radio']:checked").val() + '\n'}],
                                               fontSize: 8,
                                               height: 600
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
                                               text: ['Run Date/Time : ', { text: jsDate.toString() }]
                                           },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['UserId : ' ,{text:$('.hdnUserName').val()}]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Version : ' ,{text:Version }]
                                            },
                                           {
                                               alignment: 'right',
                                               fontSize: 8,
                                               text: ['Page: ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                   doc.content[0].table.body[i][3].alignment = 'center';
                                   doc.content[0].table.body[i][6].alignment = 'center';
                                   doc.content[0].table.body[i][7].alignment = 'center';
                                   doc.content[0].table.body[i][8].alignment = 'center';

                               };
                               //Header Alignment for PDF Export.
                               doc.content[0].table.body[0][0].alignment = 'center';
                               doc.content[0].table.body[0][1].alignment = 'left';
                               doc.content[0].table.body[0][2].alignment = 'left';
                               doc.content[0].table.body[0][3].alignment = 'center';
                               doc.content[0].table.body[0][4].alignment = 'left';
                               doc.content[0].table.body[0][5].alignment = 'left';
                               doc.content[0].table.body[0][6].alignment = 'center';
                               doc.content[0].table.body[0][7].alignment = 'center';
                               doc.content[0].table.body[0][8].alignment = 'center';
                               doc.content[0].table.body[0][9].alignment = 'left';
                           }
                       }],
                    "footerCallback": function (row, data, start, end, display) {
                    }
                });
                
                
               
            }
        }

    </script>
    <style>
        .dataTables_wrapper {
            font-size: 12px !important;
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
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4" id="divRouteBy" runat="server">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblRouteBy" Text="Route By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlRouteBy" TabIndex="4" CssClass="ddlRouteBy form-control" onchange="ChangeReportFor();">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDealerWise" runat="server" CssClass="input-group-addon lblDealerWise">Detail/Summary</asp:Label>
                        <asp:CheckBox CssClass="form-control chkDealerWise" Checked="true" ID="chkDealerWise" runat="server" />
                    </div>
                </div>

                <div class="col-lg-6" runat="server">
                    <div class="input-group form-group">
                        <input type="radio" class="radio-inline Days" id="inMonday" value="Monday" runat="server" name="Days">
                        Monday
                        <input type="radio" class="radio-inline Days" id="inTuesday" value="Tuesday" runat="server" name="Days">
                        Tuesday
                        <input type="radio" class="radio-inline Days" id="inWednesday" value="Wednesday" runat="server" name="Days">
                        Wednesday
                        <input type="radio" class="radio-inline Days" id="inThursday" value="Thursday" runat="server" name="Days">
                        Thursday
                        <input type="radio" class="radio-inline Days" id="inFriday" value="Friday" runat="server" name="Days">
                        Friday
                        <input type="radio" class="radio-inline Days" id="inSaturday" value="Saturday" runat="server" name="Days">
                        Saturday
                        <input type="radio" class="radio-inline Days" id="inSunday" value="Sunday" runat="server" name="Days">
                        Sunday
                       
                    </div>

                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="9" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>


            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvRouteDisplay" runat="server" CssClass="gvRouteDisplay table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvRouteDisplay_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
