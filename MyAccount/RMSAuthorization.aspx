<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="RMSAuthorization.aspx.cs" Inherits="MyAccount_RMSAuthorization" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
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
            $(".gvAuthorization").tableHeadFixer('70vh');
            SetHeadCheckValues();
        }

        function SetHeadCheckValues() {
            if ($('.chkNotification').length == $('.chkNotification').filter(':checked').length)
                $('.chkMainNotification').prop('checked', true);
            else
                $('.chkMainNotification').prop('checked', false);

            if ($('.chkCheck').length == $('.chkCheck').filter(':checked').length)
                $('.chkMainCheck').prop('checked', true);
            else
                $('.chkMainCheck').prop('checked', false);

            if ($('.chkWrite').length == $('.chkWrite').filter(':checked').length)
                $('.chkHeadWrite').prop('checked', true);
            else
                $('.chkHeadWrite').prop('checked', false);
        }
        function CheckMain(chk, classname) {
            if ($(chk).is(':checked')) {
                $('.' + classname).prop('checked', true);
            }
            else {
                $('.' + classname).prop('checked', false);
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
    <style type="text/css">
        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td {
            padding: 3px 8px 10px;
        }

        .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 3px 8px 2px;
        }

        .chkMainNotification, .chkHeadWrite, .chkMainCheck {
            vertical-align: middle;
            margin: 0 !important;
        }

        .txtPriority {
            height: 26px;
        }

        .table select {
            height: 26px;
            padding: 0px 12px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" AutoPostBack="True" OnSelectedIndexChanged="ddlEGroup_SelectedIndexChanged" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck"
                            DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblIsActive" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox runat="server" ID="chkIsActive" Checked="true" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="buttons" style="margin: 0 1% 1% auto;">
                <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
            </div>
            <asp:GridView ID="gvAuthorization" runat="server" AutoGenerateColumns="False" OnPreRender="gvAuthorization_PreRender" CssClass="table gvAuthorization" HeaderStyle-CssClass="table-header-gradient" DataKeyNames="MenuID" OnRowDataBound="gvAuthorization_RowDataBound" EmptyDataText="No Menu Found.">
                <Columns>
                    <asp:TemplateField HeaderText="Menu">
                        <ItemTemplate>
                            <asp:Label ID="lblMenuID" runat="server" Text='<%# Bind("MenuID") %>' Visible="false"></asp:Label>
                            <asp:Label ID="lblName" runat="server" Text='<%# Bind("MenuName") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle />
                        <HeaderStyle Width="20%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Priority">
                        <ItemTemplate>
                            <asp:TextBox ID="txtPriority" CssClass="txtPriority form-control" runat="server" MaxLength="3"
                                onkeyup="enter(this);" onBlur="ResetColor()" onFocus="ChangeColor()" onkeypress="return isNumberKey(event);"></asp:TextBox>
                        </ItemTemplate>
                        <HeaderStyle Width="7%" />
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <span>Display</span>
                            <input type="checkbox" name="chkHeadWrite" id="chkHeadWrite" class="chkHeadWrite" runat="server" onchange="CheckMain(this,'chkWrite');" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkWrite" id="chkWrite" class="chkWrite" runat="server" onchange="SetHeadCheckValues();" />
                        </ItemTemplate>
                        <HeaderStyle Width="5%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Customer Selection">
                        <ItemTemplate>
                            <asp:DropDownList ID="ddlMenuType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Compulsory" Value="1" />
                                <asp:ListItem Text="Not Compulsory" Value="2" />
                                <asp:ListItem Text="Both" Value="3" />
                            </asp:DropDownList>
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Call Type">
                        <ItemTemplate>
                            <asp:DropDownList ID="ddlCallType" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Productivity" Value="1" />
                                <asp:ListItem Text="Non Productivity" Value="2" />
                                <asp:ListItem Text="None" Value="3" />
                            </asp:DropDownList>
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <span>Notification</span>
                            <input type="checkbox" name="chkMainNotification" id="chkMainNotification" class="chkMainNotification" runat="server" onchange="CheckMain(this,'chkNotification');" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkNotification" id="chkNotification" class="chkNotification" runat="server" onchange="SetHeadCheckValues();" />
                        </ItemTemplate>
                        <HeaderStyle Width="6%" />
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <span>Mandatory</span>
                            <input type="checkbox" name="chkMainCheck" id="chkMainCheck" class="chkMainCheck" runat="server" onchange="CheckMain(this,'chkCheck');" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="SetHeadCheckValues();" />
                        </ItemTemplate>
                        <HeaderStyle Width="6%" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

