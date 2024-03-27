<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimBalanceDetailRpt.aspx.cs" Inherits="Reports_ClaimBalanceDetailRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        $(function () {
            Reload();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor('1');
        }

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployeeCode').is(":visible") ? $('.txtEmployeeCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmployeeCode').is(":visible") ? $('.txtEmployeeCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-0-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            // var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtEmployeeCode').is(":visible") ? $('.txtEmployeeCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-0-" + EmpID);
        }

        function ChangeReportFor(ReportBy) {
            if ($('.ddlOption').val() == "4") {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.ddlReportType').val(0);
                }
                $('.divSS').removeAttr('style');
                $('.ddlReportType').attr('style', 'display:none;');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlOption').val() == "2") {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.ddlReportType').val(0);
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
                $('.ddlReportType').removeAttr('style');
            }
        }

        function Reload() {

            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //minDate: new Date(2017, 6, 1),
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                }
            });

            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                //minDate: new Date(2017, 6, 1),
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });

            $('.ddlReportType').change(function () {
                if ($('.ddlReportType').is(":visible")) {
                    if ($('.ddlReportType').val() == 0) {
                        //$('#divDlrOption').show();
                    }
                    else {
                        //$('#divDlrOption').hide();
                    }
                }
            }).change();
        }

        function ClearOtherConfig() {
            if ($(".txtEmployeeCode").length > 0) {
                $(".txtCode").val('');
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtDistCode").val('');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmployeeCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtEmployeeCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmployeeCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" TabIndex="4" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divRegion" runat="server">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="5" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblOption" runat="server" Text="Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="6" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Distributor Wise" Value="2" Selected="True" />
                            <asp:ListItem Text="SS wise Balance Summary" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS">
                    <div class="input-group form-group divSS">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor">
                    <div class="input-group form-group divDistributor">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="lblCustomer input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode" BehaviorID="CustomerCode"
                            OnClientPopulating="autoCompleteDistriCode_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 ddlReportType">
                    <div class="input-group form-group ddlReportType" id="divReportType">
                        <asp:Label ID="lblType" runat="server" Text="Report Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportType" CssClass="ddlReportType form-control" TabIndex="9">
                            <asp:ListItem Text="All Transaction" Value="0" Selected="True" />
                            <asp:ListItem Text="Balance Amount" Value="1" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="10" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="11" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <iframe id="ifmClaimBalDetail" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmClaimBalDetail_Load"></iframe>
</asp:Content>

