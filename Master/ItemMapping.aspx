<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ItemMapping.aspx.cs" Inherits="Master_ItemMapping" %>

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

        function onAutoCompleteSelected(sender, e) {

            __doPostBack(sender.get_element().name, null);
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
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
                        <asp:TextBox ID="txtPlant" runat="server" CssClass="form-control" autocomplete="off" OnTextChanged="txtPlant_TextChanged" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtPlant" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPlant" MinimumPrefixLength="1" CompletionInterval="10" OnClientItemSelected="onAutoCompleteSelected"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
                        &nbsp;
                        <asp:Button ID="btnCancel" UseSubmitBehavior="false" CausesValidation="false" CssClass="btn btn-default" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
                    </div>
                </div>

                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label runat="server" Text="Upload File" ID="lblUpload" CssClass="input-group-addon"></asp:Label>
                        <asp:FileUpload ID="flCUpload" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Button ID="btnImport" runat="server" Text="Import File" CssClass="btn btn-default" OnClick="btnImport_Click" />&nbsp;
                        <asp:Button Text="Export File" ID="btnExport" OnClick="btnExport_Click" CssClass="btnExport btn btn-default" runat="server" />
                    </div>
                </div>

            </div>
            <asp:TextBox runat="server" placeholder="Search here" ID="txtConfigSearch" CssClass="txtConfigSearch form-control" />
            <asp:GridView ID="gvItem" runat="server" EmptyDataText="No Data Found." OnPreRender="gvItem_PreRender" AutoGenerateColumns="False" CssClass="gvEmailConfig table">
                <HeaderStyle CssClass="table-header-gradient" />
                <Columns>
                    <asp:TemplateField HeaderText="Check" HeaderStyle-Width="5%">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" checked='<%#Eval("Active") %>' class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Item Code" HeaderStyle-Width="12%">
                        <ItemTemplate>
                            <asp:HiddenField ID="lblItemID" runat="server" Value='<%#Eval("ItemID") %>'></asp:HiddenField>
                            <asp:Label ID="lblItemCode" runat="server" Text='<%#Eval("ItemCode") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Item Name" HeaderStyle-Width="25%">
                        <ItemTemplate>
                            <asp:Label ID="lblItemName" runat="server" Text='<%#Eval("ItemName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Created Date">
                        <ItemTemplate>
                            <asp:Label ID="lblCreatedDate" runat="server" Text='<%#Eval("CreatedDate")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Created By">
                        <ItemTemplate>
                            <asp:Label ID="lblCreatedBy" runat="server" Text='<%#Eval("CreatedBy")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Updated Date">
                        <ItemTemplate>
                            <asp:Label ID="lblUpdatedDate" runat="server" Text='<%#Eval("UpdatedDate")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Updated By ">
                        <ItemTemplate>
                            <asp:Label ID="lblUpdatedBy" runat="server" Text='<%#Eval("UpdatedBy")%>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <br />
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvMissdata" runat="server" CssClass="table table-bordered table-responsive" AutoGenerateColumns="true">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


