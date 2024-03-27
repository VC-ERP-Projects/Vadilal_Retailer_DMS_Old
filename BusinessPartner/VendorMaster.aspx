<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="VendorMaster.aspx.cs" Inherits="Master_VendorMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function AddFunction(LineID, UnitID, Price, TaxID) {
            $.ajax({
                url: 'VendorMaster.aspx/AddRecord',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                data: "{'LineID':'" + LineID + "','UnitID':'" + UnitID + "','Price':'" + Price + "','TaxID':'" + TaxID + "'}",
                dataType: "json",
                success: function (data) {
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    ModelMsg('Something is wrong...', 3);
                }
            });
        }

        function ChangeQuantity(txt) {
            var Container = $(txt).parent().parent();

            AddFunction(Container.find('.lblNo').text(), Container.find('.lblUnitID').text(), Container.find('.txtPrice').val(), Container.find('.ddlTaxCode').val())
        }
        function twidth() {
            $('.tdiv').css('max-height', (innerHeight - 100) + "px");
        }
        window.onresize = twidth;
        function Relaod() {
            twidth();
            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvItem > tbody tr").each(function () {
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
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="_masterForm">
        <div class="panel panel-default">
            <div class="panel-body">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblVendorCode" runat="server" Text="Vendor Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtVendorCode" runat="server" OnTextChanged="txtVendorCode_TextChanged" CssClass="form-control" AutoPostBack="true" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtVendorCode" runat="server" ServicePath="~/WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetVendor" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVendorCode" Enabled="false">
                            </asp:AutoCompleteExtender>
                        </div>

                        <div class="input-group form-group">
                            <asp:Label ID="lblVendorName" runat="server" Text="Vendor Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtVendorName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblPhone2" runat="server" Text="Mobile" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPhone2" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblEmail" runat="server" Text="Email" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblIsDefault" runat="server" Text="Is Company" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkIsDefault" runat="server" CssClass="form-control"></asp:CheckBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblAddress1" runat="server" Text="Address1" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAddress1" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="input-group form-group">
                            <asp:Label ID="lblAddress2" runat="server" Text="Address2" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAddress2" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblLocation" runat="server" Text="Location" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblCity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                            <asp:DropDownList ID="ddlCity" runat="server" OnSelectedIndexChanged="ddlCity_SelectedIndexChanged" AppendDataBoundItems="True" CssClass="form-control"
                                DataSourceID="edsCity" DataTextField="CityName" DataValueField="CityID" AutoPostBack="True" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:EntityDataSource ID="edsCity" runat="server" ConnectionString="name=DDMSEntities"
                                DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCTies">
                            </asp:EntityDataSource>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblPinCode" runat="server" Text="PinCode" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPinCode" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                            <asp:DropDownList ID="ddlState" runat="server" DataSourceID="edsddlState" DataTextField="StateName"
                                DataValueField="StateID" AppendDataBoundItems="True" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:EntityDataSource ID="edsddlState" runat="server" ConnectionString="name=DDMSEntities"
                                DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCSTs">
                            </asp:EntityDataSource>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblCountry" runat="server" Text="Country" CssClass="input-group-addon"></asp:Label>
                            <asp:DropDownList ID="ddlCountry" runat="server" DataSourceID="edsddlCountry" DataTextField="CountryName"
                                DataValueField="CountryID" AppendDataBoundItems="True" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:EntityDataSource ID="edsddlCountry" runat="server" ConnectionString="name=DDMSEntities"
                                DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCRies">
                            </asp:EntityDataSource>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblPhone1" runat="server" Text="Phone1" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPhone1" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-control" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Template" ID="Label1" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtTemplate" OnTextChanged="txtTemplate_TextChanged" AutoPostBack="true" CssClass="form-control" />
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetActiveSITM" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTemplate">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12 _textArea">
                        <div class="input-group form-group">
                            <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtNotes" TextMode="MultiLine" CssClass="form-control" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">Item Details</h3>
            </div>
            <div class="panel-body">
                <asp:TextBox runat="server" placeholder="Search here" CssClass="txtSearch form-control" />
                <%-- <asp:GridView ID="gvMaterial" runat="server" AutoGenerateColumns="false" CssClass="gvMaterial table" OnPreRender="gvMaterial_PreRender" EmptyDataText="No Material Found." AlternatingRowStyle="true" HeaderStyle-CssClass="table-header-gradient">
                --%>
                <div style="overflow-x: auto; overflow-y: auto" class="tdiv">
                <asp:GridView ID="gvItem" OnPreRender="gvItem_PreRender" CssClass="HighLightRowColor2 gvItem table" runat="server" EmptyDataText="No Item Found." AutoGenerateColumns="False" HeaderStyle-CssClass="table-header-gradient" OnRowCommand="gvItem_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="OITM.ItemName" HeaderText="Item Name" Visible="true" ItemStyle-Width="7%" />
                        <asp:TemplateField HeaderText="Item Name" Visible="false">
                            <ItemTemplate>
                                <asp:Label ID="lblItemID" runat="server" Text='<%#Eval("ItemID") %>'></asp:Label>
                                <asp:Label ID="lblGVItemName" runat="server" Text='<%#Eval("OITM.ItemName") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="15%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Unit">
                            <ItemTemplate>
                                <asp:Label ID="lblUnitID" CssClass="lblUnitID" runat="server" Text='<%#Eval("UnitID" ) %>' Style="display: none;"></asp:Label>
                                <asp:Label ID="lblGVUnit" runat="server" Text='<%#Eval("OUNT.UnitName" ) %>'></asp:Label>
                                <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="13%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Price">
                            <ItemTemplate>
                                <asp:TextBox ID="txtPrice" CssClass="txtPrice form-control" runat="server" Text='<%# Eval("Price","{0:0.00}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="8" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tax">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlTaxCode" runat="server" DataSourceID="edsddlTaxCode" DataTextField="TaxName" onchange="ChangeQuantity(this);" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck" SelectedValue='<%# Eval("TaxID") %>' DataValueField="TaxID" AppendDataBoundItems="true" CssClass="ddlTaxCode form-control">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlTaxCode" runat="server" ConnectionString="name=DDMSEntities"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OTAXes">
                                </asp:EntityDataSource>
                            </ItemTemplate>
                            <ItemStyle CssClass="form-group" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Delete">
                            <ItemTemplate>
                                <asp:Button Text="Delete" ID="btnDelete" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-default" CommandName="DeleteItem" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
                </div>
        </div>
    </div>
    <div class="panel">
        <div class="panel-body">
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server"
                Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" CssClass="btn btn-default" CausesValidation="false" UseSubmitBehavior="false" runat="server"
                Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>

</asp:Content>


