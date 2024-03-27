<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="SchemeMasterReport.aspx.cs" Inherits="Reports_SchemeMasterReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function acetxtCustName_OnClientPopulating(sender, args) {
            if ($('.txtCustCode').val() != undefined) {
                var key = $('.txtCustCode').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSchemeType" runat="server" Text="SchemeType" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddltype" TabIndex="1" CssClass="form-control">
                            <asp:ListItem Text="Master" Value="M" />
                            <asp:ListItem Text="QPS" Value="S" />
                            <asp:ListItem Text="Machine Discount" Value="D" />
                            <asp:ListItem Text="Parlour Discount" Value="P" />
                            <asp:ListItem Text="VRS Discount" Value="V" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="2" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStateNames"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="3" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                            ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divDealer" runat="server">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="5" CssClass="form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetChildCustomer" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="6" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="7" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" TabIndex="8" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />&nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="9" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
            <iframe id="ifmEmployee" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmEmployee_Load"></iframe>
        </div>
    </div>
</asp:Content>

