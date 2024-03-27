<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmailConfiguration.aspx.cs" Inherits="MyAccount_EmailConfiguration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            laod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            laod();
        }

        function laod() {
            $('.fht-tbody').css('max-height', '400px');
            $(".txtConfigSearch").keyup(function () {
                var word = this.value;
                $(".gvEmailConfig > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" CssClass="input-group-addon" Text="Plant"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" CssClass="form-control" AutoPostBack="true"
                            autocomplete="off" OnTextChanged="txtPlant_TextChanged" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtPlant" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPlant" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblType" Text="Type" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlType" TabIndex="7" CssClass="form-control">
                            <asp:ListItem Text="Purchase" Value="P" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="display: none;">
                        <asp:Label ID="lblCopyFromPlant" runat="server" CssClass="input-group-addon" Text="Copy from Plant"></asp:Label>
                        <asp:TextBox ID="txtCopyFrmPlant" runat="server" CssClass="form-control" AutoPostBack="true" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtCopyFromPlant" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPlant" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCopyFrmPlant">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblActive" runat="server" CssClass="input-group-addon" Text="Is Active"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSucessEmail" runat="server" CssClass="input-group-addon" Text="Sucess Email-ID"></asp:Label>
                        <asp:TextBox ID="txtSucessEmail" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblSucessMsgMobile" runat="server" CssClass="input-group-addon" Text="Sucess Mobile No."></asp:Label>
                        <asp:TextBox ID="txtSucessMsgMobile" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAddConfig" CssClass="btn btn-default" runat="server" Text="Add Configuration" OnClick="btnAddConfig_Click" OnClientClick="return _btnCheck();" />
                    <asp:Button ID="btnClear" CssClass="btn btn-default" runat="server" Text="Clear" OnClick="btnClear_Click" />
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFailureEmail" runat="server" CssClass="input-group-addon" Text="Failure Email-ID"></asp:Label>
                        <asp:TextBox ID="txtFailureEmail" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblFailureMsgMobile" runat="server" CssClass="input-group-addon" Text="Failure Mobile No."></asp:Label>
                        <asp:TextBox ID="txtFailureMsgMobile" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:TextBox runat="server" placeholder="Search here" ID="txtConfigSearch" CssClass="txtConfigSearch form-control" />
            <asp:GridView ID="gvEmailConfig" runat="server" EmptyDataText="No Configuration Found." OnRowCommand="gvEmailConfig_RowCommand" OnPreRender="gvEmailConfig_PreRender"
                AutoGenerateColumns="False" CssClass="gvEmailConfig table">
                <HeaderStyle CssClass="table-header-gradient" />
                <Columns>
                    <asp:TemplateField HeaderText="PlantName">
                        <ItemTemplate>
                            <asp:Label ID="lblPlantID" runat="server" Text='<%#Eval("PlantName" ) %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="DocType">
                        <ItemTemplate>
                            <asp:Label ID="lblDoctypek" runat="server" Text='<%#Eval("DocType") %>'>></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Success Email">
                        <ItemTemplate>
                            <asp:Label ID="lblSucessEmail" runat="server" Text='<%#Eval("SuccessEmail") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Failure Email">
                        <ItemTemplate>
                            <asp:Label ID="lblFailureEmail" runat="server" Text='<%#Eval("FailureEmail") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Success SMS">
                        <ItemTemplate>
                            <asp:Label ID="lblSuccessSMS" runat="server" Text='<%#Eval("SuccessSMS") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Failure SMS">
                        <ItemTemplate>
                            <asp:Label ID="lblFailureSMS" runat="server" Text='<%#Eval("FailureSMS") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Active">
                        <ItemTemplate>
                            <asp:Label ID="lblActive" runat="server" Text='<%#Eval("Active") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-default" CommandName="EditConfig"
                                CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField Visible="false">
                        <ItemTemplate>
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-default" CommandName="DeleteConfig"
                                CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            </br>
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" UseSubmitBehavior="false" CausesValidation="false" CssClass="btn btn-default" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>
</asp:Content>


