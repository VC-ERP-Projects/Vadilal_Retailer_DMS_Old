<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="RegionWisePriceList.aspx.cs" Inherits="Reports_RegionWisePriceList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            _ChangeSelection($('.ddlPriceList'));
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            _ChangeSelection($('.ddlPriceList'));
        }

        function _ChangeSelection(ddl) {
            if ($(ddl).val() == '3') {
                $('.divDistributor').show();
                $('.divDealerType').show();
            }
            else {
                $('.divDistributor').hide();
                $('.divDealerType').hide();
            }
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div id="divEmpCode" runat="server" class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" TabIndex="1" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" TabIndex="2" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPriceList" runat="server" Text="Pricing Of" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="3" ID="ddlPriceList" CssClass="ddlPriceList form-control" onchange="_ChangeSelection(this);">
                            <asp:ListItem Value="2">Distributor Pricing</asp:ListItem>
                            <asp:ListItem Value="3">Dealer Pricing</asp:ListItem>
                            <asp:ListItem Value="4">SS Pricing</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" TabIndex="4" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="5" Checked="true" runat="server" CssClass="chkIsDetail form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group divDistributor" id="divDistributor" runat="server" style="display: none">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="6" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group divDealerType" id="divDealerType" runat="server" style="display: none">
                        <asp:Label ID="lblDealerType" runat="server" Text="Dealer Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" TabIndex="7" ID="ddlDealerType" CssClass="ddlDealerType form-control">
                            <asp:ListItem Value="1">With Temporary Dealer</asp:ListItem>
                            <asp:ListItem Value="0">Without Temporary Dealer</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="8" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                    <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="9" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <iframe id="ifmRegionWisePriceList" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmRegionWisePriceList_Load"></iframe>
        </div>
    </div>
</asp:Content>

