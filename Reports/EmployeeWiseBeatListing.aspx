<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmployeeWiseBeatListing.aspx.cs" Inherits="Reports_EmployeeWiseBeatListing" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;

        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

        });
        function EndRequestHandler2(sender, args) {
             
        }

        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.ddlEGroup').val();
            sender.set_contextKey(key);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>

                </div>
                <div class=" col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="4" Checked="true" runat="server" CssClass="chkIsDetail form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblBeatStatus" runat="server" Text="Beat Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlBeatStatus" TabIndex="8" runat="server" CssClass="ddlBeatStatus form-control">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Beat Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlBeatOption" TabIndex="4" runat="server" CssClass="ddlBeatOption form-control">
                            <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                            <asp:ListItem Text="Distributor" Value="2" />
                            <asp:ListItem Text="Super Stockist" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmpStatus" runat="server" Text="Employee Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlEmpStatus" TabIndex="8" runat="server" CssClass="ddlEmpStatus form-control">
                            <asp:ListItem Text="Active" Value="1" Selected="True" />
                            <asp:ListItem Text="In-Active" Value="0" />
                            <asp:ListItem Text="All" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="6" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="7" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                        &nbsp
                     <asp:Button Text="Export Beat Dump" ID="btnExportBeatDump" TabIndex="7" CssClass="btn btn-default" runat="server" OnClick="btnExportBeatDump_Click" />
                    </div>
                </div>
            </div>
            <iframe id="ifmBeatlisting" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmBeatlisting_Load"></iframe>
        </div>
    </div>
</asp:Content>


