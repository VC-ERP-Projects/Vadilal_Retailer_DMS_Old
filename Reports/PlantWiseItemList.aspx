<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PlantWiseItemList.aspx.cs" Inherits="Reports_PlantWiseItemList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var ParentID = <%=ParentID %>;
        var CustType = '<% =CustType%>';

        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        
        function EndRequestHandler2(sender, args) {
        }
        
        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = $('.txtGroup').is(":visible") ? $('.txtGroup').val().split('-').pop() : "0";
            sender.set_contextKey(key);
        }

    </script>
    <style type="text/css">
        .ifmData {
            height: 450px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4" id="divPlant" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control" autocomplete="off" TabIndex="1"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlants"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" UseContextKey="true" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="2" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblActive" Text="Active Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlActive" CssClass="ddlActive form-control" TabIndex="3">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupName" runat="server" Text='Item Group' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtGroup" TabIndex="4" CssClass="txtGroup form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemGroupID" runat="server" ServiceMethod="GetItemGroup" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSubGroupName" runat="server" Text='Item Subgroup' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSubGroup" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSubGroup form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemSubGroupID" runat="server" ServiceMethod="GetSubGroupItem" ServicePath="../Service.asmx" OnClientPopulating="autoCompleteMatGroup_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSubGroup" UseContextKey="True"></asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="6" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                            <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="7" CssClass="btnExport btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
        </div>
        <iframe id="ifmData" style="width: 100%;" class="ifmData embed-responsive-item" runat="server" onload="ifmData_Load"></iframe>
    </div>

</asp:Content>

