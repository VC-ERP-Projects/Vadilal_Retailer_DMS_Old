<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetTransfer.aspx.cs" Inherits="Asset_AssetTransfer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
            $('._masterForm')
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
        }

        function Relaod() {
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("AssetTransfer", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("AssetTransfer") + '"]').tab('show');
        }

        function SetActiveTab(index) {
            $.cookie('AssetTransfer', index);
            Relaod();
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function RemoveAttachment(passVal) {

            var sel = $('._auchk').bootstrapSwitch('state');
            var row = $(passVal).parent("td").parent('tr');  // this is row that should be deleted

            if (sel == true) // means add
            {
                row.remove(); // this will remove row from DOM, but not from Db
            }
            else {

            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Asset Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" OnTextChanged="txtCode_TextChanged" CssClass="form-control" AutoPostBack="true" Enabled="false" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtAssetCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetHoldingAssetsCode" MinimumPrefixLength="1" CompletionInterval="10"
                            Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAssetName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                     <div class="input-group form-group-gro">
                        <asp:Label ID="lblModelNo" runat="server" Text="Model Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtModelNo" CssClass="form-control" ReadOnly="true" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblSerialNo" runat="server" Text="Serial Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtSerialNo" CssClass="form-control" ReadOnly="true" />
                    </div>
                </div>
                <div class="col-lg-6">
                   
                    <div class="input-group form-group">
                        <asp:Label ID="lblBrand" runat="server" Text="Brand" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtBrand" CssClass="form-control" ReadOnly="true" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblSize" runat="server" Text="Size" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtSize" CssClass="form-control" ReadOnly="true" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblAddtional" runat="server" Text="Additional Identifier" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox runat="server" ID="txtAdditional" CssClass="form-control" ReadOnly="true" />
                    </div>
                </div>
            </div>
            <ul id="tabs" class="nav nav-tabs" role="tablist">
                <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">General</a></li>
                <li><a href="#tabs-2" role="tab" data-toggle="tab">Attachment</a></li>
            </ul>
            <div id="myTabContent" class="tab-content">
                <div id="tabs-1" class="tab-pane active">

                    <div class="row">
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTransferTo" runat="server" Text="Transfer To" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlTransferTo" runat="server" DataSourceID="edsddlTransferTo" DataTextField="CustomerName"
                                    DataValueField="CustomerID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Customer" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlTransferTo" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="(it.CustomerID = @OutletPID OR it.ParentID = @ParentID) AND (it.Active = TRUE)"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCRDs">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                        <asp:SessionParameter Name="OutletPID" SessionField="OutletPID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblTransferReason" runat="server" Text="Transfer Reason" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlTransferReason" runat="server" DataSourceID="edsTransferReason" DataTextField="AssetTransferReasonName"
                                    DataValueField="AssetTransferReasonID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Type" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsTransferReason" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTRs">
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCondition" runat="server" Text="Asset Condition" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetCondition" runat="server" DataSourceID="edsddlAssetCondition" DataTextField="AssetConditionName"
                                    DataValueField="AssetConditionID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Condition" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetCondition" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTCs">
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblStatus" runat="server" Text="Asset Status" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetStatus" runat="server" DataSourceID="edsddlAssetStatus" DataTextField="AssetStatusName"
                                    DataValueField="AssetStatusID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Status" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetStatus" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTUs">
                                </asp:EntityDataSource>
                            </div>

                        </div>

                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label ID="lblTransferDate" runat="server" Text="Transfer Date" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTransferDate" CssClass="datepick form-control" /></td>
                                        <td>
                                            <asp:TextBox ID="txtTransferTime" runat="server" CssClass="form-control" placeholder="Time"></asp:TextBox></td>
                                        <asp:MaskedEditExtender ID="transferMEE" runat="server" TargetControlID="txtTransferTime" MaskType="Time"
                                            Mask="99:99:99">
                                        </asp:MaskedEditExtender>
                                    </tr>
                                </table>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblShippingDet" runat="server" Text="Shipping Detail" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtShippingDetail" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblDocketNo" runat="server" Text="Docket Number" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtDocketNo" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblShippingDate" runat="server" Text="Shipping Date" CssClass="input-group-addon"></asp:Label>
                                <table width="100%">
                                    <tr>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtShippingDate" CssClass="datepick form-control" /></td>
                                        <td>
                                            <asp:TextBox ID="txtShippingTime" runat="server" CssClass="form-control" placeholder="Time"></asp:TextBox></td>
                                        <asp:MaskedEditExtender ID="shippingMEE" runat="server" TargetControlID="txtShippingTime" MaskType="Time"
                                            Mask="99:99:99">
                                        </asp:MaskedEditExtender>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12 _textArea">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDescription" runat="server" Text="Description" CssClass="lbl_desc input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="tabs-2" class="tab-pane">
                    <div class="row">
                        <div class="panel-body">

                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblType" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtType" CssClass="form-control" ReadOnly="true" Text="Transfer" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAttachment" runat="server" Text="Subject" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtAttachment" CssClass="form-control" />
                                </div>
                            </div>

                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAtchNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtAtchNotes" CssClass="form-control" TextMode="MultiLine" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblUpload" runat="server" Text="File Upload" CssClass="input-group-addon"></asp:Label>
                                    <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuAssetReg" ClientIDMode="AutoID" runat="server"
                                        OnUploadedComplete="afuAssetReg_UploadedComplete" CssClass="file_uploader imageUploaderField" CompleteBackColor="White" />
                                </div>

                                <div class="input-group form-group">
                                    <asp:Button Text="Add Attachment" ID="btnImageUpload" Style="width: auto; min-width: 100px;" CssClass="btn_groupclass" runat="server" OnClick="btnImageUpload_Click" />
                                </div>
                            </div>

                            <asp:GridView runat="server" ID="gvAttach" CssClass="table" HeaderStyle-CssClass="table-header-gradient" AutoGenerateColumns="False" EmptyDataText="No Attchment Found." ClientIDMode="Static" OnRowCommand="gvAttach_RowCommand" Width="100%">
                                <Columns>
                                    <asp:TemplateField HeaderText="No.">
                                        <ItemTemplate>
                                            <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Type">
                                        <ItemTemplate>
                                            <asp:Label ID="lblType" runat="server" Text='<%# Bind("Type") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Subject">
                                        <ItemTemplate>
                                            <asp:Label ID="lblAttachment" runat="server" Text='<%# Bind("Subject") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Notes">
                                        <ItemTemplate>
                                            <asp:Label ID="lblNotes" runat="server" Text='<%# Bind("Notes") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEdit" ToolTip="Edit" CommandName="EditMode" CommandArgument='<%# Container.DataItemIndex %>' runat="server" Width="10%"><img src="../Images/edit.png" alt="Edit"></img></asp:LinkButton>&nbsp&nbsp
                                                <asp:LinkButton ID="lnkDownload" ToolTip="Download" CommandName="Download" CommandArgument='<%# Container.DataItemIndex %>' runat="server" Width="10%"><img src="../Images/download.png" alt="Download"></img></asp:LinkButton>&nbsp&nbsp
                                                <asp:LinkButton ID="lnkDelete" ToolTip="Delete" runat="server" CommandName="DeleteMode" Width="10%" CommandArgument='<%# Container.DataItemIndex %>'
                                                    OnClientClick="return confirm('Are sure you want delete this attchment?');"><img src="../Images/delete2.png" alt="Delete" style="height:25px; width:25px;"></img></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>


                        </div>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" ValidationGroup="RouteCode" runat="server"
                Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
            <asp:Button ID="btnCancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false" runat="server"
                Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>
</asp:Content>


