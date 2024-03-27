<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="CustomerMaster.aspx.cs" Inherits="Master_CustomerMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .error {
            /*border-color: red;*/
            box-shadow: 0px 0px 0px 2px #F55575;
            /*box-shadow: 0 0 3px rgba(245,85,117,.9);*/
            /*border:2px solid red;*/
        }

            .error:focus {
                /*border-color: red;*/
                box-shadow: 0px 0px 0px 2px #F55575;
                /*box-shadow: 0 0 3px rgba(245,85,117,.9);*/
            }
    </style>
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function checkOutlet(chk) {
            if ($(chk).find('input').is(':checked')) {
                $(".Family_Tab").removeClass('active').addClass('disabledTab');
                $(".Family_Tab").hide();
            }
            else {
                $(".Family_Tab").removeClass('disabledTab');
                $(".Family_Tab").show();

            }
            $('.General_Tab').tab('show');
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

                    data.bv.disableSubmitButtons(false);

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
                    data.bv.disableSubmitButtons(false);
                });
            $('.accountForm').data('bootstrapValidator').disableSubmitButtons(false);
            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });

            $("ul.nav-tabs > li > a").on("shown.bs.tab", function (e) {
                $.cookie("CustomerMaster", $(e.target).attr("href").substr(1));
            });

            $('#tabs a[href="#' + $.cookie("CustomerMaster") + '"]').tab('show');
        }

        function SetActiveTab(index) {
            $.cookie('Customer', index);
            Relaod();
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('.accountForm').data('bootstrapValidator').isValid())
                $('.accountForm').bootstrapValidator('validate');

            IsValid = $('.accountForm').data('bootstrapValidator').isValid();


            return IsValid;
        }

        function _btnPanelCheck() {
            var IsValid = true;
            if ($('#<% = txtBranch.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtBranch.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtBranch.ClientID %>').addClass('error');
                $('#<% = txtBranch.ClientID %>').attr("PlaceHolder", "Required Field");

            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtBranch.ClientID %>').removeClass('error');
            }

            if ($('#<% = ddlCity.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlCity.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlCity.ClientID %>').addClass('error');
                $('#<% = ddlCity.ClientID %>').attr("Title", "Required Field");

            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlCity.ClientID %>').removeClass('error');
            }

            if ($('#<% = ddlState.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlState.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlState.ClientID %>').addClass('error');
                $('#<% = ddlState.ClientID %>').attr("Title", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlState.ClientID %>').removeClass('error');
            }

            if ($('#<% = ddlCountry.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlCountry.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlCountry.ClientID %>').addClass('error');
                $('#<% = ddlCountry.ClientID %>').attr("Title", "Required Field");

            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlCountry.ClientID %>').removeClass('error');
            }

            return IsValid;
        }

        function _btnPanel2Check() {
            var IsValid = true;
            if ($('#<% = txtName.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtName.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtName.ClientID %>').addClass('error');
                $('#<% = txtName.ClientID %>').attr("PlaceHolder", "Required Field");

            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtName.ClientID %>').removeClass('error');
            }

            if ($('#<% = ddlGender.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlGender.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlGender.ClientID %>').addClass('error');
                $('#<% = ddlGender.ClientID %>').attr("Title", "Required Field");

            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlGender.ClientID %>').removeClass('error');
        }

        if ($('#<% = ddlRelation.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlRelation.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlRelation.ClientID %>').addClass('error');
                $('#<% = ddlRelation.ClientID %>').attr("Title", "Required Field");
        } else {
            if (IsValid == true)
                IsValid = true;
            $('#<% = ddlRelation.ClientID %>').removeClass('error');
        }

        if ($('#<% = txtMobile.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtMobile.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtMobile.ClientID %>').addClass('error');
                $('#<% = txtMobile.ClientID %>').attr("Title", "Required Field");

        } else {
            if (IsValid == true)
                IsValid = true;
            $('#<% = txtMobile.ClientID %>').removeClass('error');
        }

        return IsValid;
    }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" style="margin-bottom: 10px" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="accountForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <center>
                                <a class="imgCustomer" href="../Images/no.jpg" id="alink" runat="server">
                                    <asp:Image ID="imgCustomer" CssClass="imgCustomer" ImageUrl="~/Images/no.jpg" runat="server" Width="100px" Height="100px" /></a>
                                <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuCustomerPhoto" ClientIDMode="AutoID" runat="server"
                                    OnUploadedComplete="afuCustomerPhoto_UploadedComplete" Style="margin-left: 29%; margin-top: 3%" CompleteBackColor="White" CssClass="imageUploaderField" />
                            </center>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustCode" runat="server" Text="Customer Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustCode" runat="server" OnTextChanged="txtCustCode_TextChanged" AutoPostBack="true" CssClass="form-control" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" Enabled="false">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustName" runat="server" Text="Customer Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustName" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-control" />
                        </div>
                    </div>
                </div>
                <ul id="tabs" class="nav nav-tabs" role="tablist">
                    <li class="active" id="_changeTab"><a href="#tabs-1" role="tab" class="General_Tab" data-toggle="tab">General</a></li>
                    <li><a href="#tabs-2" role="tab" class="Branch_Tab">Address</a></li>
                    <li class="Family_Tab"><a href="#tabs-3" role="tab" class="Family_Tab">Family Details</a></li>
                </ul>
                <div id="myTabContent" class="tab-content">
                    <div id="tabs-1" class="tab-pane active">
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBarCode" runat="server" Text="Barcode" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtBarcode" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCustGroup" runat="server" Text="Customer Group" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlGroup" runat="server" DataSourceID="edsddlGroup" DataTextField="CustGroupName" CssClass="form-control" DataValueField="CustGroupID" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                    </asp:DropDownList>
                                    <asp:EntityDataSource ID="edsddlGroup" runat="server" ConnectionString="name=DDMSEntities"
                                        DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="CGRPs">
                                    </asp:EntityDataSource>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCreditLimit" runat="server" Text="Credit Limit" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCreditLimit" runat="server" CssClass="form-control" onkeypress="return isNumberKeyForAmount(event);"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" style="display: none">
                                    <asp:Label ID="Label4" runat="server" Text="Bulk SMS" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkSMS" runat="server" CssClass="form-control" />
                                </div>
                                <div class="input-group form-group" style="display: none;">
                                    <asp:Label Text="Is Discount" runat="server" CssClass="input-group-addon" />
                                    <asp:CheckBox ID="chkIsDiscount" runat="server" Checked="true" TabIndex="3" CssClass="chkIsDiscount form-control" />
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPhone" runat="server" Text="Mobile" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPhone" runat="server" onkeypress="return isNumberKey(event);" CssClass="form-control" MaxLength="10" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblEmail" runat="server" Text="Email" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblVATNumber" runat="server" Text="VAT Number" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtVATNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" style="display: none">
                                    <asp:Label ID="lblchkEmail" runat="server" Text="Bulk Email" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkEMail" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                            <div class="col-lg-4">

                                <div class="input-group form-group">
                                    <asp:Label ID="lblWebSite" runat="server" Text="WebSite" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtWebSite" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblFax" runat="server" Text="Fax" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtFax" runat="server" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblGSTIN" runat="server" Text="GSTIN Number" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtGSTIN" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" style="display: none">
                                    <asp:Label ID="lblAllowPush" runat="server" Text="Allow Notification" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkAllowNotify" runat="server" CssClass="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12 _textArea">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="lbl_desc input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-2" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll; direction: rtl">
                                <asp:GridView ID="gvBranch" runat="server" AutoGenerateColumns="False" CssClass="table" HeaderStyle-CssClass="table-header-gradient" Style="direction: ltr" EmptyDataText="No Address Found." OnRowCommand="gvBranch_RowCommand">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Address Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblGVBranch" runat="server" Text='<%#Eval("Branch" ) %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Location">
                                            <ItemTemplate>
                                                <asp:Label ID="lblGVLocation" runat="server" Text='<%#Eval("Location" ) %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Edit">
                                            <ItemTemplate>
                                                <asp:Button ID="btnDetails" runat="server" Text=">>" CssClass="btn btn-default" CommandName="EditBranch" CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Delete">
                                            <ItemTemplate>
                                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-default" CommandName="DeleteBranch" CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBranchType" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlBranchType" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Bill To" Value="B"></asp:ListItem>
                                        <asp:ListItem Text="Ship To" Value="S"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBranch" runat="server" Text="Address Title" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtBranch" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAddress1" runat="server" Text="Address1" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAddress1" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAddress2" runat="server" Text="Address2" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtAddress2" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblLocation" runat="server" Text="Location (Area)" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPhoneNo" runat="server" Text="Mobile" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPhoneNo" runat="server" data-bv-stringlength="false" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlCity" runat="server" OnSelectedIndexChanged="ddlCity_SelectedIndexChanged" AppendDataBoundItems="True" CssClass="form-control"
                                        DataSourceID="edsCity" DataTextField="CityName" DataValueField="CityID" AutoPostBack="True">
                                        <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                    <asp:EntityDataSource ID="edsCity" runat="server" ConnectionString="name=DDMSEntities"
                                        DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCTies">
                                    </asp:EntityDataSource>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblZipCode" runat="server" Text="Pin Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtZipCode" runat="server" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlState" runat="server" DataSourceID="edsddlState" DataTextField="StateName" CssClass="form-control"
                                        DataValueField="StateID" AppendDataBoundItems="True">
                                        <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                    <asp:EntityDataSource ID="edsddlState" runat="server" ConnectionString="name=DDMSEntities"
                                        DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCSTs">
                                    </asp:EntityDataSource>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCountry" runat="server" Text="Country" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlCountry" runat="server" DataSourceID="edsddlCountry" DataTextField="CountryName" CssClass="form-control"
                                        DataValueField="CountryID" AppendDataBoundItems="True">
                                        <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                    <asp:EntityDataSource ID="edsddlCountry" runat="server" ConnectionString="name=DDMSEntities"
                                        DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCRies">
                                    </asp:EntityDataSource>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBNotes" runat="server" Text="Notes" CssClass="textarea_label_in_one_side input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtBNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Button ID="btnAddBranch" runat="server" Text="Add Address" OnClick="btnAddBranch_Click"
                                        CssClass="btn btn-default" OnClientClick="return _btnPanelCheck();" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-3" class="tab-pane">
                        <div class="row _panel2Form">
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll; direction: rtl">
                                <asp:GridView ID="gvContactPerson" runat="server" HeaderStyle-CssClass="table-header-gradient" AutoGenerateColumns="False" CssClass="table" Style="direction: ltr" EmptyDataText="No Family Detail Found." OnRowCommand="gvContactPerson_RowCommand">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblGVName" runat="server" Text='<%#Eval("Name" ) %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Mobile">
                                            <ItemTemplate>
                                                <asp:Label ID="lblGVMobile" runat="server" Text='<%#Eval("Mobile" ) %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Edit">
                                            <ItemTemplate>
                                                <asp:Button ID="btnDetails" runat="server" Text=">>" CssClass="btn btn-default" CommandName="EditContactPerson"
                                                    CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Delete">
                                            <ItemTemplate>
                                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-default" CommandName="DeleteContactPerson" CommandArgument='<%# Container.DataItemIndex  %>'></asp:Button>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblGender" runat="server" Text="Gender" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="---Select---" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="Male" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="Female" Value="2"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblRelation" runat="server" Text="Relation" CssClass="input-group-addon"></asp:Label>
                                    <asp:DropDownList ID="ddlRelation" runat="server" DataTextField="RelationName" DataValueField="RelationID" DataSourceID="edsRelation" CssClass="form-control" AppendDataBoundItems="true">
                                        <asp:ListItem Text="---Select---" Value="0" />
                                    </asp:DropDownList>
                                    <asp:EntityDataSource ID="edsRelation" runat="server" ConnectionString="name=DDMSEntities"
                                        Where="it.Active = true" DefaultContainerName="DDMSEntities"
                                        EnableFlattening="False" EntitySetName="ORLNs">
                                    </asp:EntityDataSource>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblBirthDay" runat="server" Text="BirthDay" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtBirthDay" onfocus="this.blur();" CssClass="datepick form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblAnniversary" runat="server" Text="Anniversary" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtAnniversary" onfocus="this.blur();" CssClass="datepick form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSpecialDay" runat="server" Text="Special Day" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox runat="server" ID="txtSpecialDay" onfocus="this.blur();" CssClass="datepick form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblMobile" runat="server" Text="Mobile" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCEmail" runat="server" Text="EMail" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCEmail" runat="server" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Button ID="btnAddCP" runat="server" Text="Add Family Details" OnClick="btnAddCP_Click"
                                        CssClass="btn btn-default" OnClientClick="return _btnPanel2Check();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" CssClass="btn btn-default" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
        </div>
    </div>
</asp:Content>

