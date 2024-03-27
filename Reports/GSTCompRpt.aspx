<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="GSTCompRpt.aspx.cs" Inherits="Reports_GSTCompRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        $(function () {
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-" + EmpID);
        }
        function ChangeReportFor(SelType) {
            if ($('.ddlDistSel').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlDistSel').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
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
                        <asp:Label Text="Status" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlMatchingStatus" TabIndex="1" runat="server" CssClass="form-control">
                            <%--<asp:ListItem Text="---- All ----" Value="0" />--%>
                            <asp:ListItem Text="Mismatch" Value="1" Selected="True" />
                            <asp:ListItem Text="Match" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="DMS Form Status" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlDMSStatus" runat="server" TabIndex="2" CssClass="form-control">
                            <%--<asp:ListItem Text="---- All ----" Value="0" />--%>
                            <asp:ListItem Text="Varified" Value="2" Selected="True" />
                            <asp:ListItem Text="Not Varified" Value="1" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Distributor / SS" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlDistSel" runat="server" TabIndex="3" CssClass="ddlDistSel form-control" OnChange="ChangeReportFor('2');">
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                            <asp:ListItem Text="Super Stokiest" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divEmpCode" runat="server">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" TabIndex="4" OnChange="ClearOtherConfig()" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListTillM4" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" onchange="ClearOtherSSConfig()" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="6" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                     <asp:Button Text="Export To Excel" ID="btnExport" CssClass="btn btn-default" TabIndex="7" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>


            </div>
            <iframe id="ifmBeatSummary" style="width: 100%" class="embed-responsive-item" runat="server"></iframe>
        </div>
    </div>

</asp:Content>

