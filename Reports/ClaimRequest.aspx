<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimRequest.aspx.cs" Inherits="Reports_ClaimRequest" EnableEventValidation="false" %>

<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + "0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            Reload();
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor();
        }

        function ChangeReportFor(ddl) {

            if (CustType == 1 && $('.ddlReportBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if (CustType == 1 && $('.ddlReportBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }

        function Reload() {

            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 3, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
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
                minDate: new Date(2014, 3, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });
        }

        function HideShowPEN(ddl) {
            var ddlStatus = $('.ddlStatus').val();
            var val = ddl.value;
            $(".txtManager").val('');
            if (val == "1" || val == "0")
                $(".txtManager").prop("disabled", false);
            else
                $(".txtManager").prop("disabled", true);
        }

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtDistCode").val('');
                $(".txtRptForID").val('');
                $(".txtManager").val('');
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
                        <asp:Label Text="Option" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlOption" TabIndex="1" class="ddlOption" CssClass="ddlOption form-control">
                            <asp:ListItem Text="Entry Date" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Claim Date" Value="2"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="2" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" OnChange="ClearOtherConfig()" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="5" CssClass="ddlReportBy form-control" onchange="ChangeReportFor(this);">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="6" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divReportFor" id="divReportFor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRptForCode" runat="server" Text="Report For (USER)" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRptForID" runat="server" TabIndex="9" CssClass="form-control txtRptForID" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetApprovalEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtRptForID">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPendingFrom" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblManager" runat="server" Text="Pending From" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtManager" runat="server" CssClass="form-control txtManager" TabIndex="10" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtManagerCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetApprovalEmployee" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtManager">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divclaimtype" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblreasoncode" Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox ID="txtCustomer" runat="server" Width="150px"  Visible="false"/>
                        <asp:HiddenField ID="hfCustomerId" runat="server" />
                        <%--<cc1:DropDownExtender runat="server" DropDownControlID="pnlComboDropDownList" TargetControlID="txtCustomer" />--%>
                        <asp:Panel runat="server" ID="pnlComboDropDownList" Style="display: none; visibility: hidden;">
                            <asp:GridView ID="gvCustomers" runat="server" AutoGenerateColumns="false" 
                                OnSelectedIndexChanged="OnSelectedIndexChanged" ShowHeader="false" Visible="false">
                                <RowStyle BackColor="Azure" />
                                <Columns>
                                    <asp:BoundField DataField="ReasonName" HeaderText="Id" />
                                    <asp:BoundField DataField="ReasonID" HeaderText="Name" />
                                     
                                </Columns>
                            </asp:GridView>
                        </asp:Panel>
                        <asp:DropDownList ID="ddlMode" runat="server" TabIndex="11" CssClass="form-control" ></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divclaimStatus" runat="server"> 
                    <div class="input-group form-group">
                        <asp:Label Text="Claim Last Status" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlStatus" class="ddlStatus" TabIndex="12" CssClass="ddlStatus form-control" onchange="HideShowPEN(this);">
                            <asp:ListItem Text="---Select---" Value="0" Selected="True" />
                            <asp:ListItem Text="Pending" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Error" Value="2"></asp:ListItem>
                            <asp:ListItem Text="Success" Value="3"></asp:ListItem>
                            <asp:ListItem Text="Delete" Value="6"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divdetail" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsDetail" runat="server" Text="Is Detail" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsDetail" TabIndex="13" Checked="true" runat="server" CssClass="chkIsDetail form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="14" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" TabIndex="15" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                </div>
            </div>
        </div>
        <div class="embed-responsive embed-responsive-16by9">
            <iframe id="ifmClaimReq" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmClaimReq_Load"></iframe>
        </div>
    </div>
</asp:Content>

