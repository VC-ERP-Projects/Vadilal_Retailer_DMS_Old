<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/OutletMaster.master" CodeFile="ConsumeWasteMaterial.aspx.cs" Inherits="Reports_ConsumeWasteMaterial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;

        $(function () {
            //if (CustType == 1) {
            ChangeReportFor('1');
            ChengeReportReason('M');
            
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
            ChengeReportReason('M');
        }

        function ChengeReportReason(ReportReason) {
            if ($('.ddltype').val() == "M") {
                $('#divreason').attr('style', 'display:none;');
            }
            else {
                $('#divreason').removeAttr('style');
            }
        }

        function ChangeReportFor(ReportBy) {

            if ($('.ddlReportBy').val() == "4") {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtdealer').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divCustomer').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                
            }
            else  {
                if (ReportBy == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtdealer').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divCustomer').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            //else {
            //    if (ReportBy == "2") {
            //        $('.txtSSDistCode').val('');
            //        $('.txtCustCode').val('');
            //        $('.txtdealer').val('');
            //    }
            //    $('.divCustomer').attr('style', 'display:none;');
            //    $('.divSS').attr('style', 'display:none;');
            //    $('.divDealer').removeAttr('style');
            //}
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-0-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-0-0-" + EmpID);
        }

        function autoCompleteDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            //var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-0-0-0-" + EmpID);
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtCustCode").val('');
                $(".txtdealer").val('');
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
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="4" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="type" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddltype" TabIndex="5" runat="server" CssClass="form-control ddltype" onchange="ChengeReportReason('M');">
                            <asp:ListItem Value="M">Consume</asp:ListItem>
                            <asp:ListItem Value="W">Wastage</asp:ListItem>
                            <%--<asp:ListItem Value="R">Return</asp:ListItem>
                            <asp:ListItem Value="A">Auto Consume</asp:ListItem>--%>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Report By" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlReportBy" TabIndex="6" runat="server" CssClass="ddlReportBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                            <%--<asp:ListItem Text="Dealer" Value="3" />--%>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblItemGroup" runat="server" Text="Item Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlItemGroup" runat="server" TabIndex="7" CssClass="form-control" DataTextField="ItemGroupName" DataValueField="ItemGroupID"></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divreason">
                    <div class="input-group form-group">
                        <asp:Label ID="lblReason" runat="server" Text="Reason" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlReason" runat="server" TabIndex="8" CssClass="form-control" DataTextField="ReasonName" DataValueField="ReasonID"></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" runat="server" id="divSS">
                    <div class="input-group form-group divSS">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divCustomer" runat="server" id="divCustomer">
                    <div class="input-group form-group divCustomer">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="10" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="11" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <iframe id="ifmConsumeWasteMaterial" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmConsumeWasteMaterial_Load"></iframe>
        </div>
        <%--<div class="input-group form-group divDealer" id="divDealer" runat="server">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtdealer form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer">
                        </asp:AutoCompleteExtender>
                    </div>--%>
    </div>
</asp:Content>
