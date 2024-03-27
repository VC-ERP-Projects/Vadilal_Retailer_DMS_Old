<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CustomerFeedBack.aspx.cs" Inherits="CustomerFeedBack" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var IpAddress;
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            $("#hdnIPAdd").val(IpAddress);
        });

        function EndRequestHandler2(sender, args) {
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

        function ChangelabelFor() {
            if ($('.ddlFeedbackOf').val() == "4") {

                $('#lblRegion').text('Region of Super Stockist ');
            }
            else if ($('.ddlFeedbackOf').val() == "2") {
                $('#lblRegion').text('Region of Distributor');
            }
            else if ($('.ddlFeedbackOf').val() == "3") {
                $('#lblRegion').text('Region of Dealer');
            }
        }

            function _btnCheck() {
                var IsValid = true;
                if (!$('._masterForm').data('bootstrapValidator').isValid())
                    $('._masterForm').bootstrapValidator('validate');
                IsValid = $('._masterForm').data('bootstrapValidator').isValid();
                return IsValid;
            }

            function autoCompleteState_OnClientPopulating(sender, args) {
                var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
                sender.set_contextKey(EmpID);
            }

            function autoCompleteBeatEmployee_OnClientPopulating(sender, args) {
                var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
                sender.set_contextKey(EmpID);
            }

            function ClearOtherConfig() {
                if ($(".txtCode").length > 0) {
                    $(".txtRegion").val('');
                    $(".txtfeedtakenby").val('');
                    $(".txtBeatEmp").val('');
                }
            }
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Report Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReport"  runat="server" CssClass="ddlReport form-control" TabIndex="1">
                            <asp:ListItem Text="Feedback Master Listing" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Feedback Taken Report" Value="2"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" onchange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-4" id="divTakenBy" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblTakenby" runat="server" Text="Feedback Taken By" CssClass="lblTakenby input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtfeedtakenby" onchange="ClearfeedtakenbyConfig()" runat="server" CssClass="form-control txtfeedtakenby" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListIncludingSelfEmpData" MinimumPrefixLength="1" CompletionInterval="10"
                            OnClientPopulating="autoCompleteBeatEmployee_OnClientPopulating" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtfeedtakenby">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divBeatEmp" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblBeatEmployee" runat="server" Text="Beat Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBeatEmp" onchange="ClearBeatEmployeeConfig()" runat="server" CssClass="form-control txtBeatEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListIncludingSelfEmpData" MinimumPrefixLength="1" CompletionInterval="10"
                            OnClientPopulating="autoCompleteBeatEmployee_OnClientPopulating" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtBeatEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblFeedbackOf" Text="Feedback Of" CssClass="lblFeedbackOf input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlFeedbackOf" TabIndex="5" CssClass="ddlFeedbackOf form-control" onchange="ChangelabelFor();">
                            <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                            <asp:ListItem Text="Distributor" Value="2" />
                            <asp:ListItem Text="Super Stockist" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <label id="lblRegion" class="input-group-addon">Region of Dealer</label>
                        <asp:TextBox ID="txtRegion" onchange="ClearRegionConfig()" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="6"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="lblFromDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="7" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="lblToDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="8" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Text="Export To Excel" ID="btnGenerat" TabIndex="9" CssClass="btn btn-default" runat="server" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

