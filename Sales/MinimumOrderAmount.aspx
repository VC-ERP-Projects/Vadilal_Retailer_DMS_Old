<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MinimumOrderAmount.aspx.cs" Inherits="Sales_MinimumOrderAmount" %>

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

        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = '0';
            sender.set_contextKey(key);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode1').is(":visible") ? $('.txtCode1').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(reg + "-0-0-0");
        }

        function autoCustGroup_OnClientPopulating(sender, args) {
            var reg = $('.txtDistributor').val().split('-')[2];
            sender.set_contextKey(reg);
        }

        function autoCompleteDealerCode_OnClientPopulating(sender, args) {

            var reg = $('.txtCustGroup').val().split('-')[2];


            sender.set_contextKey(reg);
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            if (CustType == 1) {
                var reg = $('.txtRegion').val().split('-').pop();
                var key = $('.txtCustCode').val().split('-').pop();
                sender.set_contextKey(reg + "-0-0-0-" + key);
            }
            else {
                sender.set_contextKey("0-0-0-0-" + ParentID);
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
            text-align: right;
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
                        <asp:Label Text="No" runat="server" CssClass="input-group-addon" Style="min-width: 100px !important;" />
                        <asp:TextBox runat="server" ID="txtCode" OnTextChanged="txtCode_TextChanged" CssClass="form-control"
                            data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtCode" runat="server" ServiceMethod="GetMinimumOrderData"
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
                <input type="hidden" id="hdnIsActive" class="hdnIsActive" runat="server" />
                <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
                <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-success" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" ValidationGroup="cmgroup" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-danger" UseSubmitBehavior="false" CausesValidation="false" OnClick="btnCancel_Click" />
            </div>

            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab">Distributor / Dealer</a></li>
                <li><a href="#tabs-3" role="tab">Material(Division)</a></li>
            </ul>

            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Applicable Mode" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlMode_SelectedIndexChanged">
                                    <asp:ListItem Text="Order Amount" Value="OA" />
                                    <asp:ListItem Text="Order Entry" Value="OE" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label Text="Active" runat="server" CssClass="input-group-addon" />
                                <asp:CheckBox ID="chkActive" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4" runat="server" id="divLowerLimit">
                            <div class="input-group form-group">
                                <asp:Label Text="Amount" runat="server" ID="lblLowerLimit" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtLowerLimit" runat="server" TabIndex="1" CssClass="form-control textright" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" ondrage="return false" ondrop="return false" MaxLength="10" />
                            </div>
                        </div>
                        <div class="col-lg-4" id="DivStartTime" runat="server">
                            <div class="input-group form-group">
                                <asp:Label Text="Start Time" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtSTime" CssClass="form-control" />
                                <asp:MaskedEditExtender ID="meetxtSTime" runat="server" TargetControlID="txtSTime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </div>
                        </div>
                        <div class="col-lg-4" id="DivEndTime" runat="server">
                            <div class="input-group form-group">
                                <asp:Label Text="End Time" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtETime" CssClass="form-control" />
                                <asp:MaskedEditExtender ID="meetxtETime" runat="server" TargetControlID="txtETime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row _materialForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblemployee" runat="server" Text='Employee' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCode1" CssClass="txtCode1 form-control txtCode1" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode1">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                                    ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                                    TargetControlID="txtRegion" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDistributor" runat="server" Text='Distributor' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDistributor" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistributor form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                                    ContextKey="2" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetDistFromSSPlantState"
                                    MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4" id="divCustGroup">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustGroup" Text="Industry Type" CssClass="input-group-addon" runat="server" />
                                <asp:TextBox runat="server" ID="txtCustGroup" CssClass="txtCustGroup form-control" Style="background-color: rgb(250, 255, 189);" />
                                <asp:AutoCompleteExtender ID="aceCustGroup" runat="server" TargetControlID="txtCustGroup" ServiceMethod="GetCustomerGroupNameDesc" ServicePath="~/WebService.asmx"
                                    OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                                    MinimumPrefixLength="1" UseContextKey="true" OnClientPopulating="autoCustGroup_OnClientPopulating">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDealer" runat="server" Text='Dealer' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDealer" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealer form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="~/Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetDealerFromDistSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
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
                                    <asp:BoundField HeaderText="CustGroup" DataField="CustGroupDesc" HeaderStyle-Width="9%" />
                                    <asp:BoundField HeaderText="Employee" DataField="EmployeeName" HeaderStyle-Width="9%" />
                                    <asp:BoundField HeaderText="Distributor" DataField="DistributorCode" HeaderStyle-Width="20%" />
                                    <asp:BoundField HeaderText="Dealer" DataField="DealerCode" HeaderStyle-Width="20%" />
                                    <asp:BoundField HeaderText="Include" DataField="IsInclude" HeaderStyle-Width="5%" />
                                    <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="4%" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                        </asp:GridView>
                    </div>
                </div>
                <div id="tabs-3" class="tab-pane">
                    <div class="row _materialForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text='Division' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDivision" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDivision form-control" data-bv-notempty="true"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtDivisionID" runat="server" ServiceMethod="GetActiveDivision" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDivision" UseContextKey="True"></asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblInclude" runat="server" Text='Is Include' CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkInclude" Checked="true" CssClass="form-control" runat="server" />
                            </div>

                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Button ID="btnAddGroup" runat="server" Text="Add Division" CssClass="btn btn-info button" OnClientClick="return btnCheckItem();" OnClick="btnAddGroup_Click" />
                                <asp:Button ID="btnCancelGroup" runat="server" Text="Clear Division" CssClass="btn btn-warning" OnClick="btnCancelGroup_Click" />
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

            </div>
        </div>
    </div>
</asp:Content>

