<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Scheme.aspx.cs" Inherits="Marketing_Scheme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

    <script type="text/javascript">
        var IpAddress;
        $(function () {
            Relaod();
            $("#hdnIPAdd").val(IpAddress);
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
        function download() {
            window.open("../Document/CSV Formats/SchemeDealerDistriUpload.csv");
        }

        function downloadItem() {
            window.open("../Document/CSV Formats/SchemeItemUpload.csv");
        }

        function downloadMapping() {
            window.open("../Document/CSV Formats/SchemeMappingUpload.csv");
        }

        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = $('.txtGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteMatName_OnClientPopulating(sender, args) {
            var key = $('.txtSubGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-')[0];

            var plt = $('.txtPlant').val().split('-')[0];

            sender.set_contextKey(reg + "-" + plt);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }


        function autoCompleteDealerCode_OnClientPopulating(sender, args) {

            if ($('.txtDistributor').val() != undefined) {
                var key = $('.txtDistributor').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function _btnCheckActive() {
            if ($('.hdnIsActive').val() == "0") {
                if (confirm('QPS Scheme is In-Active, Do you want to Copy ?')) {
                    $('.hdnCopyActive').val('1');
                    return true;
                }
                else {
                    $('.hdnCopyActive').val('0');
                    return true;
                }
            }
            else
                $('.hdnCopyActive').val('1');
        }

        function btnCheckItem() {
            if ($('.txtGroup').val() == "" && $('.txtSubGroup').val() == "" && $('.txtMatName').val() == "") {
                if (!$('._materialForm').data('bootstrapValidator').isValid())
                    $('._materialForm').bootstrapValidator('validate');

                return $('._materialForm').data('bootstrapValidator').isValid();
            } else {
                return true;
            }

        }

        function _btnPanelCheck() {

            if (!$('._panelForm').data('bootstrapValidator').isValid())
                $('._panelForm').bootstrapValidator('validate');

            return $('._panelForm').data('bootstrapValidator').isValid();
        }

        function Relaod() {

            $('._materialForm').bootstrapValidator({
                feedbackIcons: {
                    valid: 'glyphicon glyphicon-ok',
                    invalid: 'glyphicon glyphicon-remove',
                    validating: 'glyphicon glyphicon-refresh'
                }
            });
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("Scheme", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("Scheme") + '"]').tab('show');

            ModeType();
        }

        function ModeType() {
            if ($('.ddlMode').val() == "S") {
                $("#divQPSSetting").show(500);
            }
            else {
                $("#divQPSSetting").hide(500);
            }
        }

        function ChangeQuantity(txt) {
            var Container;
            if (txt != undefined) {
                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("1");
                }
                //Container = $(txt).parent().parent();
            }
        }

        function SetDiscount() {
            $('.txtDiscount').val('');
            var cmpDic = $('.txtCompanyDisc').val();
            var disDic = $('.txtDistributorDisc').val();

            var sum = parseFloat(cmpDic) + parseFloat(disDic);
            $('.txtDiscount').val(sum.toFixed(2));
        }

        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }

        function CheckRdb() {
            if ($('.ddlMode').val() == "S") {
                if ($('input:radio[id*=rdbdis]').is(":checked")) {
                    $('.txtPrice').val(0);
                    $('.txtPrice').attr('disabled', 'disabled');
                }
                else
                    $('.txtPrice').removeAttr('disabled', 'disabled');
            }
        }

    </script>
    <style>
        .table > tbody > tr > td {
            padding: 5px !IMPORTANT;
        }

        .table {
            margin-top: 0 !important;
        }

        .button {
            margin-right: 5px;
        }
        .textright {
            text-align:right;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <asp:Label Text="No" runat="server" CssClass="input-group-addon" Style="min-width: 100px !important;"/>
                        <asp:TextBox runat="server" ID="txtCode" OnTextChanged="txtCodeTextChanged" CssClass="form-control"
                            data-bv-notempty="true" data-bv-notempty-message="Field is required"  />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtCode" runat="server" ServiceMethod="GetScheme"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onAutoCompleteSelected"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="input-group form-group">
                        <asp:Label Text="Code" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtSchmCode" CssClass="form-control" MaxLength="50" onkeypress="return isCharNumKey(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                </div>
                <div class="col-lg-5">
                    <div class="input-group form-group">
                        <asp:Label Text="Name" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtName" CssClass="form-control" MaxLength="500" data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                    </div>
                </div>
            </div>
            <div style="float: right; margin-right: 40px;">
                <asp:Button ID="btnCopyQPS" runat="server" Text="Copy QPS" CssClass="btn btn-info" OnClick="btnCopyQPS_Click" OnClientClick="return _btnCheckActive();" />
                <input type="hidden" id="hdnCopyActive" class="hdnCopyActive" runat="server" />
                <input type="hidden" id="hdnIsActive" class="hdnIsActive" runat="server" />
                <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
                <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-success" OnClientClick="return _btnCheck();" OnClick="btnSubmitClick" ValidationGroup="cmgroup" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-danger" UseSubmitBehavior="false" CausesValidation="false" OnClick="btnCancelClick" />
            </div>

            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab">Distributor / Dealer</a></li>
                <li><a href="#tabs-4" role="tab">Material</a></li>
                <li><a href="#tabs-5" role="tab">QPS Product</a></li>
            </ul>

            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Start Date" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtSDate" onfocus="this.blur();" CssClass="fromdate form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Start Time" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtSTime" CssClass="form-control" />
                                <asp:MaskedEditExtender ID="meetxtSTime" runat="server" TargetControlID="txtSTime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Tax Applicable" runat="server" CssClass="input-group-addon" />
                                <asp:CheckBox ID="chkTaxApp" runat="server" CssClass="form-control" />
                                <asp:Label ID="lblIsSAP" runat="server" Text="Is SAP" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsSAP" runat="server" Checked="false" CssClass="form-control" Enabled="false"></asp:CheckBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="End Date" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtEDate" onfocus="this.blur();" CssClass="todate form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="End Time" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtETime" CssClass="form-control" />
                                <asp:MaskedEditExtender ID="meetxtETime" runat="server" TargetControlID="txtETime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Active" runat="server" CssClass="input-group-addon" />
                                <asp:CheckBox ID="chkActive" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Applicable Mode" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" OnSelectedIndexChanged="ddlMode_SelectedIndexChanged" AutoPostBack="true">
                                    <asp:ListItem Text="Master" Value="M" Selected="True" />
                                    <asp:ListItem Text="QPS" Value="S" />
                                    <asp:ListItem Text="Machine Discount" Value="D" />
                                    <asp:ListItem Text="Parlour Discount" Value="P" />
                                    <asp:ListItem Text="S to D" Value="A" />
                                    <asp:ListItem Text="VRS Discount" Value="V" />
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Applicable On" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlApplcableOn" CssClass="form-control" OnSelectedIndexChanged="ddlApplcableOn_SelectedIndexChanged" AutoPostBack="true">
                                    <asp:ListItem Text="Distributor" Value="2" />
                                    <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Reason Code" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlReason" CssClass="form-control" DataSourceID="edsReason"
                                    DataTextField="ReasonName" DataValueField="ReasonID">
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsReason" runat="server" ConnectionString="name=DDMSEntities"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="ORSNs" Where="it.Type='S' and it.Active = true">
                                </asp:EntityDataSource>
                            </div>
                        </div>
                        <div id="divQPSSetting" style="display: none;">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="QPS For Disc. Dealer" runat="server" CssClass="input-group-addon" />
                                    <asp:DropDownList runat="server" ID="ddlQPSSchemeEligible" CssClass="form-control">
                                        <asp:ListItem Text="None" Value="3" />
                                        <asp:ListItem Text="For Both" Value="2" />
                                        <asp:ListItem Text="Only Company Discounted (Master)" Value="1" />
                                        <asp:ListItem Text="Only Company Non Discounted (Master)" Value="0" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="QPS For Temp Dealer " runat="server" CssClass="input-group-addon" />
                                    <asp:CheckBox ID="chkQPSTempDlr" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="QPS For FOW Dealer" runat="server" CssClass="input-group-addon" />
                                    <asp:CheckBox ID="chkQPSFOWDlr" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkMonday" runat="server" Checked="true" />
                                    <asp:Label Text="Monday" runat="server" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkTuesday" runat="server" Checked="true" />
                                    <asp:Label Text="Tuesday" runat="server" for="chkTuesday" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkWednesday" runat="server" Checked="true" />
                                    <asp:Label Text="Wednesday" runat="server" for="chkWednesday" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkThursday" runat="server" Checked="true" />
                                    <asp:Label Text="Thursday" runat="server" for="chkThursday" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkFriday" runat="server" Checked="true" />
                                    <asp:Label Text="Friday" runat="server" for="chkFriday" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkSaturday" runat="server" Checked="true" />
                                    <asp:Label Text="Saturday" runat="server" for="chkSaturday" Style="vertical-align: super" />
                                </div>
                                <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                    <asp:CheckBox ID="chkSunday" runat="server" Checked="true" />
                                    <asp:Label Text="Sunday" runat="server" for="chkSunday" Style="vertical-align: super" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label Text="Remarks" runat="server" ID="lblRemarks" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" />
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-3" style="display: none">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-3" style="display: none">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label runat="server" Text="Upload Customer" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                                <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Button ID="btnCUpload" runat="server" Text="Upload Customer" OnClick="btnCUpload_Click" CssClass="btn btn-primary" Style="display: inline" />
                                &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-primary" OnClientClick="download(); return false;" />
                            </div>
                        </div>
                    </div>
                    <div class="row _materialForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStateNames"
                                    ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtRegion" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                                    ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4" id="divCustGroup">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustGroup" Text="Customer Group" CssClass="input-group-addon" runat="server" />
                                <asp:TextBox runat="server" ID="txtCustGroup" CssClass="txtCustGroup form-control" Style="background-color: rgb(250, 255, 189);" />
                                <asp:AutoCompleteExtender ID="aceCustGroup" runat="server" TargetControlID="txtCustGroup" ServiceMethod="GetCustomerGroupNameDesc" ServicePath="~/WebService.asmx"
                                    OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                                    MinimumPrefixLength="1" UseContextKey="true">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDistributor" runat="server" Text='Distributor' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDistributor" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistributor form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                                    ContextKey="2" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetDistofPlantState"
                                    MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDealer" runat="server" Text='Dealer' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDealer" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealer form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="~/WebService.asmx"
                                    UseContextKey="true" ServiceMethod="GetDealerofDist" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealer">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblIsInclude" runat="server" Text="Is Include" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsInclude" runat="server" TabIndex="4" Checked="true" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="4" Checked="true" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblAssetCode" runat="server" Text="Asset Code" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtAssetCode" runat="server" MaxLength="100" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Used / Total Coupon" runat="server" ID="lblCoupon" CssClass="input-group-addon" />
                                <table width="100%">
                                    <tr>
                                        <td width="50%">
                                            <asp:TextBox ID="txtUsedCoupon" runat="server" CssClass="form-control" Enabled="false" />
                                        </td>
                                        <td width="50%">
                                            <asp:TextBox ID="txtCouponAmount" runat="server" CssClass="form-control" MaxLength="8" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Button ID="btnAddCustData" runat="server" Text="Add Cust Data" CssClass="btn btn-info button" OnClick="btnAddCustData_Click" />
                                <asp:Button ID="btnCancleCustData" runat="server" Text="Clear Cust Data" CssClass="btn btn-warning" OnClick="btnCancleCustData_Click" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <asp:GridView runat="server" ID="gvCustData" Width="100%" Style="font-size: 10px;" AutoGenerateColumns="false" CssClass="table" HeaderStyle-CssClass="table-header-gradient"
                                OnRowCommand="gvCustData_RowCommand" EmptyDataText="No Record Found.">
                                <Columns>
                                    <asp:TemplateField HeaderText="No.">
                                        <ItemTemplate>
                                            <asp:Label ID="lblGNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="3%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="editCustData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="3%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnDetails" runat="server" Text="Delete" CommandName="deleteCustData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="4%" />
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Region" DataField="RegionName" HeaderStyle-Width="6%" />
                                    <asp:BoundField HeaderText="Plant" DataField="PlantName" HeaderStyle-Width="8%" />
                                    <asp:BoundField HeaderText="CustGroup" DataField="CustGroupDesc" HeaderStyle-Width="9%" />
                                    <asp:BoundField HeaderText="Distributor" DataField="DistributorCode" HeaderStyle-Width="20%" />
                                    <asp:BoundField HeaderText="Dealer" DataField="DealerCode" HeaderStyle-Width="20%" />
                                    <asp:BoundField HeaderText="Include" DataField="IsInclude" HeaderStyle-Width="5%" />
                                    <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="4%" />
                                    <asp:BoundField HeaderText="Asset" DataField="AssetCode" HeaderStyle-Width="9%" />
                                    <asp:BoundField HeaderText="Coupon Amt" DataField="CouponAmount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                                    <asp:BoundField HeaderText="Used Coupon" DataField="UsedCoupon" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="5%" />
                                    <asp:BoundField HeaderText="Sync Date" DataField="SyncDate" HeaderStyle-Width="7%" DataFormatString="{0:dd/MM/yy HH:mm}" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                        </asp:GridView>
                    </div>
                </div>
                <div id="tabs-4" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label runat="server" Text="Upload Item" ID="Label2" CssClass="input-group-addon"></asp:Label>
                                <asp:FileUpload ID="flItemUpload" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Button ID="btnItemUpload" runat="server" Text="Upload Item" OnClick="btnItemUpload_Click" CssClass="btn btn-primary" Style="display: inline" />
                                &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Button ID="btnItemDownload" runat="server" Text="Download Format" CssClass="btn btn-primary" OnClientClick="downloadItem(); return false;" />
                            </div>
                        </div>
                    </div>
                    <div class="row _materialForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblGroupName" runat="server" Text='Item Group' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtGroup" CssClass="txtGroup form-control" runat="server" Style="background-color: rgb(250, 255, 189);" data-bv-notempty="true" data-bv-notempty-message="Any one Field is required"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemGroupID" runat="server" ServiceMethod="GetItemGroup" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblInclude" runat="server" Text='Is Include' CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkInclude" Checked="true" CssClass="form-control" runat="server" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblSubGroupName" runat="server" Text='Item Subgroup' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtSubGroup" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtSubGroup form-control" data-bv-notempty="true" data-bv-notempty-message="Any one Field is required"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemSubGroupID" runat="server" ServiceMethod="GetSubGroupItem" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSubGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text='Division' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDivision" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDivision form-control" data-bv-notempty="true"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtDivisionID" runat="server" ServiceMethod="GetActiveDivision" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDivision" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>

                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblMatName" runat="server" Text='Item' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtMatName" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtMatName form-control" data-bv-notempty="true" data-bv-notempty-message="Any one Field is required"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtMatName" runat="server" ServiceMethod="GetItemWithID" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMatName_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMatName" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Button ID="btnAddGroup" runat="server" Text="Add Group" CssClass="btn btn-info button" OnClientClick="return btnCheckItem();" OnClick="btnAddGroup_Click" />
                                <asp:Button ID="btnCancelGroup" runat="server" Text="Clear Group" CssClass="btn btn-warning" OnClick="btnCancelGroup_Click" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <asp:GridView runat="server" ID="gvItemGroup" Width="100%" Style="font-size: 10px;" AutoGenerateColumns="false" CssClass="table" HeaderStyle-CssClass="table-header-gradient" OnRowCommand="gvItemGroup_RowCommand" EmptyDataText="No Record Found." OnRowDataBound="gvItemGroup_RowDataBound">
                                <Columns>
                                    <asp:TemplateField HeaderText="No.">
                                        <ItemTemplate>
                                            <asp:Label ID="lblGNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="2%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Edit">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="editItemGroup" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="4%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Delete">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="deleteItemGroup" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="4%" />
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Item Group" DataField="OITB.ItemGroupName" HeaderStyle-Width="10%" />
                                    <asp:BoundField HeaderText="ItemSub Group" DataField="OITG.ItemSubGroupName" HeaderStyle-Width="10%" />
                                    <asp:TemplateField HeaderText="Item Code # Item Name">
                                        <ItemTemplate>
                                            <asp:Label ID="lblName" runat="server" Text='<%#string.Format("{0} # {1}", Eval("OITM.ItemCode"),Eval("OITM.ItemName")) %>'></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="20%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Division">
                                        <ItemTemplate>
                                            <asp:Label ID="lbldivID" runat="server" Text='<%#Eval("DivisionID") %>' Visible="false"></asp:Label>
                                            <asp:Label ID="lbldivName" runat="server" Text=""></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="10%" />
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Include" DataField="IsInclude" HeaderStyle-Width="5%" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <asp:GridView ID="gvitemMisdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                        </asp:GridView>
                    </div>
                </div>
                <div id="tabs-5" class="tab-pane">
                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label runat="server" Text="Upload Mapping" ID="Label3" CssClass="input-group-addon"></asp:Label>
                                <asp:FileUpload ID="flIMappingUpload" TabIndex="14" runat="server"  CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Button ID="btnMappingUpload" runat="server" TabIndex="15"  Text="Upload Mapping" OnClick="btnMappingUpload_Click" CssClass="btn btn-primary" Style="display: inline" />
                                &nbsp; &nbsp; &nbsp; &nbsp;
                            <asp:Button ID="btnMappingDwnload" runat="server"  TabIndex="16" Text="Download Format" CssClass="btn btn-primary" OnClientClick="downloadMapping(); return false;" />
                            </div>
                        </div>
                    </div>
                    <div class="row _panelForm row">
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Lower Limit" runat="server" ID="lblLowerLimit" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtLowerLimit" runat="server" TabIndex="1" CssClass="form-control textright" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDiscount" runat="server" Text="Discount Type" CssClass="input-group-addon"></asp:Label>

                                <input type="radio" id="rdbper" checked="true"  tabindex="4" style="display: inline !IMPORTANT; vertical-align: text-bottom;" runat="server" onchange="CheckRdb();" />% &nbsp;
                                            <input type="radio" id="rdbdis"  style="display: inline !IMPORTANT; vertical-align: text-bottom;" runat="server" onchange="CheckRdb();" />&#8377
                                        
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label Text="Item" runat="server" ID="lblMat" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtMat" runat="server"  TabIndex="8" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true" CssClass="form-control" OnTextChanged="txtMat_TextChanged"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtMat" runat="server" ServiceMethod="GetItemWithID" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMat" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Higher Limit" runat="server" ID="lblHigherLimit" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtHigherLimit" TabIndex="2" runat="server" CssClass="form-control textright" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Comp / Dist contr." runat="server" ID="lblComapnyDisc" CssClass="input-group-addon" />
                                <table width="90%">
                                    <tr>
                                        <td width="30%">
                                            <asp:TextBox ID="txtCompanyDisc" TabIndex="5" runat="server" onchange="SetDiscount();" CssClass="txtCompanyDisc form-control textright" MaxLength="10" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                                        </td>
                                        <td width="30%">
                                            <asp:TextBox ID="txtDistributorDisc"  TabIndex="6" runat="server" onchange="SetDiscount();" CssClass="txtDistributorDisc form-control textright" MaxLength="10" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="QPS Qty." runat="server" ID="lblQuantity" CssClass="input-group-addon" />
                                <table width="43%">
                                    <tr>
                                        <td width="43%">
                                            <asp:TextBox ID="txtQuantity" runat="server" TabIndex="9" Text="0" MaxLength="4" CssClass="form-control textright" onkeypress="return isNumberKey(event);" onpaste="return false;" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Base On" runat="server" ID="lblBaseOn" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" TabIndex="11" ID="ddlBasedOn" CssClass="form-control">
                                    <asp:ListItem Text="Gross Amount " Value="1" />
                                    <asp:ListItem Text="Purchase Qty" Value="2" />
                                    <asp:ListItem Text="Unit" Value="3" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Occurrence" runat="server" ID="lblOccurrence" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtOccurrence" runat="server" TabIndex="3" Text="0.00"  CssClass="form-control textright" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                
                                <asp:Label Text="Is Pair" runat="server" ID="Label4" CssClass="input-group-addon" Style="min-width: 100px !important;" />
                                <table width="100%">
                                    <tr>
                                        <td width="43%">
                                <asp:DropDownList ID="ddlIsPair" runat="server" TabIndex="7" CssClass="ddlIsPair form-control">
                                    <asp:ListItem Value="-1" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="false" Text="No"></asp:ListItem>
                                    <asp:ListItem Value="true" Text="Yes"></asp:ListItem>
                                </asp:DropDownList>
                                             </td>
                                        <td width="30%">
                                            <asp:TextBox ID="txtDiscount" runat="server" Text="0" Width="80%"   Enabled="false" CssClass="txtDiscount form-control textright" onpaste="return false;" data-bv-stringlength="false" MaxLength="8" autocomplete="off" AutoCompleteType="Disabled" onkeypress="return isNumberKeyForAmount(event);"></asp:TextBox>
                                        </td>
                                        </tr>
                                     </table>
                            </div>

                            

                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Label Text="Claim Rate" runat="server" ID="Label5" CssClass="input-group-addon" />
                                <table width="43%">
                                    <tr>
                                        <td width="43%">
                                            <asp:TextBox ID="txtPrice" runat="server" TabIndex="10" Text="0" MaxLength="7" CssClass="txtPrice form-control textright" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" />
                                        </td>
                                    </tr>
                                </table>

                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group">
                                <asp:Button ID="btnScheme" runat="server" TabIndex="11" Text="Submit" CssClass="btn btn-info button" OnClick="btnSchemeClick" OnClientClick="return _btnPanelCheck();" />
                                <asp:Button ID="btnCancelMapping" TabIndex="12" runat="server" Text="Clear Mapping" CssClass="btn btn-warning" OnClick="btnCancelMapping_Click" />
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div class="input-group form-group" runat="server" id="divUnit" visible="false">
                                <asp:Label Text="Unit" runat="server" ID="lblUnit" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" TabIndex="13" ID="ddlUnit" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                        </div>
                    <div class="row">
                            <div class="col-lg-12">
                                <asp:GridView ID="gvScheme" runat="server" Width="100%" Style="font-size: 10px;" CssClass="table" AutoGenerateColumns="false" EmptyDataText="No Record Found." OnRowCommand="gvScheme_RowCommand" HeaderStyle-CssClass="table-header-gradient">
                                    <Columns>
                                        <asp:TemplateField HeaderText="No">
                                            <ItemTemplate>
                                                <asp:Label ID="lblSNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="EditScheme" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteScheme" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Lower Limit" DataField="LowerLimit" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                        <asp:BoundField HeaderText="Higher Limit" DataField="HigherLimit" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                        <asp:BoundField HeaderText="Occurrence" DataField="Occurrence" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                        <asp:TemplateField HeaderText="Item">
                                            <ItemTemplate>
                                                <asp:Label ID="lblGMat" runat="server" Text='<%#string.Format("{0} # {1}", Eval("OITM.ItemCode"),Eval("OITM.ItemName")) %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="22%" />
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Unit" DataField="OUNT.UnitName" Visible="false" HeaderStyle-Width="5%" />
                                        <asp:BoundField HeaderText="QPS Qty" DataField="Quantity" DataFormatString="{0:0}"  HeaderStyle-CssClass="text-right" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                                        <asp:BoundField HeaderText="Claim Rate" DataField="Price" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="3%" />
                                        <asp:TemplateField HeaderText="Based On" HeaderStyle-Width="5%">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblBasedOn" Text='<%# Eval("BasedOn").ToString() =="1" ? "Gross Amount": Eval("BasedOn").ToString() =="2" ? "Purchase Qty": "Unit" %>' />
                                            </ItemTemplate>
                                            <HeaderStyle Width="5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Is Pair" HeaderStyle-Width="3%">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblPair" Text='<%# Eval("IsPair") == null ? "Null" : Eval("IsPair").ToString().ToLower() =="true" ? "Yes" :  "No" %>' />
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Disc Type" HeaderStyle-Width="3%">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="lblGDisType" Text='<%# Eval("DiscountType").ToString() =="A" ? "INR" : "%" %>' />
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        
                                        <asp:BoundField HeaderText="Comp Contri." DataField="CompanyDisc" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                        <asp:BoundField HeaderText="Dist Contri." DataField="DistributorDisc" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                        <asp:BoundField HeaderText="Total Dis." DataField="Discount" DataFormatString="{0:0.00}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" HeaderStyle-CssClass="text-right" HeaderStyle-Width="5%" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    <div class="col-lg-12">
                            <asp:GridView ID="gvProductMappingMissData" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>


