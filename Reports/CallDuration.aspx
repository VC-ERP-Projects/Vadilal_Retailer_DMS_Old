<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CallDuration.aspx.cs" Inherits="Reports_CallDuration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.ddlEGroup').val();
            sender.set_contextKey(key == "" ? null : "0-" + key);
        }
        $(function () {
            Reload();
        });
        function Reload() {

            $('.fromdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.txtDate').datepicker("option", "minDate", selected);
                }
            });

            $('.txtDate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.fromdate').datepicker("option", "maxDate", selected);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                  <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate date form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="txtDate date form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeListByGroup" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acettxtEmployeeCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" CssClass="btn btn-default" OnClick="btnGenerat_Click" TabIndex="3" />&nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" TabIndex="4" />
                    </div>
                </div>
                <br />
            </div>
            <iframe id="ifmCallDuration" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmCallDuration_Load"></iframe>
        </div>
    </div>
</asp:Content>

