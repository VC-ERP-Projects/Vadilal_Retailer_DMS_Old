<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="MaterialMaster.aspx.cs" Inherits="Master_MaterialMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function Relaod() {
            $('.accountForm')
                .bootstrapValidator({
                    // Only disabled elements are excluded
                    // The invisible elements belonging to inactive tabs must be validated
                    excluded: [':disabled'],
                    feedbackIcons: {
                        valid: 'glyphicon glyphicon-ok',
                        invalid: 'glyphicon glyphicon-remove',
                        validating: 'glyphicon glyphicon-refresh'
                    },
                    live: 'enabled',
                    trigger: null
                })
                // Called when a field is invalid
                .on('error.field.bv', function (e, data) {
                    // data.element --> The field element
                    // alert('errr');
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id');

                    $('a[href="#' + tabId + '"][data-toggle="tab"]')
                        .parent()
                        .find('i')
                        .removeClass('fa-check')
                        .addClass('fa-times');
                })
                // Called when a field is valid
                .on('success.field.bv', function (e, data) {
                    // data.bv      --> The BootstrapValidator instance
                    // data.element --> The field element
                    //alert(data.element.parents('.tab-pane'));
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id'),
                        $icon = $('a[href="#' + tabId + '"][data-toggle="tab"]')
                                    .parent()
                                    .find('i')
                                    .removeClass('fa-check fa-times');

                    // Check if the submit button is clicked
                    if (data.bv.getSubmitButton()) {
                        // Check if all fields in tab are valid

                        var isValidTab = data.bv.isValidContainer($tabPane);
                        $icon.addClass(isValidTab ? 'fa-check' : 'fa-times');
                    }
                });

            $('.radioList input[type="radio"]').css('vertical-align', 'text-bottom');

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("MaterialMaster", $(e.target).attr("href").substr(1));
            });

            $('#tabs a[href="#' + $.cookie("MaterialMaster") + '"]').tab('show');
        }

        function checkrdb(chk) {

            var main = $('.gvItem');
            var AllRows = $(main).find('tbody').find('tr');

            for (var i = 0; i < AllRows.length; i++) {

                if ($(AllRows[i]).find('.BaseUnit')[0].id != chk.id) {
                    $(AllRows[i]).find('.BaseUnit')[0].checked = false;
                }
                else {
                    $(AllRows[i]).find('.txtPacket').val('1');
                }
            }
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('.accountForm').data('bootstrapValidator').isValid())
                $('.accountForm').bootstrapValidator('validate');

            IsValid = $('.accountForm').data('bootstrapValidator').isValid();
            var chk = $('.BaseUnit:checked');
            if (chk.length == 0) {
                ModelMsg('Select at least one base unit.', 3);
                IsValid = false;
            }
            if (IsValid && !chk.parent().parent().find('.chkActive').is(':checked')) {
                ModelMsg('Base unit must be active.', 3);
                IsValid = false;
            }

            return IsValid;
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body accountForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <center>
                        <a class="imgMaterial" href="../Images/no.jpg" id="alink" runat="server">
                    <asp:Image ID="imgMaterial" CssClass="imgMaterial" ImageUrl="~/Images/no.jpg" runat="server" Width="100px" Height="100px" /></a>
                <br />
                <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuMaterialPhoto" ClientIDMode="AutoID" runat="server"
                    OnUploadedComplete="afuMaterialPhoto_UploadedComplete" Style="margin-left: 29%; margin-top: 3%" CompleteBackColor="White" CssClass="imageUploaderField" />
                    </center>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnTextChanged="txtCode_TextChanged" CssClass="form-control" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetMaterial" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlType" DataSourceID="edsType" CssClass="form-control" DataTextField="TypeName" DataValueField="TypeID"></asp:DropDownList>
                        <asp:EntityDataSource ID="edsType" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OITPs" Where="it.Active==true">
                        </asp:EntityDataSource>

                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-control" Checked="true" />
                    </div>
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab">Unit Mapping</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">

                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblGroup" runat="server" Text="Group" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlGroup" runat="server" DataSourceID="edsItemGroup" DataTextField="ItemGroupName" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck"
                                    DataValueField="ItemGroupID" AppendDataBoundItems="true" AutoPostBack="true">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsItemGroup" runat="server" ConnectionString="name=DDMSEntities"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OITBs" Where="it.Active==true">
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSubGroup" runat="server" Text="Sub Group" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlSubGroup" runat="server" DataSourceID="edsSubGroup" DataTextField="ItemSubGroupName" CssClass="form-control"
                                    DataValueField="ItemSubGroupID">
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsSubGroup" runat="server" ConnectionString="name=DDMSEntities"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OITGs" Where="it.Active==true">
                                    <WhereParameters>
                                        <asp:ControlParameter ControlID="ddlGroup" DbType="Int32" DefaultValue="0" PropertyName="SelectedValue" Name="GroupID" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group" style="display: none;">
                                <asp:Label Text="Manage By" runat="server" CssClass="input-group-addon" />
                                <asp:DropDownList runat="server" ID="ddlManageBy" CssClass="form-control">
                                    <asp:ListItem Text="Batch" Value="1" />
                                    <asp:ListItem Text="Serial" Value="2" />
                                    <asp:ListItem Text="None" Value="0" />
                                </asp:DropDownList>
                            </div>

                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label Text="Sellable" runat="server" CssClass="input-group-addon" />
                                <asp:CheckBox ID="chkSellable" runat="server" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group" style="display: none;">
                                <asp:Label Text="Is KOT" runat="server" CssClass="input-group-addon" />
                                <asp:CheckBox ID="chkKOT" runat="server" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="BarCode" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtBarcode" CssClass="form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12 _textArea">
                            <div class="input-group form-group">
                                <asp:Label ID="lblIngrediance" runat="server" Text="Ingredients" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtIngrediance" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>


                </div>
                <div id="tabs-2" class="tab-pane">

                    <div class="row">
                        <div class="col-lg-2" style="border: 1px solid black; border-radius: 5px; padding: 5px; margin-top: 10px; max-height: 200px; overflow: auto">
                            <asp:LinkButton Text=">>>" CssClass="btn btn-default" ID="btnBindUnit" OnClick="btnBindUnit_Click" runat="server" /><br />
                            <asp:RadioButtonList runat="server" ID="rdblstUnits" DataTextField="UnitName" CssClass="radioList" DataValueField="UnitID" RepeatColumns="1" RepeatDirection="Vertical" RepeatLayout="Flow">
                            </asp:RadioButtonList>
                        </div>
                        <div class="col-lg-10" style="overflow: auto; max-height: 200px; overflow: auto">
                            <asp:GridView ID="gvItem" runat="server" CssClass="gvItem HighLightRowColor2 table" AutoGenerateColumns="False" EmptyDataText="No Item Found." OnRowDataBound="gvItem_RowDataBound"
                                HeaderStyle-CssClass="table-header-gradient" AlternatingRowStyle="true" OnPreRender="gvItem_PreRender">
                                <Columns>
                                    <asp:TemplateField HeaderText="Active">
                                        <ItemTemplate>
                                            <input type="checkbox" id="chkActive" runat="server" class="chkActive" checked='<%#Eval("Active") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Unit Name">
                                        <ItemTemplate>
                                            <asp:Label ID="lblUnitID" runat="server" Text='<%#Eval("UnitID") %>' Visible="false"></asp:Label>
                                            <asp:Label ID="lblUnitName" runat="server" Text='<%#Eval("OUNT.UnitName") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Item Name">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control" Text='<%#Eval("UnitItemID")!=null ? Eval("UnitItemID").ToString()+ " - " +Eval("UnitOITM.ItemName") : "" %>' AutoPostBack="true" OnTextChanged="txtItemName_TextChanged" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtItemID" runat="server" ServiceMethod="GetItemWithID" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtItemName" UseContextKey="True"></asp:AutoCompleteExtender>
                                        </ItemTemplate>
                                        <HeaderStyle Width="15%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Unit Type">
                                        <ItemTemplate>
                                            <asp:DropDownList runat="server" ID="ddlUnit" SelectedValue='<%#Eval("UnitType") %>' CssClass="form-control">
                                                <asp:ListItem Text="None" Value="0" />
                                                <asp:ListItem Text="Sale" Value="1" />
                                                <asp:ListItem Text="Purchase" Value="2" />
                                                <asp:ListItem Text="Both" Value="3" />
                                            </asp:DropDownList>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="BaseUnit">
                                        <ItemTemplate>
                                            <input type="radio" id="rdbCheck" class="BaseUnit form-control" runat="server" checked='<%#Eval("IsBaseUnit" ) %>' onchange="checkrdb(this);" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Quantity">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtPacket" CssClass="txtPacket form-control" runat="server" Text='<%#Eval("Quantity") %>' onpaste="return false;" data-bv-stringlength="false" MaxLength="8" onBlur="ResetColor()" onFocus="ChangeColor()" onkeyup="enter(this);" onkeypress="return isNumberKeyForAmount(event);"></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Price">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" Text='<%#Eval("Price","{0:0.00}") %>' onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-stringlength="false" MaxLength="8" onBlur="ResetColor()" onFocus="ChangeColor()" onkeyup="enter(this);"></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false"
                OnClick="btnCancel_Click" />
        </div>
    </div>

</asp:Content>
