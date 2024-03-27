<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AssetRegister.aspx.cs" Inherits="Asset_AssetRegister" %>

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
                $.cookie("AssetRegister", $(e.target).attr("href").substr(1));
            });
            $('#tabs a[href="#' + $.cookie("AssetRegister") + '"]').tab('show');
        }

        function SetActiveTab(index) {
            $.cookie('AssetRegister', index);
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
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>

    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Asset Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAssetCode" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:TextBox ID="txtCode" runat="server" OnTextChanged="txtCode_TextChanged" CssClass="form-control" AutoPostBack="true" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtAssetCode" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetAssetsCode" MinimumPrefixLength="1" CompletionInterval="10"
                            Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Asset Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAssetName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" TabIndex="0"></asp:TextBox>
                    </div>

                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-control"></asp:CheckBox>
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
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblAssignTo" runat="server" Text="Assign To" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssignTo" runat="server" DataSourceID="edsddlAssignTo" DataTextField="CustomerName"
                                    DataValueField="CustomerID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Customer" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssignTo" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="(it.CustomerID = @OutletPID OR it.ParentID = @ParentID) AND (it.Active = TRUE)"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCRDs">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                        <asp:SessionParameter Name="OutletPID" SessionField="OutletPID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblAssetType" runat="server" Text="Asset Type" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetType" runat="server" DataSourceID="edsddlAssetType" DataTextField="AssetTypeName"
                                    DataValueField="AssetTypeID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Type" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetType" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTies">
                                </asp:EntityDataSource>
                            </div>

                            <div class="input-group form-group">
                                <asp:Label ID="lblGroup" runat="server" Text="Asset Group" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetGroup" runat="server" DataSourceID="edsddlAssetGroup" DataTextField="AssetGroupName"
                                    DataValueField="AssetGroupID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Group" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetGroup" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTGs">
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
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblModelNo" runat="server" Text="Model Number" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtModelNo" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSerialNo" runat="server" Text="Serial Number" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtSerialNo" CssClass="form-control" />
                            </div>
                           <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Asset Brand" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetBrand" runat="server" DataSourceID="edsddlAssetBrand" DataTextField="AssetBrandName"
                                    DataValueField="AssetBrandID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Brand" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetBrand" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTBs">
                                </asp:EntityDataSource>
                            </div>
                             <div class="input-group form-group">
                                <asp:Label ID="Label2" runat="server" Text="Asset Size" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList ID="ddlAssetSize" runat="server" DataSourceID="edsddlAssetSize" DataTextField="AssetSizeName"
                                    DataValueField="AssetSizeID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Asset Size" data-bv-callback-callback="_ddvalCheck">
                                    <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsddlAssetSize" runat="server" ConnectionString="name=DDMSEntities"
                                    Where="it.Active = TRUE"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OASTZs">
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblAddtional" runat="server" Text="Additional Identifier" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtAdditional" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblVendor" runat="server" Text="Vendor Details" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtVendor" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblInvoiceNo" runat="server" Text="Invoice Number" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtInvoiceNo" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblInvoiceDate" runat="server" Text="Invoice Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtInvoiceDate" CssClass="datepick form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblWarrantyDate" runat="server" Text="Warranty Expire" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtWarrantyDate" CssClass="datepick form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblLeadTime" runat="server" Text="Lead Time" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox runat="server" ID="txtLeadTime" CssClass="form-control" />
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
                                    <asp:Label ID="lblAttachment" runat="server" Text="Subject" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtAttachment" CssClass="form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAtchReminderDate" runat="server" Text="Reminder Date" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtAtchReminderDate" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
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
                                    <asp:TemplateField HeaderText="Reminder Date">
                                        <ItemTemplate>
                                            <asp:Label ID="lblReminderDate" runat="server" Text='<%# Bind("ReminderDate","{0:dd/MM/yyyy}") %>'></asp:Label>
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

