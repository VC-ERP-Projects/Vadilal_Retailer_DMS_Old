<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="RouteMaster.aspx.cs" Inherits="Marketing_RouteMaster_aspx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/fixedheader/defaultTheme.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">
        var scrollHeight = "";
        var RowCount = 0;
        var IpAddress;
        var tb;
        $(function () {
            Relaod();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

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
        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function download() {
            window.open("../Document/CSV Formats/EmployeeRouteUpload.csv");
        }

        function _btnCheck() {

            var IsValid = false;

            if ($('.chkDay').find('input:checked').length <= 0) {
                IsValid = false;
                ModelMsg("Please select any one schedule!", 3);
                event.preventDefault();
                return false;
            } else {
                if (IsValid == true)
                    IsValid = true;
            }

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            //Check to change customer in route

            if ($(".ddlActivity").val() == "0") {
                var ID = "";
                $('.gvCustomer').find('tr').each(function () {

                    if ($(this).find('.lblBStatus').text().trim() == "True") {
                        var id = $(this).find('.lblCustID').text().trim();
                        if (id != "0" && id != "")
                            ID += id + ",";
                    }
                });

                var IDs = ID.replace(/^,|,$/g, '');
                var Route = $('.txtRouteCode').val();

                var SPID = 0;
                if ($('.chckCopyBeat').find('input:checked').length > 0)
                    SPID = $('.txtCopyPrefSP').val().split('-').pop();
                else
                    SPID = $('.txtCode').val().split('-').pop();

                $.ajax({
                    url: 'RouteMaster.aspx/CheckDuplicateCust',
                    type: 'POST',
                    dataType: 'json',
                    data: JSON.stringify({ ID: IDs, Route: Route, SPID: SPID }),
                    contentType: 'application/json',
                    async: false,
                    success: function (result) {

                        if (result.d.indexOf("2|") >= 0) {
                            IsValid = false;
                            ModelMsg(result.d.split('|')[1].trim(), 3);
                            IsValid = false;
                            event.preventDefault();
                            return false;
                        }
                        else {
                            if (IsValid == true)
                                IsValid = true;
                        }
                    }
                });
            }
            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function Relaod() {
            $(".gvMissdata").tableHeadFixer('58vh');
            $(".gvMissdataEmployee").tableHeadFixer('58vh');
            $(".gvCustomer").tableHeadFixer('55vh');

            $('.dataTables_scrollBody').on('scroll', function () {
                if ($('.dataTables_scrollBody').scrollTop() != 0)
                    $.cookie("ScrollLastPos", $('.dataTables_scrollBody').scrollTop());
            });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("Route", $(e.target).attr("href").substr(1));
            });

            $('#tabs a[href="#' + $.cookie("Route") + '"]').tab('show');

            ddlactivity_selectedindexchanged();

            $(".ddlRouteType").bind("click", function (e) {
                lastValue = $(this).val();
            }).bind("change", function (e) {
                $(this).blur() // Firefox fix as suggested by AgDude
                var success = confirm('Are you sure you want to change the Route Type?');
                if (success) {
                    __doPostBack(selectlist, '');
                }
                else {
                    $(this).val(lastValue);
                    return false;
                }
            });
            if ($.cookie("ScrollLastPos") != "0" && $.cookie("ScrollLastPos") != undefined) {
                var LastScrollPos = parseFloat($.cookie("ScrollLastPos"));
                $('.dataTables_scrollBody').scrollTop(LastScrollPos + 42);
            }

            //checkBox wise Parent Change
            var autoComplete = $find("BhvParentCode");
            if ($('.chkSrchByParent').find('input:checked').length > 0)
                autoComplete.set_serviceMethod("GetRouteByParentID");

            $('.chkSrchByParent').change(function () {
                $('.txtRouteCode').val("");
                var autoComplete = $find("BhvParentCode");
                if ($('.chkSrchByParent').find('input:checked').length > 0)
                    autoComplete.set_serviceMethod("GetRouteByParentID");
                else
                    autoComplete.set_serviceMethod("GetRoute");
            });

            if ($('.chckCopyBeat').find('input:checked').length > 0) {
                $('.CopyBeat').show();
                $('.txtCopyPrefSP').val('');
            }
            else {
                $('.CopyBeat').hide();
                $('.txtCopyPrefSP').val('');
            }
            $('.chckCopyBeat').change(function () {
                if ($('.chckCopyBeat').find('input:checked').length > 0) {
                    $('.CopyBeat').show();
                    $('#txtCopyPrefSP').val('');
                }
                else {
                    $('.CopyBeat').hide();
                    $('#txtCopyPrefSP').val('');
                }
            });
        }

        function acetxtCustName_OnClientPopulating(sender, args) {
            if ($('.txtParentCode').val() != undefined || $('.ddlRouteType').val() > 0) {
                var key = ($('.txtParentCode').val().split('-')[2]) != undefined ? $('.txtParentCode').val().split('-')[2] : 0;
                if (key != undefined)
                    sender.set_contextKey(key + '-' + $('.ddlRouteType').val());
            }
            RowCount = $(".gvCustomer tbody tr").length;
            scrollHeight = $get('divCustomer').scrollTop;
        }

        var selectlist = $('.ddlRouteType').val();

        function ddlactivity_selectedindexchanged(ddl) {
            if ($('.ddlActivity').val() == 3) {
                $('.moveroutecode').show();
            }
            else
                $('.moveroutecode').hide();
        }

        function acetxtParentName_OnClientPopulating(sender, args) {
            var Type = $('.ddlRouteType').val();
            if (Type == 2)
                sender.set_contextKey(4);
            else if (Type == 3)
                sender.set_contextKey(2);
        }

        function acettxtMoveRouteCode_OnClientPopulating(sender, args) {
            sender.set_contextKey($('.ddlRouteType').val())
        }

        function CheckMain(chk) {

            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkCheck').prop('checked', true);
                }
                else {
                    $('.chkCheck').prop('checked', false);
                }
            }
        }

        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }
        
        function ResetPosition(object, args) {

            var tb = object._element; // tb.id is the associated textbox ID in the grid.

            var mode = document.compatMode;
            if (mode == 'BackCompat') {
                if (document.body.scrollTop > 0) {
                    var ex = object._completionListElement;
                    if (ex) {
                        var tbPos = $common.getLocation(tb);
                        var xPos = tbPos.x;
                        var yPos = tbPos.y + tb.offsetHeight + document.body.scrollTop;
                        $common.setLocation(ex, new Sys.UI.Point(xPos, yPos));
                    }
                }
            }
        } // End resetPosition
    </script>
    <style>
        .gvCustomer, .gvMissdata, .gvMissdataEmployee {
            font-size: 11px;
        }

            .gvCustomer > tbody > tr > td {
                padding: 1px 4px;
            }

        .txtCustCode {
            font-size: 11px;
            height: 25px;
        }

        .table {
            margin-top: 0px !important;
        }

        #divCustomer div:nth-child(2) {
            max-height: 350px;
        }

        #divCustomer .dataTables_scrollBody {
            position: relative;
        }

        .gvMissdata thead th:first-child {
            width: 5%;
        }

        .gvMissdata thead th:nth-child(3) {
            width: 30%;
        }

        .gvMissdata thead th:last-child {
            width: 55%;
        }

        .uploadbtn {
            text-align: right;
            margin: 5px 0;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" style="margin-bottom: 10px" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
        &nbsp;
        <asp:CheckBox ID="chkSrchByParent" runat="server" CssClass="chkSrchByParent" />
        <asp:Label ID="lblSrchByParent" Text="Search by Parent" runat="server" Style="vertical-align: super; padding-bottom: 2px;" />
        &nbsp;
        <asp:CheckBox ID="chckCopyBeat" runat="server" CssClass="chckCopyBeat" />
        <asp:Label CssClass="chckCopyBeat" ID="lblCopyBeat" Text="Copy Beat" runat="server" Style="vertical-align: super; padding-bottom: 2px;" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="_masterForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lbl_RouteCode" runat="server" Text="Beat Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtRouteCode" CssClass="txtRouteCode form-control" runat="server" autocomplete="off" OnTextChanged="txtRouteCode_TextChanged"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtRouteCode" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtRouteCode" BehaviorID="BhvParentCode" OnClientItemSelected="onAutoCompleteSelected">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblRouteName" runat="server" Text="Beat Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblAStatus" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkAcitve" runat="server" Checked="true" CssClass="form-control" />
                        </div>
                    </div>
                </div>
                <div class="row" hidden="hidden">
                    <div class="col-lg-12">
                        <div class="input-group form-group">
                            <asp:Label ID="lblDesc" runat="server" Text="Description" CssClass="lbl_desc input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDesc" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <ul id="tabs" class="nav nav-tabs" role="tablist">
                    <li class="active" id="_changeTab"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                    <li><a href="#tabs-3" role="tab">Customer</a></li>
                    <li><a href="#tabs-4" role="tab">Upload Customer</a></li>
                    <li><a href="#tabs-5" role="tab">Upload Route Setting</a></li>
                    <asp:Button ID="btnCopyBeat" runat="server" Text="Copy Beat" CssClass="btn btn-info CopyBeat" OnClientClick="return _btnCheck();" OnClick="btnCopyBeat_Click" />
                    <div class="col-lg-4 CopyBeat" runat="server" id="CopyBeat">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCopyPrefSP" runat="server" Text="Copy Sales Person" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCopyPrefSP" runat="server" CssClass="form-control txtCopyPrefSP" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetActiveEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCopyPrefSP">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <asp:Button ID="btnCancel" Style="float: right;" CssClass="btn btn-default" CausesValidation="false" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                    <asp:Button ID="btnSubmit" Style="float: right;" CssClass="btn btn-default" ValidationGroup="RouteCode" runat="server" Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                </ul>
                <div id="myTabContent" class="tab-content">
                    <div id="tabs-1" class="tab-pane active">
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="input-group form-group">
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkMonday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Monday" runat="server" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkTuesday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Tuesday" runat="server" for="chkTuesday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkWednesday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Wednesday" runat="server" for="chkWednesday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkThursday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Thursday" runat="server" for="chkThursday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkFriday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Friday" runat="server" for="chkFriday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkSaturday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Saturday" runat="server" for="chkSaturday" Style="vertical-align: super" />
                                    </div>
                                    <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                                        <asp:CheckBox ID="chkSunday" runat="server" Checked="true" CssClass="chkDay" />
                                        <asp:Label Text="Sunday" runat="server" for="chkSunday" Style="vertical-align: super" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrefSale" runat="server" Text="Sales Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetActiveEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtNotes" TextMode="MultiLine" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAvgBusiness" runat="server" Text="Average Call Minutes" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAvgBusiness" runat="server" placeholder="Average Call Minutes" MaxLength="10" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAvgExpense" runat="server" Text="Productive Call" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAvgExpense" runat="server" placeholder="Productive Call Count" MaxLength="10" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblDistance" runat="server" Text="Non Productive Call" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtDistance" runat="server" MaxLength="10" placeholder="Non Productive Call Count" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>

                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group" style="display: none;">
                                    <asp:Label ID="lblOwnCustomer" runat="server" Text="Own Cust. Count" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtOwnCustomer" runat="server" placeholder="Own Customer Count" MaxLength="10" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" style="display: none;">
                                    <asp:Label ID="lblCompCustomer" runat="server" Text="Competitor Cust. Count" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCompCustomer" runat="server" placeholder="Comp Customer Count" MaxLength="10" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" style="display: none;">
                                    <asp:Label ID="lblTotal" runat="server" Text="Total Amount" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtTotal" runat="server" placeholder="Amount" Enabled="false" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="txtTotal form-control"></asp:TextBox>
                                    <br />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCreatedIP" runat="server" Text="Created IP Address" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCreatedIP" Enabled="false" runat="server" CssClass="form-control txtCreatedIP" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUpdatedIP" runat="server" Text="Updated IP Address" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtUpdatedIP" Enabled="false" runat="server" CssClass="form-control txtUpdatedIP" Style="font-size: small"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-3" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblRoutetype" runat="server" Text="Route Type" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlRouteType" CssClass="form-control ddlRouteType"
                                        OnSelectedIndexChanged="ddlRouteType_SelectedIndexChanged">
                                        <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                                        <asp:ListItem Text="Distributor" Value="2" />
                                        <asp:ListItem Text="SS" Value="4" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustomer" runat="server" Text="Parent Customer" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtParentCode" runat="server" TabIndex="4" CssClass="txtParentCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtParentCode" OnClientPopulating="acetxtParentName_OnClientPopulating">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAct" runat="server" Text="Activity" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlActivity" CssClass="form-control ddlActivity" onchange="ddlactivity_selectedindexchanged()">
                                        <asp:ListItem Text="---Select---" Value="0" Selected="True" />
                                        <asp:ListItem Text="Active" Value="1" />
                                        <asp:ListItem Text="In-Active" Value="2" />
                                        <asp:ListItem Text="Move" Value="3" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group moveroutecode" style="display: none;">
                                    <asp:Label ID="lblrtcode" runat="server" Text="Move Beat Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtMoveRouteCode" runat="server" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtMoveRouteCode" runat="server" ServicePath="../WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetRoute" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acettxtMoveRouteCode_OnClientPopulating"
                                        Enabled="True" EnableCaching="true" CompletionSetCount="1" TargetControlID="txtMoveRouteCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div id="divCustomer" class="col-lg-12" style="max-height: 398px;">
                                <asp:GridView runat="server" ID="gvCustomer" CssClass="gvCustomer table " HeaderStyle-CssClass="table-header-gradient"
                                    AutoGenerateColumns="false" EmptyDataText="No Item Found." Width="100%" OnPreRender="gvCustomer_PreRender">
                                    <Columns>
                                        <asp:TemplateField HeaderText="No.">
                                            <ItemTemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="2.3%" />
                                            <ItemStyle Font-Size="12px" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Check">
                                            <HeaderTemplate>
                                                <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Label ID="lblCustID" CssClass="lblCustID" runat="server" Style="display: none;" Text='<%#Eval("CustomerID") %>'></asp:Label>
                                                <%--<asp:CheckBox ID="chkCustomer" CssClass="chkCheck" runat="server"></asp:CheckBox>--%>
                                                <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();" />
                                            </ItemTemplate>
                                            <HeaderStyle Width="2%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Customer">
                                            <ItemTemplate>
                                                    <asp:TextBox ID="txtCustCode" CssClass="txtCustCode form-control" runat="server" BackColor="#ffffcc"
                                                        autocomplete="off" OnTextChanged="txtCustCode_TextChanged" AutoPostBack="false" Text='<%#Eval("Customer") %>'></asp:TextBox>
                                                    <asp:AutoCompleteExtender OnClientShown="ResetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCustCode" runat="server" ServicePath="../WebService.asmx"
                                                        ServiceMethod="GetCustomerWithLocationForRouteMaster" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" OnClientItemSelected="onAutoCompleteSelected"
                                                        CompletionSetCount="1" TargetControlID="txtCustCode" UseContextKey="True" OnClientPopulating="acetxtCustName_OnClientPopulating">
                                                    </asp:AutoCompleteExtender>
                                            </ItemTemplate>
                                            <HeaderStyle Width="20%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Location" Visible="false">
                                            <ItemTemplate>
                                                <%# Eval("Location") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="15%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="City">
                                            <ItemTemplate>
                                                <%# Eval("CityName") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="6%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Mobile No.">
                                            <ItemTemplate>
                                                <%#Eval("Phone") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Customer Group">
                                            <ItemTemplate>
                                                <%#Eval("CustGroupDesc") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="6.5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Pricing Group">
                                            <ItemTemplate>
                                                <%#Eval("PricingGroup") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="8.5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Beat / DMS / SAP">
                                            <ItemTemplate>
                                                <asp:Label ID="lblBStatus" CssClass="lblBStatus" runat="server" Text='<%#Eval("Status") %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="7%" />
                                        </asp:TemplateField>
                                        <%-- <asp:TemplateField HeaderText="Active In Beat">
                                            <ItemTemplate>
                                                <asp:Label ID="lblBStatus" CssClass="lblBStatus" runat="server" Text='<%#Eval("BActive") %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="4%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Active As Cust">
                                            <ItemTemplate>
                                                <asp:Label ID="lblCStatus" CssClass="lblCStatus" runat="server" Text='<%#Eval("CActive") %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="4.2%" />
                                        </asp:TemplateField>--%>
                                        <asp:TemplateField HeaderText="Parent">
                                            <ItemTemplate>
                                                <%# Eval("Parent") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="15%" />
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-4" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                                    <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="uploadbtn">
                                    <asp:Button ID="btnImport" runat="server" Text="Upload" CssClass="btn btn-default" OnClick="btnImport_Click" />
                                    &nbsp;
                                 <asp:Button Text="Download" ID="btnExport" CssClass="btnExport btn btn-default" runat="server" OnClick="btnExport_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12">
                                <asp:GridView ID="gvMissdata" runat="server" CssClass="gvMissdata table" OnPreRender="gvMissdata_PreRender" AutoGenerateColumns="true" HeaderStyle-CssClass="table-header-gradient" Width="100%">
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-5" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label runat="server" Text="Upload File" ID="Label1" CssClass="input-group-addon"></asp:Label>
                                    <asp:FileUpload ID="flEUpload" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Button ID="btnImportEmployee" runat="server" Text="Upload" CssClass="btn btn-default" OnClick="btnImportEmployee_Click" />
                                    &nbsp;
                                <asp:Button ID="btnDownload" runat="server" Text="Download Format" CssClass="btn btn-primary" OnClientClick="download(); return false;" />
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <asp:GridView ID="gvMissdataEmployee" runat="server" CssClass="gvMissdataEmployee table" OnPreRender="gvMissdataEmployee_PreRender"
                                    HeaderStyle-CssClass="table-header-gradient" AutoGenerateColumns="false" Width="100%">
                                    <Columns>
                                        <asp:BoundField DataField="sr" HeaderText="Sr" HeaderStyle-Width="5%" />
                                        <asp:BoundField DataField="empcode" HeaderText="EmpCode" HeaderStyle-Width="15%" />
                                        <asp:BoundField DataField="averagecallminutes" HeaderText="AverageCallMinutes" HeaderStyle-Width="15%" />
                                        <asp:BoundField DataField="ProductiveCall" HeaderText="ProductiveCall" HeaderStyle-Width="15%" />
                                        <asp:BoundField DataField="NonProductiveCall" HeaderText="NonProductiveCall" HeaderStyle-Width="15%" />
                                        <asp:BoundField DataField="ErrorMsg" HeaderText="ErrorMsg" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</asp:Content>
