<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="InventoryTransfer.aspx.cs" Inherits="Inventory_InventoryTransfer" %>

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
                    var itmdata = $(this).find(".lblItemName").val();

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
            if (Number(Container.find('.txtEnterQty').val() == 0)) {

                ModelMsg('Update Quantity must be a greater than Zero', 3);
                return false;
            }
            return true;
        }

        function ChangeQuantity(txt) {
            var EnterQty = 0;
            if (txt != undefined) {

                if ($(txt).val() == "" || isNaN(parseInt($(txt).val()))) {
                    $(txt).val("0");
                }

                var Container = $(txt).parent().parent();
                EnterQty = Container.find('.txtEnterQty').val();

                var Data = Container.find('.ddlUnit').val().split(',');
                var Quantity = Number(Data[1]).toFixed(2);
                var AvlQty = Number(Container.find('.hdnAvailQty').val());
                if (AvlQty != NaN) {
                    Container.find('.txtAvailQty').val(Math.floor(AvlQty / Quantity));
                }
                var AvlQty = Number(Container.find('.txtAvailQty').val());
                if (EnterQty > AvlQty) {
                    ModelMsg('Total packet must be less than or equal to warehouse qty!', 3);
                    $(txt).val("0");
                    EnterQty = 0;
                }
                Container.find('.txtTotalQty').val(EnterQty * Quantity);
            }
            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');

            var AvailQty = 0, RequestQty = 0, TotalQty = 0;

            for (var i = 0; i < AllRows.length; i++) {

                var Data = $(AllRows[i]).find('.ddlUnit').val().split(',');
                var Quantity = Number(Data[1]).toFixed(2);
                $(AllRows[i]).find('.txtTotalQty').val(Number($(AllRows[i]).find('.txtEnterQty').val()) * Quantity);

                AvailQty += Number($(AllRows[i]).find('.txtAvailQty').val());
                RequestQty += Number($(AllRows[i]).find('.txtEnterQty').val());
                TotalQty += Number($(AllRows[i]).find('.txtTotalQty').val());
            }

            var FooterContainer = $(main).find('.table-header-gradient');

            FooterContainer.find('.txtTAvailQty').val(AvailQty);
            FooterContainer.find('.txtTRequestQty').val(RequestQty);
            FooterContainer.find('.txtTTotalQty').val(TotalQty.toFixed(2));
            $('body').animate({ scrollTop: $(window).width() }, 1000);
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm" style="margin-bottom: 0px">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromWarehouse" runat="server" Text="From Warehouse" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlFromWarehouse" TabIndex="1" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFromWarehouse_SelectedIndexChanged" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToWarehouse" runat="server" Text="To Warehouse" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlToWarehouse" runat="server" TabIndex="2" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDocumentNumber" runat="server" Text="Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDocumentDate" runat="server" TabIndex="3" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNotes" runat="server" TabIndex="4" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-10">
                    <asp:TextBox runat="server" placeholder="Search here" TabIndex="5" ID="txtSearch" CssClass="txtSearch form-control" Style="display: inline-block; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                </div>
                <div class="col-lg-2">
                    <asp:Button ID="btnFullTransfer" Text="Full Transfer" TabIndex="6" CssClass="btn btn-default" runat="server" OnClick="btnFullTransfer_Click" />
                </div>
            </div>
            <br />
            <asp:GridView runat="server" ID="gvItem" CssClass="gvItem table" ShowFooter="true" ShowHeader="true" AutoGenerateColumns="false" OnPreRender="gvItems_PreRender" OnRowDataBound="gvItem_RowDataBound" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient">
                <Columns>
                    <asp:TemplateField HeaderText="Item Code">
                        <ItemTemplate>
                            <asp:Label ID="lblItemCode" runat="server" Text='<%# Eval("OITM.ItemCode") %>'></asp:Label>
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Item Name">
                        <ItemTemplate>
                            <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Visible="false"></asp:Label>
                            <asp:Label ID="lblItemName" CssClass="lblItemName" runat="server" Text='<%# Eval("OITM.ItemName") %>'></asp:Label>
                        </ItemTemplate>
                        <HeaderStyle Width="25%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Unit">
                        <ItemTemplate>
                            <asp:DropDownList runat="server" ID="ddlUnit" CssClass="ddlUnit form-control" DataValueField="Value" DataTextField="Key" onchange="ChangeQuantity(this);">
                            </asp:DropDownList>
                        </ItemTemplate>
                        <HeaderStyle Width="10%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Available Qty">
                        <ItemTemplate>
                            <input type="hidden" id="hdnAvailQty" class="hdnAvailQty" runat="server" value='<%# Eval("AvalQty") %>' />
                            <asp:TextBox ID="txtAvailQty" CssClass="txtAvailQty form-control" Enabled="false" runat="server" Text='<%# Eval("AvalQty") %>'></asp:TextBox>
                        </ItemTemplate>
                        <HeaderStyle Width="15%" />
                        <FooterTemplate>
                            <asp:TextBox ID="txtTAvailQty" CssClass="txtTAvailQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtEnterQty" CssClass="txtEnterQty form-control" runat="server" onchange="ChangeQuantity(this);" onkeyup="enter(this);" onkeypress="return isNumberKeyMinusAmount(event);" Text="0" onpaste="return false;" data-bv-stringlength="false" MaxLength="12" onBlur="SetQtyDataBlur(this);" onfocus="SetQtyDataFocus(this);" autocomplete="off" AutoCompleteType="Disabled"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTRequestQty" CssClass="txtTRequestQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Total Qty">
                        <ItemTemplate>
                            <asp:TextBox ID="txtTotalQty" CssClass="txtTotalQty form-control" runat="server" Enabled="false"></asp:TextBox>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtTTotalQty" CssClass="txtTTotalQty form-control" Enabled="false" runat="server"></asp:TextBox>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Reason">
                        <ItemTemplate>
                            <asp:TextBox ID="txtNote" runat="server" Text='<%# Eval("Notes") %>' Style="background-color: rgb(250, 255, 189);" CssClas="form-control" CssClass="form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceGnote" runat="server" ServicePath="../WebService.asmx" ServiceMethod="GetActiveReason" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" ContextKey="B" CompletionSetCount="1" TargetControlID="txtNote" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:Button ID="btnSubmit" runat="server" TabIndex="7" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="8" CssClass="btn btn-default" OnClick="btnCancel_Click" />
        </div>
    </div>
    <br />
    <div class="ui-grid-b" style="margin-left: 3.5%">
        <div class="ui-block-a">
            <div style="padding-top: 0px; padding-bottom: 10px;">
            </div>
        </div>
    </div>
</asp:Content>

