<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="RetailerAuthorization.aspx.cs" Inherits="MyAccount_RetailerAuthorization" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/fixedheader/defaultTheme.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">
        $(function () {
            ReloadRadio();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndHandler);
        });

        function EndHandler(sender, args) {
            ReloadRadio();
        }

        function ReloadRadio() {
            $(".gvAuthorization").tableHeadFixer('63vh');
            SetHeadCheckValues();
        }

        function SetHeadCheckValues() {
            if ($('.Write').find('input').length == $('.Write').find('input:checked').length)
                $('.HeadWrite').find('input').prop('checked', true);
            else
                $('.HeadWrite').find('input').prop('checked', false);

            if ($('.Read').find('input').length == $('.Read').find('input:checked').length)
                $('.HeadRead').find('input').prop('checked', true);
            else
                $('.HeadRead').find('input').prop('checked', false);

            if ($('.None').find('input').length == $('.None').find('input:checked').length)
                $('.HeadNone').find('input').prop('checked', true);
            else
                $('.HeadNone').find('input').prop('checked', false);
        }


        function ClickHead(chk, classname) {
            if ($(chk).find('input').is(':checked')) {
                if (classname == "Write") {
                    $('.' + classname).find('input').prop('checked', true);
                }
                else if (classname == "Read") {
                    $('.' + classname).find('input').prop('checked', true);
                }
                else if (classname == "None") {
                    $('.' + classname).find('input').prop('checked', true);
                }
            }
            else {
                $('.' + classname).find('input').prop('checked', false);
            }
        }

        function ClearAll() {
            $('.Write').find('input').prop('checked', false);
            $('.Read').find('input').prop('checked', false);
            $('.None').find('input').prop('checked', false);
            $('.HeadWrite').find('input').prop('checked', false);
            $('.HeadRead').find('input').prop('checked', false);
            $('.HeadNone').find('input').prop('checked', false);
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        function autoCompleteState_OnClientPopulating(sender, args) {
            var countryId = 1;
            sender.set_contextKey(countryId);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(reg + "-0-0-0");
        }

    </script>
    <style type="text/css">
        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td {
            padding: 3px 8px 6px;
        }

        .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 3px 8px 2px;
        }

        .HeadWrite, .HeadNone {
            vertical-align: middle;
        }

        .txtPriority {
            height: 26px;
        }

        .table > tbody > tr > th:nth-child(n) span {
            vertical-align: top;
        }

            .table > tbody > tr > th:nth-child(n) span input {
                margin: 0;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">

                <div class="col-lg-4" id="divEmpGroup" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" AutoPostBack="True" OnSelectedIndexChanged="ddlEGroup_SelectedIndexChanged" CssClass="form-control" data-bv-callback-message="Select Value"
                            DataTextField="EmpGroupName" DataValueField="EmpGroupID" TabIndex="1">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="div1" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label ID="Label3" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmployee" runat="server" CssClass="form-control txtEmployee" OnTextChanged="txtEmployee_TextChanged" AutoPostBack="true" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmployee">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <%--  <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="7" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>--%>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group" runat="server">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" AutoPostBack="true" TabIndex="3" OnTextChanged="txtRegion_TextChanged" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetIndianStates"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistributor" runat="server" Text='Distributor' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistributor" runat="server" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true" OnTextChanged="txtDistributor_TextChanged" CssClass="txtDistributor form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            ContextKey="2" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetDistFromSSPlantState"
                            MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divCustGroup">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustGroup" Text="Customer Group" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtCustGroup" CssClass="txtCustGroup form-control" Style="background-color: rgb(250, 255, 189);" AutoPostBack="true" OnTextChanged="txtCustGroup_TextChanged" TabIndex="14" />
                        <asp:AutoCompleteExtender ID="aceCustGroup" runat="server" TargetControlID="txtCustGroup" ServiceMethod="GetCustomerGroupNameDesc" ServicePath="~/WebService.asmx"
                            OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                            MinimumPrefixLength="1" UseContextKey="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDealer" runat="server" Text='Dealer' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealer" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealer form-control" AutoPostBack="true" OnTextChanged="txtDealer_TextChanged"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromDistSSPlantState" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealer">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="active" runat="server" visible="false">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblIsActive" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox runat="server" ID="chkIsActive" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblUpdateBy" Text="Update By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtUpdateBy" CssClass="form-control" disabled="disabled" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblUpdatedDate" Text="Updated Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtUpdatedDate" CssClass="form-control" disabled="disabled" />
                    </div>
                </div>
            </div>
            <div class="buttons" style="margin: 0 1% 1% auto;">
                <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
                <asp:Button ID="btnPriority" runat="server" Text="Change Priority" CssClass="btn btn-default" Visible="false" OnClick="btnSubmitPriority_Click" OnClientClick="return _btnCheck();" />
            </div>
            <div id="divCustomer" class="col-lg-12" style="max-height: 398px;">
                <asp:GridView ID="gvAuthorization" runat="server" AutoGenerateColumns="False" CssClass="gvAuthorization table" Width="100%" OnPreRender="gvAuthorization_PreRender"
                    HeaderStyle-CssClass="table-header-gradient" DataKeyNames="MenuID" OnRowDataBound="gvAuthorization_RowDataBound" EmptyDataText="No Menu Found.">
                    <Columns>
                        <asp:TemplateField HeaderText="Menu">
                            <ItemTemplate>
                                <asp:Label ID="lblMenuID" runat="server" Text='<%# Bind("MenuID") %>' Visible="false"></asp:Label>
                                <asp:Label ID="lblName" runat="server" Text='<%# Bind("MenuName") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle />
                            <HeaderStyle Width="47%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Priority">
                            <ItemTemplate>
                                <asp:TextBox ID="txtPriority" CssClass="txtPriority form-control" runat="server" MaxLength="3" Text='<%# Bind("SortOrder") %>'
                                    onkeyup="enter(this);" onBlur="ResetColor()" onFocus="ChangeColor()" onkeypress="return isNumberKey(event);"></asp:TextBox>
                            </ItemTemplate>
                            <HeaderStyle Width="7%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Write">
                            <HeaderTemplate>
                                <asp:Label Text="Write" runat="server" />
                                <asp:RadioButton GroupName="head" ID="chkHeadWrite" runat="server" class="HeadWrite" onchange="ClickHead(this,'Write');" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:RadioButton GroupName='<%# Bind("MenuID") %>' ID="chkWrite" runat="server" class="Write" onchange="SetHeadCheckValues();" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="None">
                            <HeaderTemplate>
                                <asp:Label Text="None" runat="server" />
                                <asp:RadioButton GroupName="head" ID="chkHeadNone" runat="server" class="HeadNone" onchange="ClickHead(this,'None');" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:RadioButton GroupName='<%# Bind("MenuID") %>' ID="chkNone" runat="server" class="None" onchange="SetHeadCheckValues();" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
