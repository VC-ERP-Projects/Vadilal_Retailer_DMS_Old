<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimDocDownload.aspx.cs" Inherits="Reports_ClaimDocDownload" %>

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
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        var IpAddress;
        $(function () {
            ReLoadFn();
            $("#hdnIPAdd").val(IpAddress);
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
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
        function ChangeReportFor(SelType) {

            if ($('.ddlSaleBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
               $('.divDistributor').removeAttr('style');
            }

        }

        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });
            $(".onlymonth").on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });


            if ($('.gvCommon thead tr').length > 0) {
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyleft", "aTargets": 1 });
                aryJSONColTable.push({ "width": "200px", "sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "150px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "130px", "sClass": "dtbodyleft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 6 });
                aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 7 });
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
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,

                });
            }
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
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
            sender.set_contextKey("0-0-0-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtDealerCode").val('');
                $(".txtSSCode").val('');
            }
        }
        function ClearOtherDistConfig() {
            if ($(".txtDistCode").length > 0) {
                $(".txtDealerCode").val('');
            }
        }
        function ClearOtherSSConfig() {
            if ($(".txtSSCode").length > 0) {
                $(".txtDistCode").val('');
            }
        }

        function OpenItemImage(ClaimId, ParentId, IsDownload) {
            if (IsDownload == 0) {
                $.colorbox({
                    width: '40%',
                    height: '40%',
                    iframe: true,
                    href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=' + IsDownload
                });
            }
            else {
                window.location.assign('../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=' + IsDownload)
                //$.colorbox({
                //    width: '40%',
                //    height: '40%',
                //    iframe: true,
                //    href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=' + IsDownload
                //});
                
            }
        }
        function btnGenerat_Click() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
    <style>
        .cb-flex {
            display: flex;
            flex-wrap: wrap;
            width: 380px;
        }

            .cb-flex .wj-listbox-item {
                width: 120px;
                white-space: pre;
                overflow: hidden;
                text-overflow: ellipsis;
            }

        .wj-listbox-item table {
            table-layout: fixed;
        }

        .wj-listbox-item td {
            width: 120px;
            white-space: pre;
            overflow: hidden;
            text-overflow: ellipsis;
        }

            .wj-listbox-item td.number {
                width: 80px;
                text-align: right;
            }

        label {
            margin-right: 3px;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding: 0px 5px !important;
        }

        table {
            table-layout: inherit;
        }

            /*th {
            text-align: center !important;
        }*/

            table.dataTable tbody th, table.dataTable tbody td {
                padding: 0px 4px !important;
            }

            table.dataTable tfoot th {
                padding: 0px 18px 6px 18px !important;
              /*  border-top: 1px solid #111;*/
            }

            table.dataTable tfoot td {
                padding: 0px 4px !important;
               /* border-top: 1px solid #111;*/
            }


        .ui-datepicker-calendar {
            display: none;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        .dtbodyleft {
            text-align: left !important;
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

        #body_gvCommon_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
          /*  border: 1px solid black;*/
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 900px;
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
                width: 900px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollBody {
                width: 900px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollFoot {
                width: 900px !important;
            }

            #body_gvCommon_wrapper .dataTables_scrollFootInner {
                width: 900px !important;
            }

            .dtbodyRight {
                text-align: right;
            }

            .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
                /*padding-left: 4px !important;*/
                /*padding: 0px 0 0 4px !important;*/
                padding: 0px;
                vertical-align: middle !important;
                /*white-space: nowrap;*/
                /*overflow-x: scroll;*/
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
                        <asp:Label ID="lblDate" runat="server" Text="From Month" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control txtDate"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="To Month" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtToDate" TabIndex="2" runat="server" MaxLength="7" CssClass="onlymonth form-control txtToDate"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltype" runat="server" Text="Claim Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlMode" runat="server" TabIndex="3" CssClass="form-control cb-flex"></asp:DropDownList>

                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" OnChange="ClearOtherConfig()" TabIndex="4" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="5" CssClass="ddlSaleBy form-control" OnChange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSCode" OnChange="ClearOtherSSConfig()" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" OnChange="ClearOtherDistConfig()" runat="server" TabIndex="7" CssClass="txtDistCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="8" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="9" CssClass="btn btn-default" OnClick="btnGenerat_Click" OnClientClick="return btnGenerat_Click();" />
                    </div>
                </div>
            </div>
           
                    <asp:GridView ID="gvCommon" runat="server" CssClass="gvCommon nowrap table" Style="font-size: 11px; margin-left: 0px; border:none;" OnPreRender="gvCommon_PreRender" ShowFooter="True" AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. " OnRowCommand="gvCommon_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="Sr.">
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                    <input type="hidden" id="hdnParentID" runat="server" value='<%# Eval("ParentID") %>' />
                                    <asp:HiddenField ID="hdnParentClaimID" runat="server" Value='<%# Eval("ParentClaimID") %>' />
                                    <asp:HiddenField ID="hdnCustomerID" runat="server" Value='<%# Eval("ParentID") %>' />
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Code" DataField="CustomerCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                            <asp:BoundField HeaderText="Name" DataField="CustomerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                            <asp:BoundField HeaderText="City" DataField="CityName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                            <asp:BoundField HeaderText="Year / Month" DataField="YearMonth" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                            <asp:BoundField HeaderText="Claim Type" DataField="ReasonName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" />
                            <asp:TemplateField HeaderText="View">
                                <ItemTemplate>
                                    <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Download">
                                <ItemTemplate>
                                    <asp:Button ID="lbldownloadimg" Text="Download" CommandName="Download" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                
                
        </div>
    </div>
</asp:Content>

