<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="NoSaleEmailSMS.aspx.cs" Inherits="Master_NoSaleEmailSMS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>

    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            load();
            ChangePeriod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            load();
        }

        function load() {
            $(".gvScheduleData").tableHeadFixer('40vh');
            ChangePeriod();
            AppliForChange("0");
            $('.dataTables_scrollBody').on('scroll', function () {
                if ($('.dataTables_scrollBody').scrollTop() != 0)
                    $.cookie("ScrollLastPos", $('.dataTables_scrollBody').scrollTop());
            });
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("NoSaleEmailSMS", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("NoSaleEmailSMS") + '"]').tab('show');
        }
        function SetActiveTab(index) {
            $.cookie('NoSaleEmailSMS', index);
            load();
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-0-0-0-" + EmpID);
        }
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
            var dist = $('.txtDistributor').is(":visible") ? $('.txtDistributor').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + "0" + "-" + dist + "-" + EmpID);
        }
        function onAutoCompleteSelected(sender, e) {
            __doPostBack(sender.get_element().name, null);
        }
        function ChangePeriod() {
            if ($('.ddlSchedulePeriod').val() == 'Daily') {
                $('.lblFrequency').text("Alternate Day");
            }
            else if ($('.ddlSchedulePeriod').val() == 'Weekly') {
                $('.lblFrequency').text("Alternate Week");
            }
            else {
                $('.lblFrequency').text("Alternate Month");
            }
        }

        function AppliForChange(txt) {
            $('.divDistRegion').attr('style', 'display:none');
            $('.divEmp').attr('style', 'display:none');
            $('.divEmpCat').attr('style', 'display:none');
            $('.divDistributor').attr('style', 'display:none');

            if ($('.ddlMessageTo').val() == 'Distributor') {
                $('.divDistRegion').removeAttr('style');
                $('.divDistributor').removeAttr('style');
                if (txt == "1") {
                    $(".txtDistRegion").val('');
                    $(".txtDistributor").val('');
                    $(".txtDealerCode").val('');
                }
            }
            else if ($('.ddlMessageTo').val() == 'Employee Category') {
                $('.divEmp').removeAttr('style');
                $('.divEmpCat').removeAttr('style');
                if (txt == "1") {
                    $(".ddlEmpCategory").prop('selectedIndex', 0);
                    $(".txtDealerCode").val('');
                    $(".txtCode").val('');
                }
            }
        }
        function ClearOtherConfig() {
            if ($(this).length > 0) {
                $(".txtDistributor").val('');
                $(".txtDealerCode").val('');
            }
        }
        function ClearDealerConfig() {
            if ($(this).length > 0) {
                $(".txtDealerCode").val('');
            }
        }
        function ChangeTime() {
            var Time = $('.txtTime').val();
            if (Time > 24) {
                ModelMsg('Please select proper time', 3)
                $('.txtTime').val('');
                return false;
            }
        }
    </script>
    <style>
        .gvScheduleData {
            font-size: 11px;
        }

            .gvScheduleData > tbody > tr > td {
                padding: 1px 4px;
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

        .button {
            margin-right: 5px;
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
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="No" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNo" OnTextChanged="txtNo_TextChanged" CssClass="form-control"
                            data-bv-notempty="true" data-bv-notempty-message="Field is required" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtNo" runat="server" ServiceMethod="GetNoSaleEmailSms"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onAutoCompleteSelected"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtNo" UseContextKey="True"
                            Enabled="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" CssClass="input-group-addon" Text="StartDate/Time"></asp:Label>
                        <table width="100%">
                            <tr>
                                <td>
                                    <asp:TextBox runat="server" ID="txtSDate" onfocus="this.blur();" CssClass="fromdate form-control" />
                                </td>
                                <td>
                                    <asp:TextBox ID="txtTime" runat="server" CssClass="txtTime form-control" MaxLength="2" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);" onchange="ChangeTime();"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" CssClass="input-group-addon" Text="Active"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="chkIsActive form-control" Checked="true" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Next Schedule Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNextRunDate" disabled="disabled" TabIndex="2" MaxLength="10" CssClass="form-control" />
                    </div>
                </div>
                <div style="float: right; margin-right: 40px;">
                    <input type="hidden" id="hdnIsActive" class="hdnIsActive" runat="server" />

                    <asp:Button ID="btnSubmit" CssClass="btn btn-success" runat="server" Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" ValidationGroup="cmgroup" />
                    <asp:Button ID="btnCancel" CssClass="btn btn-danger" runat="server" Text="Cancel" UseSubmitBehavior="false" CausesValidation="false" OnClick="btnCancel_Click" />
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab">Customer/Employee</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblAct" runat="server" Text="Message Period" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlSchedulePeriod" CssClass="form-control ddlSchedulePeriod" onchange="ChangePeriod();">
                                    <%--<asp:ListItem Text="One Time" Value="O" visible="false" />--%>
                                    <asp:ListItem Text="Daily" Value="Daily" Selected="True" />
                                    <asp:ListItem Text="Weekly" Value="Weekly" />
                                    <asp:ListItem Text="Monthly" Value="Monthly" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblFrequency" runat="server" CssClass="input-group-addon lblFrequency" Text=""></asp:Label>
                                <asp:TextBox ID="txtDay" runat="server" CssClass="txtDay form-control" MaxLength="3" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblinvoiceXdays" runat="server" CssClass="input-group-addon" Text="Last Invoice 'X' Days"></asp:Label>
                                <asp:TextBox ID="txtLastInvXdays" runat="server" MaxLength="3" CssClass="txtLastInvXdays form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-lg-8 WeekDays" style="display: none">
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

                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <div id="tabs-2" class="tab-pane">
                    <div class="row _masterForm">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Message To" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlMessageTo" CssClass="ddlMessageTo form-control " TabIndex="1" onchange="AppliForChange(1);" OnSelectedIndexChanged="ddlMode_SelectedIndexChanged" AutoPostBack="true">
                                    <asp:ListItem Text="Distributor" Value="Distributor" Selected="True" />
                                    <asp:ListItem Text="Employee Category" Value="Employee Category" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4 divEmpCat">
                            <div class="input-group form-group">
                                <asp:Label ID="lblEmpCat" runat="server" Text="Employee Category" TabIndex="2" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlEmpCategory" CssClass="ddlEmpCategory form-control"
                                    DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-lg-4 divEmp" id="divEmpCode" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4 divDistRegion" id="divRegion" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lblRegion" runat="server" Text='Dist. Region' CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDistRegion" CssClass="txtDistRegion form-control" runat="server" onchange="ClearOtherConfig();" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                                    ServiceMethod="GetDistributorRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtDistRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDistributor" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" onchange="ClearDealerConfig();" CssClass="txtDistributor form-control" autocomplete="off"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtDist" runat="server"
                                    ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetDistCurrHierarchy" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                                    CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                            <div class="input-group form-group">
                                <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                                </asp:AutoCompleteExtender>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblactive" runat="server" CssClass="input-group-addon" Text="Is Active"></asp:Label>
                                <asp:CheckBox ID="chkActive" runat="server" TabIndex="7" CssClass="chkActive form-control" Checked="true" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblIsInclude" runat="server" CssClass="input-group-addon" Text="Is Include"></asp:Label>
                                <asp:CheckBox ID="chkIsInclude" runat="server" TabIndex="8" CssClass="chkIsInclude form-control" Checked="true" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Button ID="btnAddScheduleData" runat="server" TabIndex="9" Text="Add" CssClass="btn btn-info button" OnClick="btnAddScheduleData_Click" />
                                <asp:Button ID="btnCancleScheduleData" runat="server" TabIndex="10" Text="Clear" CssClass="btn btn-warning" OnClick="btnCancleScheduleData_Click" />
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-12">
                            <asp:GridView runat="server" ID="gvScheduleData" Width="100%" Style="font-size: 10px;" AutoGenerateColumns="false" CssClass="table gvScheduleData" HeaderStyle-CssClass="table-header-gradient"
                                EmptyDataText="No Record Found." OnRowCommand="gvSchedule_RowCommand">
                                <Columns>
                                    <asp:TemplateField HeaderText="No.">
                                        <ItemTemplate>
                                            <asp:Label ID="lblGNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        </ItemTemplate>
                                        <HeaderStyle Width="2%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CommandName="editData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="2%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnDetails" runat="server" Text="Delete" CommandName="deleteData" CommandArgument='<%# Container.DataItemIndex  %>'></asp:LinkButton>
                                        </ItemTemplate>
                                        <HeaderStyle Width="3%" />
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Employee Group" DataField="EmpGroup" HeaderStyle-Width="6%" />
                                    <asp:BoundField HeaderText="Employee" DataField="EmpName" HeaderStyle-Width="12%" />
                                    <asp:BoundField HeaderText="Region" DataField="RegionName" HeaderStyle-Width="6%" />
                                    <asp:BoundField HeaderText="Distributor" DataField="DistributorCode" HeaderStyle-Width="15%" />
                                    <asp:BoundField HeaderText="Dealer" DataField="DealerCode" HeaderStyle-Width="15%" />
                                    <asp:BoundField HeaderText="Include" DataField="IsInclude" HeaderStyle-Width="5%" />
                                    <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="4%" />
                                    <asp:BoundField HeaderText="Created Date" DataField="CreatedDate" HeaderStyle-Width="6%" DataFormatString="{0:dd/MM/yy HH:mm}" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
