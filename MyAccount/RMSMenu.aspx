<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="RMSMenu.aspx.cs" Inherits="MyAccount_RMSMenu" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <asp:GridView ID="gvAuthorization" runat="server" AutoGenerateColumns="False" CssClass="table" HeaderStyle-CssClass="table-header-gradient" DataKeyNames="MenuID" OnRowDataBound="gvAuthorization_RowDataBound" EmptyDataText="No Menu Found.">
                <Columns>
                    <asp:TemplateField HeaderText="Menu">
                        <ItemTemplate>
                            <asp:Label ID="lblMenuID" runat="server" Text='<%# Bind("MenuID") %>' Visible="false"></asp:Label>
                            <asp:Label ID="lblName" runat="server" Text='<%# Bind("MenuName") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle />
                        <HeaderStyle Width="20%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ref1">
                        <ItemTemplate>
                            <asp:TextBox runat="server" ID="txtRef1" Text='<%# Bind("Ref1") %>' MaxLength="150" CssClass="form-control" />
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ref2">
                        <ItemTemplate>
                            <asp:TextBox runat="server" ID="txtRef2" Text='<%# Bind("Ref2") %>' MaxLength="150" CssClass="form-control" />
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ref3">
                        <ItemTemplate>
                            <asp:TextBox runat="server" ID="txtRef3" Text='<%# Bind("Ref3") %>' MaxLength="150" CssClass="form-control" />
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ref4">
                        <ItemTemplate>
                            <asp:TextBox runat="server" ID="txtRef4" Text='<%# Bind("Ref4") %>' MaxLength="150" CssClass="form-control" />
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ref5">
                        <ItemTemplate>
                            <asp:TextBox runat="server" ID="txtRef5" Text='<%# Bind("Ref5") %>' MaxLength="150" CssClass="form-control" />
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>

