<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimRegister.aspx.cs" Inherits="Reports_ClaimRegister" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
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
        }
        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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

    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDate" runat="server" Text="Month" CssClass="input-group-addon" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:Label>
                        <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="7" CssClass="onlymonth form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbltype" runat="server" Text="Claim Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlMode" runat="server" TabIndex="2" CssClass="form-control cb-flex"></asp:DropDownList>
                         
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" OnChange="ClearOtherConfig()" TabIndex="3" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDisplay" runat="server" Text="Display" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlClaimStatus" TabIndex="4" CssClass="form-control">
                            <asp:ListItem Text="---- Select ----" Value="0" Selected="True" />
                            <asp:ListItem Text="Pending" Value="1" />
                            <asp:ListItem Text="Error" Value="2" />
                            <asp:ListItem Text="Success" Value="3" />
                            <asp:ListItem Text="InProcess" Value="4" />
                            <asp:ListItem Text="Delete" Value="6" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
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
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
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
                        <asp:Label runat="server" ID="lblItemDetail" Text="Item Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox runat="server" ID="chkItemDetail" Checked="true" TabIndex="9" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="10" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button ID="btnExport" runat="server" Text="Export to Excel" TabIndex="11" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
        </div>
        <div class="embed-responsive embed-responsive-16by9">
            <iframe id="ifmMaterialPurchase" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmMaterialPurchase_Load"></iframe>
        </div>
    </div>
</asp:Content>

