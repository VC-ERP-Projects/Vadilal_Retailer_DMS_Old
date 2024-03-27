<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="CompetitorBeatMaster.aspx.cs" Inherits="Master_CompetitorBeatMaster" %>

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
                var Route = $('.txtCBCode').val();

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

            if ($.cookie("ScrollLastPos") != "0" && $.cookie("ScrollLastPos") != undefined) {
                var LastScrollPos = parseFloat($.cookie("ScrollLastPos"));
                $('.dataTables_scrollBody').scrollTop(LastScrollPos + 42);
            }

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
            $(':checkbox').change(function () {
                if (this.checked) {
                    $(this).closest('tr').find('input[id*="lblIsChange"]').val("1");
                }
                else {
                    $(this).closest('tr').find('input[id*="lblIsChange"]').val("0");
                }
            });
        }

        function acetxtCustName_OnClientPopulating(sender, args) {
            sender.set_contextKey("0-0-0-0-0-0-1");

            RowCount = $(".gvCustomer tbody tr").length;
            scrollHeight = $get('divCustomer').scrollTop;
        }
        function acettxtMoveRouteCode_OnClientPopulating(sender, args) {
        }

        function ddlactivity_selectedindexchanged(ddl) {
            if ($('.ddlActivity').val() == 3) {
                $('.moveroutecode').show();
            }
            else
                $('.moveroutecode').hide();
        }
        $('.hide').hide(); //for hide upload route setting #tab 5

        function CheckMain(chk) {

            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck:checked').length) {
                    $('.chkMain').prop('checked', true);
                    $('.lblIsChange').val("1");
                }
                else {
                    $('.chkMain').prop('checked', false);
                    $('.lblIsChange').val("0");
                }
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkCheck').prop('checked', true);
                    $('.lblIsChange').val("1");
                }
                else {
                    $('.chkCheck').prop('checked', false);
                    $('.lblIsChange').val("0");
                }
            }
        }

        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }

    </script>
    <style>
        .gvCustomer, .gvMissdataEmployee {
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

        .uploadbtn {
            text-align: right;
            margin: 5px 0;
        }

        .dtClassCenter {
            text-align: center;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" style="margin-bottom: 10px" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
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
                            <asp:Label ID="lbl_CBCode" runat="server" Text="CB Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCBCode" CssClass="txtCBCode form-control" runat="server" autocomplete="off" OnTextChanged="txtCBCode_TextChanged"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCBCode" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCBCode" OnClientItemSelected="onAutoCompleteSelected">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lbl_CBName" runat="server" Text="CB Name" CssClass="input-group-addon"></asp:Label>
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
                <ul id="tabs" class="nav nav-tabs" role="tablist">
                    <li class="active" id="_changeTab"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                    <li><a href="#tab-2" role="tab">Competitor</a></li>
                    <li><a href="#tab-3" role="tab" class="hide">Upload Route Setting</a></li>
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
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrefSale" runat="server" Text="Sales Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetActiveEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                                        EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                                    </asp:AutoCompleteExtender>
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
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
                    <div id="tab-2" class="tab-pane">
                        <div class="row">
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
                                    <asp:Label ID="lblrtcode" runat="server" Text="Move to CB Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtMoveRouteCode" runat="server" CssClass="form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtMoveRouteCode" runat="server" ServicePath="../WebService.asmx"
                                        UseContextKey="true" ServiceMethod="GetCompetitorRoute" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acettxtMoveRouteCode_OnClientPopulating"
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
                                        <asp:TemplateField HeaderText="Sr.">
                                            <ItemTemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="1%" />
                                            <ItemStyle Font-Size="12px" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Check">
                                            <HeaderTemplate>
                                                <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Label ID="lblCustID" CssClass="lblCustID" runat="server" Style="display: none;" Text='<%#Eval("OCOMPID") %>'></asp:Label>
                                                <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();" />
                                            </ItemTemplate>
                                            <HeaderStyle Width="1%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Code">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtCustCode" CssClass="txtCustCode form-control" runat="server" BackColor="#ffffcc"
                                                    autocomplete="off" OnTextChanged="txtCustCode_TextChanged" AutoPostBack="true" Text='<%#Eval("Code") %>'></asp:TextBox>
                                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCustCode" runat="server" ServicePath="../Service.asmx"
                                                    ServiceMethod="GetCompetitorName" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false"
                                                    CompletionSetCount="1" TargetControlID="txtCustCode" UseContextKey="True" OnClientPopulating="acetxtCustName_OnClientPopulating">
                                                </asp:AutoCompleteExtender>
                                                <%--<input ID="lblIsChange" runat="server" Visible="false" Text='<%#Eval("IsChange") %>'></input>--%>
                                                <input type="hidden" name="lblIsChange" id="lblIsChange" class="lblIsChange" runat="server" value='<%#Eval("IsChange") %>' />
                                            </ItemTemplate>
                                            <HeaderStyle Width="2%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Competitor Name">
                                            <ItemTemplate>
                                                <%# Eval("CompetitorName") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="City">
                                            <ItemTemplate>
                                                <%# Eval("City") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Mobile">
                                            <ItemTemplate>
                                                <%#Eval("Mobile") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Temporary Code">
                                            <ItemTemplate>
                                                <%# Eval("TemporaryCode") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Distributor Code & Name">
                                            <ItemTemplate>
                                                <%# Eval("DistributorCode") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="4%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Active">
                                            <ItemTemplate>
                                                <%# Eval("Active") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="1.5%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Created Date/Time" HeaderStyle-CssClass="dtClassCenter">
                                            <ItemTemplate>
                                                <%# Eval("CreatedDateTime") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Created By">
                                            <ItemTemplate>
                                                <%# Eval("CreatedBy") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Updated Date/Time" HeaderStyle-CssClass="dtClassCenter">
                                            <ItemTemplate>
                                                <%# Eval("UpdatedDateTime") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Updated By">
                                            <ItemTemplate>
                                                <%# Eval("UpdatedBy") %>
                                            </ItemTemplate>
                                            <HeaderStyle Width="3%" />
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                    <div id="tab-3" class="tab-pane">
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
