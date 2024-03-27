<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="AssetHistoryReport.aspx.cs" Inherits="Reports_AssetHistoryReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">
        var IpAddress;
        var ParentID = <%=ParentID %>;
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $('.txtRegion').val('');
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
            }
        }

        function ChangeRegion() {
            if ($(".txtRegion").length > 0) {
                $('.txtDistCode').val('');
                $('.txtDealerCode').val('');
            }
        }

        function ChangeDist() {
            if ($(".txtDistCode").length > 0) {
                $('.txtDealerCode').val('');
            }
        }
        function OnChangeRefortFor(){
            
            if ($('.ddlReportFor').val() == "1") {
                $('.dvDealerUpload1').removeAttr('style');
                $('.dvDealerUpload2').removeAttr('style');
                $('.dvAssetUpload1').attr('style', 'display:none;');
                $('.dvAssetUpload2').attr('style', 'display:none;');
            }
            else{
                $('.dvAssetUpload1').removeAttr('style');
                $('.dvAssetUpload2').removeAttr('style');
                $('.dvDealerUpload1').attr('style', 'display:none;');
                $('.dvDealerUpload2').attr('style', 'display:none;');
            }
           
        }
        function EndRequestHandler2(sender, args) {

        }
        $(function () {
            $(".gvMissdata").tableHeadFixer('55vh');
            OnChangeRefortFor();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            // allow decimal values only
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
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
        
        function autoCompleteState_OnClientPopulating(sender, args) { //Region
            var EmpID = ($('.txtCode').length > 0 && $('.txtCode').val() != "")? $('.txtCode').val().split('-').pop() : "";
            sender.set_contextKey(EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = ($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').pop() : "0";
            var RegionId = ($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(RegionId+"-0-0-0-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = ($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').pop() : "0";
            var dist = ($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').pop() : "0";
            var RegionId = ($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(RegionId+"-0-0-0-" + dist + "-" + EmpID);
        }
        function downloadDocDealer() {
            window.open("../Document/CSV Formats/DealerCodeList.csv");
        }
        function downloadDocAsset() {
            window.open("../Document/CSV Formats/AssetCodeList.csv");
        }
        function _btnCheck() {
            $(".gvMissdata").attr('style', 'display:none;');
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
      
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Sale/Deposit Option</label>
                        <asp:DropDownList runat="server" ID="ddlSaleType" CssClass="ddlSaleType form-control" TabIndex="1">
                            <asp:ListItem Text="Sale" Value="1" />
                            <asp:ListItem Text="Deposit" Value="0" Selected="True" />
                            <asp:ListItem Text="Both" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Asset Type</label>
                        <asp:DropDownList runat="server" ID="ddlAssetType" CssClass="ddlAssetType form-control" TabIndex="2">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Employee</label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListTillM4" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Distributor Region</label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" onChange="ChangeRegion()" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Distributor</label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" onChange="ChangeDist()" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Dealer</label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Division</label>
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="7" CssClass="ddlDivision form-control">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Inv. Date From</label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="8" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Inv. Date To</label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="9" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Inv. Gross Amt. From</label>
                        <asp:TextBox ID="txtInvGrAmtFr" runat="server" Text="0" TabIndex="10" CssClass="txtInvGrAmtFr allownumericwithdecimal form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Inv. Gross Amt. To</label>
                        <asp:TextBox ID="txtInvGrAmtTO" runat="server" Text="0" TabIndex="11" CssClass="txtInvGrAmtTO allownumericwithdecimal form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4 dvReportFor" id="dvReportFor" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Report For</label>
                        <asp:DropDownList runat="server" ID="ddlReportFor" onChange="OnChangeRefortFor()" CssClass="ddlReportFor form-control" TabIndex="12">
                            <asp:ListItem Text="Selected Dealer" Value="1" Selected="True" />
                            <asp:ListItem Text="Selected Asset" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4 dvDealerUpload1" id="dvDealerUpload1" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Upload Dealer</label>
                        <asp:FileUpload ID="DealerCodeUpload" runat="server" TabIndex="13" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4 dvDealerUpload2" id="dvDealerUpload2" runat="server">
                    <div class="input-group form-group">
                        <asp:Button ID="btnDealerUpload" runat="server" Text="Upload Dealer" TabIndex="14" OnClick="btnDealerUpload_Click" CssClass="btn btn-success btnCustUpload" />
                        &nbsp<asp:Button ID="btnDownDealer" runat="server" Text="Download Format Dealer" TabIndex="15" CssClass="btn btn-info" OnClientClick="downloadDocDealer(); return false;" />
                        <input type="hidden" class="hdnDealerCodes" id="hdnDealerCodes" runat="server" />
                    </div>
                </div>

                <div class="col-lg-4 dvAssetUpload1" id="dvAssetUpload1" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Upload Asset</label>
                        <asp:FileUpload ID="AssetCodeUpload" runat="server" TabIndex="15" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4 dvAssetUpload2" id="dvAssetUpload2" runat="server">
                    <div class="input-group form-group">
                        <asp:Button ID="btnAssetUpload" runat="server" Text="Upload Asset" TabIndex="16" OnClick="btnAssetUpload_Click" CssClass="btn btn-success btnAssetUpload" />
                        &nbsp<asp:Button ID="btnDownAsset" runat="server" Text="Download Format Asset" TabIndex="17" CssClass="btn btn-info" OnClientClick="downloadDocAsset(); return false;" />
                        <input type="hidden" class="hdnAssetCodes" id="hdnAssetCodes" runat="server" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="18" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
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
