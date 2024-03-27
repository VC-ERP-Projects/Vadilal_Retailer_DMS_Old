<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="PriceListMaster.aspx.cs" Inherits="Master_PriceListMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

    <script type="text/javascript">

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function ChangePrice(txt, type) {
            if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                $(txt).val("0");
            }
            var Container = $(txt).parent().parent();
            if (type == "Row") {
                var Price = Container.find('.txtPacketPrice').length > 0 ? Number(Container.find('.txtPacketPrice').val()) : 0
                var DiscPer = Container.find('.txtDiscountPer').length > 0 ? Number(Container.find('.txtDiscountPer').val()) : 0
                if (Price != undefined) {
                    if (DiscPer > 0) {
                        Container.find('.txtDiscountAmt').val(((Number(Container.find('.txtDiscountPer').val()) * Price) / 100).toFixed(2));
                        Container.find('.txtSellPrice').val((Price - Number(Container.find('.txtDiscountAmt').val())).toFixed(2));
                    }
                    else {
                        Container.find('.txtDiscountPer').val(((Number(Container.find('.txtDiscountAmt').val()) * 100) / Price).toFixed(2));
                        Container.find('.txtSellPrice').val((Price - Number(Container.find('.txtDiscountAmt').val())).toFixed(2));
                    }
                }
                else {
                    Container.find('.txtDiscountAmt').val("0");
                    Container.find('.txtDiscountPer').val("0");
                    Container.find('.txtSellPrice').val("0");
                }
            }
            else if (type == "Hedr") {
                var Dis = Container.find('.txtDiscount').length > 0 ? Number(Container.find('.txtDiscount').val()) : 0
                var Tax = Container.find('.ddlTax').val()

                var main = $('.gvItem');
                var AllRows = $(main).find('tbody').find('tr');
                for (var i = 0; i < AllRows.length; i++) {

                    if ($('input:radio[class=rdbdiscount][id*=rdbdis]').is(":checked") && txt.className != 'ddlTax') {
                        $(AllRows[i]).find('.txtDiscountAmt').val((Dis).toFixed(2));
                        $(AllRows[i]).find('.txtDiscountPer').val((($(AllRows[i]).find('.txtDiscountAmt').val() * 100) / $(AllRows[i]).find('.txtPacketPrice').val()).toFixed(2));
                        $(AllRows[i]).find('.txtSellPrice').val(($(AllRows[i]).find('.txtPacketPrice').val() - $(AllRows[i]).find('.txtDiscountAmt').val()).toFixed(2));
                    }
                    else if ($('input:radio[class=rdbdiscount][id*=rdbper]').is(":checked") && txt.className != 'ddlTax') {
                        $(AllRows[i]).find('.txtDiscountPer').val((Dis).toFixed(2));
                        $(AllRows[i]).find('.txtDiscountAmt').val((($(AllRows[i]).find('.txtDiscountPer').val() * $(AllRows[i]).find('.txtPacketPrice').val()) / 100).toFixed(2));
                        $(AllRows[i]).find('.txtSellPrice').val(($(AllRows[i]).find('.txtPacketPrice').val() - $(AllRows[i]).find('.txtDiscountAmt').val()).toFixed(2));
                    }
                    if (txt.className.indexOf('ddlTax') >= 0) {
                        $(AllRows[i]).find('.ddlTaxCode').val(Tax);
                    }
                }
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>

    <div class="panel panel-default">
        <div class="panel-body ">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNo" runat="server" OnTextChanged="txtNo_TextChanged" AutoPostBack="true" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPriceList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtNo">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlState" runat="server" DataSourceID="edsddlState" DataTextField="StateName" CssClass="form-control"
                            DataValueField="StateID" AppendDataBoundItems="true">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlState" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCSTs">
                        </asp:EntityDataSource>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblBasePriceList" runat="server" Text="Base Price List" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBasePriceList" runat="server" OnTextChanged="txtBasePriceList_TextChanged" AutoPostBack="true" CssClass="form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtBasePriceList" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPriceList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtBasePriceList">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblEffectiveDate" runat="server" Text="Effective Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEffectiveDate" runat="server" nfocus="this.blur();" CssClass="datepick form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblDiscount" runat="server" Text="Discount" CssClass="input-group-addon"></asp:Label>
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:TextBox ID="txtDiscount" runat="server" Text="0"
                                        CssClass="txtDiscount form-control" onchange="ChangePrice(this,'Hedr');" onpaste="return false;" MaxLength="12" autocomplete="off" AutoCompleteType="Disabled" Style="margin-right: 2%"></asp:TextBox></td>
                                <td width="50%" align="center">
                                    <input type="radio" id="rdbper" onchange="ChangePrice(this,'Hedr');" class="rdbdiscount" checked="true" style="display: inline !IMPORTANT;" runat="server" />%
                        <input type="radio" id="rdbdis" onchange="ChangePrice(this,'Hedr');" class="rdbdiscount" style="display: inline !IMPORTANT;" runat="server" />INR</td>
                            </tr>
                        </table>


                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblTax" runat="server" Text="Tax" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlTax" runat="server" DataSourceID="edsddlTax" DataTextField="TaxName"
                            DataValueField="TaxID" AppendDataBoundItems="true" CssClass="ddlTax form-control" onchange="ChangePrice(this,'Hedr');">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlTax" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OTAXes">
                        </asp:EntityDataSource>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDescription" runat="server" Text="Description" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table" ShowFooter="false" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItem_PreRender" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-footer">
                <Columns>
                    <asp:BoundField DataField="ItemID" HeaderText="Item ID" Visible="false" />
                     <asp:BoundField DataField="OITM.ItemCode" HeaderText="Item Code" Visible="true" ItemStyle-Width="7%" />
                    
                    <asp:BoundField DataField="ItemID" HeaderText="Item ID" Visible="false" />
                    <asp:BoundField DataField="OITM.ItemName" HeaderText="Item Name" Visible="true" ItemStyle-Width="7%" />
                    <asp:TemplateField HeaderText="Item Code" Visible="false">
                        <ItemTemplate>
                            <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>'></asp:Label>
                            <asp:Label ID="lblUnitID" runat="server" Text='<%# Eval("UnitID") %>' Visible="false"></asp:Label>
                            <asp:Label ID="lblItemName" runat="server" Text='<%# Eval("OITM.ItemCode") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Unit">
                        <ItemTemplate>
                            <asp:Label ID="lblUnitName" runat="server" Text='<%# Eval("OUNT.UnitName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Base Price">
                        <ItemTemplate>
                            <asp:TextBox ID="txtPacketPrice" runat="server" CssClass="txtPacketPrice form-control" Text='<%# Eval("UnitPrice","{0:0.00}") %>' onchange="ChangePrice(this,'Row');" onkeyup="enter(this);" onkeypress="return isNumberKeyMinusAmount(event);" onpaste="return false;" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Discount %">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDiscountPer" runat="server" CssClass="txtDiscountPer form-control" Text='<%# Eval("DiscountPer","{0:0.00}") %>' onchange="ChangePrice(this,'Row');" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Discount Amount">
                        <ItemTemplate>
                            <asp:TextBox ID="txtDiscountAmt" runat="server" CssClass="txtDiscountAmt form-control" Text='<%# Eval("DiscountAmt","{0:0.00}") %>' onchange="ChangePrice(this,'Row');" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" MaxLength="12" onBlur="ResetColor()" onFocus="ChangeColor()" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Net Sell Price">
                        <ItemTemplate>
                            <asp:TextBox ID="txtSellPrice" runat="server" CssClass="txtSellPrice form-control" Enabled="false" Text='<%# Eval("SellPrice","{0:0.00}") %>' MaxLength="12"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Tax">
                        <ItemTemplate>
                            <asp:DropDownList ID="ddlTaxCode" runat="server" DataSourceID="edsddlTaxCode" DataTextField="TaxName" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck" AppendDataBoundItems="true" SelectedValue='<%# Eval("TaxID") %>' DataValueField="TaxID" CssClass="ddlTaxCode form-control">
                                <asp:ListItem Text="---Select---" Value="0" />
                            </asp:DropDownList>

                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:EntityDataSource ID="edsddlTaxCode" runat="server" ConnectionString="name=DDMSEntities" Where="it.Active = true"
                DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OTAXes">
            </asp:EntityDataSource>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancelClick" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>

</asp:Content>
