<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CompetitorMasterVisitRpt.aspx.cs" Inherits="Reports_CompetitorMasterVisitRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var CustType = '<% =CustType%>';
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

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            if ($('.txtRegion').val() != undefined || $('.txtPlant').val() != undefined || $('.txtCode').val() != undefined) {
                var reg = $('.txtRegion').val().split('-').pop();
                var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            }
            sender.set_contextKey(reg + "-0-0" + plt + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }
        function autoCompleteCompetitor_OnClientPopulating(sender, args) {
            var EmpID = ($('.txtCode').val() != "") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = ($('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').pop() : "0";
            var CreatedEmpID = ($('.txtCreatedEmp').val() != "") ? $('.txtCreatedEmp').val().split('-').pop() : "0";
            var BeatEmpID = ($('.txtBeatEmp').val() != "") ? $('.txtBeatEmp').val().split('-').pop() : "0";
            var Dist = ($('.txtDistCode').is(":visible") ? ($('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').pop() : "0" : "0");
            sender.set_contextKey(EmpID + "-" + Region + "-" + CreatedEmpID + "-" + BeatEmpID + "-0-" + Dist + "-" + $('.ddlReport').val());
        }
        function autoCompleteBeatEmployee_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }


        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtCreatedEmp").val('');
                $(".txtBeatEmp").val('');
                if (CustType == 1)
                    $(".txtDistCode").val('');
                $(".txtCompetitorCode").val('');
            }
        }
        function ClearRegionConfig() {
            if ($(".txtRegion").length > 0) {
                if (CustType == 1)
                    $(".txtDistCode").val('');
                $(".txtCompetitorCode").val('');
            }
        }
        function ClearDistConfig() {
            if ($(".txtDistCode").length > 0) {
                $(".txtCompetitorCode").val('');
            }
        }
        function ClearCreatedByConfig() {
            if ($(".txtCreatedEmp").length > 0) {
                $(".txtCompetitorCode").val('');
            }
        }
        function ClearBeatEmployeeConfig() {
            if ($(".txtBeatEmp").length > 0) {
                $(".txtCompetitorCode").val('');
            }
        }

        function ddlReportChange() {
            $(".txtCode").val('');
            $(".txtRegion").val('');
            $(".txtCreatedEmp").val('');
            $(".txtBeatEmp").val('');
            $(".txtCompetitorCode").val('');
            if (CustType == 1)
                $(".txtDistCode").val('');
            if ($('.ddlReport').val() == "1") {
                $(".lblFromDate").text("Created Period From");
                $(".lblToDate").text("Created Period To");
                $(".lblCreatedEmployee").text("Created By");
                //$('.btnExpPDF').attr('style', 'display:none');
            }
            else {
                $(".lblFromDate").text("Visited Period From");
                $(".lblToDate").text("Visited Period To");
                $(".lblCreatedEmployee").text("Visited By");
                //$('.btnExpPDF').removeAttr("style");
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
                        <asp:DropDownList ID="ddlReport" onchange="ddlReportChange()" runat="server" CssClass="ddlReport form-control" TabIndex="1">
                            <asp:ListItem Text="Competitor Master Listing" Value="1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Competitor Visit Report" Value="2"></asp:ListItem>
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
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region of Competitor' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" onchange="ClearRegionConfig()" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Created Period From" CssClass="lblFromDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="4" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Created Period To" CssClass="lblToDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="5" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divCreatedEmp" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedEmployee" runat="server" Text="Created By" CssClass="lblCreatedEmployee input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedEmp" onchange="ClearCreatedByConfig()" runat="server" CssClass="form-control txtCreatedEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="6"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListIncludingSelfEmpData" MinimumPrefixLength="1" CompletionInterval="10"
                            OnClientPopulating="autoCompleteBeatEmployee_OnClientPopulating" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCreatedEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divBeatEmp" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblBeatEmployee" runat="server" Text="Beat Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBeatEmp" onchange="ClearBeatEmployeeConfig()" runat="server" CssClass="form-control txtBeatEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="7"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListIncludingSelfEmpData" MinimumPrefixLength="1" CompletionInterval="10"
                            OnClientPopulating="autoCompleteBeatEmployee_OnClientPopulating" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtBeatEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" onchange="ClearDistConfig()" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divCompetitor" id="divCompetitor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Competitor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCompetitorCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtCompetitorCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender4" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCompetitorName" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteCompetitor_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCompetitorCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="10" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Text="Export To Excel" ID="btnGenerat" TabIndex="9" CssClass="btn btn-default" runat="server" OnClick="btnGenerat_Click" />
                        <%--<asp:Button Text="Export To PDF" ID="btnExpPDF" style="display:none" TabIndex="10" CssClass="btn btn-default btnExpPDF" runat="server" OnClick="btnExpPDF_Click" />--%>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

