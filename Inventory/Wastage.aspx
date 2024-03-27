<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Wastage.aspx.cs" Inherits="Inventory_Wastage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable/jquery.dataTables.min.css" rel="stylesheet" />
    <script src="../Scripts/datatable/jquery.dataTables.min.js"></script>
    <script type="text/javascript">

        $(function () {

            $('.gvItem').DataTable({
                bFilter: false,
                paging: false,
                scrollY: '50vh',
                scrollCollapse: true,
                ordering: false
            });

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 1000);

            Relaod();

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function _btnCheck() {

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            $('.gvItem').DataTable().destroy();

            if (IsValid && Number($('.txtTTotalQty').val()) <= 0) {
                ModelMsg('Select at least one quantity.', 3);
                IsValid = false;
            }

            $('.gvItem').DataTable({
                bFilter: false,
                paging: false,
                scrollY: '50vh',
                scrollCollapse: true,
                ordering: false
            });

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 1000);

            return IsValid;
        }

        function Relaod() {

            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvItem > tbody tr").each(function () {
                    var itmdata = $(this).find(".txtItem").val();

                    if (($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0) || (itmdata.toUpperCase().indexOf(word.toUpperCase()) >= 0))
                        $(this).show();
                    else
                        $(this).hide();
                });
            });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $('.gvItem').DataTable().destroy();

            $('.gvItem').DataTable({
                bFilter: false,
                paging: false,
                scrollY: '50vh',
                scrollCollapse: true,
                ordering: false
            });

            $('.dataTables_scrollBody').animate({ scrollTop: $('.dataTables_scrollBody').prop("scrollHeight") }, 1000);

        }

        function Checkvalidation() {
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');

            var qty = "";
            var totQty = 0;
            for (var i = 0; i < AllRows.length; i++) {
                qty = $(AllRows[i]).find('.txtEnterQty').val();
                if (qty != "") {

                    totQty += Number(qty);
                }
            }
            if (Number(totQty) == 0) {
                ModelMsg('Wastage Quantity must be a greater than Zero', 3);
                event.preventDefault();
                return false;
            }
            else
                return true;
        }

        function ChangeQuantity(txt) {
            var EnterQty = 0;
            if (txt != undefined) {

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                }
                var Container = $(txt).parent().parent();
                var Data = Container.find('.ddlUnit').val().split(',');

                EnterQty = Container.find('.txtEnterQty').val();

                if ($('.ddlType').val() == "1") {
                    var AvlQty = Number(Container.find('.txtAvailQty').val());
                    if (EnterQty > AvlQty) {
                        ModelMsg('Total packet must be less than or equal to Warehouse/ Order qty!', 3);
                        $(txt).val("0");
                        EnterQty = 0;
                    }
                }
                Container.find('.lblUnitPrice').val(Number(Data[1]).toFixed(2));
                Container.find('.lblPrice').val(Number(Data[1]).toFixed(2));
                Container.find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                Container.find('.lblSubTotal').val((Number(Container.find('.lblPrice').val()) * EnterQty).toFixed(2));
                Container.find('.txtAvailQty').val((Number(Container.find('.hdnAvailQty').val()) / Number(Data[3])).toFixed(2));

                AddFunction(Container.find('.lblNo').text(), Data[0], Container.find('.ddlUnit option:selected').text().trim(), Container.find('.lblPrice').val(), Data[2], Container.find('.txtEnterQty').val() == undefined ? 0 : Container.find('.txtEnterQty').val(), Data[3], Container.find('.txtTotalQty').val(), Container.find('.lblSubTotal').val(), Container.find('.ddlReason').val());
            }
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');
            var AvailQty = 0, RequestQty = 0, DispatchQty = 0, TotalQty = 0, SubTotal = 0, Tax = 0, TotalPrice = 0;
            for (var i = 0; i < AllRows.length; i++) {

                if (txt == undefined) {

                    var Data = new Array();

                    if ($(AllRows[i]).find('.lblUnitID').text() != null)
                        Data = $(AllRows[i]).find('.lblUnitID').text().split(',');

                    if ($(AllRows[i]).find('.ddlUnit').val() != null)
                        Data = $(AllRows[i]).find('.ddlUnit').val().split(',');

                    EnterQty = $(AllRows[i]).find('.txtEnterQty').val();

                    if (Data.length == 4) {
                        $(AllRows[i]).find('.lblPrice').val(Number(Data[1]).toFixed(2));
                        $(AllRows[i]).find('.txtTotalQty').val(EnterQty * Number(Data[3]));
                        $(AllRows[i]).find('.lblSubTotal').val((Number($(AllRows[i]).find('.lblPrice').val()) * EnterQty).toFixed(2));
                        $(AllRows[i]).find('.txtAvailQty').val((Number($(AllRows[i]).find('.hdnAvailQty').val()) / Number(Data[3])).toFixed(2));
                    }
                }

                AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
                RequestQty += Number($(AllRows[i]).find('.txtEnterQty').val());

                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
                SubTotal += Number($(AllRows[i]).find('.lblSubTotal').val());


            }
            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTDispatchQty').val(DispatchQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty);
            FooterContainer.find('.lblTSubTotal').val(SubTotal.toFixed(2));
            //FooterContainer.find('.lblTTax').val(Tax.toFixed(2));
            //FooterContainer.find('.lblTPrice').val(TotalPrice.toFixed(2));

            isNaN(SubTotal) ? SubTotal = 0 : 0;
            isNaN(Tax) ? Tax = 0 : 0;
            isNaN(TotalPrice) ? TotalPrice = 0 : 0;

            $('.txtSubTotal').val(SubTotal.toFixed(2));
            $('.txtTax').val(Tax.toFixed(2));
            $('body').animate({ scrollTop: $(window).width() }, 1000);

        }

        function AddFunction(LineID, UnitID, UnitName, UnitPrice, PriceTax, Quantity, MapQty, TotalQty, SubTotal, ReasonID) {
            $.ajax({
                url: 'Wastage.aspx/AddRecord',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                data: "{'LineID':'" + LineID + "','UnitID':'" + UnitID + "','UnitName':'" + UnitName + "','UnitPrice':'" + UnitPrice + "','PriceTax':'" + PriceTax + "','Quantity':'" + Quantity + "','MapQty':'" + MapQty + "','TotalQty':'" + TotalQty + "','SubTotal':'" + SubTotal + "','ReasonID':'" + ReasonID + "'}",
                dataType: "json",
                success: function (data) {
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    ModelMsg('Something is wrong...', 3);
                }
            });
        }

        function autoCompleteMat_OnClientPopulating(sender, args) {
           
            var DistID = '<%= ParentID%>';
            var key = DistID + '#';

            $('.gvItem').find('.lblItemID').each(function () {
                key += $(this).text() + ",";
            });

            key = key.substring(0, key.length - 1);

            sender.set_contextKey(key);
        }

        function CheckItemVal(txt) {
            var Container = $(txt).parent().parent();

            var txtval = Container.find('.txtItem').val().trim();
            if (txtval == "-" || txtval == " - " || txtval == "") {
                Container.find('.txtItem').val('');
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Date" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtDate" disabled="disabled" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Template" ID="Label1" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtTemplate" TabIndex="2" OnTextChanged="txtTemplate_TextChanged" AutoPostBack="true" CssClass="form-control" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetActiveSITM" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtTemplate">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Amount" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtAmount" CssClass="txtAmount form-control" Enabled="false" Text="0" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblwarehouse" Text="Warehouse" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlWhs" TabIndex="3" DataValueField="WhsID" DataTextField="WhsName" CssClass="form-control"
                            AutoPostBack="True" OnSelectedIndexChanged="txtTemplate_TextChanged">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label Text="Notes" ID="lblNotes" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtNotes" TabIndex="4" TextMode="MultiLine" CssClass="form-control" Style="resize: none;" />
                    </div>
                </div>
            </div>
            <asp:TextBox runat="server" placeholder="Search here" TabIndex="5" ID="txtSearch" CssClass="txtSearch form-control" />
            <br />
            <asp:GridView runat="server" ID="gvItem" CssClass="gvItem HighLightRowColor2 table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient">
                <Columns>
                    <asp:TemplateField HeaderText="Item Name">
                        <ItemTemplate>
                            <asp:Label ID="lblNo" CssClass="lblNo" runat="server" Text='<%# Container.DataItemIndex %>' Style="display: none;"></asp:Label>
                            <asp:Label ID="lblItemID" CssClass="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Style="display: none;"></asp:Label>
                            <asp:TextBox runat="server" ID="txtItem" OnTextChanged="txtItem_TextChanged" AutoPostBack="true" CssClass="txtItem form-control" Style="background-color: rgb(250, 255, 189);" Text='<%# String.Format("{0} - {1}", Eval("ItemCode"),Eval("ItemName"))  %>' onfocus="CheckItemVal(this);" />
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtItem" runat="server" ServicePath="../WebService.asmx" OnClientPopulating="autoCompleteMat_OnClientPopulating" UseContextKey="true" ServiceMethod="GetActiveMaterialByPlant" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItem">
                            </asp:AutoCompleteExtender>
                        </ItemTemplate>
                        <HeaderStyle Width="20%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Unit">
                        <ItemTemplate>
                            <asp:Label Text='<%# Eval("UnitID") %>' ID="lblUnitID" CssClass="lblUnitID" runat="server" Style="display: none;" />
                            <asp:Label Text='<%# Eval("UnitName") %>' ID="lblUnit" runat="server" Visible="false" />
                            <asp:DropDownList runat="server" ID="ddlUnit" CssClass="ddlUnit form-control" DataValueField="Value" DataTextField="Key" onchange="ChangeQuantity(this);">
                            </asp:DropDownList>
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Price">
                        <ItemTemplate>
                            <asp:TextBox ID="lblPrice" Text='<%# Eval("UnitPrice","{0:0.00}") %>' CssClass="lblPrice form-control" Enabled="false" runat="server"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Available Qty">
                        <ItemTemplate>
                            <input type="hidden" id="hdnAvailQty" class="hdnAvailQty" runat="server" value='<%# Eval("AvailQty") %>' />
                            <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text='<%# Eval("AvailQty") %>'></asp:TextBox>
                        </ItemTemplate>
                        <HeaderStyle Width="15%" />
                        <FooterTemplate>
                            <asp:TextBox ID="txtTAvailQty" CssClass="txtTAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Wastage Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtEnterQty" CssClass="txtEnterQty form-control" runat="server" Text='<%# Eval("Quantity","{0:0}") %>' onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="SetQtyDataBlur(this);" onfocus="SetQtyDataFocus(this);" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Total Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtTotalQty" CssClass="txtTotalQty form-control" Text='<%# Eval("TotalQty","{0:0.00}") %>' runat="server" Enabled="false"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="SubTotal">
                        <ItemTemplate>
                            <asp:TextBox ID="lblSubTotal" CssClass="lblSubTotal form-control" Text='<%# Eval("SubTotal","{0:0.00}") %>' Enabled="false" runat="server"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="lblTSubTotal" CssClass="lblTSubTotal form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Reason">
                        <ItemTemplate>
                            <asp:DropDownList runat="server" ID="ddlReason" CssClass="ddlReason form-control" onchange="ChangeQuantity(this);" DataValueField="Value" DataTextField="Text">
                            </asp:DropDownList>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <br />
            <asp:Button Text="Submit" runat="server" CssClass="btn btn-default" TabIndex="6" ID="btnSubmit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-default" TabIndex="7" OnClick="btnCancel_Click" runat="server" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>
