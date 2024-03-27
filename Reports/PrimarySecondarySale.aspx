<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="PrimarySecondarySale.aspx.cs" Inherits="Reports_PrimarySecondarySale" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }
        function ReLoadFn() {

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            ReportOptionChange();

        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            sender.set_contextKey(Region + "-2-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "";
            
            sender.set_contextKey(EmpID);
        }
        
        function ClearOnChangeEmp() {
            $('.txtDistCode').val('');
            $('.txtRegion').val('');
        }
        function ClearOnChangeRegion() {
            $('.txtDistCode').val('');
        }
        function ReportOptionChange() {
            $('.txtDistCode').val('');
            $('.txtCode').val('');
            $('.txtRegion').val('');
            $('.ddlDivision').val('3');

            //$('#divEmpCode').show();
            //$('#divDistributor').show();

            if ($('.ddlReportOption').val() == '1')
                $('#divEmpCode').show();
            else
                $('#divEmpCode').hide();

            if ($('.ddlReportOption').val() == '1' || $('.ddlReportOption').val() == '2')
                $('#divDistributor').show();
            else
                $('#divDistributor').hide();
        }
    </script>
    <style type="text/css">
        .ui-datepicker-calendar {
            display: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Report Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlReportOption" OnChange="ReportOptionChange();" TabIndex="1" runat="server" CssClass="ddlReportOption form-control">
                            <asp:ListItem Text="Territory Head + Region + City + Distributor Wise" Value="1" Selected="True" />
                            <asp:ListItem Text="Region + City + Distributor Wise" Value="2" />
                            <asp:ListItem Text="Region + City Wise" Value="3" />
                            <asp:ListItem Text="Region Wise" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="2" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" >
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" onChange="ClearOnChangeEmp();" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="lblRegion input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" onChange="ClearOnChangeRegion();" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesStoreHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" >
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistributorCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Month" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromMonth" TabIndex="6" runat="server" MaxLength="7" CssClass="onlymonth form-control" ></asp:TextBox>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" Text="Week" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlWeek" TabIndex="7" runat="server" CssClass="form-control">
                            <asp:ListItem Text="First" Value="1" Selected="True" />
                            <asp:ListItem Text="Second" Value="2" />
                            <asp:ListItem Text="Third" Value="3" />
                            <asp:ListItem Text="Fourth" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="8" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>

