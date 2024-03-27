<%@ Page Language="C#" AutoEventWireup="true" CodeFile="StockStatement.aspx.cs" MasterPageFile="~/OutletMaster.master" Inherits="Reports_StockStatement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';
        
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
            }
        }
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-0-" + "0" + "-" + EmpID);
        }

        $(document).ready(function() {
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        }); 

        function EndRequestHandler2(sender, args) {
            ChangeReportFor();
        }

        function ChangeReportFor(ddl) {

            if(CustType == 1 && $('.ddlReportBy').val() == "4")
            {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style','display:none;');
            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "2")
            {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style','display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnChange="ClearOtherConfig()" TabIndex="1" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="2" CssClass="ddlReportBy form-control" onchange="ChangeReportFor(this);">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="3" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divWarehouse" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblWarehouse" runat="server" Text="Warehouse" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlwarehouse" runat="server" TabIndex="5" CssClass="form-control" DataTextField="WhsName" DataValueField="WhsID"></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label text="Division" runat="server" cssclass="input-group-addon" />
                        <asp:dropdownlist runat="server" id="ddlDivision" AutoPostBack="true" OnSelectedIndexChanged="ddlDivision_SelectedIndexChanged" tabindex="6" cssclass="ddlDivision form-control" datatextfield="DivisionName" datavaluefield="DivisionlID">
                        </asp:dropdownlist>
                    </div>
                </div>
                 <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblItemGroup" runat="server" Text="Item Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlItemGroup" runat="server" TabIndex="7" CssClass="form-control" DataTextField="ItemGroupName" DataValueField="ItemGroupID"></asp:DropDownList>
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
            <iframe id="ifmStockStatementList" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmStockStatementList_Load"></iframe>
        </div>
    </div>
</asp:Content>
